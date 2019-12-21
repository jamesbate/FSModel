function FSModellingTest()
% Executable file: Launches all the tests.
% All of them should pass and it takes only a couple of seconds.


fprintf('Setting up tests...\n');
 
% Detailed can be used to turn off some of the slower tests.
% Make sure to run them every now and then though!
global DETAILED;
DETAILED = true;
global SHOW_COVERAGE;
SHOW_COVERAGE = true;

[here, ~, ~] = fileparts(mfilename('fullpath'));
cd(here);
cd tests;
timer = tic;
AddAllModules();
fprintf('Running tests...\n');

runtests();

fprintf('>> Testing took %.1f.\n', toc(timer));
cd ..;
end %FSModellingTest
