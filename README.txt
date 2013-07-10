This folder contains the algorithm in "Unvoiced speech separation from 
nonspeech interference via CASA and spectral subtraction," by K. Hu and 
D. L. Wang in IEEE Trans. Audio, Speech, and Lang. Process., vol. 19, pp.
1600-1609, 2011.

This program segregates speech from nonspeech noise in monaural
mixtures. Both voiced and unvoiced speech is segregated, where voiced
speech is segregated by a tandem algorithm (Hu & Wang'10) and unvoiced
speech by the aforementioned paper.

Main processing steps include:
1. Voiced speech segregation by a tandem algorithm (Hu & Wang'10)
2. Periodic signal removal
3. Unvoiced speech segmentation based on spectral subtraction
4. Grouping unvoiced speech

Syntax: [mask, uMask, vMask, pitch] = unvoiced(mixture, pRange, grpMethod, nChan, Srate, workFolder)

Input : - mixture is a time-domain noisy speech signal
	- pRange (in Hz) is the range for estimated pitch in the tandem
          algorithm (use [70,400] in a general situation)
        - grpMethod ('thresholding' or 'mlp') specifiies unvoiced speech grouping method 
        - nChan is the number of gammatone filters (64 or 128)
        - Srate is the sampling frequency (in Hz) of the input mixture
        - workFolder is a folder storing temporary files

Output: - mask is an estimated voiced binary mask
        - uMask is an estimated unvoiced binary mask
        - vMask is an estimated overall binary mask
        - pitch is the correspoding estimated pitch

To run an example program, do the following:
1. In a linux system, start MATLAB
2. Go to "matlab/run" folder and execute the following
3. mixture = load('mixture');
4. [mask, uMask, vMask, pitch] = unvoiced(mixture, [160, 290], 'thresholding', 128, 16000, '.');

Note:
- The 64-channel tandem algorithm used in this program has been updated due to implementation changes of the original tandem algorithm, 6/7/2012
