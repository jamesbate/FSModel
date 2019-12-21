function r = InsideClosedCurve(xx, yy, x, y)
% Check if (x,y) is inside the closed curve (xx,yy);
%
% Algorithm
% ---------
% Swipe the angle with respect to (x,y) over the orbit and see if the 
% the sum is 0 (outside) or +-2piN (inside), where N is the number of 
% times the trace loops around.
%
% Note: Adds the first point to the end, so you are free to add the
%       starting point yourself or let this fix it for you.

% Note that the atan argument is sin/cos = cross product / dot product;
% the normalizations cancel out.
xx = xx - x;
yy = yy - y;
xx(end+1) = xx(1);
yy(end+1) = yy(1);
angles = atan2((xx(1:end-1).*yy(2:end) - yy(1:end-1).*xx(2:end)), ...
               (xx(1:end-1).*xx(2:end) + yy(1:end-1).*yy(2:end)));
total = abs(sum(angles));

% Sanity - does not actually trigger now that atan2 is used and not atan.
if total > 2 && total < 2*pi-2       
    error('%s(%.3e,%.3e) %s',...
          'Uncertain if this point is included: ', ...
          x, y, ...
          'You are likely right at the edge of the cycle.');
end
r = total > pi;
end %InsideClosedCurve

