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
subplot(2,1,1)
hold on;box on;
pltFx = animatedline('Color','r','MaximumNumPoints',1000);
pltFy = animatedline('Color','g','MaximumNumPoints',1000);
pltFz = animatedline('Color','b','MaximumNumPoints',1000);
xlabel("Samples")
ylabel("Force (N)")
legend(["X","Y","Z"],'Location','northwest')

subplot(2,1,2)
hold on;box on;
pltTx = animatedline('Color','r','MaximumNumPoints',1000);
pltTy = animatedline('Color','g','MaximumNumPoints',1000);
pltTz = animatedline('Color','b','MaximumNumPoints',1000);
xlabel("Samples")
ylabel("Torque (N/m)")
legend(["X","Y","Z"],'Location','northwest')
%% Start Data aquisition

% Hard tare (zero-balance)
% hardTare(s);
% pause(0.1)

% Software tare
offsets = softTare(s,ID_START_FT_DATA_OUTPUT);

% Start FT data output
sendCommand(s, COMMAND_START_FT_DATA_OUTPUT);
pause(0.1);

cnt = 1;
while true
    response = read(s,19,"uint8"); % Read 19 bytes of data

    if response(1)==0x55
        data = response(2:17);
        checksum = response(18);
        eop = response(19);

        if eop==0xAA && data(1) == ID_START_FT_DATA_OUTPUT

            % Convert bytes to force / torques
            [Fx,Fy,Fz,Tx,Ty,Tz] = getFT(data,offsets);

            if flag == 1
                fprintf('%.4f, %.4f, %.4f, %.4f, %.4f, %.4f\n', Fx,Fy,Fz,Tx,Ty,Tz)
            end

            % Add data to plots
            addpoints(pltFx,cnt,Fx)
            addpoints(pltFy,cnt,Fy)
            addpoints(pltFz,cnt,Fz)
            addpoints(pltTx,cnt,Tx)
            addpoints(pltTy,cnt,Ty)
            addpoints(pltTz,cnt,Tz)
            cnt = cnt + 1;
        end
    end
end

%% Stop FT data output
sendCommand(s, COMMAND_STOP_FT_DATA_OUTPUT);
pause(0.1);

% Clean up
delete(s)
clear s;
