function result = MultiExtremalOrbit(bands, txtresult)
% Determine the extremal orbits, plot on a new graph.
% Preferably call MultiFermiSurface afterwards.
%
% txtresult : bool
%   set - presentable text with kz positions and frequencies
%   unset - cell array of {bandid, [centrepoints], [freqs], [times]}.
%
% Responsibility: Combine results and regulate color over the bands.

% Initiate global
tic;
figure;
bands = InitiateBands(bands);
output = OutputExtremalOrbit(txtresult);
colors = cool(length(bands));

for ind = 1:length(bands)    
    % Initiate particular
    band = bands{ind};
    fprintf('Working on band %s. Timer: %.2f s\n', ...
            band('id'), toc);
    [cg, vf] = GeometryFromBand(band);
    color = colors(ind, :);
    
    % Compute
    results = PhysicalExtremae(cg, band('id'), band('BPolar'), ...
                               band('type'), band('effmass'));
    
    % Process
    for rind = 1:length(results)
        EODecoratedUpdate(output,results{rind},cg,vf,band,color);
    end
end %for
fprintf('Completed MultiExtremalOrbit after %.2f s\n', toc);

% Finalize
result = output.GetResult();
end %MultiExtremalOrbit
