clc;
clear all;
close all;

%% Configuration Of Input and Basic Data

location = 'D:\Jayanta\Google Drive\College\Mini Project 7th Sem\MATLAB\SpeechDBs\';
% location = 'C:\Users\sony\Google Drive\College\7th Sem\Mini Project 7th Sem\MATLAB\SpeechDBs\';

TESSfileLocation = 'TESS\';
TESSperson = {'OAF', 'YAF'};
TESSword = {'youth', 'walk'};
TESSemotion = {'neutral', 'sad', 'happy', 'angry',  'ps',  'fear', 'disgust'};
emotionList = {'Neutral', 'Sad', 'Happy', 'Angry',  'Surprise',  'Fear', 'Disgust'};
SAVEEfileLocation = 'SAVEE\';
SAVEEperson = {'JE', 'JK'};
SAVEEword = {'01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15'};
SAVEEemotion = {'n', 'sa', 'h', 'a', 'su', 'f', 'd'};

noOfAudios = 0;
audioList = {};
x = cell(238);
n = 1;
audioProps = ['AudioData', 'Person', 'Word', 'Emotion', 'Database', 'Mean', 'Variance', 'StD', 'FFT'];

%% Input of database samples and standardisation

for i = 1:length(TESSemotion)
    for j = 1:length(TESSword)
        for k = 1:length(TESSperson)
            noOfAudios = noOfAudios + 1;
            audioList(noOfAudios) = strcat(location, TESSfileLocation, TESSperson(k), '_', TESSword(j), '_', TESSemotion(i), '.wav');
            
            [y, Fs] = audioread(char(audioList(noOfAudios)));
            audioMasterList{n, 1} = transpose(y);
            audioMasterList{n, 2} = TESSperson(k);
            audioMasterList{n, 3} = TESSword(j);
            if(strcmp(TESSemotion{i},'neutral'))
                audioMasterList{n, 4} = 'n';
            elseif(strcmp(TESSemotion{i},'angry'))
                audioMasterList{n, 4} = 'a';
            elseif(strcmp(TESSemotion{i},'sad'))
                audioMasterList{n, 4} = 's';
            elseif(strcmp(TESSemotion{i},'fear'))
                audioMasterList{n, 4} = 'f';
            elseif(strcmp(TESSemotion{i},'disgust'))
                audioMasterList{n, 4} = 'd';
            elseif(strcmp(TESSemotion{i},'happy'))
                audioMasterList{n, 4} = 'h';
            elseif(strcmp(TESSemotion{i},'ps'))
                audioMasterList{n, 4} = 'p';
            end
            audioMasterList{n, 5} = 'TESS';
            n = n + 1;
        end
    end
end

TESSFs = Fs;
TESSnumber = noOfAudios;

for i = 1:length(SAVEEemotion)
    for j = 1:length(SAVEEword)
        for k = 1:length(SAVEEperson)
            noOfAudios = noOfAudios + 1;
            audioList(noOfAudios) = strcat(location, SAVEEfileLocation, SAVEEperson(k), '\', SAVEEemotion(i), SAVEEword(j), '.wav');
            [y, Fs] = audioread(char(audioList(noOfAudios)));
            audioMasterList{n, 1} = transpose(y);
            audioMasterList{n, 2} = SAVEEperson(k);
            audioMasterList{n, 3} = SAVEEword(j);
            if(strcmp(SAVEEemotion{i},'sa'))
                audioMasterList{n, 4} = 's';
            elseif(strcmp(SAVEEemotion{i},'su'))
                audioMasterList{n, 4} = 'p';
            else
                audioMasterList{n, 4} = SAVEEemotion(i);
            end
            audioMasterList{n, 5} = 'SAVEE';
            n = n + 1;
        end
    end
end

SAVEEFs = Fs;
SAVEEnumber = noOfAudios - TESSnumber;

%% Analysis of Database parameters

n = 1;
s = 1;
h = 1;
a = 1;
p = 1;
f = 1;
d = 1;

for i = 1:noOfAudios
    audioMasterList{i, 6} = mean(audioMasterList{i, 1});
    audioMasterList{i, 7} = var(audioMasterList{i, 1});
    audioMasterList{i, 8} = std(audioMasterList{i, 1});
    audioMasterList{i, 9} = fft(audioMasterList{i, 1});
    audioMasterList{i, 10}= sum(audioMasterList{i, 1}.^2);
    audioMasterList{i, 11} = mean(audioMasterList{i, 9});
    
    if(char(audioMasterList{i, 4})=='n')
        neutralMValues(n) = audioMasterList(i, 6);
        neutralVValues(n) = audioMasterList(i,7);
        neutralSDValues(n) = audioMasterList(i,8);
        neutralEValues(n) = audioMasterList(i, 10);
        neutralMeanF(n) = audioMasterList(i,11);
        n = n + 1;
    end
    
    if(char(audioMasterList{i, 4})=='s')
        sadMValues(s) = audioMasterList(i, 6);
        sadVValues(s) = audioMasterList(i,7);
        sadSDValues(s) = audioMasterList(i,8);
        sadEValues(s) = audioMasterList(i,10);
        sadMeanF(s) = audioMasterList(i,11);
        s = s + 1;
        
    end
    if(char(audioMasterList{i, 4})=='h')
        happyMValues(h) = audioMasterList(i, 6);
        happyVValues(h) = audioMasterList(i,7);
        happySDValues(h) = audioMasterList(i,8);
        happyEValues(h) = audioMasterList(i,10);
        happyMeanF(h) = audioMasterList(i,11);
        h = h + 1;
    end
    if(char(audioMasterList{i, 4})=='a')
        angerMValues(a) = audioMasterList(i, 6);
        angerVValues(a) = audioMasterList(i,7);
        angerSDValues(a) = audioMasterList(i,8);
        angerEValues(a) = audioMasterList(i,10);
        angerMeanF(a) = audioMasterList(i,11);
        a = a + 1;
    end
    if(char(audioMasterList{i, 4})=='p')
        psMValues(p) = audioMasterList(i, 6);
        psVValues(p) = audioMasterList(i,7);
        psSDValues(p) = audioMasterList(i,8);
        psEValues(p) = audioMasterList(i,10);
        psMeanF(p) = audioMasterList(i,11);
        p = p + 1;
    end
    if(char(audioMasterList{i, 4})=='f')
        fearMValues(f) = audioMasterList(i, 6);
        fearVValues(f) = audioMasterList(i,7);
        fearSDValues(f) = audioMasterList(i,8);
        fearEValues(f) = audioMasterList(i,10);
        fearMeanF(f) = audioMasterList(i,11);
        f = f + 1;
    end
    if(char(audioMasterList{i, 4})=='d')
        disgustMValues(d) = audioMasterList(i, 6);
        disgustVValues(d) = audioMasterList(i,7);
        disgustSDValues(d) = audioMasterList(i,8);
        disgustEValues(d) = audioMasterList(i,10);
        disgustMeanF(d) = audioMasterList(i,11);
        d = d + 1;
    end
end

%% Generation of threshold range values

meanMean = [mean(cell2mat(neutralMValues)) mean(cell2mat(sadMValues)) mean(cell2mat(happyMValues)) mean(cell2mat(angerMValues)) mean(cell2mat(psMValues)) mean(cell2mat(fearMValues)) mean(cell2mat(disgustMValues))];
meanMax = [max(cell2mat(neutralMValues)) max(cell2mat(sadMValues)) max(cell2mat(happyMValues)) max(cell2mat(angerMValues)) max(cell2mat(psMValues)) max(cell2mat(fearMValues)) max(cell2mat(disgustMValues))];
meanMin = [min(cell2mat(neutralMValues)) min(cell2mat(sadMValues)) min(cell2mat(happyMValues)) min(cell2mat(angerMValues)) min(cell2mat(psMValues)) min(cell2mat(fearMValues)) min(cell2mat(disgustMValues))];

varMean = [mean(cell2mat(neutralVValues)) mean(cell2mat(sadVValues)) mean(cell2mat(happyVValues)) mean(cell2mat(angerVValues)) mean(cell2mat(psVValues)) mean(cell2mat(fearVValues)) mean(cell2mat(disgustVValues))];
varMax = [max(cell2mat(neutralVValues)) max(cell2mat(sadVValues)) max(cell2mat(happyVValues)) max(cell2mat(angerVValues)) max(cell2mat(psVValues)) max(cell2mat(fearVValues)) max(cell2mat(disgustVValues))];
varMin = [min(cell2mat(neutralVValues)) min(cell2mat(sadVValues)) min(cell2mat(happyVValues)) min(cell2mat(angerVValues)) min(cell2mat(psVValues)) min(cell2mat(fearVValues)) min(cell2mat(disgustVValues))];

stdMean = [mean(cell2mat(neutralSDValues)) mean(cell2mat(sadSDValues)) mean(cell2mat(happySDValues)) mean(cell2mat(angerSDValues)) mean(cell2mat(psSDValues)) mean(cell2mat(fearSDValues)) mean(cell2mat(disgustSDValues))];
stdMax = [max(cell2mat(neutralSDValues)) max(cell2mat(sadSDValues)) max(cell2mat(happySDValues)) max(cell2mat(angerSDValues)) max(cell2mat(psSDValues)) max(cell2mat(fearSDValues)) max(cell2mat(disgustSDValues))];
stdMin = [min(cell2mat(neutralSDValues)) min(cell2mat(sadSDValues)) min(cell2mat(happySDValues)) min(cell2mat(angerSDValues)) min(cell2mat(psSDValues)) min(cell2mat(fearSDValues)) min(cell2mat(disgustSDValues))];

energyMean = [mean(cell2mat(neutralEValues)) mean(cell2mat(sadEValues)) mean(cell2mat(happyEValues)) mean(cell2mat(angerEValues)) mean(cell2mat(psEValues)) mean(cell2mat(fearEValues)) mean(cell2mat(disgustEValues))];
energyMax = [max(cell2mat(neutralEValues)) max(cell2mat(sadEValues)) max(cell2mat(happyEValues)) max(cell2mat(angerEValues)) max(cell2mat(psEValues)) max(cell2mat(fearEValues)) max(cell2mat(disgustEValues))]
energyMin = [min(cell2mat(neutralEValues)) min(cell2mat(sadEValues)) min(cell2mat(happyEValues)) min(cell2mat(angerEValues)) min(cell2mat(psEValues)) min(cell2mat(fearEValues)) min(cell2mat(disgustEValues))]

FFTMean = [mean(cell2mat(neutralMeanF)) mean(cell2mat(sadMeanF)) mean(cell2mat(happyMeanF)) mean(cell2mat(angerMeanF)) mean(cell2mat(psMeanF)) mean(cell2mat(fearMeanF)) mean(cell2mat(disgustMeanF))];
FFTMax = [max(cell2mat(neutralMeanF)) max(cell2mat(sadMeanF)) max(cell2mat(happyMeanF)) max(cell2mat(angerMeanF)) max(cell2mat(psMeanF)) max(cell2mat(fearMeanF)) max(cell2mat(disgustMeanF))];
FFTMin = [min(cell2mat(neutralMeanF)) min(cell2mat(sadMeanF)) min(cell2mat(happyMeanF)) min(cell2mat(angerMeanF)) min(cell2mat(psMeanF)) min(cell2mat(fearMeanF)) min(cell2mat(disgustMeanF))];

typNeutral = audioread(strcat(location, 'typical_neutral.wav'));
typNeutralFFT = fft(typNeutral);
typSad = audioread(strcat(location, 'typical_sad.wav'));
typSadFFT = fft(typNeutral);
typAngry = audioread(strcat(location, 'typical_angry.wav'));
typAngryFFT = fft(typAngry);
typHappy = audioread(strcat(location, 'typical_happy.wav'));
typHappyFFT = fft(typHappy);
typSurprise = audioread(strcat(location, 'typical_ps.wav'));
typSurpriseFFT = fft(typSurprise);
typFear = audioread(strcat(location, 'typical_fear.wav'));
typFearFFT = fft(typFear);
typDisgust = audioread(strcat(location, 'typical_disgust.wav'));
typDisgustFFT = fft(typDisgust);

%% Input for Testing

testInput = 'TESS\OAF_walk_angry.wav';
%testInput = 'SAVEE\DC\sa01.wav';

RealTime = 0;

if RealTime == 0
    inputAudio = audioread(strcat(location,testInput));                                                                                                                                                                                                         f0 = Bana_auto(testInput);
else
    testInput = 'Manual Input Audio';
    input = audiorecorder(SAVEEFs, 8, 1);
    disp('Start speaking.');
    recordblocking(input, 3);
    disp('End of Recording.');
    inputAudio = getaudiodata(input);
end
if (testInput(1) == 'T')
    outFs = TESSFs;
else
    outFs = SAVEEFs;
end

figure(2);
plot(inputAudio);
xlabel('t');
ylabel('I(t)');
title(strcat('Input Audio - ', testInput));

%% Input Signal Analysis

sound(inputAudio, outFs);

inputMean = mean(inputAudio);
inputVar = var(inputAudio);
inputStd = std(inputAudio);
inputE = sum(inputAudio.^2);
inputFFTSig = fft(inputAudio);
inputFFT = mean(fft(inputAudio));

%% Comparison with threshold range values

corrVal(1) = mean(xcorr(inputAudio, typNeutral));
corrVal(2) = mean(xcorr(inputAudio, typSad));
corrVal(3) = mean(xcorr(inputAudio, typHappy));
corrVal(4) = mean(xcorr(inputAudio, typAngry));
corrVal(5) = mean(xcorr(inputAudio, typSurprise));
corrVal(6) = mean(xcorr(inputAudio, typFear));
corrVal(7) = mean(xcorr(inputAudio, typDisgust));
corrVal = abs(corrVal/max(corrVal));
corrFFTVal(1) = mean(xcorr(inputFFTSig, typNeutralFFT));
corrFFTVal(2) = mean(xcorr(inputFFTSig, typSadFFT));
corrFFTVal(3) = mean(xcorr(inputFFTSig, typHappyFFT));
corrFFTVal(4) = mean(xcorr(inputFFTSig, typAngryFFT));
corrFFTVal(5) = mean(xcorr(inputFFTSig, typSurpriseFFT));
corrFFTVal(6) = mean(xcorr(inputFFTSig, typFearFFT));
corrFFTVal(7) = mean(xcorr(inputFFTSig, typDisgustFFT));
corrFFTVal = abs(corrFFTVal/max(corrFFTVal))

emoSet = ones(1,7)
for i = 1:7
    
    if((inputE>=energyMin(i)&&inputE<=energyMax(i))==0)
        emoSet(i) = 0;
    else
        emoSet(i) = emoSet(i)*(abs(inputE-energyMean(i))/(energyMax(i)-energyMin(i)));
    end
    
    if((inputMean>=meanMin(i)&&inputMean<=meanMax(i))==0)
        emoSet(i) = 0;
    else
        emoSet(i) = emoSet(i)*(abs(inputMean-meanMean(i))/(meanMax(i)-meanMin(i)));
    end
    if((inputVar>=varMin(i)&&inputVar<=varMax(i))==0)
        emoSet(i) = 0;
    else
        emoSet(i) = emoSet(i)*(abs(inputVar-varMean(i))/(varMax(i)-varMin(i)));
    end
    if((inputStd>=stdMin(i)&&inputStd<=stdMax(i))==0)
        emoSet(i) = 0;
    else
        emoSet(i) = emoSet(i)*(abs(inputStd-stdMean(i))/(stdMax(i)-stdMin(i)));
    end
    if(RealTime==0)
        if((inputFFT>=FFTMin(i)&&inputFFT<=FFTMax(i))==0)
            emoSet(i) = 0;
        else
            emoSet(i) = emoSet(i)*(abs(inputFFT-FFTMean(i))/(FFTMax(i)-FFTMin(i)));
        end
        emoSet = emoSet*corrVal(i);
        emoSet = emoSet*corrFFTVal(i);
        emoSet = abs(emoSet/max(emoSet));

        for j = 1:7
            if (emoSet(j)>emoSet(f0))
                emoSet(j) = emoSet(f0)/2;
            end
        end
    end
    emoSet
end

%% Display output

emoSet
[MAX, MAXEMO] = max(emoSet)

sprintf('Therefore the emotion is %s',cell2mat(emotionList(MAXEMO)))