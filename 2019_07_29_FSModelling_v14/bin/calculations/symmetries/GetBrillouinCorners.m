function points = GetBrillouinCorners(symmetry, a, b, c)
% Return the points spanning the Brillouin zone.

name = sprintf('%sCorners', symmetry);
try
    f = str2func(name);
    nargin(f);
catch 
    error('Cannot make handle to non-existent %s', name);
end

points = f(a, b, c);
end %GetBrillouinCorners
