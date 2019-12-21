function result = MultiFractionalFilling(bands, message)
% Calculate the number of electrons/holes in each band.
% message : bool
%   set - create a message printable to a message/file
%           triggers calculating Hall and heat capacity in addition to n.
%   unset - instead return numerical fractional fillings. 
%           Holes >0, Electrons <0 simple array matching the given bands.
% bands : containers.Map or array of containers.Map
%   see readme.txt in this folder
%
% Responsibility: Looping over FractionalFilling and combining the results

bands = InitiateBands(bands);
numbers = zeros(length(bands));
for ind = 1:length(bands)
    band = bands{ind};
    numbers(ind) = FillingFraction(band);
end

if ~message
    result = numbers;
else
    [rh, n] = FillingHallSimple(sum(numbers(:)), bands{1});
    % [~, rh] = MultiSigma(bands);
    result = FillingMessage(bands, numbers, rh, n);
end
end %MultiFractionalFilling

