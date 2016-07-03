function TrainOut = SC_DT_SVM(TrainIn, Options, verbose)
% SC_DT_SVM Performs SC and DT simultaneosly with SVM.
%           Returns all the parameters in the Output structure.
% =========================================================================

if verbose; disp('Performing SC+DT+SVM training...'); end

SampleNum    = size(TrainIn.Features,2);
SampleMatrix = TrainIn.Features;

% Normalize features
SampleMatrix = SampleMatrix*diag(1./sqrt(sum(SampleMatrix.^2,1)));

LabeledIdx = find(TrainIn.Labeled == 1);
LabelIdx = unique(TrainIn.Labels(LabeledIdx));
LabelNum = length(LabelIdx);

if verbose; disp('  Building matrices...'); end

% Build label-sample matrix (one-hot encoding for all the labels)
LabelMatrix = -ones(LabelNum, SampleNum);
for i=LabeledIdx
    LabelMatrix(TrainIn.Labels(i) == LabelIdx,i) = 1;
end

if verbose
    figure('name','Label-Sample Matrix'); imagesc(LabelMatrix); colorbar;
end

% Build L-matrix composed of Graph matrix and MMD matrix
[L1,~,GL] = BuildMatrices(TrainIn, Options, verbose);

% Init codebook with random samples (how about completely random init?)
%Dict = SampleMatrix(:,randi(size(TrainIn.Features,2),...
%                                1,Options.CodebookSize));
%Dict = rand(size(TrainIn.Features,1),Options.CodebookSize);
Dict = rand(size(TrainIn.Features,1),Options.CodebookSize) - 0.5;
Dict = Dict - repmat(mean(Dict,1), size(Dict,1),1);
Dict = Dict*diag(1./sqrt(sum(Dict.*Dict)));
%SC = learn_coefficients(Dict,SampleMatrix,Options.e,L1);

% Unsupervised pretraining
if any(strcmp('PreIter',fieldnames(Options)))
    if verbose; fprintf('  Pre-training...'); end;
    for t = 1:Options.PreIter
        if verbose; fprintf('%d...',t); end;

        % Learn the sparse codes
        if t == 1
            SC = learn_coefficients(Dict, SampleMatrix, Options.e, L1);
        else
            SC = learn_coefficients(Dict, SampleMatrix, Options.e, L1, SC);
        end
        SC(isnan(SC)) = 0;

        % Learn the codebook
        Dict = learn_basis(SampleMatrix, SC, Options.g);
    end
    if verbose; fprintf('Done.\n'); end;
end

% Initialize KappaMatrix before starting training iterations
Alpha_Y = zeros(1, size(L1,1));
KappaMatrix = zeros(size(L1));
%LabeledTargetIdx = find((TrainIn.Labeled == 1) & (TrainIn.DomainIdx == -1));

% Learn the sparse codes and the codebook iteratively
if verbose; disp('  Performing iterative learning...'); end

fobj_vals = [];
if verbose; figure('name','SC+DT+SVM objective function'); end
for t = 1:Options.MaxIter
    if verbose; fprintf('    Iteration %d/%d: ', t, Options.MaxIter); end

    % Learn the sparse codes
    L = L1 - 0.5*KappaMatrix;
    SC = learn_coefficients(Dict, SampleMatrix, Options.e, L, SC);
    SC(isnan(SC))=0;

    % Learn the classifier parameters
    Alpha_Y = learn_SVM_step(SC, LabelMatrix, Options.a, LabeledIdx);
    KappaMatrix = Alpha_Y'*Alpha_Y;

    % Learn the codebook
    Dict = learn_basis(SampleMatrix, SC, Options.g);

    % Compute the objective function
    fobj = fobj_STSC_SVM(SampleMatrix,Dict,SC,L,Options.e,Options.a,Alpha_Y);
    fobj_vals = [fobj_vals fobj];
    if verbose; fprintf('%f\n', fobj); end;

    if verbose
        clf;
        title('SC+DT+SVM objective function');
        xlabel('Iteration');
        ylabel('Sparse Code weight');
        plot(fobj_vals); hold on;
        drawnow;
    end
end

if verbose
    figure('name','L-matrix'); imagesc(L); colorbar;
end

% Write out the output
TrainOut = TrainIn;

TrainOut.LabelMatrix = LabelMatrix;
TrainOut.LabelIdx    = LabelIdx;

% Finally, learn the pure sparse codes and the SVM model
%L = zeros(size(SampleMatrix,2),size(SampleMatrix,2));
L = Options.h*GL;
SC = learn_coefficients(Dict,SampleMatrix,Options.e,L); SC(isnan(SC))=0;
Alpha_Y = learn_SVM_step(SC,LabelMatrix,Options.C,LabeledIdx);

TrainOut.Features = SC;
TrainOut.Fobj = fobj_vals;
TrainOut.Dict = Dict;

TrainOut.weight = Alpha_Y;
TrainOut.W      = Alpha_Y*SC';

% Compute the free terms of all the SVMs
WX = Alpha_Y*(SC'*SC);  % W * X
for c=1:LabelNum
    TrainOut.b(c) = -(max(WX(c,LabelMatrix(c,:)==-1)) +...
                      min(WX(c,LabelMatrix(c,:)== 1))) / 2;
end
TrainOut.b = TrainOut.b';

end

function Alpha_Y = learn_SVM_step(V, Y, c, SelectedIdx)
% LEARN_SVM_STEP Performs generalized SVM parameters learning:
%                learns a matrix A parameters which are used further to
%                construct W matrix of SVM weights.
% =========================================================================
quadprogOptions = struct('Display', 'off', ...
                         'Algorithm', 'interior-point-convex', ...
                         'MaxIter', 100);
SelectedNum = length(SelectedIdx);
ClassNum   = size(Y,1);

% Build Hessian matrix
H = [];
for cl=1:ClassNum
    H1 = V(:, SelectedIdx) * diag(Y(cl, SelectedIdx));
    H1 = 0.5*(H1' * H1);
    H = blkdiag(H, H1);
end

% This is s.t.: sum_i(alpha_i * y_i) = 0
Aeq = reshape(Y(:, SelectedIdx)', 1, []);
beq = 0;

% Bounds for alpha are n-qubic
LB = zeros(SelectedNum*ClassNum,1);
UB = c*ones(SelectedNum*ClassNum,1);

Alpha = quadprog(H, -ones(SelectedNum * ClassNum, 1), [], [], ...
                 Aeq, beq, LB, UB, [], quadprogOptions);
Alpha = reshape(Alpha, SelectedNum, ClassNum)';

Alpha_all = zeros(size(Y));
Alpha_all(:,SelectedIdx) = Alpha;

Alpha_Y = Alpha_all.*Y;

end

% The previous version of the SVM learning step
function Alpha_Y = learn_SVM_step_(V, Y, c, SelectedIdx)
% LEARN_SVM_STEP Performs generalized SVM parameters learning:
%                learns a matrix A parameters which are used further to
%                construct W matrix of SVM weights.
% =========================================================================
quadprogOptions = struct('Display', 'off', ...
                         'Algorithm', 'interior-point-convex', ...
                         'MaxIter', 100);
SelectedNum = length(SelectedIdx);

for cl=1:size(Y,1)
    H = V(:,SelectedIdx)*diag(Y(cl,SelectedIdx));
    H = 0.5*(H'*H);

    % This is s.t.: sum_i(alpha_i * y_i) = 0
    Aeq = Y(cl,SelectedIdx);
    beq = 0;

    % Bounds for alpha are n-qubic
    LB = zeros(SelectedNum,1);
    UB = c*ones(SelectedNum,1);

    Alpha(cl,:) = quadprog(H, -ones(SelectedNum, 1), [], [], ...
                           Aeq, beq, LB, UB, [], quadprogOptions);
end

Alpha_all = zeros(size(Y));
Alpha_all(:,SelectedIdx) = Alpha;

Alpha_Y = Alpha_all.*Y;

end
