chunk = 2^8;
ydev = 2^7;
xdev = 40;
ycut_under = 8;
ycut_upper = 20;
target = '194';
net1 = load(strcat('CNN', target, '.mat')).net;
wavFiles = dir(strcat('org', target, '\*\*.wav'));
p = length(wavFiles);
list = [0:500:p p];
for k = 1:length(list)-1
    data = zeros(1000);
    blank = 0;
    for i = list(k)+1:list(k+1)
        wavFile = wavFiles(i).name;
        disp(wavFile);
        data = cat(1, data, cellstr(wavFile));
        fileReader = dsp.AudioFileReader( ...
            strcat(wavFiles(i).folder,'\',wavFiles(i).name), ...
            'SamplesPerFrame',chunk);
        x = zeros(ydev-ycut_under-ycut_upper,xdev);
        v = zeros(ydev-ycut_under-ycut_upper,xdev);
        seq = '';
        while ~isDone(fileReader)
            w = fileReader();
            w = w.*hamming(chunk);
            w = abs(fft(w));
            x(:,1) = w(ydev+1+ycut_upper:end-ycut_under);
            x = circshift(x,-1,2);
            e = edge(x(:,end-2:end), 'Prewitt', 0.03);
            v(:,1) = e(:,end-1);
            v = circshift(v,-1,2);
            u = find(~max(v),1,'first');
            blank = blank + 1;
            if blank > 50
                seq = strcat(seq, '/');
                blank = 0;
            end
            if u > 4
                xx = x;
                xx(:,u:end) = min(min(v));
                [~, syl] = max(net1(reshape(xx,[(ydev-ycut_under-ycut_upper)*xdev,1])));
                v(:,1:u) = 0;
                seq = strcat(seq, char(syl+96));
                blank = 0;
            end
        end
        disp(seq)
        data = cat(1, data, cellstr(seq));
    end
    if k < 10
        save(strcat('corpus-edge-', target, '-0', string(k), '.mat'),'data')
    else
        save(strcat('corpus-edge-', target, '-', string(k), '.mat'),'data')
    end
    disp('print:'+string(k))
end
release(fileReader)
disp('complete')