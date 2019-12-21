function x = ParabolaFit(x0, dx, y1, y2, y3)
% Given [x0-dx, x0, x0+dx] and [y1, y2, y3] find where it is extreme.

x = ParabolaFitIrr(x0-dx, x0, x0+dx, y1, y2, y3);
end


