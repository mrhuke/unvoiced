function uMask=mlp_classification(ssMask, nChan, fRange)

p=load('../function/bayesClass.mat');

[nChan,nFrame] = size(ssMask);
uMask = zeros(nChan,nFrame);
segments = bwlabel(ssMask);

if max(max(segments))>0
    for k =1:max(max(segments))
        seg_k = segments==k;
        % low,high,size
        in = [find(sum(seg_k,2),1,'first') find(sum(seg_k,2),1,'last')...
                   sum(sum(seg_k))];

        % convert to 64-channel features
        if nChan~=64
            cfs0 = erb2hz(linspace(hz2erb(fRange(1)), hz2erb(fRange(2)), nChan));            
            cfs = erb2hz(linspace(hz2erb(fRange(1)), hz2erb(fRange(2)), 64));            
            [dummy, in(1)] = min(abs(cfs-cfs0(in(1))));    
            [dummy, in(2)] = min(abs(cfs-cfs0(in(2))));
            in(3) = in(3)/(nChan/64)/(nChan/64);
        end      
               
        out = sim(p.net,in');        
        judge = (out>0) && (in(2)-in(1)<35) && (sum(sum(seg_k,1)>0)<=35) && (sum(sum(seg_k,1)>0)>2);
        if judge
            uMask = uMask + seg_k;
        end
    end    
end