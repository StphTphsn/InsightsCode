function [features, labels] = SAPfeatures(TS, fs, specDT)

labels = {'AM', 'FM' ,'Entropy' , 'Amplitude' , 'Pitch goodness' , 'Pitch' ,...
    'Pitch chose', 'Pitch weight','Gravity center', 'Spectral s.d.','time'};
if ischar(TS) && strcmp(TS,'params')
    features.Names = {};
    features.Values = {};
    return
end

%        Writen by Sigal Saar August 08 2005
% Spectral width added by Yael and Tatsuo, 2013

if size(TS,2)>size(TS,1)
    TS=TS';
end
TS=TS-min(TS);
TS=TS/max(TS)*2;
TS=TS-1;
TS=resample(TS,44100,round(fs));
fs=44100;
 

[param]=sf_Parameters;
param.winstep = ceil(param.fs*specDT); 

E=mtap;
    
[TSM,center_window]=sf_runing_windows(TS',param.window, param.winstep);

if param.k==0 || param.NW==0
    J1=(fft(TSM(:,:).*(ones(size(TSM,1),1)*(E(:,1))'),param.pad,2));
    J1=J1(:,1:param.spectrum_range)* ( 27539);
    J2=(fft(TSM(:,:).*(ones(size(TSM,1),1)*(E(:,2))'),param.pad,2));
    J2=J2(:,1:param.spectrum_range)* ( 27539);
else
    error('not implemented');
%     params.pad=param.pad;
%     params.tapers=[param.NW param.k];
%     [dS,f]=mtfftc(TS,[0,pi/2],params); %Unused output and undefined function??
end

%% ==============Power spectrum=============
m_powSpec= abs(J1).^2+abs(J2).^2;
m_time_deriv= -1*(real(J1).*real(J2)+imag(J1).*imag(J2));
m_freq_deriv= ((imag(J1).*real(J2)-real(J1).*imag(J2)));

m_time_deriv_max=max(m_time_deriv.^2,[],2);
m_freq_deriv_max=max(m_freq_deriv.^2,[],2);
%===========================================

freq_winer_ampl_index= param.min_freq_winer_ampl:param.max_freq_winer_ampl;
m_amplitude=sum(m_powSpec(:,freq_winer_ampl_index),2);

m_SumLog=sum(log(m_powSpec(:,freq_winer_ampl_index)+eps),2);
m_LogSum=(sum(m_powSpec(:,freq_winer_ampl_index),2)); 

m_AM=sum(m_time_deriv(:,freq_winer_ampl_index),2);
m_AM=m_AM./(m_amplitude+eps);
m_amplitude=log10(m_amplitude+1)*10-70; %units in dB

%% TO (using linear power)
NFFT = 512;
windowSize = param.window;
windowOverlap = param.window - param.winstep; %365;
freqRange = [500 8000]; % [Hz]

[S,F] = spectrogram(TS, windowSize, windowOverlap, fs, NFFT);
ndx = find((F>=freqRange(1)) & (F<=freqRange(2)));
f = F(ndx)';
lin_power = abs(S(ndx,:)').^2; % power spectrum in linear scale
[m,n]=size(lin_power);
gravity_center = ((f*lin_power')./sum(lin_power'))';
spectral_SD = (sqrt(sum((repmat(f,m,1)-repmat(gravity_center,1,n))'.^2.*lin_power')./sum(lin_power')))';

%%


%===========Wiener entropy==================

m_LogSum(m_LogSum==0)=length(freq_winer_ampl_index); 
m_LogSum=log(m_LogSum/length(freq_winer_ampl_index)); %divide by the number of frequencies
m_Entropy=(m_SumLog/length(freq_winer_ampl_index))-m_LogSum;
m_Entropy(m_LogSum==0)=0; 


%============FM===================

m_FM=atan(m_time_deriv_max./(m_freq_deriv_max+eps));

%%%%%%%%%%%%%%%%%%%%%%%%

%==========Directional Spectral derivatives=================


cFM=cos(m_FM);
sFM=sin(m_FM);

%==The image==
m_spec_deriv=m_time_deriv(:,3:255).*(sFM*ones(1,255-3+1))+m_freq_deriv(:,3:255).*(cFM*ones(1,255-3+1));
Cepstrum=(fft(m_spec_deriv./(m_powSpec(:,3:255)+eps),512,2))*( 1/2);
x=(real(Cepstrum(:,param.up_pitch:param.low_pitch))).^2+(imag(Cepstrum(:,param.up_pitch:param.low_pitch))).^2;
[m_PitchGoodness,m_Pitch]=sort(x,2);
m_PitchGoodness=m_PitchGoodness(:,end);
m_Pitch=m_Pitch(:,end);
m_Pitch(m_PitchGoodness<1)=1;
m_PitchGoodness=max(m_PitchGoodness,1);

m_Pitch=m_Pitch+3;
Pitch_chose= 22050./m_Pitch ; %1./(m_Pitch/1024*fs*512);

index_m_freq=find(Pitch_chose>param.pitch_HoP & (m_PitchGoodness<param.gdn_HoP | m_Entropy>param.up_wiener));

Pitch_chose(index_m_freq)=gravity_center(index_m_freq);

Pitch_weight=Pitch_chose.*m_PitchGoodness./sum(m_PitchGoodness);

m_FM=m_FM*180/pi;
        
%save features.mat m_amplitude m_amplitude_band_1 m_amplitude_band_2 m_amplitude_band_3 m_Entropy m_Entropy_band_1 m_Entropy_band_2 m_Entropy_band_3
%m_amplitude=m_amplitude_band_3;
%m_Entropy=m_Entropy_band_3;


%% using AA algorithm for pitch
[pitch, pg, hp, pt, ent] = estimatePitch(TS, fs, 'winSize',param.window,'winStep',param.winstep); %%% TO

m_Pitch = pitch';
m_PitchGoodness = pg';
m_entropy = ent';

features = {m_AM, m_FM , m_Entropy, m_amplitude, m_PitchGoodness , m_Pitch, Pitch_chose,...
    Pitch_weight, gravity_center, spectral_SD,center_window./fs};


function E = mtap

E = [   0.10082636028528   0.48810350894928
   0.10532280057669   0.50016260147095
   0.10990284383297   0.51226782798767
   0.11456660926342   0.52441596984863
   0.11931420862675   0.53660380840302
   0.12414572387934   0.54882800579071
   0.12906123697758   0.56108516454697
   0.13406077027321   0.57337194681168
   0.13914434611797   0.58568495512009
   0.14431197941303   0.59802067279816
   0.14956362545490   0.61037564277649
   0.15489923954010   0.62274640798569
   0.16031874716282   0.63512933254242
   0.16582205891609   0.64752095937729
   0.17140907049179   0.65991759300232
   0.17707960307598   0.67231565713882
   0.18283350765705   0.68471157550812
   0.18867060542107   0.69710153341293
   0.19459065794945   0.70948195457458
   0.20059344172478   0.72184902429581
   0.20667870342732   0.73419916629791
   0.21284613013268   0.74652844667435
   0.21909542381764   0.75883322954178
   0.22542624175549   0.77110970020294
   0.23183822631836   0.78335398435593
   0.23833100497723   0.79556238651276
   0.24490414559841   0.80773097276688
   0.25155723094940   0.81985598802566
   0.25828978419304   0.83193349838257
   0.26510134339333   0.84395974874497
   0.27199140191078   0.85593080520630
   0.27895939350128   0.86784279346466
   0.28600478172302   0.87969189882278
   0.29312700033188   0.89147418737411
   0.30032539367676   0.90318578481674
   0.30759936571121   0.91482281684875
   0.31494826078415   0.92638140916824
   0.32237139344215   0.93785762786865
   0.32986804842949   0.94924771785736
   0.33743748068809   0.96054774522781
   0.34507897496223   0.97175377607346
   0.35279172658920   0.98286205530167
   0.36057496070862   0.99386870861054
   0.36842781305313   1.00476980209351
   0.37634941935539   1.01556169986725
   0.38433897495270   1.02624034881592
   0.39239549636841   1.03680217266083
   0.40051811933518   1.04724323749542
   0.40870589017868   1.05755984783173
   0.41695779561996   1.06774818897247
   0.42527288198471   1.07780468463898
   0.43365013599396   1.08772540092468
   0.44208851456642   1.09750676155090
   0.45058691501617   1.10714507102966
   0.45914432406425   1.11663687229156
   0.46775957942009   1.12597823143005
   0.47643154859543   1.13516581058502
   0.48515912890434   1.14419603347778
   0.49394109845161   1.15306520462036
   0.50277632474899   1.16176998615265
   0.51166349649429   1.17030680179596
   0.52060145139694   1.17867243289948
   0.52958887815475   1.18686318397522
   0.53862458467483   1.19487595558167
   0.54770720005035   1.20270740985870
   0.55683541297913   1.21035408973694
   0.56600785255432   1.21781289577484
   0.57522326707840   1.22508060932159
   0.58448016643524   1.23215413093567
   0.59377723932266   1.23903024196625
   0.60311305522919   1.24570596218109
   0.61248612403870   1.25217819213867
   0.62189501523972   1.25844407081604
   0.63133829832077   1.26450049877167
   0.64081448316574   1.27034485340118
   0.65032202005386   1.27597427368164
   0.65985941886902   1.28138577938080
   0.66942512989044   1.28657686710358
   0.67901766300201   1.29154479503632
   0.68863534927368   1.29628694057465
   0.69827669858932   1.30080080032349
   0.70794004201889   1.30508399009705
   0.71762382984161   1.30913388729095
   0.72732639312744   1.31294822692871
   0.73704612255096   1.31652474403381
   0.74678134918213   1.31986105442047
   0.75653040409088   1.32295513153076
   0.76629155874252   1.32580471038818
   0.77606326341629   1.32840788364410
   0.78584367036820   1.33076262474060
   0.79563117027283   1.33286690711975
   0.80542397499084   1.33471894264221
   0.81522035598755   1.33631694316864
   0.82501864433289   1.33765923976898
   0.83481699228287   1.33874404430389
   0.84461367130279   1.33956992626190
   0.85440695285797   1.34013533592224
   0.86419498920441   1.34043884277344
   0.87397605180740   1.34047901630402
   0.88374835252762   1.34025466442108
   0.89351004362106   1.33976447582245
   0.90325933694840   1.33900737762451
   0.91299438476563   1.33798217773438
   0.92271345853805   1.33668816089630
   0.93241471052170   1.33512413501740
   0.94209629297257   1.33328926563263
   0.95175635814667   1.33118307590485
   0.96139311790466   1.32880449295044
   0.97100472450256   1.32615327835083
   0.98058933019638   1.32322859764099
   0.99014514684677   1.32003021240234
   0.99967026710510   1.31655764579773
   1.00916278362274   1.31281065940857
   1.01862108707428   1.30878901481628
   1.02804315090179   1.30449247360229
   1.03742706775665   1.29992127418518
   1.04677128791809   1.29507517814636
   1.05607366561890   1.28995430469513
   1.06533253192902   1.28455901145935
   1.07454609870911   1.27888941764832
   1.08371245861053   1.27294600009918
   1.09282970428467   1.26672899723053
   1.10189616680145   1.26023912429810
   1.11090993881226   1.25347697734833
   1.11986923217773   1.24644303321838
   1.12877237796783   1.23913824558258
   1.13761734962463   1.23156344890594
   1.14640247821808   1.22371935844421
   1.15512585639954   1.21560716629028
   1.16378593444824   1.20722794532776
   1.17238080501556   1.19858264923096
   1.18090879917145   1.18967282772064
   1.18936800956726   1.18049955368042
   1.19775688648224   1.17106437683105
   1.20607352256775   1.16136872768402
   1.21431636810303   1.15141415596008
   1.22248351573944   1.14120233058929
   1.23057353496552   1.13073492050171
   1.23858451843262   1.12001371383667
   1.24651479721069   1.10904061794281
   1.25436294078827   1.09781765937805
   1.26212716102600   1.08634674549103
   1.26980578899384   1.07462990283966
   1.27739727497101   1.06266951560974
   1.28489995002747   1.05046772956848
   1.29231238365173   1.03802680969238
   1.29963290691376   1.02534937858582
   1.30685997009277   1.01243758201599
   1.31399202346802   0.99929422140122
   1.32102763652802   0.98592185974121
   1.32796525955200   0.97232311964035
   1.33480334281921   0.95850080251694
   1.34154057502747   0.94445770978928
   1.34817540645599   0.93019676208496
   1.35470652580261   0.91572093963623
   1.36113238334656   0.90103322267532
   1.36745178699493   0.88613671064377
   1.37366318702698   0.87103462219238
   1.37976539134979   0.85573017597198
   1.38575696945190   0.84022665023804
   1.39163672924042   0.82452732324600
   1.39740324020386   0.80863571166992
   1.40305554866791   0.79255521297455
   1.40859210491180   0.77628940343857
   1.41401195526123   0.75984185934067
   1.41931378841400   0.74321621656418
   1.42449653148651   0.72641617059708
   1.42955899238586   0.70944553613663
   1.43450009822845   0.69230806827545
   1.43931877613068   0.67500764131546
   1.44401395320892   0.65754824876785
   1.44858467578888   0.63993370532990
   1.45302975177765   0.62216812372208
   1.45734846591949   0.60425555706024
   1.46153962612152   0.58620011806488
   1.46560251712799   0.56800597906113
   1.46953618526459   0.54967725276947
   1.47333967685699   0.53121829032898
   1.47701227664948   0.51263326406479
   1.48055315017700   0.49392655491829
   1.48396146297455   0.47510254383087
   1.48723638057709   0.45616558194161
   1.49037742614746   0.43712010979652
   1.49338376522064   0.41797062754631
   1.49625468254089   0.39872157573700
   1.49898970127106   0.37937757372856
   1.50158810615540   0.35994309186935
   1.50404930114746   0.34042277932167
   1.50637280941010   0.32082122564316
   1.50855803489685   0.30114310979843
   1.51060461997986   0.28139305114746
   1.51251196861267   0.26157575845718
   1.51427984237671   0.24169597029686
   1.51590764522552   0.22175838053226
   1.51739513874054   0.20176777243614
   1.51874196529388   0.18172888457775
   1.51994776725769   0.16164653003216
   1.52101242542267   0.14152547717094
   1.52193558216095   0.12137054651976
   1.52271711826324   0.10118655860424
   1.52335667610168   0.08097834140062
   1.52385437488556   0.06075073406100
   1.52420985698700   0.04050857573748
   1.52442324161530   0.02025671303272
   1.52449429035187  -0.00000000211473
   1.52442324161530  -0.02025671675801
   1.52420985698700  -0.04050857946277
   1.52385437488556  -0.06075073778629
   1.52335667610168  -0.08097834885120
   1.52271711826324  -0.10118656605482
   1.52193558216095  -0.12137055397034
   1.52101242542267  -0.14152547717094
   1.51994776725769  -0.16164653003216
   1.51874196529388  -0.18172889947891
   1.51739513874054  -0.20176777243614
   1.51590764522552  -0.22175839543343
   1.51427984237671  -0.24169597029686
   1.51251196861267  -0.26157575845718
   1.51060461997986  -0.28139305114746
   1.50855803489685  -0.30114310979843
   1.50637280941010  -0.32082122564316
   1.50404930114746  -0.34042277932167
   1.50158810615540  -0.35994309186935
   1.49898970127106  -0.37937757372856
   1.49625468254089  -0.39872160553932
   1.49338376522064  -0.41797062754631
   1.49037742614746  -0.43712010979652
   1.48723638057709  -0.45616558194161
   1.48396146297455  -0.47510254383087
   1.48055315017700  -0.49392655491829
   1.47701227664948  -0.51263326406479
   1.47333967685699  -0.53121829032898
   1.46953618526459  -0.54967725276947
   1.46560251712799  -0.56800597906113
   1.46153962612152  -0.58620011806488
   1.45734846591949  -0.60425561666489
   1.45302975177765  -0.62216812372208
   1.44858467578888  -0.63993370532990
   1.44401395320892  -0.65754824876785
   1.43931877613068  -0.67500770092010
   1.43450009822845  -0.69230806827545
   1.42955899238586  -0.70944553613663
   1.42449653148651  -0.72641617059708
   1.41931378841400  -0.74321621656418
   1.41401195526123  -0.75984185934067
   1.40859210491180  -0.77628940343857
   1.40305554866791  -0.79255521297455
   1.39740324020386  -0.80863571166992
   1.39163672924042  -0.82452732324600
   1.38575696945190  -0.84022665023804
   1.37976539134979  -0.85573017597198
   1.37366318702698  -0.87103468179703
   1.36745178699493  -0.88613677024841
   1.36113238334656  -0.90103322267532
   1.35470652580261  -0.91572093963623
   1.34817540645599  -0.93019676208496
   1.34154057502747  -0.94445770978928
   1.33480334281921  -0.95850080251694
   1.32796525955200  -0.97232311964035
   1.32102763652802  -0.98592185974121
   1.31399202346802  -0.99929428100586
   1.30685997009277  -1.01243758201599
   1.29963290691376  -1.02534937858582
   1.29231238365173  -1.03802680969238
   1.28489995002747  -1.05046772956848
   1.27739727497101  -1.06266951560974
   1.26980578899384  -1.07462990283966
   1.26212716102600  -1.08634674549103
   1.25436294078827  -1.09781765937805
   1.24651479721069  -1.10904061794281
   1.23858451843262  -1.12001371383667
   1.23057353496552  -1.13073492050171
   1.22248351573944  -1.14120233058929
   1.21431636810303  -1.15141415596008
   1.20607352256775  -1.16136872768402
   1.19775688648224  -1.17106437683105
   1.18936800956726  -1.18049955368042
   1.18090879917145  -1.18967282772064
   1.17238080501556  -1.19858264923096
   1.16378593444824  -1.20722794532776
   1.15512585639954  -1.21560716629028
   1.14640247821808  -1.22371935844421
   1.13761734962463  -1.23156344890594
   1.12877237796783  -1.23913824558258
   1.11986923217773  -1.24644303321838
   1.11090993881226  -1.25347697734833
   1.10189616680145  -1.26023912429810
   1.09282970428467  -1.26672899723053
   1.08371245861053  -1.27294600009918
   1.07454609870911  -1.27888941764832
   1.06533253192902  -1.28455901145935
   1.05607366561890  -1.28995430469513
   1.04677128791809  -1.29507517814636
   1.03742706775665  -1.29992127418518
   1.02804315090179  -1.30449247360229
   1.01862108707428  -1.30878901481628
   1.00916278362274  -1.31281065940857
   0.99967020750046  -1.31655764579773
   0.99014514684677  -1.32003021240234
   0.98058933019638  -1.32322859764099
   0.97100472450256  -1.32615327835083
   0.96139311790466  -1.32880449295044
   0.95175635814667  -1.33118307590485
   0.94209629297257  -1.33328926563263
   0.93241471052170  -1.33512413501740
   0.92271345853805  -1.33668816089630
   0.91299438476563  -1.33798217773438
   0.90325933694840  -1.33900737762451
   0.89351004362106  -1.33976447582245
   0.88374835252762  -1.34025466442108
   0.87397605180740  -1.34047901630402
   0.86419498920441  -1.34043884277344
   0.85440695285797  -1.34013533592224
   0.84461367130279  -1.33956992626190
   0.83481699228287  -1.33874404430389
   0.82501864433289  -1.33765923976898
   0.81522035598755  -1.33631694316864
   0.80542397499084  -1.33471894264221
   0.79563117027283  -1.33286690711975
   0.78584367036820  -1.33076262474060
   0.77606326341629  -1.32840788364410
   0.76629155874252  -1.32580471038818
   0.75653040409088  -1.32295513153076
   0.74678134918213  -1.31986105442047
   0.73704612255096  -1.31652474403381
   0.72732639312744  -1.31294822692871
   0.71762382984161  -1.30913388729095
   0.70794004201889  -1.30508399009705
   0.69827669858932  -1.30080080032349
   0.68863534927368  -1.29628694057465
   0.67901766300201  -1.29154479503632
   0.66942512989044  -1.28657686710358
   0.65985941886902  -1.28138577938080
   0.65032202005386  -1.27597427368164
   0.64081448316574  -1.27034485340118
   0.63133829832077  -1.26450049877167
   0.62189501523972  -1.25844407081604
   0.61248612403870  -1.25217819213867
   0.60311305522919  -1.24570596218109
   0.59377723932266  -1.23903024196625
   0.58448016643524  -1.23215413093567
   0.57522326707840  -1.22508060932159
   0.56600785255432  -1.21781289577484
   0.55683541297913  -1.21035408973694
   0.54770720005035  -1.20270740985870
   0.53862458467483  -1.19487595558167
   0.52958887815475  -1.18686318397522
   0.52060145139694  -1.17867243289948
   0.51166349649429  -1.17030680179596
   0.50277632474899  -1.16176998615265
   0.49394109845161  -1.15306520462036
   0.48515912890434  -1.14419603347778
   0.47643154859543  -1.13516581058502
   0.46775957942009  -1.12597823143005
   0.45914432406425  -1.11663687229156
   0.45058691501617  -1.10714507102966
   0.44208851456642  -1.09750676155090
   0.43365013599396  -1.08772540092468
   0.42527288198471  -1.07780468463898
   0.41695779561996  -1.06774818897247
   0.40870586037636  -1.05755984783173
   0.40051811933518  -1.04724323749542
   0.39239549636841  -1.03680217266083
   0.38433894515037  -1.02624034881592
   0.37634941935539  -1.01556169986725
   0.36842781305313  -1.00476980209351
   0.36057496070862  -0.99386870861054
   0.35279172658920  -0.98286205530167
   0.34507897496223  -0.97175377607346
   0.33743748068809  -0.96054774522781
   0.32986804842949  -0.94924771785736
   0.32237139344215  -0.93785762786865
   0.31494826078415  -0.92638140916824
   0.30759936571121  -0.91482281684875
   0.30032539367676  -0.90318578481674
   0.29312697052956  -0.89147418737411
   0.28600478172302  -0.87969189882278
   0.27895939350128  -0.86784279346466
   0.27199140191078  -0.85593080520630
   0.26510134339333  -0.84395974874497
   0.25828978419304  -0.83193349838257
   0.25155723094940  -0.81985598802566
   0.24490414559841  -0.80773097276688
   0.23833100497723  -0.79556238651276
   0.23183822631836  -0.78335398435593
   0.22542624175549  -0.77110970020294
   0.21909542381764  -0.75883322954178
   0.21284613013268  -0.74652844667435
   0.20667870342732  -0.73419916629791
   0.20059344172478  -0.72184902429581
   0.19459065794945  -0.70948195457458
   0.18867060542107  -0.69710153341293
   0.18283350765705  -0.68471157550812
   0.17707960307598  -0.67231565713882
   0.17140905559063  -0.65991759300232
   0.16582205891609  -0.64752095937729
   0.16031874716282  -0.63512933254242
   0.15489923954010  -0.62274640798569
   0.14956361055374  -0.61037564277649
   0.14431196451187  -0.59802067279816
   0.13914434611797  -0.58568495512009
   0.13406075537205  -0.57337194681168
   0.12906122207642  -0.56108516454697
   0.12414572387934  -0.54882800579071
   0.11931420117617  -0.53660380840302
   0.11456660181284  -0.52441596984863
   0.10990284383297  -0.51226782798767
   0.10532280057669  -0.50016260147095
   0.10082635283470  -0.48810350894928];


function   [windowed_data, center_window]=sf_runing_windows(data,window_size, step_size)

%This function gets a vector of data and returns a matrix of
%N X (window_size). data is a 1 X N vector. The step size betwin the
%windows is step_size

%        Writen by Sigal Saar August 08 2005


size_data=size(data,2);
start_window=[1:step_size:(size_data-window_size+1)]';
end_window=[window_size:step_size:size_data]';
center_window = (start_window+end_window)./2; % center of the analysis frame (TO)
char_string_dot=char(':'*ones(length(end_window),1));
char_string_coma=char(';'*ones(length(end_window),1));
starting_string=['[' ; char(' '*ones(length(end_window)-1,1))];
ending_string=[char(' '*ones(length(end_window)-1,1)) ; ']' ];

eval_matrix=[starting_string num2str(start_window) char_string_dot num2str(end_window) char_string_coma ending_string]';
if 1
 %Due to memory problems I splited the calculations
           matrix_is_1=eval([ eval_matrix(1:size(eval_matrix,1)*floor(size(eval_matrix,2)/8)) ']' ]);
           matrix_is_2=eval([ '[' eval_matrix(size(eval_matrix,1)*(floor(size(eval_matrix,2)/8)):size(eval_matrix,1)*(floor(size(eval_matrix,2)/8))*2) ']' ]);
           matrix_is_3=eval([ '[' eval_matrix(size(eval_matrix,1)*(floor(size(eval_matrix,2)/8))*2:size(eval_matrix,1)*(floor(size(eval_matrix,2)/8))*3) ']'  ]);
           matrix_is_4=eval([ '[' eval_matrix(size(eval_matrix,1)*(floor(size(eval_matrix,2)/8))*3:size(eval_matrix,1)*(floor(size(eval_matrix,2)/8))*4) ']' ]);
           matrix_is_5=eval([ '[' eval_matrix(size(eval_matrix,1)*(floor(size(eval_matrix,2)/8))*4:size(eval_matrix,1)*(floor(size(eval_matrix,2)/8))*5) ']' ]);
           matrix_is_6=eval([ '[' eval_matrix(size(eval_matrix,1)*floor(size(eval_matrix,2)/8)*5:size(eval_matrix,1)*(floor(size(eval_matrix,2)/8))*6) ']' ]);
           matrix_is_7=eval([ '[' eval_matrix(size(eval_matrix,1)*floor(size(eval_matrix,2)/8)*6:size(eval_matrix,1)*(floor(size(eval_matrix,2)/8))*7) ']' ]);
           matrix_is_8=eval([ '[' eval_matrix(size(eval_matrix,1)*(floor(size(eval_matrix,2)/8))*7:end)  ]);
   %        windowed_matrix=eval(tmp_char(1:(size(tmp_char,1)*size(tmp_char,2))));

windowed_data=data([ matrix_is_1 ; matrix_is_2 ;matrix_is_3 ;matrix_is_4 ;matrix_is_5 ;matrix_is_6 ;matrix_is_7 ;matrix_is_8]);
else
matrix_is=eval( eval_matrix(1:size(eval_matrix,1)*size(eval_matrix,2)));
windowed_data=data([ matrix_is]);
end
clear matrix_is*



function [param]=sf_Parameters(param,do,location)

%     Written by Sigal Saar 10.25.05
%==============================================================

if nargin==0
    param.fs = 44100;
    param.cutoff= 7.584000000000000e+009;
    param.pad= 1024;
    param.window= 409;
    param.winstep= 44;
    param.cutoff_value= 5.50000000000000;
    param.spectrum_range= 256;
    param.min_freq_winer_ampl= 20;
    param.max_freq_winer_ampl= 200;
    param.up_pitch= 3;
    param.low_pitch= 55;
    param.pitch_HoP= 1800;
    param.gdn_HoP= 100;
    param.up_wiener= -3;
    param.pitch_averaging= 1;
    param.x_length= 750;
    param.y_length= 250;
    param.initial_axes= 'on';
    param.NW= 0;
    param.k= 0;

elseif ~isempty(do) && location(1)~=0
    if strcmpi(do(1:4),'init')

        param.fs=44100;
        param.cutoff=10*758400000;
        param.pad=1024;%index
        param.window=409;%index
        param.winstep=44;%index
        param.cutoff_value=5.5;
        param.spectrum_range=256;%index %???
        param.min_freq_winer_ampl=20;%index 100
        param.max_freq_winer_ampl=200;%index
        param.up_pitch=3;% index 7350hz??
        param.low_pitch=55;%index 400hz??
        param.pitch_HoP=1800;%hz
        param.gdn_HoP=100;
        param.up_wiener=-3;
        param.pitch_averaging=1;%adjust pitch by its goodness
        param.x_length=750;
        param.y_length=250;
        param.initial_axes='on';
        param.NW=0;
        param.k=0;

        save parameters param;

    else
        save parameters param;
    end
else
    display('Action canceled');
end