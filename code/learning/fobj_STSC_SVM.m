function f = fobj_STSC_SVM( X, D, V, M, e, a, Alpha_Y)
% FOBJ_STSC_SVM Computes the objective function for STSC-SVM.
%               Returns the value of the function of given parameters.
% =========================================================================

f = fobj_TSC( X, D, V, M, e);
f = f + 0.5*a*sum(sum((Alpha_Y*V').^2));

end

