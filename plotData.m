function plotData(src,~,s,pltX,pltY,pltZ)
try
    % Read data only when its not being written
    if s.Tag == '0'
        % Read available data
        data = s.UserData(:,2:7);
        samples = linspace(0,numel(data(:,3)),numel(data(:,3)));

        % Add data to plots
        set(pltX,'XData',samples)
        set(pltX,'YData',data(:,1))
        set(pltY,'XData',samples)
        set(pltY,'YData',data(:,2))
        set(pltZ,'XData',samples)
        set(pltZ,'YData',data(:,3))
    end
catch
end
end