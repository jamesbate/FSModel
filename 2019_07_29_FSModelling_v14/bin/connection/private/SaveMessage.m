function SaveMessage(filename, string)
% Show this message and save it.
% Saving is done before showing, it is shown even if no save was possible.

stream = fopen(filename, 'wt');
if stream == -1
    msgbox(string);
    error('Cannot open file to save the message:\n%s', string);
end
raii = onCleanup(@()fclose(stream));
fprintf(stream, string);
msgbox(string);
end %SaveMessage
 