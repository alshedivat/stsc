function f = fobj_TSC(X, D, V, M, e)
% FOBJ_TSC Computes the objective function for TSC.
%          Returns the value of the function of given parameters.
% =========================================================================

f = norm(X-D*V, 'fro')^2;     % Coding error
f = f + e*sum(sum(abs(V)));   % Sparsity penalty
f = f + trace(V*M*V');        % Transfer + geometry penalty

end

