function bytesCallback(s,evt,expectedID,flag,offsets,tStart)
tEnd = toc(tStart); % Timestamp

response = read(s,19,"uint8"); % Read 19 bytes of data

if response(1)==0x55
    data = response(2:17);
    checksum = response(18);
    eop = response(19);

    if eop==0xAA && data(1)==expectedID
        % Convert bytes to force / torques
        [Fx,Fy,Fz,Tx,Ty,Tz] = getFT(data,offsets);

        if flag == 1
            fprintf('%.4f, %.4f, %.4f, %.4f, %.4f, %.4f\n', Fx,Fy,Fz,Tx,Ty,Tz)
        end

        % Save data
        s.Tag = '1';
        buffer = s.UserData;
        buffer(end+1,:) = [tEnd,Fx,Fy,Fz,Tx,Ty,Tz];
        s.UserData = buffer;
        s.Tag = '0';
    end
end
end