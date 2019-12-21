% Class which handles settings in a buffer with 
% automated file read/write on construction/destruction
%
% Methods:
%   obj = MySettings(name, useFile)
%   string = get(key[, default])
%   set(key, value[, new])
%   remove(key)
%   read()
%   write()
%   keys = getKeys()
%   [keys, vals] = getContent()
% Properties
%   name (char)
%   filepath (char)
%   destroyAfter (bool)
%
%
% Version 1.0: 08 may 2019
%       Simple API with read, write, keys, content
% Version 1.1: 09 May 2019
%       Change the common case to multiple reads in a single sweep
%       This has major consequences to get close to SOLID 
%       Breaking: change to get/set from read/write, remove .content
%       as get(settings.keys) is good enough.
% Version 1.2: 23 May 2019
%       Change it to be buffer based with file read/write on init/destroy
%       Breaks compatibility in that input is now single keys/values 
%       no longer batches as before and the API is extended.
%       Extends it with read/write/destroyAfter
%       Reintroduce getContent, rename keys => getKeys
% Version 1.3: 25 May 2019
%       Backwards compatibility with Matlab 2016a (2018b before)
%       by eliminating the use of string literals and replacing 
%       strip by strtrim.
% Version 1.4: 31 May 2019
%       New method: remove to remove a key from the settings.
% Author: Roemer Hinlopen
%

classdef MySettings < handle
   % Simple API to manage string settings within a file
   % The settings are saved in a human readable and adjustable manner.
   %
   % Please note that implementation and API are separated and you 
   % really can and should read this high level APIs code.
    
   properties
       destroyAfter = false;
   end
   
   properties (SetAccess = private)
       name
       filepath = '';
   end
   
   properties (Access = private)
        keys = repmat('', 1, 0);
        vals = repmat('', 1, 0);
        amount = 0;
        usesFile;
   end
   
   methods
       function obj = MySettings(settingsname, useFile)
           % Initiate a MySettings object, if useFile then read as well.
           %
           % name : string
           %    example: 'application_settings'
           %    names starting with 'test_' may be overridden when testing.
           % useFile (optional, true) : bool
           %    if unset, just buffer and no file interaction.
           %        Calling read and write in this mode causes errors.
           %    if set, read at the start, write at destruction
           %        Recommended way to use this.
           %
           % Note: If you wish to destroy a settingsfile, use:
           %    s = Settings('name');
           %    s.destroyAfter = true;
           %    delete(s);  OR let object go out of scope.
           %    NO confirmation and NO undo possible!
           %
          
           obj.name = settingsname;
           
           if nargin == 1
               useFile = true;
           end
           obj.usesFile = useFile;
           if useFile
               obj.filepath = SettingsPath(settingsname, true);
               obj.read();
           end
       end %constructor
       
       function string = get(obj, key, default)
           % Obtain this one setting.
           % If default is given, set and return it if non-existent
           %
           % key                : char array / string
           % default (optional) : char array / string
                 
           if ~ischar(key)
               key = char(key);
           end
           if isempty(key)
               error('Setting:Reserved', 'Empty key');
           end
           
           position = find(strcmp(obj.keys, key), 1);
           if numel(position) == 1
               string = obj.vals{position};
           elseif numel(position) > 1
               error('Setting:NoMatch', 'Key was found %d times. Bug.',...
                     numel(position));
           elseif nargin == 3
               obj.set(key, default, true);
               position = strcmp(obj.keys, key);
               string = obj.vals{position};
           else
               error('Setting:NoMatch', 'Key %s does not exist.', key);
           end
       end %get
       
       function set(obj, key, value, new)
           % Overwrite the given setting, existing or not.
           %
           % key   : char array / string
           % value : char array / string
           % new (optional, true) : bool, allow creation 
              
           if nargin < 4
               new = true;
           end
           [key, value] = MakeValidKeyValue(key, value);
           
           % Position will be an empty array or 
           position = find(strcmp(obj.keys, key), 1);
           if ~isempty(position)
               obj.vals{position} = value;
           elseif new
               obj.keys{obj.amount + 1} = key;
               obj.vals{obj.amount + 1} = value;
               obj.amount = obj.amount + 1;
               [obj.keys, order] = sort(obj.keys);
               obj.vals = obj.vals(order);
           else
               error('Setting:NoMatch', 'Key %s does not exist.', key);
           end     
       end %set
       
       function remove(obj, key)
          % Remove this key from the settings buffer. Error if no match.
          
          position = find(strcmp(obj.keys, key), 1);
          if isempty(position)
              error('Setting:NoMatch', 'Key %s does not exist.', key);
          end
          obj.keys(position) = [];
          obj.vals(position) = [];   
          obj.amount = length(obj.keys);
       end
       
       function kk = getKeys(obj)
           % Obtain an array of all keys available.
           
           if obj.amount > 0
               kk = obj.keys;
           else
               kk = [];
           end
       end %getKeys
       
       function [kk, vv] = getContent(obj)
           % Obtain keys and values, matching indices correspond.
           kk = obj.keys;
           vv = obj.vals;
       end
       
       function write(obj)
           % Replace the current settingsfile.
           
           if ~obj.usesFile
               error('File backing disabled on initiation.');
           end
           
           % Make the file close whatever happens, errors or not.
           stream = fopen(obj.filepath, 'w');
           if stream == -1
               error('Cannot open settingsfile to write %s', obj.filepath);
           end
           raii = onCleanup(@()fclose(stream));
           WriteSettingsFile(stream, obj.keys, obj.vals);
       end %write
       
       function read(obj)
           % Read in all settings from the file.
           % Does set() on every setting in the file.
           % Does NOT clear the buffer beforehand.
           
           if ~obj.usesFile
               error('File backing disabled on initiation.');
           end
           
           % Make the file close whatever happens, errors or not.
           stream = fopen(obj.filepath, 'r');
           if stream == -1
               error('Cannot open settingsfile to read %s', obj.filepath);
           end 
           raii = onCleanup(@()fclose(stream));
           ReadSettingsFile(stream, @obj.set);
       end %read
       
       function delete(obj)
           % Write settings on destruction.
           
           try
               if obj.destroyAfter
                   if exist(obj.filepath,'file')
                        delete(obj.filepath);
                   end
                   
               % The latter is necessary because 
               % SettingsPath can raise resulting in a partial constructor
               % which DOES trigger the destructor in matlab.
               % Only if obj.filepath is set can it be sure the constructor
               % did not raise. 
               elseif obj.usesFile && ~isempty(obj.filepath)
                   obj.write();
               end
           catch exc
               fprintf('!!Settings destructor: %s', exc.message);
           end %try
       end %delete
   end %methods
end %Settings
