function [kffunc, vffunc] = QueryKfVf(symmetry, a, b, c, kpara, mass, mode)
% Get the kf and vf functions and specify them down to the 2
% parametrization variables. You may provde 2 arguments in which 
% case the signature is QueryKfVf(band, mode) and parameters are extracted.
%
% Evaluates these functions once in (0,0) to make sure that they work with
% these parameters.
%
% If you take 1 output parameter, you do not need to give mass or mode.
% mode: int
%   -1 => vector
%   0 => absolute
%   1 => 1st component
%   2 => 2nd component
%   3 => 3rd component
%
% This is the way these functions are queried for most of the time.
% Mode: See GetVFermiFunc
%
% Responsibility: Partially specify kf and vf, call them once.

% If 2 input arguments the first is band, the second is mode.
if nargin == 2
    mode = a;
    a = symmetry('a');
    b = symmetry('b');
    c = symmetry('c');
    kpara = symmetry('kcoeff');
    mass = symmetry('effmass');
    symmetry = symmetry('symmetry');
end
    

% Fermi function
kffull = GetKFermiFunc(symmetry);
if nargin(kffull) - 5 ~= length(kpara)
    error('%d k parameters instead of %d (symmetry %s)', ...
          length(kpara), nargin(kffull) - 5, symmetry);
end
if ~iscell(kpara)
    kpara = num2cell(kpara);
end
arguments = {a, b, c, kpara{:}};
kffull(0, 0, arguments{:});
kffunc = @(X, Y) kffull(X, Y, arguments{:}); 

if nargout == 1
    return;
end

% Velocity function
if mass == 0
    error('Effective mass cannot be 0 for velocity calculations.');
end
hm = hbar / mass;
vffull = GetVFermiFunc(symmetry, mode);

% Cannot ask nargin here because these are generally using variable 
% arguments themselves. nargin(function(varargin)) => -1.
vffull(0, 0, hm, a, b, c, kpara{:});


vffunc = @(X, Y) vffull(X, Y, hm, a, b, c, kpara{:});

end %SelectKFermiWithCheck
