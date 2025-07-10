function bytesCallback(s,evt,expectedID,flag,offsets)
<<<<<<< HEAD
DF = 50;    % force scale
DT = 1000;  % torque scale

response = read(s,19,"uint8"); % Read 19 bytes of data
=======

response = read(s,19,"uint8"); % Read 19 bytes of data
DF = 50;    % force scale
DT = 1000;  % torque scale
>>>>>>> 762e46dd1eb658fc419dbb7a7c0103a68b0b061a

if response(1)==0x55
    data = response(2:17);
    checksum = response(18);
    eop = response(19);
<<<<<<< HEAD

    if eop==0xAA && data(1)==expectedID
=======
    if eop==0xAA && data(1)==expectedID

>>>>>>> 762e46dd1eb658fc419dbb7a7c0103a68b0b061a
        response = data;

        % Combine high and low bytes, then cast to int16
        Fx = double(typecast(uint16(bitor(bitshift(uint16(response(2)),8), uint16(response(3)))), 'int16')) / DF - offsets(1);
        Fy = double(typecast(uint16(bitor(bitshift(uint16(response(4)),8), uint16(response(5)))), 'int16')) / DF - offsets(2);
        Fz = double(typecast(uint16(bitor(bitshift(uint16(response(6)),8), uint16(response(7)))), 'int16')) / DF - offsets(3);

        Tx = double(typecast(uint16(bitor(bitshift(uint16(response(8)),8), uint16(response(9)))), 'int16')) / DT - offsets(4);
        Ty = double(typecast(uint16(bitor(bitshift(uint16(response(10)),8), uint16(response(11)))), 'int16')) / DT - offsets(5);
        Tz = double(typecast(uint16(bitor(bitshift(uint16(response(12)),8), uint16(response(13)))), 'int16')) / DT - offsets(6);

        if flag == 1
            fprintf('%.4f, %.4f, %.4f, %.4f, %.4f, %.4f\n', Fx,Fy,Fz,Tx,Ty,Tz)
        end

        % Save data
<<<<<<< HEAD
        s.Tag = '1';
        buffer = s.UserData;
        buffer(end+1,:) = [datevec(evt.AbsTime),Fx,Fy,Fz,Tx,Ty,Tz];
        s.UserData = buffer;
        s.Tag = '0';
=======
        buffer = s.UserData;
        buffer(end+1,:) = [datevec(evt.AbsTime),Fx,Fy,Fz,Tx,Ty,Tz];
        s.UserData = buffer;
>>>>>>> 762e46dd1eb658fc419dbb7a7c0103a68b0b061a
    end
end
end