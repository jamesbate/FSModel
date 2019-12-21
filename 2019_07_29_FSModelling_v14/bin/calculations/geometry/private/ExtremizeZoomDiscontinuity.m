function result = ExtremizeZoomDiscontinuity(geometry, result, aa3, bb3, areas3)
% Provided the optimum found is at least 10% different than 
% the 3 surrounding areas while they are closer, 
% zoom in to find out if there is something fishy and discontinuous 
% going on and solve the problem.
% 
% Returns the same result (common), a changed result or a NaN.

% Can't deal with cases that are inherently unstable
% This normally does not occur.
if abs(areas3(1) - areas3(2)) > 0.1 * areas3(2) || ...
    abs(areas3(3) - areas3(2)) > 0.1 * areas3(2)
    return;

% If there is a sudden discrepancy then this is definitely a discontinuity.
% This would be a jump up on a max or jump down on a min.
elseif abs(result.area - areas3(1)) > 0.1 * areas3(1) || ...
    abs(result.area - areas3(2)) > 0.1 * areas3(2) || ...
    abs(result.area - areas3(3)) > 0.1 * areas3(3)

% To ROBUSTLY exclude it, evaluate in the vicinity over a couple orders 
% of magnitude of zoom. The common case is to return here.
else
    discontinuous = false;
    dd = geometry.CalcDistance(aa3, bb3);
    f = 1;
    while f > 1e-5
        f = f/4;
        dOff = result.plane + abs(dd(3)-dd(1)) .* f;
        try
            area = geometry.CalcArea(dOff(ind));
        catch
            discontinuous = true;
            break;
        end %try

        if abs(area - result.area) > 0.1*result.area
            discontinuous = true;
            break
        end
    end %for
    
    if ~discontinuous
        return;
    end
end

% From here, there is likely a discontinuity present and it is warranted
% to pay extra evaluations to check it out in more detail.

% Zoom from the lower end till the discontinuity is found.
% Keep the discontinuity boundaries themselves in view.
lower = geometry.CalcDistance(aa3(1), bb3(1));
areaLow = areas3(1);
iter = 0;
while abs(areaLow - areas3(1)) < 0.1 * areas3(1)
    lower = lower + (result.plane - lower)*0.5;
    try
        [a, b] = geometry.FindPlane(lower);
        areaLow = geometry.CalcArea(a, b);
    catch
        break;
    end
    iter = iter + 1;
    if iter > 20
        error('Somehow an infinite loop was created')
    end
end
lower = lower - (result.plane - lower);

% Same for the upper side.
upper = geometry.CalcDistance(aa3(3), bb3(3));
areaUpper = areas3(3);
iter = 0;
while abs(areaUpper - areas3(3)) < 0.1 * areas3(3)
    upper = upper - (upper - result.plane)*0.5;
    try
        [a, b] = geometry.FindPlane(upper);
        areaUpper = geometry.CalcArea(a, b);
    catch
        break;
    end
    
    iter = iter + 1;
    if iter > 20
        error('Somehow an infinite loop was created')
    end
end
upper = upper + (upper - result.plane);


% With this minimalist view of the discontinuity, 
% at least half the interval is inside the discontinuous region.
% Meaning that if it is stable at all, 20 points is enough to see if 
% there is a proper extremum here.
%
% Because these discontinuities are very narrow, it is geometrically 
% no sensible to think there may ever be multiple extrema. If that is 
% the case, then the initial linear grid used to find where everything 
% is should be made more fine grained.
distances = (lower:(upper-lower)/19:upper);
areas = zeros(1, length(distances));
errors = zeros(1, length(distances));
for ind2 = 1:length(distances)
    try
        [a, b] = geometry.FindPlane(distances(ind2));
        [areas(ind2), errors(ind2)] = geometry.CalcArea(a, b);
    catch
        areas(ind2) = NaN;
    end
end
distances(isnan(areas)) = [];
errors(isnan(areas)) = [];
areas(isnan(areas)) = [];

% Now if there is exactly 1 extremum found, this is resolved properly.
stats = ExtrClassifyAll(areas);
stats(stats>1) = NaN;
minmax = stats;
minmax(isnan(minmax)) = [];

if isempty(minmax)
    % This message may have to be deleted.
    fprintf('%s %.3e found no proper extremum.\n', ...
            'Zooming into the discontintuity at distance', result.plane);
    return;
end

% Find the least uncertain extremum and consider that to say the truth.
index = 0;
for ind = 2:length(errors)-1
    if ~isnan(stats(ind)) && (index == 0 || errors(ind) < errors(index))
        index = ind;
    end
end %for
[aLocal(1), bLocal(1)] = geometry.FindPlane(distances(index-1));
[aLocal(2), bLocal(2)] = geometry.FindPlane(distances(index));
[aLocal(3), bLocal(3)] = geometry.FindPlane(distances(index+1));
areasLocal = areas(index-1:index+1);
result = ExtrRefine(geometry, aLocal, bLocal, areasLocal, stats(index));
if isstruct(result)
    fprintf('Succesfully resolved discontinuity distance %.3e, area %.3e.\n', ...
            result.plane, result.area);
end
end %ExtrZoomDiscontinuity
