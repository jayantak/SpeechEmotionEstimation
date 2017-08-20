clear all;clc
[stimulus, rate] = wavread('filename');
filename = input('filename = ','s');
a = textread(filename);

epoch = input('total epoch in msec = ');
prestim = input('prestim time in msec (ignoring sign) = ');
post = epoch -prestim;

n = length(a);
fs = n*1000/epoch;
time = -prestim/1000 :1/fs: post/1000 -1/fs;
zerotime = -prestim/1000:1/fs:0-1/fs ;

detrend = a - mean(a(1:size(zerotime)));

FFTstart = input('FFT start time = ')/1000;
FFTend = input('FFT end time = ')/1000;

[trash position1] = min(abs(time-FFTstart));
[trash position2] = min(abs(time-FFTend));

sample = (a(position1:position2))';

lin = 0:1/fs:0.01-1/fs;
win = 1*length(lin);
window = hann(win);
env = window(1:round((length(window))/2));
vne = fliplr(env');
sample(1:length(env)) = env'.*sample(1:length(env));
sample(length(sample)-length(vne)+1:length(sample)) = vne.*sample(length(sample)-length(vne)+1:length(sample));
zero = zeros(1,1024);
abc = [zero sample zero];


spect = abs(fft(abc));

amp=spect;
n=length(spect);
freq=fs/n.*(1:n);
a=amp(1:(n/2));
f=freq(1:(n/2));
f0 = f(80:120);

subplot(2,1,1),bar(f,a,'r'),xlim([0 1000]),xlabel('Frequency in Hertz'),ylabel('amplitude')
subplot(2,1,2), plot(time*1000,detrend, 'k'),xlabel('Time in milliseconds')


MAX = max(a);
maxlocus = find(a==MAX);

Fo = f(1,maxlocus);

lin1 = 0:1/rate:0.01-1/rate;
win1 = 1*length(lin1);
window1 = hann(win1);
env1 = window1(1:round((length(window1))/2));
vne1 = fliplr(env');

stimulus = stimulus(rate*0.010:rate*0.090);
sample1= stimulus;
sample1(1:length(env1)) = env1.*sample1(1:length(env1));
sample1(length(sample1)-length(vne1)+1:length(sample1)) = vne1'.*(sample1(length(sample1)-length(vne1)+1:length(sample1)));
zero1 = zeros(1,1024);
abc1 = [zero1 sample1' zero1];

spect1 = abs(fft(abc1));

amp1=spect1;
n1=length(spect1);
freq1=rate/n1.*(1:n1);
a1=amp1(1:(round(n1/2)));
f1=freq1(1:(n1/2));
MAX1 = max(a1);


z = 20*log(MAX/MAX1);
clc
disp('Fundamental frequency = '), disp(Fo)
disp('amplitude (arbitrary units)= '),disp(MAX)
disp ('amplitude of F0 ='), disp (z)
M = [Fo MAX z];
