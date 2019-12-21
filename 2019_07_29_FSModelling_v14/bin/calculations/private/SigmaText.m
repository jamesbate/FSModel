function s = SigmaText(sigma, RHall, bands)
% Create a message to show for the conductivity.

band1 = bands{1};
polar = band1('BPolar') * 180/pi;
azu = band1('BAzumithal') * 180/pi;
B = band1('B');

s = sprintf('At polar angle %.2f and azumithal %.2f, field %.1f.\n', ...
            polar, azu, B);
s = sprintf('%sThe *leading order in B* sigma tensor is in (mu Ohm cm)^-1:\n', s);
        
% 6 powers for micro, 2 for cm.
sigma = sigma ./ 1e8;
s = sprintf('%s\n%10.3e %10.3e %10.3e\n',s,sigma(1,1),sigma(1,2),sigma(1,3));
s = sprintf('%s\n%10.3e %10.3e %10.3e\n',s,sigma(2,1),sigma(2,2),sigma(2,3));
s = sprintf('%s\n%10.3e %10.3e %10.3e\n',s,sigma(3,1),sigma(3,2),sigma(3,3));

s = sprintf('%s\nThe resulting Hall coefficient would be:\n', s);
s = sprintf('%s%.3e cm^3/C\n\n', s,RHall*1e8);
s = sprintf('%sReminder that this is in lowest order of omega_c tau.\n',s);
s = sprintf('%sAnd that diagonal is B-independent, off is proportional.',s);

end %ShowSigma
