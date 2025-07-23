function bytesCallback(s,~,expectedID,flag,offsets)

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
        % Read stored data
        buffer = s.UserData;
        counter = buffer.counter;
        bufferData = buffer.data;

        % Add data
        bufferData(counter,:) = [Fx,Fy,Fz,Tx,Ty,Tz];
        counter = counter + 1;

        % Update data
        buffer.data = bufferData;
        buffer.counter = counter;
        s.UserData = buffer;
        s.Tag = '0';
    end
end
end