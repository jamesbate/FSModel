function bool = ExtremizeIsInteresting(results, area, isMini)
% Make sure this extremum does not already exist and 
% it is an actual extremum and not a middle point

bool = true;

% Only extremae are processed ...
if isnan(isMini) || isMini > 1
    bool = false;
    return;
end

% ... upon first find.
for ind = 1:length(results)
    if abs(results{ind}.area - area) < area * 1e-3
        bool = false;
        return;
    end
end %for
end %ExtremizeIsInteresting
