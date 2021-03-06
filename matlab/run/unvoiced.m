function [mask, uMask, vMask, pitch] = unvoiced(mixture, pRange, grpMethod, nChan, Srate, workFolder)
% This program implements the algorithm in "Unvoiced speech separation from 
% nonspeech interference via CASA and spectral subtraction," by K. Hu and 
% D. L. Wang in IEEE Trans. Audio, Speech, and Lang. Process., vol. 19, pp.
% 1600-1609, 2011.
%
% This program segregates speech from nonspeech noise in monaural
% mixtures. Both voiced and unvoiced speech is segregated, where voiced
% speech is segregated by a tandem algorithm (Hu & Wang'10) and unvoiced
% speech by the aforementioned paper.
%
% Input : - mixture is a time-domain 16-kHz noisy speech signal
%         - pRange is the range for estimated pitch in the tandem
%           algorithm (use 70 to 400 Hz in a general situation)
%         - grpMethod is a string ("thresholding" or "mlp") specifiying 
%           unvoiced speech grouping method 
%         - nChan is the number of gammatone filters
%         - Srate is the sampling frequency
%         - workFoler is a folder storing temporary files
%
% Output: - mask is an estimated voiced binary mask
%         - uMask is an estimated unvoiced binary mask
%         - vMask is an estimated overall binary mask
%         - pitch is an estimated pitch

addpath('../function/')

params = struct('Srate',Srate,'lc',0,'osub',2,'uvGrp',grpMethod,'nChan',nChan,'workFolder',workFolder);

%% 1. Voiced speech segregation by a tandem algorithm (Hu & Wang'10)
fprintf('Voiced speech segregation...\n');
[allMasks params] = runTandem(mixture, params);
[pitch vMask] = tandemPostProcess(allMasks, 20000, pRange); % 20kHz because of resampling
fprintf('Done.\n');

%% 2. Periodic signal removal
% read cross-channel correlations
cross=load([params.crossFN,'.',num2str(params.nChan)])';         
evCross=load([params.evCrossFN,'.',num2str(params.nChan)])';
if params.nChan == 128
    crossMask = cross>.985 | evCross>.985;
else
    crossMask = cross>.9 | evCross>.96;
end
                                                                                        
%% 3. Unvoiced speech segmentation based on spectral subtraction
fprintf('Unoiced speech segregation...');
pMask = sign(vMask + crossMask);
intv = intervals(pMask, pitch); % find voiced intervals
eng = load([params.engFN,'.',num2str(params.nChan)])';
noise = noiseEst(eng, intv, pMask); % noise estimation
voiced_n_noise = noise.*(1-pMask)+eng.*pMask;
ssMask = specSub(eng, voiced_n_noise, params.osub); % spectral subtraction
ssMask(:, pitch>0) = 0;
tmpSegs = bwlabel(ssMask,4);
ssSegs = refineSegs(tmpSegs); % remove isolated regions
ssMask = sign(ssSegs);

%% 4. Grouping unvoiced speech
switch params.uvGrp
    case 'thresholding'
        uMask = simple_selection(ssMask, [50,8000]);    
    case 'mlp'
        uMask= mlp_classification(ssMask, params.nChan, [50,8000]);   
end       
fprintf('Done.\n');

%% 5. produce the overall mask
mask = sign(vMask+uMask);

% remove temporary files
files = dir([params.prefix,'*']);
folder = fileparts(params.prefix);
for k=1:length(files)
    delete([folder,'/',files(k).name]);
end