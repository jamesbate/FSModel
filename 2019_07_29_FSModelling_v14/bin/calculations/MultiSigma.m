function [sigma,RHall,msg] = MultiSigma(bands)
% Compute the sigma tensor components.
% Assumes all bands share tau, B and direction.
%
% Note that on diagonal components are independent of B, 
% Off diagonal components are linear in B.
% This is based on Ong 1991,
% which is lowest order in B but allows for anisotropic tau.
%
% band('tau') may be either a double or a parametrized function.
% Namely [R,R] => [R,R,R] matching the geometry in parametrization
% but returning the velocity rather than position at that location.

bands = InitiateBands(bands);
band1 = bands{1};
tau = band1('tau');
B = band1('B');
BPolar = band1('BPolar');

sigma = zeros(3,3);
for ind = 1:length(bands)
    band = bands{ind};
    [cg, vf] = GeometryFromBand(band);
    isEl = strcmp(band('type'), 'electron');
    sigma = sigma + SigmaDiagonal0(cg, vf, tau);
    sigma = sigma + SigmaOffDiagonal(cg, vf, tau, B, isEl);
end
RHall = sigma(1,2) / (sigma(1,1) * sigma(2,2) * B * cos(BPolar));
msg = SigmaText(sigma, RHall, bands);

end %MultiSigma
