function cmd = commandSetDataOutputRate(hz)
    % Map Hz to parameter
    switch hz
        case 200
            parameter = 0;
        case 10
            parameter = 1;
        case 20
            parameter = 2;
        case 50
            parameter = 3;
        case 100
            parameter = 4;
        case 333
            parameter = 6;
        case 500
            parameter = 7;
        case 1000
            parameter = 8;
        otherwise
            error('Invalid hz. Supported: 200, 10, 20, 50, 100, 333, 500, 1000');
    end

    % Build command: first byte 0x17, then parameter, then six zeros
    cmd = uint8([0x17, parameter, 0,0,0,0,0,0]);
end
