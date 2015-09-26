function pitchgoodness = pitchgoodnessELM(S,yinPitch,F);
% following aaron's definition of pitch goodness from estimatePitch.m: harmonic power/total power

% create a mask to collect harmonic power
syinPitch = smooth(yinPitch,1)'; 
nF = size(S,1); nt = size(S,2); 
ts = reshape(repmat(1:nt,nF,1),1,nF*nt); 
Fs = reshape(repmat((1:nF)',1,nt),1,nF*nt); 
fwidth = 2*(F(2)-F(1)); 
inHstack = mod(F(Fs),syinPitch(ts))<fwidth | ...
    mod(F(Fs),syinPitch(ts))>(syinPitch(ts) - fwidth); 
% minPitch = 400; % min pitch eligable -- low pitch estimate usually means it's noise; 
% inHstack(syinPitch(ts)<minPitch) = 0; 
mask = reshape(inHstack, nF,nt); 
maskSize = max(sum(mask,1),1)./max(sum(~mask+eps,1),1); % relative size of mask -- this will be bigger for lower frequencies, because they have more harmonics within range
mask = bsxfun(@rdivide, mask, maskSize); % normalize by relative size of the mask
% imagesc(mask); 
harmonicPower = sum(mask.*S,1);
totalPower = sum(S,1); 
pitchgoodness = harmonicPower./(totalPower+eps); 
pitchgoodness = smooth(pitchgoodness,5); 
% plot(pitchgoodness)