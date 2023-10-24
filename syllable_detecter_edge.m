function syllable_detecter_edge
chunk=2^8; ydev=2^7; xdev=40; ycut_under=8; ycut_upper=20;
audioReader = audioDeviceReader(44100, chunk, 'Device',' (USB Audio CODEC )');
%deviceWriter = audioDeviceWriter('SampleRate',audioReader.SampleRate);
%scope = dsp.TimeScope( ...
%    'SampleRate',audioReader.SampleRate, ...
%    'TimeSpan',2, ...
%    'BufferLength',audioReader.SampleRate*2, ...
%    'YLimits',[0,2], ...
%    'TimeSpanOverrunAction','Scroll');
net = load('CNN194.mat');
x = zeros(ydev-ycut_under-ycut_upper,xdev); v = zeros(ydev-ycut_under-ycut_upper,xdev); blank = 0;
song_time = 0; before_hour = -1; before_minute = -1;
start_flag = false; song_flag = false;
seq = ''; target = 'dddddd'; versus = 'dddddddd';
disp('Start')
reward_flag = true;
too_flag = false;
while true
    t = audioReader();
    %scope(t)
    w = t.*hamming(chunk);
    w = abs(fft(w));
    x(:,1) = w(ydev+1+ycut_upper:end-ycut_under);
    x = circshift(x,-1,2);
    e = edge(x(:,end-2:end), 'Prewitt', 0.02);
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
        [~, syl] = max(net.net(reshape(xx,[(ydev-ycut_under-ycut_upper)*xdev,1])));
        v(:,1:u) = 0;
        seq = strcat(seq, char(syl+96));
        blank = 0;
        if song_time < 345
            song_time = song_time + 50;
        end
    end
    if song_time > 0
        song_time = song_time - 1;
        if song_time > 200 && song_flag == false
            song_time = 345;
            song_flag = true;
        end
    elseif song_flag == true
        if contains(seq, versus)
            cond = 3;
        elseif contains(seq, target)
            if start_flag == true
                cond = 0;%trigger
                if reward_flag == true
                    py.pyautogui.moveTo(1920, 1079);
                    py.pyautogui.click();
                    py.pyautogui.press('t');
                end
            else
                cond = 1;%trigger but no reward
            end
        else
            cond = 2;%not trigger
        end
        date = string(datetime('now'));
        disp(seq)
        f = fopen('log194.txt', 'a');
        fprintf(f, '%s\t%d\n%s\n', date, cond, seq);
        fclose(f);
        song_flag = false;
    else
        seq = '';
    end
    [after_hour, after_minute, ~] = hms(datetime('now', 'Format', 'HH'));
    if after_hour ~= before_hour
        before_hour = after_hour;
        if 21 < after_hour || after_hour < 8
            disp('e')
            start_flag = false;
            reward_flag = true;
            %versus = 'none';
            too_flag = false;
        else
            disp('s')
            start_flag = true;
        end
    end
    if before_minute ~= after_minute && too_flag == true && start_flag == true
        before_minute = after_minute;
        py.pyautogui.moveTo(1920, 1079);
        py.pyautogui.click();
        py.pyautogui.press('t');
        disp('touch')
    end
end
end