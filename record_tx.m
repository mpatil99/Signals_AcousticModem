fs = 8192;  % this is the sample rate
r = audiorecorder(fs, 16, 1); % create an audiorecorder object
recordblocking(r, 10);     % record for 2 seconds
p = play(r);   % listen to recording to verify

y_r = double(getaudiodata(r, 'int16'));
save funky_modem_rx.mat y_r x_sync Fs msg_length