function FractionalFillingLauncher(handles, settings)
% Derive the number of electrons for all bands, 
% show a message and save said message to an output file
%
% Responsibility: Separate functional physics from IO and Settings 

bands = ExtractParameters(settings);
string = MultiFractionalFilling(bands, true);
filename = IOPathFractionalFilling(settings, handles);
SaveMessage(filename, string);
end %FractionalFillingLauncher

