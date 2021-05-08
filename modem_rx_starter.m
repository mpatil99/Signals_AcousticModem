close all
load short_modem_rx.mat

% The received signal includes a bunch of samples from before the
% transmission started so we need discard the samples from before
% the transmission started. 

start_idx = find_start_of_signal(y_r,x_sync);
% start_idx now contains the location in y_r where x_sync begins
% we need to offset by the length of x_sync to only include the signal
% we are interested in
y_t = y_r(start_idx+length(x_sync):end); % y_t is the signal which starts at the beginning of the transmission
% y_t = x_tx %(start_idx+length(x_sync):end);
% plot([1:39660]', y_t);
% % plot([1:39660]', y_t);
% figure
% plot_ft_rad(y_t, Fs);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Put your decoder code here
%%
% figure()
% plot(y_t)

figure()
c = cos(2*pi*f_c/Fs*[0:length(y_t)-1]');
y_tc = y_t .* c;
% plot_ft_rad(y_tc, Fs);
% title("y_tc");
% figure
% plot_ft_rad(y_tc, Fs);
filter = Fs/(2*f_c) * sinc(2*f_c/Fs*[0:length(y_t)-1]');

% figure
plot_ft_rad(filter, Fs);

y_tfil = conv(y_tc, filter);
y_norm = y_tfil ./ abs(y_tfil);
% 
figure
plot(y_tfil)
figure
plot(y_norm(1:4000));
x_d = (y_norm(1:4000) + 1) ./2;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% convert to a string assuming that x_d is a vector of 1s and 0s
% representing the decoded bits
BitsToString(x_d)

