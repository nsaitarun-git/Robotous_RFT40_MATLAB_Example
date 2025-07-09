function offsets = softTare(s,ID_START_FT_DATA_OUTPUT)
disp("Soft Tare...")
COMMAND_START_FT_DATA_OUTPUT          = uint8([0x0B,0,0,0,0,0,0,0]);
COMMAND_STOP_FT_DATA_OUTPUT           = uint8([0x0C,0,0,0,0,0,0,0]);

% Start FT data output
sendCommand(s, COMMAND_START_FT_DATA_OUTPUT);
pause(0.1);

% Initialise
offsets = zeros(1,6);

% Execute callback function when 19 bytes of data is available
configureCallback(s,"byte",19,@(s,evt) bytesCallback(s,evt,ID_START_FT_DATA_OUTPUT,0,offsets))
pause(2); % Aquire data for some time
configureCallback(s,"off")

% Stop FT data output
sendCommand(s, COMMAND_STOP_FT_DATA_OUTPUT);
pause(0.1);

% Calculate offsets
data = s.UserData;
s.UserData = [];

for i = 7:12
    offsets(i-6) = mean(data(:,i));
end

flush(s);
disp("Soft Tare Complete")
end