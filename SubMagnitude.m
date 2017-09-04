function [ OutSpect ] = SubMagnitude( Spect, SubVals )
%SUBMAGNITUDE Summary of this function goes here
%   Detailed explanation goes here
    Args = angle(Spect);
    SubValue = bsxfun(@times, cos(Args) + (sin(Args)*1i), SubVals);
    OutSpect = Spect - SubValue;
end

