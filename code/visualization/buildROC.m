function buildROC( labels, scores, black_bg, save_path )
%BUILDROC Plots ROC curves for all the classes in one vs. all fashion.
% =========================================================================

classes = unique(labels);
one_vs_all_labels = [];

for i=classes
    one_vs_all_labels = [one_vs_all_labels; labels == i];
end

rcf = figure('name','ROC-curves');
set(gcf,'Position',[300 300 600 400]);
plotroc(one_vs_all_labels, scores);
th = title('ROC-curves','FontSize',16);
set(get(gca,'xlabel'),'FontSize',16);
set(get(gca,'ylabel'),'FontSize',16);

if black_bg
    set(gcf,'color','black');
    set(gcf,'InvertHardCopy','off');
    set(gca,'XColor','white');
    set(gca,'YColor','white');
    set(th,'Color','white');
end

if exist('save_path','var')
    saveas(rcf,save_path,'png');
end

end

