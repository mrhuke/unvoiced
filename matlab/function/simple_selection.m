function uMask = simple_selection(ssMask, fRange)

[nChan,nFrame] = size(ssMask);

segments = bwlabel(ssMask);

% knowledge-based segment selection
uMask = zeros(nChan,nFrame);
for k = 1:max(max(segments))
    seg_k = segments==k;
    
    channel_span = find(sum(seg_k,2) > 0);
    time_span = find(sum(seg_k,1) > 0);
    bottom_channel = min(channel_span);
    top_channel = max(channel_span);
        
    cfs = erb2hz(linspace(hz2erb(fRange(1)), hz2erb(fRange(2)), nChan));
    l_bound = 2000;
    h_bound = 6000;
    [dummy, l_channel] = min(abs(cfs-l_bound));    
    [dummy, h_channel] = min(abs(cfs-h_bound));

    if (top_channel>=h_channel || bottom_channel>=l_channel) && length(time_span)>2 && length(time_span)<40 && length(channel_span)<.5*nChan
        uMask = uMask + seg_k;    
    end
end      

