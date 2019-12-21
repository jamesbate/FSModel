function [planes, freqs] = ODEvaluation(geo, aa, bb)
% For all of these points, get the frequencies in such a way that
% resilience to 0-area orbits is guaranteed.

nr = length(aa);
planes = zeros(1, nr);
freqs = zeros(1, nr);
for ind2 = 1:length(aa)
   planes(ind2) = geo.CalcDistance(aa(ind2), bb(ind2));
   try
       area = geo.CalcArea(aa(ind2), bb(ind2));
   catch exc
       area = 0;
       if isempty(strfind(exc.message, '0 steps')) && ...
          isempty(strfind(exc.message, '1 step'))
           fprintf('Error occured in area calculation: %s\n', exc.message)
       end
   end %try
   freqs(ind2) = AreaToFrequency(area);
end %for
end %ODEvaluation
