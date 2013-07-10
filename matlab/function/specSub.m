function mask = specSub(energy,noiseEst,osub)

speech = energy-osub*noiseEst;
speech = speech.*(speech>0);
mask = 10*log10(speech./(noiseEst*osub+eps)+eps) > 0;
