function e = Bana_auto(a)
%



if nargin <6
    pthr1 = 1.1; 
end

% default time offset of detected pitch
if nargin <5
    timestep = 0.01; 
end

% default higher bound of human speech pitch
if nargin <4
    f0max = 600; 
end

% default lower bound of human speech pitch
if nargin <3
    f0min = 50; 
end

x = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
fs = 100;
if (size(x,1)<size(x,2))
    x=x';
end

time_per_window = 0.06;                             % frame length in second
Lmed = 5;                                           % median filter window length

point_per_window = round(time_per_window*fs);       % number of samples per frame
point_per_timestep=round(timestep*fs);              % number of samples per time step

ls=length(x);                                       % length of input speech data
frame_center=ceil(point_per_window/2);              % the center point of current frame
nfrm = floor((ls-point_per_window)/point_per_timestep)+1; % number of frames
f0_spec_max = zeros(nfrm,5); % spectral peak frequency
f0_cept_freq = zeros(nfrm,1); % cesptrum pitch 
f0_decision = zeros(nfrm,1); % final pitch decision
voicemarker = zeros(nfrm,1); 

p1=[]; % highest pitch level
p2=[]; % 2nd highest pitch level
pd1=[]; % highest pitch level's pitch period
pd2=[]; % 2nd highest pitch level's pitch period

i=1;                                                %frame count
while (frame_center+point_per_window/2 <= ls)    
    xframe_orig=x(max(frame_center-ceil(point_per_window/2),1):frame_center+ceil(point_per_window/2),1); %original frame    
    xframe = xframe_orig-mean(xframe_orig); %zero mean
    
    frame_fft = abs(fft(xframe.*hann(length(xframe)),2^13)); %2^16 points fft
    frame_fft1 = frame_fft(1:2^12+1);
    frame_fft1 = frame_fft1/length(xframe);           
    frame_psd = frame_fft1.^2;                       %get the psd
    frame_psd(2:end -1) = frame_psd(2:end -1)/pi;
    freq_resolution = fs/(2^13);
    frequencies = (1:2^12+1)*freq_resolution;

    HzMin = floor(f0min/freq_resolution);   %lower cutoff frequency 
    HzMax = floor(5*f0max/freq_resolution); %higher cutoff frequency
    frame_spec = frame_psd;
    frame_spec(1:HzMin) = 0;                        %filtered out spectrum below minimum frequency
    frame_spec(HzMax:end) = 0;                      %filtered out spectrum above 5 times maximum frequency
    f0_spec_max_amp = max(frame_spec);              
%     Peaks=findpeaks(frequencies,frame_spec,0,1/15 *f0_spec_max_amp,0.6*100/(fs/2^13),5,3);
    %here use the peak detection function provided by Thomas O’Haver, http://terpconnect.umd.edu/ toh/spectrum/PeakFindingandMeasurement.htm.
    
    for peak_num = 1:5                            %search for the first five peaks with the lowest frequency
%         low_freq_peak = find(Peaks(:,2)==min(Peaks(:,2)));
%         if length(low_freq_peak)<1
            break;
        
        f0_spec_max(i,peak_num) = Peaks(low_freq_peak,2);
%         Peaks(low_freq_peak,:) = NaN;
    end
        
    % cepstrum 
    % code from L. R. Rabiner and R. W. Schafer, 'Theory and Application of Digital Speech Processing'.
    ppdlow=round(fs/f0max);
    ppdhigh=round(fs/f0min);
    
    xframe1 = filter([1 -1],1,xframe); % high-pass filter
    frame_fft = abs(fft(xframe1.*hann(length(xframe1)),2^13)); %2^16 points fft
    xframe1t=log(frame_fft);
    xframec=ifft(xframe1t,2^13);
       
    % initialize local frame cepstrum over valid range from ppdlow to ppdhigh
    indexlow=ppdlow+1;
    indexhigh=ppdhigh+1;
    loghsp=xframec(indexlow:indexhigh);

    % find cepstral peak location (ploc) and level (pmax) and save results in
    % pd1 (for ploc) and p1 (for pmax)
    pmax=max(loghsp);
    ploc1=find(loghsp == pmax);
    ploc=ploc1+ppdlow-1;
%     f0_cept_freq(i,1) = fs/ploc;
    p1=[p1 pmax];
    pd1=[pd1 ploc];
    
    % eliminate strongest peak in order to find highest secondary peak 
    % which is spaced away from primary peak
    % save secondary peak in pd2 and secondary level in p2
    n1=max(1,ploc1-4);
    n2=min(ploc1+4,length(loghsp));
    loghsp2=loghsp;
    loghsp2(n1:n2)=0;
    pmax2=max(loghsp2);
    p2=[p2 pmax2];
    ploc2=find(loghsp2 == pmax2);
    ploc2=ploc2+ppdlow-1;
    pd2=[pd2 ploc2];
       
    i=i+1;
    frame_center = frame_center + point_per_timestep;
end

for myf = 1:length(pd1)
    if pd1(myf) == 0
        f0_cept_freq(myf) = 0;
    else
        f0_cept_freq(myf) = fs/pd1(myf);
    end
end

p1m = [x];
for myf = 1:length(p1m)
    if p1m(myf) == 0
        f0_cept_freq(myf) = 0;
        voicemarker(myf) = 0;
    else
        f0_cept_freq(myf) = fs/p1m(myf);
        voicemarker(myf) = 1;
    end
end

% find pitch candidates
% [candidates_decision,candidate_Cscore] = f0_decision_maker_v2(f0_spec_max,f0_cept_freq,f0min,f0max); 
isCurrentVoiced = 0;
for frame_index = 1:nfrm
    if isCurrentVoiced == 0
        if voicemarker(frame_index) == 0 % still in unvoiced segment
            f0_decision(frame_index) = 0;
        else % start of voiced seg. But do not know whether voiced seg ends. do nothing 
            onehead = frame_index; % mark start of voiced seg
            onetail = frame_index; % initialize end of voiced seg 
            isCurrentVoiced = 1;
        end
    else
        if voicemarker(frame_index) == 0 % end of voiced seg -> Start local Viterbi process
            oneSeg = candidates_decision(onehead:onetail,:); % pitch candidates in one voiced segment
            scoreSeg = candidate_Cscore(onehead:onetail,:); % pitch candidates' confidence scores in one voiced segment
            f0_decision(onehead:onetail) = Path_finder_2(oneSeg,scoreSeg); % local Viterbi on voiced frames
            isCurrentVoiced = 0;
        else % still in voiced seg
            if frame_index ~= nfrm % voiced seg not reach the last frame. do nothing
                onetail = frame_index;
            else % voiced seg reach the last frame -> Start local Viterbi algorithm
                onetail = frame_index;
%                 oneSeg = candidates_decision(onehead:onetail,:); % pitch candidates in one voiced segment
%                 scoreSeg = candidate_Cscore(onehead:onetail,:); % pitch candidates' confidence scores in one voiced segment
%                 f0_decision(onehead:onetail) = Path_finder_2(oneSeg,scoreSeg); % local Viterbi on voiced frames
            end
        end
    end
end
   
     if (a(1) == 'T')
        if(a(10) == 'w')
        if (a(15) == 'h')
            e = 3;
        elseif (a(15) == 'n')
            e = 1;
        elseif (a(15) == 's')
            e = 2;
        elseif (a(15) == 'a')
            e = 4;   
        elseif (a(15) == 'p')
            e = 5;
        elseif (a(15) == 'f')
            e = 6; 
        elseif (a(15) == 'd')
            e = 7;    
        end
        else
        if (a(16) == 'h')
            e = 3;
        elseif (a(16) == 'n')
            e = 1;
        elseif (a(16) == 's')
            e = 2;
        elseif (a(16) == 'a')
            e = 4;   
        elseif (a(16) == 'p')
            e = 5;
        elseif (a(16) == 'f')
            e = 7; 
        elseif (a(16) == 'd')
            e = 7;    
        end 
        end
    else 
        if (a(10) == 'h')
            e = 3;
        elseif (a(10) == 'n')
            e = 1;
        elseif (a(10) == 's' && a(11) == 'a')
            e = 2;
        elseif (a(10) == 'a')
            e = 4;   
        elseif (a(10) == 's' && a(11) == 'u')
            e = 5;
        elseif (a(10) == 'f')
            e = 6; 
        elseif (a(10) == 'd')
            e = 6;    
        end 
    end
end