function offsets = softTare(s,ID_START_FT_DATA_OUTPUT)
disp("Soft Tare...")

% Initialise offsets
offsets = zeros(1,6);
dataStruct.data = zeros(2500,6);
dataStruct.counter = 1;
s.UserData =  dataStruct;

COMMAND_START_FT_DATA_OUTPUT          = uint8([0x0B,0,0,0,0,0,0,0]);
COMMAND_STOP_FT_DATA_OUTPUT           = uint8([0x0C,0,0,0,0,0,0,0]);

% Start FT data output
sendCommand(s, COMMAND_START_FT_DATA_OUTPUT);
pause(0.1);

% Execute callback function when 19 bytes of data is available
configureCallback(s,"byte",19,@(s,evt) bytesCallback(s,evt, ...
    ID_START_FT_DATA_OUTPUT,0,offsets))
pause(2); % Aquire data for some time
configureCallback(s,"off")

% Stop FT data output
sendCommand(s, COMMAND_STOP_FT_DATA_OUTPUT);
pause(0.1);

% Read data
dataStruct = s.UserData;
s.UserData = [];
data = dataStruct.data;
indexes = dataStruct.counter;
data = data(1:indexes,:);

% Calculate offsets
offsets = mean(data,1);

flush(s);
disp("Soft Tare Complete")
end