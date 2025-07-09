function sendCommand(s, command)
    checksum = mod(sum(command),256);
    packet = uint8([0x55, command, checksum, 0xAA]);
    write(s, packet, "uint8");
end
