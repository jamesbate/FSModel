function xx = DescendNext1(x, dx, minx, maxx, isMod)
% Shift to west and east, but respect the limits of the interval
% and the type of boundary conditions.

xx = [x-dx/2, x+dx/2];
xx(1) = adjust(x-dx/2, minx, maxx, isMod);
xx(2) = adjust(x+dx/2, minx, maxx, isMod);
end %NextPositions1

function value = adjust(value, low, high, isMod)
    % If isMod is set, low is ignored.
    % This is where the boundary behaviour is implemented.
    % If a step passes the bound, set it to the bound.
    % Unless modulo is set, in which case it is mapped back with mod.
    if value < low
        if isMod
            value = mod(value, high);
        else
            value = low;
        end
    elseif value > high
        if isMod
            value = mod(value, high);
        else
            value = high;
        end
    end
end %adjust
