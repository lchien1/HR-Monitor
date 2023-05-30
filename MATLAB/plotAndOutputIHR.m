function plotAndOutputIHR(portIn, Fs, windowWidth)
%plotAndOutputIHR Plot Incoming ECG Waveform and Output Instantaneous Heart
% Rate. Fs in Hz (set to 1/Ticker period) and windowWidth in seconds.

    port = serialport(portIn,9600); % initialize serial port

    datapoints = []; % array of data
    time = []; % array of times
    numPoints = 0; % counting number of points

    % peak arrays and times
    peaks = [];
    peakTimes = [];

    xWidth = Fs*windowWidth; % calculate windowWidth in indices using Fs

    figure % new figure each time, can comment out

    % loop forever, hit ctrl+c in MATLAB window to cancel
    
    onPeak = false; % keep track of whether or not we are above the threshold or not
    maxTime = -1; % keep track of the index of our peak
    maxPeak = -1;
    t1 = -1;
    t2 = -1;
    
    while(true)
        datapoint = str2double(port.readline); % get datapoint, one per line
        
        datapoints = [datapoints,datapoint]; % save datapoint
        time = [time,numPoints*1/(Fs)]; % update time array

        numPoints = numPoints + 1; % increment number of points

        % plot
        % plot(time,datapoints);

        % adjust to window width
        if (xWidth < numPoints)
            xlim([time(numPoints - xWidth) time(numPoints)])
        else
            xlim([0 windowWidth]);
        end
        
        % maintain full y axis range, feel free to adjust
        ylim([0 70000]);

        % Peak detector example: output when value is over 40k. 
        
        % if our signal is above the threshold, update maxIndex, onPeak,
        % calculated accordingly

        if datapoint > 55000
            if ~onPeak
                % new peak
                maxTime = time(end);
                maxPeak = datapoint;
                onPeak = true;
            else
                if datapoint > maxPeak
                    maxTime = time(end);
                    maxPeak = datapoint;
                end
            end

        % if our signal is below the threshold, update onPeak, calculated
        % accordingly, and decide whether or not to plot and calculate IHR
        else
            if onPeak

                plot(maxTime,maxPeak,'o')
                onPeak = false;
                t2 = maxTime;
                if t1 ~= -1
                    1/(t2 - t1)*60
                end
                t1 = t2;


                peaks = [peaks,maxPeak];
                peakTimes = [peakTimes,maxTime];
            end
        end
        
        hold on
        plot(peakTimes,peaks,'Color','red','Marker','o','LineStyle','none');
        hold off
        

        % Code seems to slow down a lot with these on...feel free to try it
        % xlabel('Time (seconds');
        % ylabel('ADC count');
    end
end
