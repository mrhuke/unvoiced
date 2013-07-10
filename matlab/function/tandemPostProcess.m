function [pitch, vMask] = tandemPostProcess(allMasks, sf, pRange)
% remove pitch contours out of pitch range (pRange)

if nargin==2
    pRange = [70,400];   % 70-400 Hz for pitch range by default
end

pRange = [sf/pRange(2), sf/pRange(1)];

%% remove pitch out of the plausible range
ct = 1;
for k=1:length(allMasks)
    pc = allMasks{k}.pitch;
    out_of_range = sum( pc(pc>0)<pRange(1) | pc(pc>0)>pRange(2) ) / sum(pc>0);  % out-of-range frames
    d_pc = diff( pc(pc>0) );    % stationary pitch frames
    s = sum(d_pc==0)/sum(pc>0);     
    if s<0.6 && out_of_range<0.5  % only retain if this condition is met
        pc(pc>pRange(2)) = 0;   % remove out-of-range pitches
        pc(pc<pRange(1)) = 0;
        newMasks{ct}.pitch = pc;
        msk = allMasks{k}.msk;
        msk(:,pc>pRange(2)) = 0;
        msk(:,pc<pRange(1)) = 0;
        newMasks{ct}.msk = msk;
        ct = ct+1;
    end
end

%% deal with overlapping pitch contours
% produce a pitch contour matrix
allPC = [];
for k=1:length(newMasks)
    allPC = [allPC; newMasks{k}.pitch];
end
% given two overlapping contours, set the pitches in overlapping frames to be those of
% the longer one
b_overlap = sum(allPC>0,1)>1;
while any(b_overlap)
    overlap_frames = find( sum(allPC>0,1)>1 );
    overlap_pc_ind = find( allPC(:,overlap_frames(1))>0 ); % index of overlapping contours
    pc1 = allPC( overlap_pc_ind(1), : );
    pc2 = allPC( overlap_pc_ind(2), : );
    overlap = find( (pc1>0)+(pc2>0)==2 );    % overlapping frames    
    judge = (sum(pc1>0) > sum(pc2>0));    
    if judge
        allPC(overlap_pc_ind(2), overlap) = 0;    % update for loop conditions
        newMasks{overlap_pc_ind(2)}.pitch(overlap) = 0;   % modify the simultaneous streams
        newMasks{overlap_pc_ind(2)}.msk(:,overlap) = 0;        
    else
        allPC(overlap_pc_ind(1), overlap) = 0;
        newMasks{overlap_pc_ind(1)}.pitch(overlap) = 0;
        newMasks{overlap_pc_ind(1)}.msk(:,overlap) = 0;        
    end
    b_overlap = sum(allPC>0,1)>1;
end

%% create overall pitch and mask
pitch = zeros(1, length(newMasks{1}.pitch) );
vMask = zeros( size(newMasks{1}.msk) );
for k = 1:length(newMasks)
    pitch = pitch + newMasks{k}.pitch;
    vMask = vMask + newMasks{k}.msk;
end