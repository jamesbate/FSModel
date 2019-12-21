function CoveragePlotOrbitsAB(geometry, aa, bb)
% Plot these orbits in AB space on the *CURRENT* figure
% This is particularly interesting when you want to know the topological 
% stuff going on, where the limit cycles are and how the general picture
% looks like that this program is solving.
%
% Because Computational Geometry's main task is just that:
%   separate out all the topologically distinct regions with 
%   razorsharp edges to be able to analyse each without 
%   losing any significant volume.

colors = jet(length(aa));
for ind = 1:length(aa)
    try
        path = geometry.CalcPath(aa(ind),bb(ind), true);
    catch
        continue;
    end
    
    hold on;
    plot(path(:,1), path(:,2), 'Color', colors(ind,:));
end

end %CoveragePlotOrbitsAB
