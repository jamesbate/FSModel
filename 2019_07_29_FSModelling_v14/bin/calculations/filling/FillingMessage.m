function message = FillingMessage(bands, numbers, rh, n)
% Turn this result into a formatted result to present.

if length(bands) ~= length(numbers)
    error('Expected exactly 1 fractional filling per band.');
end

message = sprintf('Fractional filling of bands:\n'); 
for ind = 1:length(numbers)
    band = bands{ind};
    message = sprintf('%sBand %s: %.5f %s\n', ...
                      message, band('id'), ...
                      abs(numbers(ind)), band('type'));
end

total = sum(numbers(:));
message = sprintf('%s\n--------\n', message);
message = sprintf('%sIn total %.5f fractional filling\n', ...
                  message, total);


message = sprintf('%sOr charge density %.3e cm^-3\n', message, n );
message = sprintf('%s\nOr Hall coefficient %.3e cm^3/C\n', message, rh * 1e8);
message = sprintf('%s^assuming all have equal mobility^\n', message);
end %MakeMessage
