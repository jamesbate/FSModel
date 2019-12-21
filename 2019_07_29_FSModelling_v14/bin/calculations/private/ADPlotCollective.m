function ADPlotCollective(results)
% Given a cell array of structs with angles, frequencies and ids, plot.
% Uses the CURRENT figure.
% Responsiblity: Low level mutable presenter function.


% Identify the different bands present here for the coloring.
% Really get an array of unique IDs.
IDs = {};
for ind = 1:length(results)
    res = results{ind};
    
    found = false;
    for ind2 = 1:length(IDs)
        if strcmp(IDs{ind2}, res.id)
            found = true;
            break;
        end
    end %for
    if ~found
        IDs{end+1}= res.id;
    end
end %for

% Then make the plot, using the IDs found above to group the coloring.
colors = winter(length(IDs));
for ind = 1:length(results)
    res = results{ind};
    found = false;
    for loc = 1:length(IDs)
        if isequal(res.id, IDs{loc})
            found = true;
            break;
        end
    end % for
    if ~found
        error('An ID was not selected as unique');
    end
    color = colors(loc, :);
    cellColors{ind} = color;
    
    hold on;
    X = res.angle * 180/pi;
    Y = res.freq * cos(res.angle) / 1000;
    dY = res.dfreq * cos(res.angle) / 1000;
    scatter(X, Y, 'MarkerFaceColor', color, 'MarkerEdgeColor', 'none');
    errorbar(X, Y, dY, 'LineStyle', 'none', 'Color', color);
end %for

cellColors = cell(1, length(IDs));
for ind = 1:length(IDs)
    cellColors{ind} = colors(ind, :);
end
AddLegend(IDs, cellColors);
end %ADPlotOneBand
