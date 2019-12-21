function output = MultiAngularFrequency(bands, angles)
% Make a (theta, freq) sweep on a new figure.
% Angles is polar direction and is an array in RADIANS.
% The azumithal angle is taken from the bands
%
% Responsibility: Split actual calculation from output / plots
%
% Returns an OutputLikeFSPlotter object with method .Save(filepath)

% Part 1: Initiation
bands = InitiateBands(bands);

% Part 2: Computational
collective = {};
for ind = 1: length(bands)
    band = bands{ind};
    cg = GeometryFromBand(band);
    id = band('id');
    type = band('type');
    effmass = band('effmass');
    
    album = cell(1, length(angles));
    parfor ind2 = 1:length(angles)
        try
            tic;
            cg.SetDirection(angles(ind2), cg.Uazumithal);
            results = PhysicalExtremae(cg, id, angles(ind2), type, effmass);
            album{ind2} = results;
            fprintf('Finished band %s, angle %05.2f in %.2f s.\n', ...
                    id, angles(ind2)*180/pi, toc);
        catch exc   
            fprintf('!! Failed angle %.2f. Error: %s\n', ...
                    angles(ind2)*180/pi, getReport(exc));
            album{ind2} = {};
        end
    end
    album = Concatenate(album);
    for ind3 = 1:length(album)
        collective{end+1} = album{ind3};
    end %for
end %for

% Part 3: Output format
output = OutputLikeFSPlotter();
for ind = 1:length(bands)
    output.AddBand(bands{ind});
end 
for ind = 1:length(collective)
    output.Update(collective{ind});
end 

% Part 4: Plotting
figure;
ADPlotCollective(collective);
ADFigureProperties();
end %MultiAngularFrequency

