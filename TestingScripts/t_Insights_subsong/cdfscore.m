function newdatavec = cdfscore(datavec, percentiles)
% passes data through cdf, so values range from 0 to 1 with maximal
% discriminability. If there's baseline noise you want to ignore, set
% everything less than the baseline to zero before passing through
% cdfscore. Use percentiles to flatten everything except what's between the
% percentiles
% -ELM 8/20/2015

if nargin < 2; percentiles=[0 100]; end
[n m] = size(datavec); 
if n>1 & m>1
    newdatavec = zeros(n,m); 
    for i = 1:m
        newdatavec(:,i) = cdfscore(datavec(:,i), percentiles); 
    end
else
    upbnd = prctile(datavec,percentiles(2)); 
    lowbnd = prctile(datavec,percentiles(1)); 
    datavec(datavec<lowbnd) = lowbnd; 
    datavec(datavec>upbnd) = upbnd; 

    [C,ia,ic] = unique(datavec); 
    L = length(C); 
    r = 1:L; 
    [~,sortind] = sort(C); 
    [~,unsortind] = sort(sortind); 
    ranks = r(unsortind); 
    newdatavec = ranks(ic)/L; 
end