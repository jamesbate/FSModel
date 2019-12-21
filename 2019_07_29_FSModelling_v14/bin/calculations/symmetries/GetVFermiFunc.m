function f = GetVFermiFunc(name, component)
% Get a function of 2 arguments to Fermi velocity.
% kffunc and dkffunc are full, as returned by their factories!
%
% Component: int
%   -1 => vector
%   0 => absolute
%   1 => 1st component
%   2 => 2nd component
%   3 => 3rd component
%

name = strcat(name, 'Deriv');

try
    func = str2func(name);
    nargin(func);
catch exc
    error('Cannot make handle to non-existent symmetry %s. %s', ...
          name, exc.message);
end %try

function vabs = absderiv(varargin)
    [vx, vy, vz] = func(varargin{:});
    vabs = sqrt(vx.^2 + vy.^2 + vz.^2);
end

function vx = xderiv(varargin)
    [vx, ~, ~] = func(varargin{:});
end

function vy = yderiv(varargin)
    [~, vy, ~] = func(varargin{:});
end

function vz = zderiv(varargin)
    [~, ~, vz] = func(varargin{:});
end


if component == -1
    f = func;
elseif component == 0
    f = @absderiv;
elseif component == 1
    f = @xderiv;
elseif component == 2
    f = @yderiv;
elseif component == 3
    f = @zderiv;
else
    error('unknown component identifier %d', component);
end

end %MakeVelocityFunc



