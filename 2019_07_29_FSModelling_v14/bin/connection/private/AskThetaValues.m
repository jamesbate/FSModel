function result = AskThetaValues(settings)
% Return the theta values where to evaluate.
% Return -1 if the dialog was terminated.


finished = false;
title = 'Angle Selection';
while ~finished
    % Step 1: ask
    mini = settings.get('ThetaMin', '0');
    step = settings.get('ThetaStep', '2');
    maxi = settings.get('ThetaMax', '70');
    input = inputdlg({'Minimum polar angle (deg)', ...
                      'Stepsize (deg)', ...
                      'Maximum polar angle (deg)'}, ...
                     title, ...
                     [1 50], ...
                     {mini, step, maxi});

    if isempty(input)
        result = -1;
        return
    end
    settings.set('ThetaMin', input{1});
    settings.set('ThetaStep', input{2});
    settings.set('ThetaMax', input{3});
    
    % Step 2: Convert
    mini = str2double(input{1});
    step = str2double(input{2});
    maxi = str2double(input{3});
    
    if isnan(mini)
        title = 'Check minimum';
    elseif isnan(maxi)
        title = 'Check maximum';
    elseif isnan(step)
        title = 'Check steps';
        
    % Step 3: Evaluate
    else
        result = (mini:step:maxi);
        if ~isempty(result)
            finished = true;
        % think: mini 2, step -1, maxi 70
        else
            title = 'No angles at all';
        end
    end
    
end %while
end %AskThetaValues
