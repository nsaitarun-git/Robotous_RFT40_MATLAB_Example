function hardTare(s)
cmd = uint8([0x21,1,0,0,0,0,0,0]);
sendCommand(s, cmd);
end
