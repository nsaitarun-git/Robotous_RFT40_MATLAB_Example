function offsets = softTare(s,ID_START_FT_DATA_OUTPUT)
disp("Soft Tare...")
<<<<<<< HEAD

COMMAND_START_FT_DATA_OUTPUT          = uint8([0x0B,0,0,0,0,0,0,0]);
COMMAND_STOP_FT_DATA_OUTPUT           = uint8([0x0C,0,0,0,0,0,0,0]);

% Initialise offsets
offsets = zeros(1,6);

=======
COMMAND_START_FT_DATA_OUTPUT          = uint8([0x0B,0,0,0,0,0,0,0]);
COMMAND_STOP_FT_DATA_OUTPUT           = uint8([0x0C,0,0,0,0,0,0,0]);

>>>>>>> 762e46dd1eb658fc419dbb7a7c0103a68b0b061a
% Start FT data output
sendCommand(s, COMMAND_START_FT_DATA_OUTPUT);
pause(0.1);

<<<<<<< HEAD
% Execute callback function when 19 bytes of data is available
configureCallback(s,"byte",19,@(s,evt) bytesCallback(s,evt, ...
    ID_START_FT_DATA_OUTPUT,0,offsets))
=======
% Initialise
offsets = zeros(1,6);

% Execute callback function when 19 bytes of data is available
configureCallback(s,"byte",19,@(s,evt) bytesCallback(s,evt,ID_START_FT_DATA_OUTPUT,0,offsets))
>>>>>>> 762e46dd1eb658fc419dbb7a7c0103a68b0b061a
pause(2); % Aquire data for some time
configureCallback(s,"off")

% Stop FT data output
sendCommand(s, COMMAND_STOP_FT_DATA_OUTPUT);
pause(0.1);

% Calculate offsets
data = s.UserData;
s.UserData = [];
<<<<<<< HEAD
offsets = mean(data(:,7:12),1);
=======

for i = 7:12
    offsets(i-6) = mean(data(:,i));
end
>>>>>>> 762e46dd1eb658fc419dbb7a7c0103a68b0b061a

flush(s);
disp("Soft Tare Complete")
end