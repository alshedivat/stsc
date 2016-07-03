function f = fobj_STSC(X, D, V, M, e, FeatureNum, LabelNum, LabeledIdx)
% FOBJ_STSC Computes the objective function for STSC.
%           Returns the value of the function of given parameters.
% =========================================================================

LM = X(FeatureNum+1:FeatureNum+LabelNum,LabeledIdx);
X = X(1:FeatureNum,:);
Q = D(FeatureNum+1:FeatureNum+LabelNum,:);
D = D(1:FeatureNum,:);

f = norm(X-D*V,'fro')^2;                     % Coding error
f = f + norm(LM-Q*V(:,LabeledIdx),'fro')^2;  % Label-based error
f = f + e*sum(sum(abs(V)));                  % Sparsity penalty
f = f + trace(V*M*V');                       % Transfer + geometry penalty

end

