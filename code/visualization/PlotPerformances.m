function PlotPerformances(path, filenames, cl_names, extra_title, save_path)
% PLOTPERFORMANCES Plots performances for the provided names of
%                  measurements. The filenames argument should be a list of
%                  strings.
% =========================================================================

if ~exist('path','var'); path = './'; end
%if ~exist('black_bg','var'); black_bg = false; end
if ~exist('extra_title','var'); extra_title = ''; end

% Read the data and build up matrices of measures and their errors
graphs_num = 0;
Legends = {};
Measurments = [];
Errors      = [];
for k=1:numel(filenames)
    name = filenames{k};
    if iscell(name)
        cl_names = name{2};
        name = name{1};
    end
    load(sprintf('%s/%s.mat',path,name));
    if ~exist('cl_names','var') || isempty(cl_names)
        cl_names = fieldnames(Performances);
    end
    for i=1:numel(cl_names)
        graphs_num = graphs_num + 1;
        Legends{graphs_num} = sprintf('%s : %s',name,cl_names{i});
        perf_means = mean(Performances.(cl_names{i}),1);
        perf_stds  = std(Performances.(cl_names{i}));
        Measurments = [Measurments perf_means'];
        Errors      = [Errors perf_stds'];
    end
end
param_vals = repmat(param_vals',[1 graphs_num]);

% Plot
fig = figure('name','Performance measurments');
set(fig,'Position',[300 300 1200 600]);
col = rand(graphs_num,3); hold on;
for i=1:graphs_num
    errorbar(param_vals(:,i),Measurments(:,i),Errors(:,i),...
             'Color', col(i,:),...
             'LineWidth',2,...
             'MarkerEdgeColor','k',...
             'MarkerSize',8);
end
%plot(param_vals,Measurments,'-',...
%    'LineWidth',2,...
%    'MarkerEdgeColor','k',...
%    'MarkerSize',8);
%if black_bg
%    set(gcf,'color','black');
%    set(gcf,'InvertHardCopy','off');
%    set(gca,'XColor','white');
%    set(gca,'YColor','white');
%    color = 'white';
%end
ylim([0.0 0.9]);
title(sprintf('Performances vs. Dictionary size %s',extra_title),...
      'FontSize',16)
xlabel('Codebook size','FontSize',16);
ylabel('CV@5 Accuracy','FontSize',16);
legend(Legends{:},'Location','NorthEastOutside');
hold off;

if exist('save_path','var')
    set(fig, 'PaperPosition', [0 0 10 5]);
    saveas(fig,save_path,'png');
end

end

