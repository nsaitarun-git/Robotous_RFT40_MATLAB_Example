% This example code is for the Robotous RFT40 Force / Torque sensor.
% Run the code sequentially for stable operation.
%%
clc;clear;close all;
%% Define commands
COMMNAD_READ_MODEL_NAME               = uint8([0x01,0,0,0,0,0,0,0]);
COMMAND_READ_SERIAL_NUMBER            = uint8([0x02,0,0,0,0,0,0,0]);
COMMAND_READ_BAUDRATE                 = uint8([0x07,0,0,0,0,0,0,0]);
COMMAND_START_FT_DATA_OUTPUT          = uint8([0x0B,0,0,0,0,0,0,0]);
COMMAND_STOP_FT_DATA_OUTPUT           = uint8([0x0C,0,0,0,0,0,0,0]);
COMMAND_READ_DATA_OUTPUT_RATE           = uint8([0x10,0,0,0,0,0,0,0]);
COMMAND_READ_COUNT_OVERLOAD_OCCURRENCE  = uint8([0x12,0,0,0,0,0,0,0]);
ID_READ_MODEL_NAME                  = uint8(0x01);
ID_READ_SERIAL_NUMBER               = uint8(0x02);
ID_READ_FIRMWARE_VERSION            = uint8(0x03);
ID_SET_BAUDRATE                     = uint8(0x06);
ID_READ_BAUDRATE                    = uint8(0x07);
ID_SET_FILTER                       = uint8(0x08);
ID_READ_FILTER                      = uint8(0x09);
ID_READ_FT_DATA                     = uint8(0x0A);
ID_START_FT_DATA_OUTPUT             = uint8(0x0B);
ID_SET_DATA_OUTPUT_RATE             = uint8(0x0F);
ID_READ_DATA_OUTPUT_RATE            = uint8(0x10);
ID_READ_COUNT_OVERLOAD_OCCURRENCE   = uint8(0x12);
%% Connect to Sensor
port = "COM15";
baudrate = 115200; % Default baudrate

% Open serial port
s = serialport(port, baudrate);
flush(s);
pause(0.1);
%% Stop FT data output first
sendCommand(s, COMMAND_STOP_FT_DATA_OUTPUT);
pause(0.1);
%% Read model name
sendCommand(s, COMMNAD_READ_MODEL_NAME);
pause(0.1);
resp = readResponse(s, ID_READ_MODEL_NAME);
if ~isempty(resp)
    modelName = char(resp(2:end));
    disp("Model name: " + modelName);
end
%% Read serial number
sendCommand(s, COMMAND_READ_SERIAL_NUMBER);
pause(0.1);
resp = readResponse(s, ID_READ_SERIAL_NUMBER);
if ~isempty(resp)
    serialNum = char(resp(2:end));
    disp("Serial number: " + serialNum);
end
%% Read baudrate
sendCommand(s, COMMAND_READ_BAUDRATE);
pause(0.1);
resp = readResponse(s, ID_READ_BAUDRATE);
if ~isempty(resp)
    disp("Baudrate param1: " + resp(2));
    disp("Baudrate param2: " + resp(3));
end
%% Set data rate
sendCommand(s, commandSetDataOutputRate(100));
pause(0.1);
sendCommand(s,COMMAND_READ_DATA_OUTPUT_RATE)
pause(0.1);
resp = readResponse(s, ID_READ_DATA_OUTPUT_RATE);
if ~isempty(resp)
    disp("Output Rate: " + resp(1) + "," + resp(2));
end
%% Set filter (type=1, parameter)
cmdFilter = [0x08,1,14,0,0,0,0,0]; %Cut-off 1Hz
sendCommand(s, cmdFilter);
pause(0.1);
%% Create timer for plotting data in real-time
hold on;
pltX = plot(0,0);
pltY = plot(0,0);
pltZ = plot(0,0);
xlabel("Number of Samples")
ylabel("Force (N)")
legend(["X","Y","Z"],'Location','northwest')

% Create timer
plotTimer = timer("ExecutionMode","fixedRate","Period",0.1);
plotTimer.TimerFcn = @(plotTimer,evt) plotData(plotTimer,evt,s,pltX,pltY,pltZ);
%% Start Data aquisition

% Hard tare (zero-balance)
% hardTare(s);
% pause(0.1)

% Software tare
offsets = softTare(s,ID_START_FT_DATA_OUTPUT);

% Start FT data output
sendCommand(s, COMMAND_START_FT_DATA_OUTPUT);
pause(0.1);

% Execute callback function when 19 bytes of data is available
tStart = tic; %Use for precise timestamps
configureCallback(s,"byte",19,@(s,evt) bytesCallback(s,evt, ...
    ID_START_FT_DATA_OUTPUT,1,offsets,tStart))
start(plotTimer) % Start timer to plot data

pause(20) % Aquire data for some time

stop(plotTimer) % Stop timer
configureCallback(s,"off") % Disable callback

% Stop FT data output
sendCommand(s, COMMAND_STOP_FT_DATA_OUTPUT);
pause(0.1);

% Copy and save recorded data
data = s.UserData;
data(:,1) = data(:,1) - data(1,1); % Adjust time
names = {'Timestamps','Fx','Fy','Fz',...
    'Tx','Ty','Tz'};
data = array2table(data,"VariableNames",names);
writetable(data,sprintf('Data_%s.csv',string(datetime('today'))))

% Clean up
delete(s)
clear s;
%% Plot aquired data
data = table2array(data);
timeStamps = data(:,1);

% Plot forces
close all;
subplot(2,1,1)
hold on;
plot(timeStamps,data(:,2))
plot(timeStamps,data(:,3))
plot(timeStamps,data(:,4))

xlabel("Time (s)")
ylabel("Force (N)")
legend(["X","Y","Z"])
title("Forces")

% Plot torques
subplot(2,1,2)
hold on;
plot(timeStamps,data(:,5))
plot(timeStamps,data(:,6))
plot(timeStamps,data(:,7))

xlabel("Time (s)")
ylabel("Torque (N/m)")
legend(["X","Y","Z"])
title("Torques")
