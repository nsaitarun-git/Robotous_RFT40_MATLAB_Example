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
%% Initialize plots
maxpoints = 200;

fig = figure(1);
subplot(2,1,1)
hold on;box on;
pltFx = animatedline('Color','r','MaximumNumPoints',maxpoints);
pltFy = animatedline('Color','g','MaximumNumPoints',maxpoints);
pltFz = animatedline('Color','b','MaximumNumPoints',maxpoints);
xlabel("Samples")
ylabel("Force (N)")
title('Press (t) - Zero tare, (s) - Stop')
legend(["X","Y","Z"],'Location','northwest')

subplot(2,1,2)
hold on;box on;
pltTx = animatedline('Color','r','MaximumNumPoints',maxpoints);
pltTy = animatedline('Color','g','MaximumNumPoints',maxpoints);
pltTz = animatedline('Color','b','MaximumNumPoints',maxpoints);
xlabel("Samples")
ylabel("Torque (N/m)")
legend(["X","Y","Z"],'Location','northwest')

% Use a key press callback for zero tare
fig.KeyPressFcn = @(fig,evt) keyCallback(fig,evt);
%% Start Data aquisition

% Hard tare (zero-balance)
% hardTare(s);
% pause(0.1)

% Software tare
offsets = softTare(s,ID_START_FT_DATA_OUTPUT);
tareflag = 0;

% Start FT data output
sendCommand(s, COMMAND_START_FT_DATA_OUTPUT);
pause(0.1);

counter = 1; % Counter for aquired samples
stopflag = 0; % Stop main loop with flag

%================================== Main =================================%
while stopflag == 0

    % Check for zero-tare command
    if tareflag == 1
        % Stop FT data output
        sendCommand(s, COMMAND_STOP_FT_DATA_OUTPUT);
        pause(0.1);

        % Zero tare
        sgtitle("Taring...")
        offsets = softTare(s,ID_START_FT_DATA_OUTPUT);
        tareflag = 0;
        counter = 1;
        sgtitle("Tare Complete")

        % Clear plots
        clearpoints(pltFx)
        clearpoints(pltFy)
        clearpoints(pltFz)
        clearpoints(pltTx)
        clearpoints(pltTy)
        clearpoints(pltTz)

        % Start FT data output
        sendCommand(s, COMMAND_START_FT_DATA_OUTPUT);
        pause(0.1);
    end

    % Read 19 bytes of data
    flush(s);
    response = read(s,19,"uint8");

    if response(1)==0x55
        data = response(2:17);
        checksum = response(18);
        eop = response(19);

        if eop==0xAA && data(1) == ID_START_FT_DATA_OUTPUT

            % Convert bytes to force / torques
            [Fx,Fy,Fz,Tx,Ty,Tz] = getFT(data,offsets);

            % Display data
            msg = sprintf('Fx:%.3f, Fy:%.3f, Fz:%.3f, Tx:%.2f, Ty:%.3f, Tz:%.3f', ...
                Fx,Fy,Fz,Tx,Ty,Tz);
            sgtitle(msg)
            disp(msg)

            % Add data to plots
            addpoints(pltFx,counter,Fx)
            addpoints(pltFy,counter,Fy)
            addpoints(pltFz,counter,Fz)
            addpoints(pltTx,counter,Tx)
            addpoints(pltTy,counter,Ty)
            addpoints(pltTz,counter,Tz)
            drawnow;
            counter = counter + 1;
        end
    end
end

% Stop FT data output
sendCommand(s, COMMAND_STOP_FT_DATA_OUTPUT);
pause(0.1);

% Clean up
delete(s)
clear s;
sgtitle("Stopped")
%% Callback
function keyCallback(src,evt)
% If 't' is pressed, zero-tare
if evt.Character == 't'
    tareflag = 1;
    assignin("base","tareflag",tareflag)
elseif evt.Character == 's'
    stopflag = 1;
    assignin("base","stopflag",stopflag)
end
end