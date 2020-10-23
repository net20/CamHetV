function [ IndexOut ] = IndexSpect( AmpSpect, nLevels )
%INDEXSPECT Convert an amplitude spectrum from double to int
%   AmpSpect is an amplitude or power spectrogram, at some
%   floating-point precision (it'll be double, everything in Matlab's a
%   double).  Displaying that directly using imagesc is a bit slow,
%   particularly when zooming and panning.  So this takes logs and
%   quantizes the log spectrogram into nLevels levels, suitable for
%   displaying using image, indexed.  Then squashes it down into the
%   smallest integer type it'll fit.

    ampMin = min(AmpSpect(AmpSpect>0));
    AmpSpect(AmpSpect == 0) = ampMin;
    logSpect = log(AmpSpect);
    ScaleFacts = range(logSpect);
    ScaleOffs = min(logSpect);
    
    DispP = (((logSpect - ScaleOffs) ./ ScaleFacts) * nLevels-1) + 1;
    
    if (nLevels < 256)
    	IndexOut = uint8(DispP);
    elseif (nLevels < 65536)
        IndexOut = uint16(DispP);
    elseif (nLevels < 4294967296)
        IndexOut = uint32(DispP);
    elseif (nLevels < 2^64);
        IndexOut = uint64(DispP);
    else
        IndexOut = DispP;
    end
end

