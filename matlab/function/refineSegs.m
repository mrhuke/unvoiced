function out_segments = refineSegs(segments,f,t)

if nargin==1
    f = 7;
    t = 2;
end

out_segments = zeros(size(segments));
ct = 1;
for k=1:max(max(segments))
    seg_k = segments==k;
    f_len = sum( sum(seg_k,2)>0 );
    t_len = sum( sum(seg_k,1)>0 );    
    if f_len>f && t_len>t
        out_segments = out_segments + ct*seg_k;
    end
end
       
