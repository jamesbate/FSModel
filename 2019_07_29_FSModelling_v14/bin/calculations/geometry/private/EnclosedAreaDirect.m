function area = EnclosedAreaDirect(func, number)
% Distribute number points between 0 and 2 pi and return the area enclosed
% by the function over this interval. Assumes periodicity.
%
% Responsibility: Adapter for AreaEnclosedOrbit for function input.

discrete = (0:2*pi/(number-1):2*pi);
[X, Y, Z] = func(discrete);
area = AreaEnclosedOrbit(X, Y, Z);
end %AreaEnclosedDirect
