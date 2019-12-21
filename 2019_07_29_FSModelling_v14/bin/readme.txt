Location: FSModelling/bin
Version: 1.3

The main grouping here is to deal with any and all code that knows about
the GUI. The "GUI-group" is a quite large modular part that contains
- API
- Connection

Has three interactions
- The user
- Settings
- Calculations

Has a three-way task
- Let the user 
- Create bands
- And send those bands to calculations.

Architecturally, this means calculations and settings are modular
and unaware of the existance of a GUI, you could make a CLI or code
as long as you create the same bands objects in the end.

Task 1 is the job of the main code file and the fig file: The user interface.
Task 2 is the job of API and it relies on Settings to do so.
Task 3 is outsourced to calculations, initiated by connection

----------------------------------

The fig file contains the design of the GUI and relies in a fragile manner 
on the main code file for a plethora of Callbacks and control, which 
are subsequently send to API and Connection to be handled.

API deals with setting up all the details and memorizing them in a 
structured manner using Settings.
Settings is quite close to an interface, though it is not fully formalized.
The main point of contention for API is to keep Settings and the GUI 
in sync as well as implement the grouping on symmetries and bands.
It is isolated by only endorsing access through ExtractParameters (and GetFolderLocation)
Anything else is subject to change.

Connection then relies on ExtractParameters to get these bands
and calls the right functions in Calculations. 

All of this is made such that calculations does not know
anything about the GUI and the way the bands are made,
whereas the GUI-group does not know anything about the 
way the calculations are performed nor the way 
settings are handled, just that these tasks can be called upon.

Roemer Hinlopen
19 June 2019