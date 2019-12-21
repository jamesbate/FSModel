function SigmaLauncher(handles, settings)
% Compute sigma xx, yy, xy using the L-space geometric formalism introduced
% by Ong 1991.
%
% Reponsibility: Separate computation from File IO / messaging

bands = ExtractParameters(settings);
[sigma, RHall, msg] = MultiSigma(bands);
[matloc, msgloc] = IOPathSigma(settings, handles);
save(matloc, 'sigma', 'RHall', 'bands');
SaveMessage(msgloc,msg);
end %SigmaLauncher
