function sections = CoverageTrivialSections()
% Make the simplest section of all that guarantees mapping everything
% when you have no nodes: run a and b from 0 to 2pi.

sections = {struct('alpha', [0,0], 'beta', [2*pi,2*pi], 'topology', -1)};

end %CoverageTrivialSections
