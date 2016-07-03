function VisRunOutput(RunOutput, black_bg, save_path)
% VISRUNOUTPUT Visualizes the output of a single run of an algorithm.
% =========================================================================

if ~exist('black_bg','var'); black_bg = false; end

% Visualize the codebook
ncols = 10;
nrows = floor(size(RunOutput.Train.Dict,2) / ncols);
if exist('save_path','var')
    VisualizeCodewords(RunOutput.Train.Dict,nrows,ncols,16,black_bg,true,...
                       sprintf('%s_codebook.png',save_path));
else
    VisualizeCodewords(RunOutput.Train.Dict,nrows,ncols,16,black_bg,true);
end

% Visualize the train and test codes
tcf = figure('name','Train codes');
set(gcf,'Position',[300 300 800 600]);
color = 'black';
if black_bg
    set(gcf,'color','black');
    set(gcf,'InvertHardCopy','off');
    color = 'white';
end
subplot(2,1,1);
imagesc(RunOutput.Train.SC); colorbar;
title('Train sparse codes','FontSize',16,'Color',color);
if black_bg; set(gca,'XColor','white'); set(gca,'YColor','white'); end
subplot(2,1,2);
imagesc(RunOutput.Test.Logit.SC); colorbar;
title('Test sparse codes','FontSize',16,'Color',color);
if black_bg; set(gca,'XColor','white'); set(gca,'YColor','white'); end

if exist('save_path','var')
    saveas(tcf,sprintf('%s_sparsecodes',save_path),'png');
end

% Build ROC curves
classifiers = fieldnames(RunOutput.Test);
for cl=classifiers
    if exist('save_path','var')
        buildROC(RunOutput.Test.(cl{1}).Labels,RunOutput.Test.Scores,...
                 black_bg,sprintf('%s_rocs',save_path));
    else
        buildROC(RunOutput.Test.(cl{1}).Labels,RunOutput.Test.Scores,...
                 black_bg);
    end
end

end

