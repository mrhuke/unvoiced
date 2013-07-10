function noise = noiseEst( eng, intv, pMask )
% estimate noise energy based on inactive units in voiced intervals

nInt = length(intv);
[nChan, nFrame] = size(eng);

noise = zeros(nChan, nFrame);
eng_dB = 10*log10(eng+eps);

if nInt==1 && ~any(any(intv{1}.inactive))  % special treat for all-zero estimate
    apMask = 1-pMask(:,1:5);    % take the first 5 frames
    chn = sum(apMask,2)>0;    
    noise(chn,:) = repmat( sum(eng_dB(chn,1:5).*apMask(chn,:),2)./...
        sum(apMask(chn,:),2), 1, nFrame );
else
    for k = 1:nInt  
        switch intv{k}.type
            case 'v'
                intvMask = zeros(nChan, nFrame);
                intvMask(:, intv{k}.be:intv{k}.ed) = 1;
                noise = noise + eng_dB.*intvMask;
            case 'uv'
                % special treatment for the first and last intervals
                if k==1
                    n_inact = sum(intv{k+1}.inactive, 2);
                    sum_dB = sum(eng_dB.*intv{k+1}.inactive, 2);
                elseif k==nInt
                    n_inact = sum(intv{k-1}.inactive, 2);
                    sum_dB = sum(eng_dB.*intv{k-1}.inactive, 2);
                else
                    n_inact = sum(intv{k-1}.inactive,2) + sum(intv{k+1}.inactive,2);
                    sum_dB = sum(eng_dB.*intv{k-1}.inactive,2) + sum(eng_dB.*intv{k+1}.inactive,2);
                end
                chn_inact = n_inact>0;
                noise_k = zeros(nChan,1);
                noise_k(chn_inact) = sum_dB(chn_inact)./n_inact(chn_inact);

                % search beyond neighboring intervals
                for c = find(~chn_inact)
                    ind_F = k+3; %forward search
                    ind_B = k-3; %backward search

                    bEst = 0;
                    n_inact_F = 0;
                    n_inact_B = 0;
                    sum_dB_F = 0;
                    sum_dB_B = 0;
                    tmpEst = 0;
                    while ~bEst && (ind_F<=nInt || ind_B>=1)
                        % search for inactive units                
                        if ind_F <= nInt
                            n_inact_F = sum(intv{ind_F}.inactive(c,:));
                        end
                        if ind_B >= 1
                            n_inact_B = sum(intv{ind_B}.inactive(c,:));
                        end
                        % inactive units found?
                        if n_inact_F
                            sum_dB_F = sum( eng_dB(c,:).*(intv{ind_F}.inactive(c,:)) );
                            bEst = 1;
                        end
                        if n_inact_B
                            sum_dB_B = sum( eng_dB(c,:).*(intv{ind_B}.inactive(c,:)) );
                            bEst = 1;
                        end
                        % further search
                        ind_F = ind_F+2;
                        ind_B = ind_B-2; 
                    end
                    % found eventually
                    if bEst
                        tmpEst = (sum_dB_F+sum_dB_B)/(n_inact_F+n_inact_B);
                    else
                        % not found, and use 5 initial frames for estimation                    
                        apMask = 1-pMask(c,1:5);
                        if sum(apMask)>0
                            tmpEst = sum(eng_dB(c,1:5).*apMask)/sum(apMask);
                        end
                    end
                    % update estimate
                    noise_k(c) = tmpEst;
                end
                % final estimate
                noise( : , intv{k}.be:intv{k}.ed ) = repmat(noise_k , 1, intv{k}.ed-intv{k}.be+1);
        end
    end
end

% convert back from dB
noise = 10.^(noise/10);
