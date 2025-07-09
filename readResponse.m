function resp = readResponse(s, expectedID)
    resp = [];
    timeout = 0.1;  % seconds
    tic;
    while toc < timeout
        if s.NumBytesAvailable >= 19
            b = read(s,1,"uint8");
            if b==0x55
                data = read(s,16,"uint8");
                checksum = read(s,1,"uint8");
                eop = read(s,1,"uint8");
                if eop==0xAA && data(1)==expectedID
                    resp = data;
                    return;
                end
            end
        end
        pause(0.005);
    end
end
