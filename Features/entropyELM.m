function Entropy = entropyELM(S);
nF = size(S,1);
sumlog = sum(log(S)+eps,1)/nF; 
Sum = (sum(S,1)); 
Sum(Sum==0)=nF; % to avoid taking log of 0
logsum=log(Sum/nF); %divide by the number of frequencies
Entropy=sumlog-logsum;
Entropy(logsum==0)=0;