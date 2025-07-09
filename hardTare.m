function hardTare(s)
cmd = uint8([0x21,0x01,0,0,0,0,0,0]);
sendCommand(s, cmd);
end
