function volume = ConvexVolumeDirect(func, nrA, nrB)
% Take a function of 2 arguments.
% Each argument varies [0, 2pi]
% Using nrA/nrB points to form a grid, calculate the enclosed area
% using triangulation

aa = (0:2*pi/nrA:2*pi);
bb = (0:2*pi/nrB:2*pi);
[aaa, bbb] = meshgrid(aa, bb);
[xxx, yyy, zzz] = func(aaa, bbb);
[~, volume] = convhull(xxx,yyy,zzz);

end %ConvexVolumeDirect
