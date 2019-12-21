function f = GetKFermiFunc(name)
% Return the function which calculates kf given 
% kz, psi, c, *kmodes
%
% Raises when it is not implemented.
% Will try to call the function with a bunch of Inf as args.
% The function does NOT have to calculate a
%

try
    f = str2func(name);
    nargin(f);
catch exc
    error('Cannot make handle to non-existent symmetry %s. %s', ...
          name, exc.message);
end
end %SelectKFermiFunc
