function VisualizeCodewords(Codebook, n_rows, n_cols, img_sz, black_bg, verbose, filename)
% VISUALIZECODEWORDS Builds a figure of visualized codewords.
% =========================================================================

% Default arguments
if ~exist('img_sz',  'var'); img_sz = 16;      end
if ~exist('n_rows',  'var'); n_rows = 2;       end
if ~exist('n_cols',  'var'); n_cols = 10;      end
if ~exist('verbose', 'var'); verbose = true;   end
if ~exist('black_bg','var'); black_bg = false; end

faceW = img_sz + 1;
faceH = img_sz + 1;

Y = zeros(faceH*n_rows+1,faceW*n_cols+1);
Y(1,:) = 1; Y(:,1) = 1;
for i=0:n_rows-1
    for j=0:n_cols-1
        Y(i*faceH+2:(i+1)*faceH,j*faceW+2:(j+1)*faceW) = ...
            mat2gray(reshape(Codebook(:,i*n_cols+j+1),[faceH-1,faceW-1])');
        Y(:,(j+1)*faceW+1) = 1;
    end
    Y((i+1)*faceH+1,:) = 1;
end

if verbose
    figure('name', 'Codebook');
    set(gcf,'Position',[500 500 n_cols*50 n_rows*50]);
    imagesc(Y); colormap(gray);
    color = 'black';
    if black_bg
        set(gcf,'color','black');
        set(gcf,'InvertHardCopy','off');
        color = 'white';
    end

    title('Learned Dictionary','FontSize',16,'Color',color);
    if black_bg; set(gca,'XColor','white'); set(gca,'YColor','white'); end
end

if exist('filename', 'var')
    imwrite(Y, filename, 'png');
end

end
