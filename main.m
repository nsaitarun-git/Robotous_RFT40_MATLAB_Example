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
plotTimer = timer("ExecutionMode","fixedRate","Period",0.2);
plotTimer.TimerFcn = @(plotTimer,evt) plotData(plotTimer,evt,s,pltX,pltY,pltZ);
%% Start Data aquisition

% Hard tare (zero-balance)
% hardTare(s);
% pause(0.1)

% Software tare
offsets = softTare(s,ID_START_FT_DATA_OUTPUT);

% Pre-allocate data buffer
buffsize = 4200;
dataStruct.counter = 1;
dataStruct.data = zeros(buffsize,6);
s.UserData =  dataStruct;

% Start FT data output
sendCommand(s, COMMAND_START_FT_DATA_OUTPUT);
pause(0.1);
tStart = tic; % Start timing

% Execute callback function when 19 bytes of data is available
configureCallback(s,"byte",19,@(s,evt) bytesCallback(s,evt, ...
    ID_START_FT_DATA_OUTPUT,1,offsets))
start(plotTimer) % Start timer to plot data

pause(20) % Aquire data for some time

configureCallback(s,"off") % Disable callback
tEnd = toc(tStart); % Stop timing
stop(plotTimer) % Stop timer

% Stop FT data output
sendCommand(s, COMMAND_STOP_FT_DATA_OUTPUT);
pause(0.1);

% Copy and save recorded data
dataStruct = s.UserData;
s.UserData = [];
data = dataStruct.data;
indexes = dataStruct.counter;
data = data(1:indexes-1,:);

% Time data
time = linspace(0,tEnd,size(data,1));
data = [time' data];
names = {'Time','Fx','Fy','Fz',...
    'Tx','Ty','Tz'};
dataTable = array2table(data,"VariableNames",names);
writetable(dataTable,sprintf('Data_%s.csv',string(datetime('today'))))

% Clean up
delete(s)
clear s;
%% Plot aquired data

% Plot forces
close all;
subplot(2,1,1)
hold on;
plot(time,data(:,2))
plot(time,data(:,3))
plot(time,data(:,4))

xlabel("Time (s)")
ylabel("Force (N)")
legend(["X","Y","Z"])
title("Forces")

% Plot torques
subplot(2,1,2)
hold on;
plot(time,data(:,5))
plot(time,data(:,6))
plot(time,data(:,7))

xlabel("Time (s)")
ylabel("Torque (N/m)")
legend(["X","Y","Z"])
title("Torques")
