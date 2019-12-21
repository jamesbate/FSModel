% Version 1.0: 10 may 2019
%       Test the API with read, write, keys, content
%       More strict than a general MySettings has to be as it tests
%       actual file interaction without closing the objects. 
%       So be aware that this is made for this specific MySettings
%   See MySettings itself for the requirements.
% Version 1.1: 12 may 2019
%       Change naming conventions with the changes in Settings
% Version 1.2: 23 may 2019
%   Change the tests as the settings go buffer instead of file
% Version 1.3: 31 may 2019
%   Add test for remove. 
%   NB: later, make all errors have ids and test on them.
%       branch complete testing is important, but time consuming
%       

classdef MySettingsTest < matlab.unittest.TestCase
% Make sure the settings.m file is within MATLAB PATH.
    
    methods  (Test)
        
    function testBasicUsage(obj)
        % The common and simple use case of just set/get
        
        % If there is a previous version, fine. Only get/set is tested.
        s = MySettings('test_settings');
        s.set('Hello', 'World!');        
        obj.verifyEqual(s.get('Hello'), 'World!');
        s.set('Setting', 'Value');
        obj.verifyEqual(s.get('Setting'), 'Value');
        obj.verifyEqual(s.get('Hello'), 'World!');
    end %testBasicUsage
    
    function testDestroy(obj)
        % Make sure file handling is done well on a constr/destr level.
        % This is not very necessary for everyday life, but very 
        % much so for these tests to be valid. 
        
        s = MySettings('test_settings');
        s.destroyAfter = true;
        path = s.filepath;
        obj.verifyTrue(exist(path, 'file') ~= 0);
        delete(s);
        obj.verifyTrue(exist(path, 'file') == 0);
        
        w = MySettings('test_settings', false);
        obj.verifyTrue(isempty(w.filepath));
    end
    
    function testBaseFunctionality(obj)
        % Extends BasicUsage to include getKeys and overwrites.
             
        s = MySettings('test_content', false);
        obj.verifyTrue(isempty(s.getKeys));
        s.set('1', 'value');
        s.set('2', 'value');
        s.set('three', 'other');
        s.set('2', 'overwrite');
        obj.verifyEqual(length(s.getKeys), 3);
        
        expectKeys = {'1', '2', 'three'};
        expectVals = {'value', 'overwrite', 'other'};
        
        keys = s.getKeys();
        obj.verifyEqual(length(keys), length(expectKeys));
        for ind = 1:length(keys)
            obj.verifyEqual(keys{ind}, expectKeys{ind});
        end
            
        [kk, vv] = s.getContent();
        obj.verifyEqual(length(keys), length(expectKeys));
        for ind = 1:length(keys)
            obj.verifyEqual(keys{ind}, expectKeys{ind});
        end
        obj.verifyEqual(length(keys), length(kk));
        for ind = 1:length(keys)
            obj.verifyEqual(keys{ind}, kk{ind});
        end
        obj.verifyEqual(length(vv), length(expectVals));
        for ind = 1:length(vv)
            obj.verifyEqual(vv{ind}, expectVals{ind});
        end
        
    end
        
    function testReadWrite(obj)
        % Test a read-write cycle across settings which share name.
        % This is not good practise for normal use, 
        % simply because writing upon destruction means arbitrary 
        % order if both objects go out of scope at the same time.
        % If double deletion of files is not taken care of, this warns.
        s1 = MySettings('test_FileSharing');
        s1.destroyAfter = true;
        delete(s1);
        s1 = MySettings('test_FileSharing');
        s2 = MySettings('test_FileSharing');
        s1.destroyAfter = true;
        s2.destroyAfter = true;
        s1.set('Haha', ':)');
        s1.write();
        s2.read();
        obj.verifyEqual(s2.get('Haha'), ':)');
    end
    
    function testMultiReadWrite(obj)
        % There was a bug 24/5 where settings were not properly
        % written on newlines, but all concatenated on a single one
        % because some matlab functionality removes whitspaces,
        % so this has now a test to verify it works as it should
        
        s1 = MySettings('test_file_sharing');
        s1.destroyAfter = true;
        delete(s1);
        s1 = MySettings('test_file_sharing');
        s2 = MySettings('test_file_sharing');
        s1.destroyAfter = true;
        s2.destroyAfter = true;
        
        s1.set('abc', 'value1');
        s1.set('def', 'value2');
        s1.set('ghi', 'value3');
        s1.write();
        s2.read();
        obj.verifyEqual(length(s2.getKeys), 3);
    end %testMultiReadwrite    
    
    function testNames(obj)
        % Tests all codepaths of the constructor and MySettingsPath.m
        
        % Destroy remnants otherwise testing is futile.
        s = MySettings('nonexistent_tests');
        s.destroyAfter = true;
        delete(s);
        
        % Creation is tested by testDestroy,
        % The focus here is on illegal or difficult names for MySettingsPath.m
        obj.verifyError(@()MySettings('illegal/'), 'Setting:Reserved');
        obj.verifyError(@()MySettings('illegal\'), 'Setting:Reserved');
        obj.verifyError(@()MySettings('illegal.txt'), 'Setting:Reserved');
        obj.verifyError(@()MySettings('i llegal'), 'Setting:Reserved');
        obj.verifyError(@()MySettings(''), 'Setting:Reserved');
        
        % Without file backing there is no problematic names ever.
        s = MySettings('', false);
        s = MySettings('legal_-+=£$%^)(');
        s.destroyAfter = true;
        
    end
        
    function testFormat(obj)
        % Make sure all reserved characters in names & keys
        % raise the correct errors and that other annoying corner cases
        % are dealt with correctly.
        
        % Illegal keys
        % Please note that | is the separation character so it is legal
        s = MySettings('test_reserved_chars');
        s.destroyAfter = true;
        delete(s);
        s = MySettings('test_reserved_chars');
        s.destroyAfter = true;
        obj.verifyError(@()s.set('illegal|', 'v'), 'Setting:Reserved');
        obj.verifyError(@()s.set(sprintf('illegal\nd'), 'v'), 'Setting:Reserved');
        obj.verifyError(@()s.set('fine', sprintf('ddd\nd')), 'Setting:Reserved');
        obj.verifyError(@()s.set('', 'v'), 'Setting:Reserved');
        obj.verifyTrue(isempty(s.getKeys()));
        
        % Annoying key/value
        key = strcat('it_is_stupid_to_use_very_long_setting_keys_', ...
                     'because_you_will_have_to_somehow_generate_or_', ...
                     'remember_them,_but_you_are_free_to_enter_an_', ...
                     'essay_if_you_like');
        for blah = 1:5
            key = strcat(key, key);
        end
        s.set(key, strcat(key, 'value'));
        obj.verifyEqual(s.get(key), strcat(key, 'value'));
        s.write();
        s.read();
        obj.verifyEqual(s.get(key), strcat(key, 'value'));
        
        % Use some problematic cases simultaneously.
        % Like: multidimensional problems
        % | is part of the formatting in the settings file
        % \ is linked to escape characters and hence paths are not simple.
        % whitespace is silently ignored at the ends, kept in the middle.
        % An empty value is actually not problematic unlike an empty key
        %   which is an ideology issue, not an algorithm issue. 
        %   The empty key can be allowed, but it is really uncomfortable.
        s.set(' H\\\a ha/\ ', '  a value \._.|  ');
        s.set('path', s.filepath);
        s.set(sprintf('£\n'), sprintf('value\n'));
        s.set('empty', '');
        
        obj.verifyEqual(s.get('H\\\a ha/\'), 'a value \._.|');
        obj.verifyEqual(s.get('path'), s.filepath);
        obj.verifyEqual(s.get('£'), 'value');
        obj.verifyEqual(s.get('empty'), '');
    end %testReserved
    
    function testTypes(obj)
        % Test what happens when you give integers etc. as value
        
        s = MySettings('test_settings', false);
        s.set('key', 15);
        obj.verifyFalse(isnumeric(s.get('key')));
        obj.verifyEqual(s.get('key'), '15');
        s.set('key', 15.1);
        obj.verifyFalse(isnumeric(s.get('key')));
        obj.verifyLessThan(abs(str2double(s.get('key')) - 15.1), 1e-6);
    end %testTypes
    
    function testDelete(obj)
       % Added 31/5/19 
        
       s = MySettings('test_settings');
       s.destroyAfter = true;
       delete(s);
       s = MySettings('test_settings');
       
       % Write to the file
       s.set('hello', 'world');
       obj.verifyEqual(s.get('hello'), 'world');
       s.write();
       s.remove('hello');
       obj.verifyError(@()s.get('hello'), 'Setting:NoMatch');
       s.read();
       obj.verifyEqual(s.get('hello'), 'world');
       s.remove('hello');
       obj.verifyError(@()s.get('hello'), 'Setting:NoMatch');
       delete(s);
       
       % Read it in and make sure it is gone.
       s = MySettings('test_settings');
       s.destroyAfter = true;
       obj.verifyError(@()s.get('hello'), 'Setting:NoMatch');
       
    end
    
    end %methods
end %MySettingsTest
