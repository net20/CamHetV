function [ IndexOut ] = IndexSpect( AmpSpect, nLevels )
%INDEXSPECT Summary of this function goes here
%   Detailed explanation goes here
    ScaleFact = range(log(AmpSpect(AmpSpect>0)));
    ScaleOffs = min(log(AmpSpect(AmpSpect>0)));
    
    DispP = (((log(AmpSpect)-ScaleOffs)/ScaleFact)*(nLevels - 1)) + 1;
    
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

