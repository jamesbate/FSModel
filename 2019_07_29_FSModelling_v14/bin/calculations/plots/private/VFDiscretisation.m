function [x, y, z, v] = VFDiscretisation(symm, a, b, c, m, kpara, amount, mode)
% Get a partitioning of the Fermi surface with absolute velocities

A = linspace(0, 2 * pi, amount);
B = linspace(0, 2 * pi, amount);
[AA, BB] = meshgrid(A, B);

[kf, vf] = QueryKfVf(symm, a, b, c, kpara, m, mode-1);
[x, y, z] = kf(AA, BB);
v = vf(AA, BB);
end %VFDiscretisation
 