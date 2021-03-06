%vibrotactile speech training. called by VT_speechTraining.m
%PSM pmalone333@gmail.com

function VT_speechTraining_generalization_experiment(name, exptdesign, stimType)

    rand('twister',sum(100*clock))

    %open a screen and display instructions
    screens = Screen('Screens');
    screenNumber = min(screens);

    %open window with default settings:
    [w windowRect] = Screen('OpenWindow', screenNumber,[128 128 128]);
    
    %set font size
    Screen('TextSize',w, 24);

    %load images
    fixationImage = imread(exptdesign.fixationImage);
    blankImage = imread(exptdesign.blankImage);
    fixationTexture=Screen('MakeTexture', w, double(fixationImage));
    blankTexture=Screen('MakeTexture', w, double(blankImage));

    %display experiment instructions
%     drawAndCenterText(w, ['Please review instructions \n'...
%         'Press any key to continue'],1)

    drawAndCenterText(w,'\nVibrotactile speech testing.\n\n\nPress any key to continue.',0)
    KbWait
    
    

    level = exptdesign.training.level;
    

    for iBlock=1:exptdesign.numSessions %how many blocks to run this training session
%         if iBlock==1 || iBlock ==2 
%             drawAndCenterText(w,['Testing Block #' num2str(iBlock) ' of ' num2str(exptdesign.numSessions) '\n\n\n\n'...
%                 'This block will use the words that you trained on.\n\n\n'...
%                 'Press any key to continue'],0);
%         else
%             drawAndCenterText(w,['Testing Block #' num2str(iBlock) ' of ' num2str(exptdesign.numSessions) '\n\n\n\n'...
%                 'This block will use the NEW words that you have never felt before.\n\n' ... 
%                 'Good luck!\n\n\n'...
%                 'Press any key to continue'],0);
%         end

        drawAndCenterText(w,['Testing Block #' num2str(iBlock) ' of ' num2str(exptdesign.numSessions) '\n\n\n\n'...
            'This block will use the NEW words that you have never felt before.\n\n' ...
            'Good luck!\n\n\n'...
            'Press any key to continue'],0);
        while KbCheck; end % Wait until all keys are released.
        KbWait
        
%         if iBlock==1 || iBlock==2
%             if stimType == 1
%                 load('stimuli_GU_openSet.mat');
%             elseif stimType == 2
%                 load('stimuli_FB_openSet.mat');
%             end
%         elseif iBlock==4 || iBlock==3
%             if stimType == 1
%                 load('stimuli_GU_generalization_openSet.mat');
%             elseif stimType == 2
%                 load('stimuli_FB_generalization_openSet.mat');
%             end
%         end

        if stimType == 1
            load('stimuli_Gen2_generalization_openSet.mat');
        elseif stimType == 2
            load('stimuli_FB_generalization_openSet.mat');
        end
        
        stimuli = stim;
        labels = label;
        stimOrder = randperm(length(stimuli))';
        stimuli = stimuli(stimOrder,:);
        labels = labels(stimOrder,:);

        for iTrial=1:exptdesign.numTrialsPerSession
            
            %get start sample and num_samples for each word in pair
            target = labels{iTrial,1};

            %draw fixation
            Screen('DrawTexture', w, fixationTexture);
            [FixationVBLTimestamp FixationOnsetTime FixationFlipTimestamp FixationMissed] = Screen('Flip',w);


  
            %play stimulus   target=worda worda wordb 
            eventFile = stimuli{iTrial,1};
            piezoDriverGen2('loadGesture',eventFile);
            piezoDriverGen2('start');
            
           
            while KbCheck; end % Wait until all keys are released.
            clear sResp
            FlushEvents
            responseStartTime = GetSecs;
            sResp = GetEchoString(w,'Please type the word you felt, followed by the Enter key:',25, 400, [], [255 255 255]);
            responseFinishedTime = GetSecs;
            
            %get confidence 
            drawAndCenterText(w, ['How correct do you think your response is? \n\n Select a number between 1 and 7. \n\n 1=not correct at all\n 2=16% correct\n 3=32% correct\n 4=48% correct\n 5=64% correct\n 6=80% correct\n 7=100% correct'], 0);
            while KbCheck; end % Wait until all keys are released.
            while 1
                % Check the state of the keyboard.
                [ keyIsDown, seconds, keyCode ] = KbCheck;
                if keyIsDown
                    confResp = KbName(keyCode);
                    break
                end
            end

            %score the answer
            accuracy=0;
            if strcmp(sResp,target)
                accuracy=1;
                drawAndCenterText(w, ['Correct!\n\nThe correct answer was ' target '.\n\n Press any key to feel ' target ' again, \n\n or press Enter to continue to the next trial.'], 0)
%                 while KbCheck; end % Wait until all keys are released.
%                 KbWait
            else
                drawAndCenterText(w, ['Incorrect.\n\nThe correct answer was ' target '.\n\n Press any key to feel ' target ' again, \n\n or press Enter to continue to the next trial.'], 0)
%                 while KbCheck; end % Wait until all keys are released.
%                 KbWait
            end
            
            while KbCheck; end % Wait until all keys are released.
            while 1
                % Check the state of the keyboard.
                [ keyIsDown, seconds, keyCode ] = KbCheck;
                if keyIsDown
                    fbResp = KbName(keyCode);
                    if strcmp(fbResp,'return'), break; end
                    eventFile = stimuli{iTrial,1};
                    piezoDriverGen2('loadGesture',eventFile);
                    piezoDriverGen2('start');
                    WaitSecs(1)
                    break
                end
            end
    
            drawAndCenterText(w, ['Press any key to continue.'], 0)
            while KbCheck; end % Wait until all keys are released.
            KbWait

            %record parameters for the trial
            trialOutput(iBlock).responseStartTime(iTrial)=responseStartTime;
            trialOutput(iBlock).responseFinishedTime(iTrial)=responseFinishedTime;
            trialOutput(iBlock).RT(iTrial)=responseFinishedTime-responseStartTime;
            trialOutput(iBlock).sResp{iTrial}=sResp;
            trialOutput(iBlock).accuracy(iTrial)=accuracy;
            trialOutput(iBlock).target{iTrial}=target;
            trialOutput(iBlock).stim{iTrial}=stimuli{iTrial};
            trialOutput(iBlock).confResp{iTrial}=confResp;
        end


            
            %tell subject how they did on last trial
            if iTrial==exptdesign.numTrialsPerSession && iBlock < exptdesign.numSessions
                accuracyForBlock=mean(trialOutput(iBlock).accuracy);
                drawAndCenterText(w, ['Your accuracy was ' num2str(round(accuracyForBlock.*100)) '%\n\n\n'...
                    'Press any key to continue' ],0)
                while KbCheck; end % Wait until all keys are released.
                KbWait

            elseif iTrial==exptdesign.numTrialsPerSession && iBlock == exptdesign.numSessions
                %calculate accuracy
                accuracyForBlock=mean(trialOutput(iBlock).accuracy);
                drawAndCenterText(w, ['Your accuracy was ' num2str(round(accuracyForBlock.*100)) '%\n\n\n'...
                    'You have completed this training session.  Thank you for your work! Please press enter.' ],0) % was a 1
                %KbWait(1)
                while KbCheck; end % Wait until all keys are released.
                KbWait
                Screen('CloseAll')
            end
            
            %record parameters for the block
            trialOutput(iBlock).order=stimOrder;
            trialOutput(iBlock).stimuli=stimuli;
            trialOutput(iBlock).labels=labels;
            trialOutput(iBlock).accuracyForBlock=accuracyForBlock;

            
            clear correctResp;
            
            %save the session data in the data directory
            save(['./data/' exptdesign.subNumber '/' datestr(now, 'yyyymmdd_HHMM') '-' exptdesign.subName '_block' num2str(iBlock) '.mat'], 'trialOutput', 'exptdesign');
            
    end
        
    %if accuracyForBlock>exptdesign.accuracyCutoff, level=level+1; end
    

   
    
    %save the history data (stimuli, last level passed
    history = [exptdesign.training.history];
    exptdesign.training.history = history;
    %exptdesign.training.stimType = stimType;
    save(['./history/SUBJ' exptdesign.subNumber 'training.mat'], 'history', 'level', 'stimType');

    

    ShowCursor;
end

function drawAndCenterText(window,message, wait)
if wait == 1
    [nx, ny, bbox] = DrawFormattedText(window, message, 'center', 'center', 1);
    Screen('Flip',window);
    KbPressWait(1);
else
    % Now horizontally and vertically centered:
    [nx, ny, bbox] = DrawFormattedText(window, message, 'center', 'center', 1);
    Screen('Flip',window);
end
end

function numericalanswer = getResponseMouse(waitTime)

%Wait for a response
numericalanswer = -1;
mousePressed = 0;
startWaiting=clock;
while etime(clock,startWaiting) < waitTime && mousePressed == 0
    %check to see if a button is pressed
    [x,y,buttons] = GetMouse();
    if (~buttons(1) && ~buttons(3))
        continue;
    else
        if buttons(1)
            numericalanswer = 1;
        elseif buttons(3)
            numericalanswer = 2;
        else
            numericalanswer = 0;
        end
        if numericalanswer ~= -1
            %stop checking for a button press
            mousePressed = 1;
        end
    end

end
if numericalanswer == -1
    numericalanswer =0;
end
end
