The connection code is similar to API in that they are called from 
the main function.

The real qualitative difference is that they are bridges to calcuations.
Furthermore, they are reponsible for file IO of the results.
Because calculations is meant to be useable from code as well, which 
means you would not want to save all the time.
Calculations just knows that 'bands can be created', but does not care how.

These are each responsible for a single GUI command with this outline:
- call ExtractParameters for bands
- call GetFolderPath and make an output path
- call upon the right calculations with the obtained bands
- save any and all results to files

Contrary, the only thing this knows about each calculation is its arguments,
return type and if a plot is made or not (such that it can be saved).
These do not know anything about how their calculations are done.

Roemer Hinlopen
13 June 2019 - initial document
19 June 2019 - specify outline