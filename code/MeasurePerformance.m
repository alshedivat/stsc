function Performances = MeasurePerformance(config, param_names, param_vals, cv, seed, verbose)
% MEASUREPERFORMANCE Measures performance of the given method using cross-
%                    validation and sweeping given parameter.
% =========================================================================
if ~exist('cv','var'); cv = 10; end
if ~exist('seed','var'); seed = 42; end
if ~exist('save_fl','var'); save_fl = true; end
if ~exist('verbose','var'); verbose = true; end

if verbose; fprintf('Performing parametric sweep...\n'); end
tic

%cl_meth = config.ClassificationMethods;
%Performances = cell2struct(cell(1,length(cl_meth)),cl_meth,2);
Measures = cell(1,size(param_vals,1));

parfor i=1:size(param_vals,1)
    LocalConfig = config;
    if verbose; fprintf('Parameters:'); end
    for j=1:length(param_names)
        if verbose; fprintf(' %s: %.2f', param_names{j}, param_vals(i,j)); end
        LocalConfig.(param_names{j}) = param_vals(i,j);
    end
    if verbose; fprintf('\n'); end

    [best_param, best_acc] = CrossValidation(LocalConfig, cv, seed, false);
    Measures{i} = {best_acc, best_param};
%    for j=1:numel(cl_meth)
%        Performances.(cl_meth{j}) =...
%            [Performances.(cl_meth{j})...
%             [best_acc.(cl_meth{j}); best_cl_param.(cl_meth{j})]];
%    end
end

cl_meth = config.ClassificationMethods;
Performances = cell2struct(cell(1,length(cl_meth)),cl_meth,2);
for i=1:size(param_vals,1)
    for j=1:numel(cl_meth)
        Performances.(cl_meth{j}) =...
            [Performances.(cl_meth{j});...
             [Measures{i}{1}.(cl_meth{j}); Measures{i}{2}.(cl_meth{j})]];
    end
end

Performances.elapsed_time = toc / 3600;

end
