function freq = AreaToFrequency(area)
% Onsager relation. Array or floats accepted.
freq = area .* hbar ./ (2 * pi * e);
end
