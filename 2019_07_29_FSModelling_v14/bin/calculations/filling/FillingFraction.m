function fraction = FillingFraction(band)
% Derive for this one band the fractional filling (negative for electrons)
%
% Responsibility: Extract props from band for FractionalFilling and sign.

err = 0.01;

fraction = FillingFractionAbsolute(band('symmetry'), band('a'), ...
                                   band('b'), band('c'), ...
                                   band('kcoeff'), band('precision'), err);
                         
if strcmp(band('type'), 'electron')
    fraction = -fraction;
elseif ~strcmp(band('type'), 'hole')
    error('A band has character %s, which is unknown.', band('type'));
end
end %SingleFractionalFilling