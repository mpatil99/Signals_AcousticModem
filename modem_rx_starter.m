close all
clear

test = "funky"; % Replace with "short" or "long" to test that file
should_plot = true; % "Turn plotting on or off

if test == "funky"
%     load("sync_noise.mat")
    f_c = 1000;
%     y_r = x_tx;
%     msg_length = 282;
end

load(strcat(test,"_modem_rx.mat"))

% The received signal includes a bunch of samples from before the
% transmission started so we need discard the samples from before
% the transmission started. 

start_idx = find_start_of_signal(y_r,x_sync);
% start_idx now contains the location in y_r where x_sync begins
% we need to offset by the length of x_sync to only include the signal
% we are interested in

y_t = y_r(start_idx+length(x_sync):end); % y_t is the signal which starts at the beginning of the transmission
x_t = (0:1/8192:(length(y_t)-1)/8192)';

message_length = msg_length * 8 * 100;
x_t = x_t(1:message_length);
y_t = y_t(1:message_length);

if should_plot
    figure
    plot(x_t, y_t);
    title("Received Signal", 'Interpreter', 'Latex');
    xlabel("Time (s)", 'Interpreter', 'Latex');
    ylabel("$y_t(t)$", 'Interpreter', 'Latex');
    saveas(gcf,strcat('images/received_time_',test),'epsc')

    figure
    plot_ft_rad(y_t, Fs);
    title("Received Signal Frequency Plot", 'Interpreter', 'Latex');
    saveas(gcf,strcat('images/received_freq_',test),'epsc')
end
%% Convolve with cos
c = cos(2*pi*f_c/Fs * [0:message_length-1]');
y_c = y_t .* c;

if should_plot
    figure
    plot(x_t, y_c);
    title("Signal convolved with cosine", 'Interpreter', 'Latex');
    xlabel("Time (s)", 'Interpreter', 'Latex');
    ylabel("$y_c(t)$", 'Interpreter', 'Latex');
    saveas(gcf,strcat('images/convolved_time_',test),'epsc')

    figure
    plot_ft_rad(y_c, Fs);
    title("Signal convolved with cosine Frequency Plot", 'Interpreter', 'Latex');
    ylabel('$|Y_c(j\omega)|$', 'Interpreter', 'Latex');
    saveas(gcf,strcat('images/convolved_freq_',test),'epsc')
end
%% Low pass Filter

W = 2*pi*1000;	% set the cutoff frequency to 2 pi * 1000 rads/s
t = (-100:1:99)*(1/Fs);   % create a 200 sample time vector to generate sinc
filter = W/pi*sinc(W/pi*t);
y_filtered = conv(y_c, filter);

% Truncate filtered signal by extra added by convolved cosine length
y_tilde = y_filtered(length(t)/2:end -length(t)/2);

if should_plot
    figure
    plot(t, filter);
    title("Filter", 'Interpreter', 'Latex');
    xlabel("Time (s)", 'Interpreter', 'Latex');
    ylabel("$h_t(t)$", 'Interpreter', 'Latex');
    saveas(gcf,'images/filter_time','epsc')

    figure
    plot_ft_rad(filter, Fs);
    title("Filter Frequency Plot", 'Interpreter', 'Latex');
    ylabel('$|H_t(j\omega)|$', 'Interpreter', 'Latex');
    saveas(gcf,'images/filter_freq','epsc')

    figure
    plot(x_t, y_tilde);
    title("Filtered Signal", 'Interpreter', 'Latex');
    xlabel("Time (s)", 'Interpreter', 'Latex');
    ylabel("$\tilde{y}(t)$", 'Interpreter', 'Latex');
    saveas(gcf,strcat('images/filtered_time_',test),'epsc')

    figure
    plot_ft_rad(y_tilde, Fs);
    title("Filtered Signal Frequency Plot", 'Interpreter', 'Latex');
    ylabel('$|\tilde{Y}(j\omega)|$', 'Interpreter', 'Latex');
    saveas(gcf,strcat('images/filtered_freq_',test),'epsc')
end
%% Clean up
% Normalize data to unit length 
y_norm = y_tilde ./ abs(y_tilde);
% and then shift to 0s and 1s
x_d = (y_norm + 1) ./2;

if should_plot
    figure
    plot(x_t, x_d);
    title("Normalized and Shifted", 'Interpreter', 'Latex');
    xlabel("Time (s)", 'Interpreter', 'Latex');
    ylabel("$x_d(t)$", 'Interpreter', 'Latex');
    saveas(gcf,strcat('images/normalshifted_time_',test),'epsc')

    figure
    plot_ft_rad(x_d, Fs);
    title("Normalized and Shifted Signal Frequency Plot", 'Interpreter', 'Latex');
    ylabel('$|X_d(j\omega)|$', 'Interpreter', 'Latex');
    saveas(gcf,strcat('images/normalshifted_freq_',test),'epsc')
end
%% Decode

% convert to a string assuming that x_d is a vector of 1s and 0s
% representing the decoded bits

% Uncomment to see all letters before downsampling
BitsToString(x_d);
x_d = downsample(x_d, 100, 50);
data = BitsToString(x_d)


