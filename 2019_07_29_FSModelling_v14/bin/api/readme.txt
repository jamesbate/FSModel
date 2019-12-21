These functions are everything behind the GUI's feeling or API or frontend.
The most important control flow of this front end is given by readme.png
The responsibility of this folder is to encapsulate settings and handles.

This code strives to be DRY (Do not Repeat Yourself).
This code strives to be SOLID.

-------------------------------------

Let it be clear: this responsibility is what has been derived
by hard practise and it is not something a scientist does lightly
unless he fears his program will suffer if he does not change it.

This is what SOLID principles are in this context:
ExtractParameters and GetFolderLocation have to be considered
as the only public functions in this folder. 
The rest you never call outside of main.

The GUI with handles and settings is event driven.
It has to be, because that is how MATLAB and almost anyone runs a GUI.
Have a "while true" loop which checks all the possible callbacks and when it 
it finds one, trigger it. 
This requires a notion of state to memorize things from one call to the next.

State has the classic weakness of being corrupted and hard to debug as
any changes may come from anywhere.
This is in part what made object oriented programming as large as it is,
to allow for encapsulated state - which is what this architecture aims at.

Secondly there is SOLID (see elsewhere for an explanation).
The D especially - dependency inversion.
All these callback functions here depend on one another and on
extractParameters to present it.
All the other code also relies on ExtractParameters as the way 
the data will be presented.
ExtractParameters is a contract making the code independent or *modular*
By making it so that any problems in settings are always known to arise here,
in this folder and not outside of it.

13 June 2019
Roemer Hinlopen 