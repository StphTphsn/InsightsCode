% Determining the role of boxOffset
% Tatsuo Okubo
% 2009/06/16

clear
cd('C:\Documents and Settings\Tatsuo\My Documents\DSP_programs\Aaron')
load boxOffset.mat
%Fs = 24414; % sampling frequency [Hz]
%Duration = 10/1000; % FB minimum duration [s]

% for n = 1:7
%     Onset = 5; % input pulse onset [ms]
%     Offset_pool = [6,10,25,30,50,80,100];
%     Offset = Offset_pool(n); % input pulse offset [ms]
% 
%     Time = 0:1/Fs:(Offset+20)/1000; % time vector [s]
%     Time = 1000*(Time(1:end-1))'; % display time in [ms]
% 
%     X = zeros(size(Time));
%     %X(round((Fs*0.005))) = 1; % impulse
%     X(round(Fs*Onset/1000):round(Fs*Offset/1000)) = 1; % input
%     Y = filter(b,1,X);
% 
% %     figure
% %     subplot(211)
% %     stem(Time,X)
% %     subplot(212)
% %     stem(Time,Y)
% %     xlabel('Time [ms]')
% 
%     Threshold_1 = 0.5;
%     Threshold_2 = 1e-6; % set the threshold low as possible
% 
%     In_length = length(find(X > Threshold_1))*1000/Fs; % in [ms]
%     Out_length = length(find(Y > Threshold_2))*1000/Fs;
%     In(n)= In_length;
%     Out(n) = Out_length;
% end
% 
% cd('C:\Program Files\MATLAB\R2007a\work\electrogui')
% 
% P = polyfit(In,Out,1); % linear fit
% 
% figure
% plot(In,Out,'rx','markersize',10,'linewidth',2), hold on
% plot(In,polyval(P,In),'r-')
% plot(In,polyval([1 0],In,'k:')), hold off
% set(gca,'xtick',0:20:120,'ytick',0:20:120,'fontsize',12)
% xlabel('Input duration [ms]','fontsize',20)
% ylabel('Output duration [ms]','fontsize',20)
% axis equal
% xlim([0 100])

%% testing input that has two peaks separated less than 10 ms

Onset_1 = 5; % input first pulse onset [ms]
Offset_1 = 10 % input first pulse offset [ms]

Onset_2 = 25; % input second pulse onset [ms]
Offset_2 = 30; % input second pulse onset [ms]

Time = 0:1/Fs:(Offset_2+20)/1000; % time vector [s]
Time = 1000*(Time(1:end-1))'; % display time in [ms]

X = zeros(size(Time));
X(round(Fs*Onset_1/1000):round(Fs*Offset_1/1000)) = 1; % first input
X(round(Fs*Onset_2/1000):round(Fs*Offset_2/1000)) = 1; % first input
Y = filter(b,1,X);

figure
subplot(211)
stem(Time,X)
subplot(212)
stem(Time,Y)
xlabel('Time [ms]')


%% conclusion
% having boxOffset is a way to add 10 ms to the duration of threshold
% crossing