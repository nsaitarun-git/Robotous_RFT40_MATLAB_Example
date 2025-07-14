function [Fx,Fy,Fz,Tx,Ty,Tz] = getFT(response,offsets)
DF = 50;    % force scale
DT = 1000;  % torque scale

% Combine high and low bytes, then cast to int16
Fx = double(typecast(uint16(bitor(bitshift(uint16(response(2)),8), uint16(response(3)))), 'int16')) / DF - offsets(1);
Fy = double(typecast(uint16(bitor(bitshift(uint16(response(4)),8), uint16(response(5)))), 'int16')) / DF - offsets(2);
Fz = double(typecast(uint16(bitor(bitshift(uint16(response(6)),8), uint16(response(7)))), 'int16')) / DF - offsets(3);

Tx = double(typecast(uint16(bitor(bitshift(uint16(response(8)),8), uint16(response(9)))), 'int16')) / DT - offsets(4);
Ty = double(typecast(uint16(bitor(bitshift(uint16(response(10)),8), uint16(response(11)))), 'int16')) / DT - offsets(5);
Tz = double(typecast(uint16(bitor(bitshift(uint16(response(12)),8), uint16(response(13)))), 'int16')) / DT - offsets(6);
end