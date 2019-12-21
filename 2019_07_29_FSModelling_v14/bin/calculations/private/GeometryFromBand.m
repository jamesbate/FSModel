function [cg, vf] = GeometryFromBand(band)
% Extract all parameters and create a ComputationalGeometry (initialized).
% Outsources also QueryKfVf.


precision = band('precision');
[kf, vf] = QueryKfVf(band('symmetry'), ...
                     band('a'), band('b'), band('c'), ...
                     band('kcoeff'), band('effmass'), -1);
B = band('B');
a = band('a');
b = band('b');
c = band('c');
id = band('id');
geo = Geometry(kf, precision);
geo.SetDirection(band('BPolar'), band('BAzumithal'));
cg = ComputationalGeometry(geo);

end
