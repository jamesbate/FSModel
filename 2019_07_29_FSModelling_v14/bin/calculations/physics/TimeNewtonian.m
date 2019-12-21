function time = TimeNewtonian(path, kffunc, vffunc, Bvec)
% Use Newton to determine the rate of change,
% then take the discretisation of the path to approximate the 
% local rate of change to be constant to find the traversal time.
%
% path : array (100+, 2)
%   Parametrized path traversed.
% kffunc : func [R,R] => [R,R,R]
%   Given a parametrized point, get the actual Carthesian point
% vffunc : func [R,R] => [R,R,R]
%   Given a parametrized point, get the velocity there.
% Bvec : 3-vector
%   Magnetic field vector [with size included!]
%
% The problem with just Newton to evolve the orbit is that slight 
% deviations occur and it is very hard to constrain perfectly such that
% return is possible. The choice for marching squares over RK4
% was not made lightly. A Python implementation of RK4 was actually 
% made, but it had some motion in B direction as a result of 
% imperfections of the implementation of vFermi.
%
% Responsibility: Calculate the traversal time for a general path,
%   general velocity functional, general kf functional, general B direction

time = 0;
nextPos = path(1, :);
next = kffunc(nextPos(1), nextPos(2));
for ind = 1:length(path) - 1
    nowPos = nextPos;
    now = next;
    nextPos = path(ind + 1, :);
    
    [x, y, z] = kffunc(nextPos(1), nextPos(2));
    next = [x, y, z];
    [vx, vy, vz] = vffunc(nowPos(1), nowPos(2));
    vnow = [vx, vy, vz];
    
    kdist = norm(next - now);
    kdot = norm(cross(vnow, Bvec)) * e;
    time = time + hbar * kdist / kdot;    
end %for
end %NewtonTime
