function intv = intervals(pMask,pitch)

[nChan nFrame] = size(pMask);

voiced = pitch>0;
d_pitch = diff( [1 voiced] );
bounds = find( d_pitch~=0 );

% forming intervals
for k = 1:length(bounds)
    % interval bounds
    intv{k}.be = bounds(k);
    if k == length(bounds)
        intv{k}.ed = nFrame;
    else
        intv{k}.ed = bounds(k+1)-1;
    end
    % interval type
    if d_pitch(bounds(k))>0
        intv{k}.type = 'v';
    else
        intv{k}.type = 'uv';
    end    
    % inactive units in this interval    
    tmp = zeros(nChan, nFrame);
    tmp( :,intv{k}.be:intv{k}.ed ) = 1;
    intv{k}.mask = tmp;
    if strcmp(intv{k}.type,'v')                        
        intv{k}.inactive = tmp.*(1-pMask);        
    else
        intv{k}.inactive = 0;   % not used
    end    
end
