function results = AddCurvature(results, geo)
% Compute the curvature by a parabolic fit around the extremae given.
% Do this over multiple orders of magnitude to get a good approximation 
% for the curvature. Will not raise if it fails, just prints.

dplaneBase = 5e6;
for ind = 1:length(results)
    res = results{ind};
    
    curves = zeros(1, 7);
    for ind2 = 1:7
        try
            dplane = dplaneBase * 2^ind2;
            [aLow, bLow] = geo.FindPlane(res.plane - dplane, res.a, res.b);
            yLow = geo.CalcArea(aLow, bLow);

            [aUp, bUp] = geo.FindPlane(res.plane + dplane, res.a, res.b);
            yUp = geo.CalcArea(aUp, bUp);

            curves(ind2) = ParabolaCurvature(res.plane, dplane, yLow, res.area, yUp);
        catch
        end
    end
    
    % Choose the median here.
    % The point is that these extrema can be quite rough due to 
    % 'precision' discretising the orbit, but normally a few are fine and
    % a few are off, so use the median as a compromise.
    curves(curves==0) = [];
    if isempty(curves)
        fprintf('Note: No curvature verification possible.\n');
    else
        results{ind}.curvature = median(curves);
    end
end %for
end %AddCurvature
