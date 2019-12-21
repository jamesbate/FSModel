function LSurfacePlot(cgeo, vf, band)
% Plot the L surface of this computational geometry on the CURRENT figure. 
% Lvec = vvec * tau, 
%   For isotropic tau this is just the velocity distribution.
%   More generally for anisotropic tau it represents the mean free path 
%   of all electrons as a function of direction.
%
% The plot is made with respect to the current magnetic field direction
% and includes orbits in planes perpendicular to that magnetic field, each
% orbit has its own color and its velocity-space trajectory is shown.
%

amount = NrLSurfaceLines;
[avals, bvals] = cgeo.Cover(amount);
colors = jet(length(avals));

for ind = 1:length(avals)
    try
        path = cgeo.CalcPath(avals(ind), bvals(ind), true);
    catch exc
        if strcmp(exc.identifier, 'Marching:Mini') || ...
           strcmp(exc.identifier, 'Marching:Maxi')
           if isempty(strfind(exc.message, '0 steps')) 
               fprintf('L Orbit at (%.3f, %.3f) failed because %s\n', ...
                       avals(ind), bvals(ind), exc.message);
           end
        end
        continue;
    end
        
    filter = ceil(length(path) / 200);
    [vx, vy, vz] = vf(path(1:filter:end,1), path(1:filter:end,2));   
    vxt = vx .* band('tau') * 1e9;
    vyt = vy .* band('tau') * 1e9;
    vzt = vz .* band('tau') * 1e9;
    hold on;
    LSurfacePlotOrbit(vxt, vyt, vzt, colors(ind, :));
end
colormap(colors);
LSFigureProperties;
end %LSurfacePlot
