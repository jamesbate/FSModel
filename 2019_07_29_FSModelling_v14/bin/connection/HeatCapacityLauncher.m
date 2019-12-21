function HeatCapacityLauncher(handles, settings)
% Compute the linear heat capacity coefficient gamma both 
% using a perfect 2D approximation and the actual Fermi surface
% density of states, related to the area and inverse velocity.
%
% Reponsibility: Separate computation from File IO / messaging

bands = ExtractParameters(settings);
[gamma, gamma2d] = MultiGamma(bands);
msg = GammaMessage(gamma, gamma2d);
msgloc = IOPathGamma(settings, handles);
SaveMessage(msgloc,msg);

end

function s = GammaMessage(gamma, gamma2d)

s = sprintf('%s\n\n%s\n%s\n%s\n%s\n\n', ...
            'Linear coefficient of the heat capacity', ...
            'This property can be found from the masses.', ...
            'This assumes the Fermi surfaces are perfectly 2D and is rough.', ...
            'Alternatively it is the density of states,', ...
            'meaning inverse velocity and Fermi surface area.');
        
s = sprintf('%s2D case (mJ/mol/K^2):\n', s);
for ind = 1:length(gamma2d)
    s = sprintf('%sBand %d: %.5f\n', s, ind, gamma2d(ind) * 1000);
end
s = sprintf('%s-------\n%s = %.5f\n\n', s, char(947), sum(gamma2d) * 1000);
        
s = sprintf('%sGeneral case (mJ/mol/K^2):\n', s);
for ind = 1:length(gamma)
    s = sprintf('%sBand %d: %.5f\n', s, ind, gamma(ind) * 1000);
end
s = sprintf('%s-------\n%s = %.5f\n', s, char(947), sum(gamma) * 1000);
end
