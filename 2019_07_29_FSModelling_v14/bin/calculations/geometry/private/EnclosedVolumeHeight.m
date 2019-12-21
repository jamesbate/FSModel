function height = EnclosedVolumeHeight(X1, Y1, Z1, X2, Y2, Z2)
% Approximate the area-averaged distance between these two trajectories.


% Seems it may not be proper
% It does not adjust well enough when you use a Torus
% You can see this when trying to approximate a torus accurately, the
% number of iterations shoots up and this is because the non-parallel
% surfaces causes this to not get the correct height. This does work well
% for spheres where subsequent areas shrink/enlarge but does not work well
% when the A axis itself is bend and the B angle (over these trajectories)
% the height changes. May as well use norm(shift).
persistent MESSAGE
if isempty(MESSAGE)
   disp('Remember EnclosedVolumeHeight needs attention');
   MESSAGE = true;
end


% The distance between the centres is one component
centre1 = [sum(X1) / length(X1), ...
           sum(Y1) / length(Y1), ...
           sum(Z1) / length(Z1)];
centre2 = [sum(X2) / length(X2), ...
           sum(Y2) / length(Y2), ...
           sum(Z2) / length(Z2)];
shift = centre2 - centre1;
height = norm(shift);
return


% Nice notion, but it does not work and costs a ton of time. This is
% limiting code remember!
% Slows down by factor 18 for ellipses.

% The distance between individual points is another.
distances = 0;
for ind = 1:length(X1)
    delta = [X1(ind) - X2(ind), ...
             Y1(ind) - Y2(ind), ...
             Z1(ind) - Z2(ind)];
         
    % This is 1/3 and 2/3 because you want integral(r*h(r)) and h(r)
    % is accurately linear between the center and edge. The weight is added
    % here because at larger radius there is a larger area element
    % associated with this line. This line is basically an element dPhi and
    % this always has the Jacobian 'r' added to it.
    % Hence just averaging centre and edge is not the right approach.
    % Similarly you do not just want the circumference averaged height,
    % because volume = integral h dA and not h dS.
    distances = distances + norm(shift) / 3 + 2 /3 * norm(dot(direc, delta));
end %for
height = abs(distances) / length(X1);

end %EnclosedVolumeHeight
