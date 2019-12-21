The purpose of Multi... functions is to take in bands and launch 
all the physics. If you want to change the way you get to bands,
be my guest. That is the contract. You provide bands, this does the job.

bands = array of containers.Map with all sorts of band properties.

I would like to invite you into the world of SOLID.
Single responsibility
Open-closed principle
Liskov subsitution (not relevant)
Interface segregation
Dependency Inversion


Single Responsibility
---------------------
Each function/class is given one responsibility.
Especially, I focus on giving it either high level or low level control,
never a mix. This forces with properly named functions that each 
low level function has a goal to comply to and high level functions
have lower level functions to combine. This allows for clear control flow.
It also helps in localising mistakes and modularity.

Open-Closed Principle
---------------------
Open for extension, closed for modification.
This applies to classes and although they are not used really outside 
the GUI design, which is basically one big class although it is represented
graphically in a .fig file.
However one structure here acts as a class: band.
The containers.Map which translates keys (e.g. 'id', 'effmass') to values.
This container is open for extension - new keys will never interfere.
But closed for modification - edited keys break the code as all are used.

Liskov Subsitution Principle
----------------------------
Any parent instance should be replaceable with a child without breaking the code.
There is no inheritance here so skip this.

Interface Segregation Principle
-------------------------------
Make small abstract base classes.
The only base class here is "containers.Map" which is a built-in.
So skip this.

Dependency Inversion Principle
------------------------------
Break fragility of the code by relying on abstractions not instances.
The case is as follows. A naive code obeying the above will still have 
its high level code depending on the input formats which the lower level
code takes. If any of these has to change or turns out to be impossible 
and requires high level access, these low level changes ripple up until
the highest levels of code have to be changed just to satisfy the low level
functionality. To prevent this abstractions are made.
Abstractions are like "I require this class to have these properties/methods"
or "function taking 2 arguments returning a double". Any class or function
satisfying the *contract* is valid. It can then change a whole lot, but 
it does not matter as long as the contract stays intact.
The classical example is a print function taking a string and returning nothing.
You can hard-code print, or you can take a function handle.
Then you can change to a file output, pop-up, ignore, web publisher or mail function.

This D is the real key to SOLID and the reason bands is made as it is.
It is a contract in simple form, without the abstract class but with the
clear dependency inversion. Both sides (whatever determines bands & bandphysics) 
rely on just one thing: an array of containers.Map.
Bands should be considered immutable.
If you wish to replace the entire GUI by a hardcoded function, be my guest.
If you build a new front-end which results in the required 
array of containers.Map, be my guest. This will work.


That is why this pause is build in.
I am not saying it is perfectly SOLID, but there is this break of dependency
onto a common interface (bands) at the most important breakpoint in the program flow:
the separation between frontend and functional backend code.


06 June 2019
Roemer Hinlopen