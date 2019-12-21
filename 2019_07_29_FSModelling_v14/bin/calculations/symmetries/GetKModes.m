function kmodes = GetKModes(symmetry)
% Get a list of symmetry modes
% e.g. {'k00', 'k10', 'k20', 'k21'}

if strcmp(symmetry, 'Choose Symmetry Group')
    kmodes = {'1st', '2nd', '3rd', '4th', '5th', '6th', '7th', ...
              '8th', '9th' '10th'};
    for ind = 1:length(kmodes)
        kmodes{ind} = sprintf('%s Component', kmodes{ind});
    end %for
else
    func = GetKFermiFunc(symmetry);
    kmodes = Signature(func);
    kmodes = kmodes(6:end);
end
end %GetKModes