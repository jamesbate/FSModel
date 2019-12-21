function results = PhysicalExtremae(cg, id, angle, type, effmass)
% Calls cg.ExtremalAreas and adds the physics, i.e. from area to frequency
% and curvature and information etc.
%
% Note that you have to set the direction for cg even though it is an input
% parameter, that is just straight up copied into the result.


results = cg.ExtremalAreas();

for ind = 1:length(results)
    results{ind}.angle = angle;
    results{ind}.id = id;
    results{ind}.type = type;
    results{ind}.effmass = effmass;
    results{ind}.freq = AreaToFrequency(results{ind}.area);
    results{ind}.dfreq = AreaToFrequency(results{ind}.dArea);
end

results = AddCurvature(results, cg);
end %PhysicalExtremae
