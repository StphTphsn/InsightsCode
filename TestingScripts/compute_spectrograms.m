function [Stot] = compute_spectrograms(songs, cuts)

Stot = [];
for c = 1:size(cuts,2)
    song = songs(cuts(1,c):cuts(2,c));
    fs = 40000;
    specDT = 0.001;
    Flim = [1000 4000];
    [S,Time,F] = spectrogramELM(song,fs,specDT, false,Flim);
    % figure;
    % cmap = hot;
    % cmap(1,:) = zeros(1,3);
    % axis off
    % set(gca, 'ydir', 'normal')
    % Plot = 10*log10(S);
    % Thres = median(Plot(:));
    % Plot(Plot<Thres) = Thres;
    % imagesc(Time, F/1000, flipud(Plot)); axis tight;
    % colorbar;
    % colormap(cmap)
    % ylabel('Frequency (kHz)'); xlabel('Time (s)')
    
    
    %% Compute amplitude
    
    Amplitude = amplitudeELM(S,F);
    
    
    %% wavelet transform of Amplitude
    
    specDTamp = 0.005;
    F = 1:0.1:10;
    %F = logspace(-1,2,10);
    S2 = [];
 %   for w=1:5
    w = 1;
    [Stmp,W] = fastWavelet_morlet_convolution_parallel(Amplitude,F,w,specDT);
    S2 = [S2; Stmp(:,mod(1:size(Stmp,2),round(1/specDT*specDTamp))==0)];
 %   end
    Plot = 10*log10(S2);
    Time = specDTamp*(1:size(S2,2));
    
    % figure;
    % cmap = hot;
    % cmap(1,:) = zeros(1,3);
    % axis off
    % set(gca, 'ydir', 'normal')
    % Thres = median(Plot(:));
    % %Plot(Plot<Thres) = Thres;
    % imagesc(Time, F, flipud(Plot)); axis tight;
    % colormap(cmap)
    % ylabel('Frequency (kHz)'); xlabel('Time (s)')
    % colorbar;
    
    Plot2 = Plot;
    
    %%
    fs = 40000;
    specDT = 0.005;
    Flim = [1000 8000];
    
    %[S1,Time,F] = spectrogramELM(songs,fs,specDT, false,Flim);
    F = linspace(1000,8000, 100);
    S1 = [];
    %for w=logspace(log10(5),log10(200),5)
    w = 50;
    w
    [Stmp,W] = fastWavelet_morlet_convolution_parallel(song,F,w,1/fs);
    S1 = [S1; Stmp(:,mod(1:size(Stmp,2),round(fs*specDT))==0)];
    %end
    
    Plot = 10*log10(S1);
    % figure;
    % cmap = hot;
    % cmap(1,:) = zeros(1,3);
    % axis off
    % set(gca, 'ydir', 'normal')
    % Thres = median(Plot(:));
    % %Plot(Plot<Thres) = Thres;
    % imagesc(Time, F/1000, flipud(Plot)); axis tight;
    % colorbar;
    % colormap(cmap)
    % ylabel('Frequency (kHz)'); xlabel('Time (s)')
    
    Plot1 = Plot;
    
    
    IN2 =  flipud(Plot2)+0.1;
    IN1 =  flipud(Plot1)+0.1;
%      IN2 =  flipud(Plot2)+eps;
%      IN1 =  flipud(Plot1)+eps;

    S = [IN1;IN2];
    Stot = [Stot S]; 
end

for x = 1:size(Stot,1)
    Stot(x,:) = smooth(Stot(x,:),10);
end
for x = 1:size(Stot,2)
    Stot(:,x) = smooth(Stot(:,x),2);
end
Stot = cdfscore(Stot',[50 100])';
%Stot = bsxfun(@minus, Stot, mean(Stot))
% Stot = bsxfun(@rdivide, Stot', std(Stot'))';



