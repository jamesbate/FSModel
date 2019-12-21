function area = EnclosedAreaImplementation(xx, yy, zz)
% Calculate the area enclosed by this curve.
% 
% Definition of enclosed is here by triangulation with respect to the 
% centre of mass of this trace. The last point is connected back to the
% first so you are free to repeat the starting point (= area 0 triangle).
%
% The area has a sign, if you move counter clockwise it is positive.
% If the first step is 10x the step from the last element to the first
% to close the orbit, an error is reasied that the orbit is not closed.
% 
% Notes:
% Weakly checks that the orbit is cloesd. The points do not need to be
% linearly spaced in any sense of the word. 
% Smooth curves converge with O(N^-2) in error. The
% leading term comes from the interval where a straight connection line
% cuts off most of the orbit. This means without a priori information, you
% should aim at equidistantly spaced points. With a priori information you
% are free to sample more in regions of higher curvature.
% Convex shapes are strictly underestimated, with concave areas it depends
% which errors are larger.
%
% Responsibility: Remove centre and traingulate the area. Low level.


% Basic idea: Cross product results in the area spanned by two vectors,
% half that value is the traingle area. By constructing triangles from each
% neighbouring data pair as well as the origin, the entire area can be
% decomposed into triangles.
nr = length(xx);
if nr < 3
    error('Need at least 3 points.');
end

centreX = sum(xx) / nr;
centreY = sum(yy) / nr;
centreZ = sum(zz) / nr;
xx = xx - centreX;
yy = yy - centreY;
zz = zz - centreZ;

% The 0.5 is based on my experience.
p1 = [xx(end), yy(end), zz(end)];
pstart = [xx(1),yy(1),zz(1)];
if norm(p1-pstart) > 0.5 * norm(p1)
    % Now the real test
    mx = max(abs(xx));
    my = max(abs(yy));
    mz = max(abs(zz));
    if norm(p1-pstart) > 0.5 * max([mx,my,mz])        
        error('The orbit is not closed.');
    end
end

% The vectorial nature is critical here and is a bug in v1.1 and v1.2.
% You won't notice normally, but when the area is very wonky and the 
% triangles reverse direction as a result, adding the norms is strictly
% wrong and caused high-angle strongly-corrugated cylinders to diverge.
% Very serious bug.
% Fixed 2 July 2019
areaVec = zeros(1,3);
for ind = 1:length(xx)
    p2 = p1;
    p1(1) = xx(ind);
    p1(2) = yy(ind);
    p1(3) = zz(ind);
    areaVec = areaVec + 0.5 .* cross(p1, p2);
end %for 
area = norm(areaVec);
end %EnclosedAreaImplementation

