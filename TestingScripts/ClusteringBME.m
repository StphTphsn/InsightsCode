% clear all; close all; clc
% 
% for rowi = [15 14 13]% 11 12]
%     load(['rec_allthefeatures_' num2str(rowi) '.mat'])
%     indUse = 1:5000; 
%     Spectrogram = log(AllLabels(FeatureInd.ForGuiSpectrogram,indUse)); 
%     TimeFromOnset = AllLabels(FeatureInd.TimeFromOnset,indUse); 
% 
%     % define syllable start and end times
%     sylOn = find(diff(TimeFromOnset)>1)+1;
%     sylOf = find(diff(TimeFromOnset)<0);
%     if sylOn(1)>sylOf(1)
%         sylOf = sylOf(2:end); 
%     end
%     if sylOf(end)<sylOn(end)
%         sylOn = sylOn(1:end-1); 
%     end
%     
%     % interpolate so each syllable is nbins bins long
%     nbins = 15; 
%     newSpec = []; 
%     newTimeFromOnset = []; 
%     for syli = 1:length(sylOn)
%         newSpec = [newSpec interp1(sylOn(syli):sylOf(syli), ...
%         Spectrogram(:,sylOn(syli):sylOf(syli))', ...
%         linspace(sylOn(syli),sylOf(syli),nbins))']; 
%         newTimeFromOnset = [newTimeFromOnset 1:nbins];
%     end
%     
%     indKeep = 1:min(size(newSpec,2),3000);
%     Data = newSpec(:,indKeep)';
%     TimeFromOnset = newTimeFromOnset(indKeep); 
%     
%     nt = size(Data,1); 
%     nf = size(Data,2); 
% 
%     % subtract mean, divide by std
%     Data = bsxfun(@minus, Data, mean(Data,1));
%     Data = bsxfun(@rdivide, Data, std(Data,1));
%     % Data = cdfscore(Data, [70 100]); 
% 
%     % create distance matrix, in format they want
%      D = pdist(Data, 'correlation'); 
% %     xx = [squareform(repmat(1:nt,nt,1).*~eye(nt))' ...
% %         squareform(repmat((1:nt)',1,nt).*~eye(nt))' ...
% %         D']; 
% 
%     % perform clustering
% %     [NCLUST, halo] = cluster_dp(xx);
%     tic; [COMTY ending] = cluster_jl_cpp(squareform(D),1,1,0,0); toc
%     %
%     figure; hold on
%     surf(Data', 'edgecolor', 'none'); view(0,90); colormap parula
%     plotpts = 100*ones(1,nt)
%     Colors = jet(NCLUST); 
%     for ci = 1:NCLUST
%         plotptsc = plotpts; 
%         plotptsc(halo~=ci) = nan; 
%         plot3(1:nt, plotptsc, 1000*ones(1,nt),'s', 'markersize', 5, 'markerfacecolor', Colors(ci,:), 'markeredgecolor', Colors(ci,:))
%     end
%     xlim([200 500])
%     title(num2str(rowi)); 
%     set(gcf, 'papersize', [7 2], 'paperposition',[0 0 7 2])
% 
%     latencies = 1:nbins+1
%     H = []; 
%     for lati = 2:length(latencies)
%         prob = [];
%         for ci = 1:NCLUST%+1
%             prob(ci) = sum(TimeFromOnset>=latencies(lati-1) ...
%                 & TimeFromOnset<latencies(lati) ...
%                 & halo==(ci));%-1));
%         end
%         if sum(prob==0)>0
%             'warning--some probabilities are 0, may need more data'
%         end
%         prob(prob==0) = []; 
%         prob = prob/sum(prob); 
%         H(lati-1) = -sum(prob.*log2(prob)); 
%     end
%     figure; plot(latencies(1:(end-1))/nbins,H, 'k'); shg
%     xlabel('Latency (fraction of syllable)'); ylabel('Entropy (bits)')
%     ylim([0 max(H)*1.2])
%     title(num2str(rowi)); 
%     set(gcf, 'papersize', [3 2], 'paperposition',[0 0 3 2])
% end


%%
clear all; close all; clc
for rowi = 13%[4:11 13:15]
    clearvars -except rowi
    indUse = 1:5000; 
    if rowi>=11
        load(['rec_allthefeatures_' num2str(rowi) '.mat'])
        Spectrogram1 = log(AllLabels(FeatureInd.ForGuiSpectrogram,indUse)); 
    else
        load(['tmp_allthefeatures_' num2str(rowi) '.mat'])
        Spectrogram1 = log((AllLabels(FeatureInd.Spectrogram,indUse))); 
    end
    TimeFromOnset = AllLabels(FeatureInd.TimeFromOnset,indUse); 
    keepTimeFromOnset = TimeFromOnset; 
    
    
    % smooth spectrogram
    Spectrogram1 = conv2(Spectrogram1, gausswin(20)', 'same'); 

    % define syllable start and end times
    sylOn = find(diff(TimeFromOnset)>1)+1;
    sylOf = find(diff(TimeFromOnset)<0);
    if sylOn(1)>sylOf(1)
        sylOf = sylOf(2:end); 
    end
    if sylOf(end)<sylOn(end)
        sylOn = sylOn(1:end-1); 
    end
    
    % create a conversion matrix, from old times to new times (3 new times
    % per syllable, averaging over the first, middle, and last parts of the
    % syllable)
    
%     
%     nbins = 3; 
%     bedges = linspace(0,1,nbins+1); 
%     sylID = zeros(1,length(TimeFromOnset)); 
%     sylDur = []; 
%     sylMat = zeros(size(Spectrogram1,2),nbins*length(sylOn)); 
%     for syli = 1:length(sylOn); 
%         sylMat(sylOn(syli):sylOf(syli), (0:(nbins-1))*length(sylOn) + syli) = ...
%             1/(sylOf(syli)-sylOn(syli)); % 3 entries for each syllable, 1/length of the syllable
% %         sylID(sylOn(syli):sylOf(syli)) = syli;
% %         sylDur(syli) = sylOf(syli)-sylOn(syli);
%     end
%     newTimeFromOnset = []; 
%     for bini = 1:nbins
%         indBin = TimeFromOnset>=bedges(bini) & TimeFromOnset<=bedges(bini+1); % which times were in this bin of the syllables
%         indbin2 = (length(sylOn)*(bini-1)+1):length(sylOn)*bini+1;
%         sylMat(~indBin,indbin2) = 0; 
%         newTimeFromOnset = [newTimeFromOnset 1:length(sylOn)]; 
%     end
%     newSpec = Spectrogram1*sylMat; 
    
    % interpolate so each syllable is nbins bins long
    nbins = 15; 
    newSpec = []; 
    newTimeFromOnset = [];
    for syli = 1:length(sylOn)
        if sylOf(syli)-sylOn(syli)>3
            tmp = interp1(sylOn(syli):sylOf(syli), ...
            Spectrogram1(:,sylOn(syli):sylOf(syli))', ...
            linspace(sylOn(syli),sylOf(syli),nbins+2))'; 
            tmp = tmp(:,2:end-1); 
            newSpec = [newSpec tmp]; 
            newTimeFromOnset = [newTimeFromOnset 1:nbins];
        end
    end
    
    indKeep = 1:min(size(newSpec,2),3000);
    Data = newSpec(:,indKeep)';
    TimeFromOnset = newTimeFromOnset(indKeep); 
    
    nt = size(Data,1); 
    nf = size(Data,2); 

    % subtract mean, divide by std
    Data = bsxfun(@minus, Data, mean(Data,1));
    Data = bsxfun(@rdivide, Data, std(Data,1));
    % Data = cdfscore(Data, [70 100]); 

    % create distance matrix, in format they want
    D = pdist(Data, 'correlation'); 
    xx = [squareform(repmat(1:nt,nt,1).*~eye(nt))' ...
        squareform(repmat((1:nt)',1,nt).*~eye(nt))' ...
        D']; 
    
    figure
    modularity = [];
    ncl = []; 
    entropy = []; 
    nplots = ceil(sqrt(nbins+10)); 
    subplot(nplots,nplots,1:nplots);
    surf(cdfscore(Spectrogram1(:,500:1500)',[70 100])', ...
        'edgecolor', 'none'); view(0,90); 
    keepTimeFromOnset(keepTimeFromOnset<0) = 0;
    keepTimeFromOnset(keepTimeFromOnset>0) = 1;
    hold on; plot3(1:1001, keepTimeFromOnset(500:1500)*100 +50, 1000*ones(1,1001), 'c', 'linewidth', 1)
    ylim([0 size(Spectrogram1,1)])
    axis tight; axis off; colormap hot
    title(['Bird ' num2str(rowi)])
    for bi = 1:nbins
        Dmat = Data*Data'; 
        Dmat = Dmat(TimeFromOnset==bi, TimeFromOnset==bi); 
        Dmat1 = Dmat; 
        Dmat1(Dmat<prctile(Dmat(:), 50)) = 0; 
        % calculate entropy of Dmat
        pr = prctile(Dmat1(:), 10:10:90);
        prob = hist(Dmat1(:),100); prob = prob/sum(prob); 
        prob(prob==0) = []; 
        entropy(bi) = -sum(prob.*log(prob)); 
%         indsort = sortbyCorr(Dmat);
%         Dmat = Dmat(indsort,indsort); % presort, so clusters are in less arbitrary order
        [COMTY ending] = cluster_jl_cpp(Dmat1,1,0,0,0);
        modularity(bi) = COMTY.MOD(1);
        ncl(bi) = length(unique(COMTY.COM{1}));
        %[~,indsort] = sort(COMTY.COM{1});
        %Dmat = Dmat(indsort,indsort)
        

        indsort = symrcm(Dmat1);
        Dmat = Dmat(indsort,indsort);
        subplot(nplots,nplots,nplots+bi)
        imagesc(Dmat); shg; axis off; 
%         E = sort(eig(Dmat), 'descend'); 
%         plot((E(1:100)), 'k.'); set(gca, 'yscale', 'log')
        if bi == 1
            title(['Latency = 1/15']); 
        else
            title(num2str(bi)); 
        end
    end
    subplot(nplots,nplots,nplots+nbins+5); hold on; 
    plot(modularity, 'k', 'linewidth', 2); 
    xlabel('Latency'); ylabel('Modularity')
    
    subplot(nplots,nplots,nplots+nbins+3); ylim([0 max(modularity)*1.1])
    plot(ncl, 'k', 'linewidth', 2); 
    xlabel('Latency'); ylabel('# Clusters'); ylim([0 max(ncl)*1.1])
    
    subplot(nplots,nplots,nplots+nbins+1);
    plot(entropy, 'k', 'linewidth', 2); 
    xlabel('Latency'); ylabel('Entropy (bits)'); %ylim([0 max(entropy)*1.1])
%     xl = xlim; yl = ylim; 
%     text(xl(1)*-50, yl(2)*.9, 'modularity', 'color', 'c')
%     text(xl(1)*-50, yl(2)*.6, '# clusters', 'color', 'r')
%     text(xl(1)*-50, yl(2)*.3, 'entropy', 'color', 'g')
    
    tightfig; drawnow
    set(gcf, 'papersize', [12 15], 'paperposition',[0 0 12 15])
end