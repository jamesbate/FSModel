function FermiSurfacePlot(band, mode, color)
% Plot this Fermi Surface, optionally colored with Fermi velocity components
%
% Band : Containers.Map
%   Global contract
% mode : int
%   0 => Fermi surface
%   1 => Fermi velocity
%   2 => Fermi velocity radial in plane component
%   3 => Fermi velocity azumithal component
%   4 => Fermi velocity z component
% color : color (optional)
%   If not provided, color blue/red depending on band character.
%
% Reponsibility: Guides the steps for the FS plot. High level.


% The mass only affects the velocity
% If you set it to 0 it is raising an error
% But this is not necessary when the Fermi surface is concerned,
% so bypass it to something non-sensical but non-zero. 1 kg.
%
% Please note that mode 0 here would result in vector Fermi velocity
% and crash plots due to dimensionality, but the mode==0 for Fermi
% Surface catches this and makes it impossible to get into this state.
if mode == 0
    mass = 1;
else
    mass = band('effmass');
end

[xxx, yyy, zzz, vvv] = VFDiscretisation(band('symmetry'), ...
                                   band('a'), ...
                                   band('b'), ...
                                   band('c'), ...
                                   mass, ...
                                   band('kcoeff'), ... 
                                   150, mode);
                               
[xxx, yyy, zzz] = FSTransformCoordinates(band, xxx, yyy, zzz);

if mode == 0
    if nargin < 3
        arg = band('type');
    else
        arg = color;
    end
    FSMakeSurface(xxx, yyy, zzz, arg);
else
    VFMakeSurface(xxx, yyy, zzz, vvv);
end
            
end %FermiSurfacePlot

