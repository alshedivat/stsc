function [Coef,FeaturesOut] = PCA( FeaturesIn, variance )
% PCA Performs PCA on the provided dataset and keeps only the principal
%     components that hold the provided variance percentage of the data.
% =========================================================================

%FeaturesIn = full(FeaturesIn);
[Coef,FeaturesOut,eigvals] = princomp(FeaturesIn');

% Find the right number of principal components
if variance < 100
    eigval_sum = sum(eigvals) / 100;
    pca_var = 0; k = 0;
    while (pca_var < variance)
        k = k + 1;
        pca_var = pca_var + (eigvals(k) ./ eigval_sum) ;
    end
else
    k = size(FeaturesOut,2);
end

%FeaturesOut = sparse(FeaturesOut(:,1:k)');
FeaturesOut = FeaturesOut(:,1:k)';
Coef = Coef(:,1:k)';

end

