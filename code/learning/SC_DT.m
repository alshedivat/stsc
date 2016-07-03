function TrainOut = SC_DT(TrainIn, Options, verbose)
% DT_SC Performs SC and DT alltogether in an unsupervised fashion.
%       Returns the sparse codes and the codebook in the Output structure.
%
% Reference: Long, Mingsheng, et al. "Transfer Sparse Coding for Robust
%            Image Representation.", IEEE CVPR, 2013.
% =========================================================================

if verbose; fprintf('Performing SC+DT training...\n'); end;

%SampleNum    = size(TrainIn.Features,2);
SampleMatrix = TrainIn.Features;

% Normalize features
SampleMatrix = SampleMatrix*diag(sparse(1./sqrt(sum(SampleMatrix.^2,1))));

LabelIdx = unique(TrainIn.Labels(TrainIn.Labeled == 1));
%LabeledIdx = find(TrainIn.Labeled == 1);
%LabelIdx = unique(TrainIn.Labels(LabeledIdx));
%LabelNum = length(LabelIdx);

if verbose; fprintf('  Building matrices...\n'); end;

% Build label-sample matrix (one-hot encoding for all the labels)
%LabelMatrix = zeros(LabelNum,SampleNum);
%for i=LabeledIdx
%    LabelMatrix(TrainIn.Labels(i) == LabelIdx,i) = 1;
%end

%if verbose
%    figure('name','Label-Sample Matrix'); imagesc(LabelMatrix); colorbar;
%end

% Build L-matrix composed of Graph matrix and MMD matrix
[L,~,GL] = BuildMatrices(TrainIn, Options, verbose);

% Learn the sparse codes and the codebook iteratively
if verbose; fprintf('  Performing iterative learning...\n'); end;

% Init dictionary
%Dict = SampleMatrix(:,randi(size(TrainIn.Features,2),...
%                                1,Options.CodebookSize));
Dict = rand(size(TrainIn.Features,1),Options.CodebookSize) - 0.5;
Dict = Dict - repmat(mean(Dict,1), size(Dict,1),1);
Dict = Dict*diag(1./sqrt(sum(Dict.*Dict)));

fobj_vals = [];
if verbose; figure('name','SC+DT objective function'); end

for t = 1:Options.MaxIter
    if verbose; fprintf('    Iteration %d/%d: ',t,Options.MaxIter); end;

    % Learn the sparse codes
    if t == 1
        SC = learn_coefficients(Dict,SampleMatrix,Options.e,L);
    else
        SC = learn_coefficients(Dict,SampleMatrix,Options.e,L,SC);
    end
    SC(isnan(SC))=0;

    % Learn the codebook
    Dict = learn_basis(SampleMatrix,SC,Options.g);

    % Compute the objective function
    fobj = fobj_TSC(SampleMatrix,Dict,SC,L,Options.e);
    fobj_vals = [fobj_vals fobj];
    if verbose; fprintf('%f\n',fobj); end;

    if verbose
        clf;
        title('SC+DT objective function');
        xlabel('Iteration');
        ylabel('Sparse Code weight');
        plot(fobj_vals); hold on;
        drawnow;
    end
end
if verbose; disp('  Done.'); end;

% Write out the output
TrainOut = TrainIn;

%TrainOut.LabelMatrix = LabelMatrix;
TrainOut.LabelIdx    = LabelIdx;

% Finally, learn the pure sparse codes according to the learned dictionary
%L = zeros(size(SampleMatrix,2),size(SampleMatrix,2));
L = Options.h*GL;
SC = learn_coefficients(Dict,SampleMatrix,Options.e,L); SC(isnan(SC))=0;

TrainOut.Features = SC;
TrainOut.Fobj = fobj_vals;
TrainOut.Dict = Dict;

end
