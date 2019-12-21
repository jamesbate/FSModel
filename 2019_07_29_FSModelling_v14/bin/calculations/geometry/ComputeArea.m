function area = ComputeArea(xx, yy, zz)
% Compute the area enclosed by this orbit, defined by triangulation with
% respect to the centre of mass of the orbit. The area carries a sign
% depending on the circulation direction.
%
% Exposed because it turns out this is useful outside of Geometry as well
% for L-surfaces.
% 

area = EnclosedAreaImplementation(xx, yy, zz);
end %ComputeArea
