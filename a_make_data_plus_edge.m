chunk = 2^8;
ydev = 2^7;
xdev = 40;
ycut_under = 8;
ycut_upper = 20;
sequences = 2000;
limit = 20000;
data = zeros(limit,(ydev-ycut_under-ycut_upper)*xdev);
xs = 1;
target = '194';
wavFiles = dir(strcat('red',target,'\*\*.wav'));
disp(length(wavFiles))
p = randperm(length(wavFiles),sequences);
%p = 1:23;
Vname = {'label', 'onset_s', 'offset_s'};
t = linspace(0,chunk*50000/44100,50000);
x = zeros(ydev-ycut_under-ycut_upper,xdev);
v = zeros(ydev-ycut_under-ycut_upper,xdev);
for i = 1:sequences
    disp(wavFiles(p(i)).name)
    fileReader = dsp.AudioFileReader(strcat(wavFiles(p(i)).folder,'\',wavFiles(p(i)).name), 'SamplesPerFrame',chunk);
    if xs <= limit
        %csv_data = strings(500, 3);
        j = 1-xdev;
        %k = 1;
        while ~isDone(fileReader)
            j = j + 1;
            w = fileReader();
            w = w.*hamming(chunk);
            w = abs(fft(w));
            x(:,1) = w(ydev+1+ycut_upper:end-ycut_under);
            x = circshift(x,-1,2);
            e = edge(x(:,end-2:end), 'Prewitt', 0.02);
            v(:,1) = e(:,end-1);
            v = circshift(v,-1,2);
            u = find(~max(v),1,'first');
            if false
                f = figure(1);
                im = imagesc(reshape(v, [ydev-ycut_under-ycut_upper,xdev]));
                im.CDataMapping = 'scaled';
                axis off
                drawnow
                f = figure(2);
                im = imagesc(reshape(rescale(x), [ydev-ycut_under-ycut_upper,xdev]),[0,0.8]);
                im.CDataMapping = 'scaled';
                axis off
                drawnow
            end
            if u > 4
                if j > 0
                    xx = x;
                    xx(:,u:end) = min(min(v));
                    %xx(:,u:end) = rand(ydev-ycut_under-ycut_upper,xdev-u+1)/1000;
                    %xx(:,u:end) = xx(:,u:end).*exp(linspace(0,-20,xdev-u+1));
                    data(xs,:) = reshape(xx,[(ydev-ycut_under-ycut_upper)*xdev,1]);
                    %csv_data(k,:) = ['x', string(t(j)), string(t(j+u))];
                    v(:,1:u) = 0;
                    xs = xs + 1;
                    %k = k + 1;
                end
            end
        end
        %csv_data(k:end,:) = [];
        %writematrix([Vname;csv_data], strcat("tweetynet\edge_online\default_",wavFiles(p(i)).name,".csv"))
    else
        break
    end
end
disp(xs-1)
data(randperm(size(data,1),size(data,1)-limit),:)=[];
data(xs:end,:) = [];
save(strcat('data',target,'.mat'),'data')
release(fileReader)
disp('complete')