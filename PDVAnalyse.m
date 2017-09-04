function [ OutVect ] = PDVAnalyse( Spec, Times, Vels, ...
    Errors, Interpolate, MCRuns, ...
    NoiseROI, DataROI)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if (NoiseROI ~= 0)
    [LeftNoise, RightNoise, ...
        BottomNoise, TopNoise] = BoundArgs(Times, Vels, NoiseROI);
    [NoiseOffs, Sigmas] = AssessNoise(Spec, ...
        [LeftNoise RightNoise BottomNoise TopNoise]);
end

ROIMask = createMask(DataROI);
[FirstTArg, LastTArg, FirstVArg, LastVArg] = ...
    BoundArgs(Times, Vels, DataROI);
RedT = Times(FirstTArg:LastTArg);
RedV = Vels(FirstVArg:LastVArg);
RedSpec = Spec(FirstVArg:LastVArg, FirstTArg:LastTArg);
RedMask = ROIMask(FirstVArg:LastVArg, FirstTArg:LastTArg);
RedSpec = RedSpec .* RedMask;
if (NoiseROI ~= 0)
    NoiseMisalign = (FirstVArg - NoiseOffs) + 1;
    RedSigma = Sigmas(NoiseMisalign:(LastVArg - FirstVArg) + NoiseMisalign);
end

TripletOut = 0;

if ((Interpolate == 0) && (Errors == 0))
    [~,MaxInds] = max(RedSpec, [], 1);
    OutVels = RedV(MaxInds);
elseif ((Interpolate == 1) && (Errors == 0))
    if (NoiseROI == 0)
        PassSigmas = 0;
    else
        PassSigmas = RedSigma;
    end
    OutVels = FitGaussian(RedT, RedV, PassSigmas,...
        RedSpec, RedMask, 0);
elseif ((Interpolate == 1) && (Errors == 1))
    assert(NoiseROI ~= 0);
    TripletOut = 1;
    [OutVels, OutError] = MCErrors(RedT, RedV, RedSigma, ...
        RedSpec, RedMask, MCRuns);
elseif (Errors == 2)
    OutVels = FitGaussian(RedT, RedV, 0, RedSpec, RedMask, 1);
end

if (TripletOut)
    OutVect = [transpose(RedT), transpose(OutVels), transpose(OutError)];
else
    OutVect = [transpose(RedT), OutVels];
end
end

function [NoiseOffs, Sigmas] = AssessNoise( Spec, NoiseLims)
LeftArg = NoiseLims(1);
RightArg = NoiseLims(2);
BottomArg = NoiseLims(3);
TopArg = NoiseLims(4);

NoiseRegion = Spec(BottomArg:TopArg,LeftArg:RightArg);
NoiseMean = mean(NoiseRegion, 2);
Sigmas = sqrt(2/pi) * NoiseMean;
NoiseOffs = BottomArg;
end

function [OutVels] = FitGaussian (Times, Vels, Sigmas,...
    Spec, ROIMask, NeedAll)
    if (NeedAll == 0)
        OutVels = zeros([length(Times) 1]);
    else
        OutVels = zeros([length(Times) 3]);
    end
    GaussFit = fittype('gauss1');
    HaveNoise = any(Sigmas);
    if HaveNoise
        Weights = (Sigmas.^-2);
    end
    for i = 1:length(OutVels)
        if (sum(ROIMask(:,i)) < 3)
            OutVels(i,:) = nan;
            continue
        end
        GaussOpts = fitoptions('gauss1');
        GaussOpts.Exclude = ~ROIMask(:,i);
        LowerArg = find(ROIMask(:,i), 1, 'first');
        UpperArg = find(ROIMask(:,i), 1, 'last');
        LowerVel = Vels(LowerArg);
        UpperVel = Vels(UpperArg);
        GaussOpts.Lower = [-Inf LowerVel 0];
        GaussOpts.Upper = [Inf UpperVel Inf];
        if HaveNoise
            GaussOpts.Weights = Weights;
        end
        f = fit(Vels, Spec(:,i), GaussFit, GaussOpts);
        if (NeedAll == 0)
            OutVels(i) = f.b1;
        else
            OutVels(i,:) = [f.a1 f.b1 f.c1];
        end
    end
end

function [OutVels, OutError] = MCErrors (Times, Vels, Sigmas,...
    Spec, ROIMask, MCRuns)
    OutVels = zeros(size(Times));
    OutError = zeros(size(Times));
    Weights = Sigmas.^-2;
    GaussFit = fittype('gauss1');
    
    parfor i = 1:length(OutVels)
        MCOuts = zeros(MCRuns,1);
        MCUsable = zeros(MCRuns,1);
        if (sum(ROIMask(:,i)) < 3)
            OutVels(i) = nan;
            OutError(i) = nan;
            continue
        end
        GaussOpts = fitoptions('gauss1');
        GaussOpts.Exclude = ~ROIMask(:,i);
        LowerArg = find(ROIMask(:,i), 1, 'first');
        UpperArg = find(ROIMask(:,i), 1, 'last');
        LowerVel = Vels(LowerArg);
        UpperVel = Vels(UpperArg);
        GaussOpts.Lower = [-Inf LowerVel 0];
        GaussOpts.Upper = [Inf UpperVel Inf];
        GaussOpts.Weights = Weights;
        f = fit(Vels, Spec(:,i), GaussFit, GaussOpts);
        OutVels(i) = f.b1;
        CurrVels = Vels(LowerArg:UpperArg);
        CurrSigma = Sigmas(LowerArg:UpperArg);
        GaussOpts.Weights = Weights(LowerArg:UpperArg);
        GaussOpts.Exclude = ~ROIMask(LowerArg:UpperArg,i);
        IdealDataMod = f(CurrVels);
        for j = 1:MCRuns
            IdealDataArg = random('Uniform', ...
                -pi, pi, length(IdealDataMod), 1);
            IdealData = (IdealDataMod .* (cos(IdealDataArg) + ...
                (sin(IdealDataArg) * i)));
            NoisyData = abs(IdealData + ...
                random('Normal', 0, CurrSigma) + ...
                (random('Normal', 0, CurrSigma) * i));
            f2 = fit(CurrVels, NoisyData, GaussFit, GaussOpts);
            MCOuts(j) = f2.b1;
            MCUsable(j) = 1;
        end
        OutError(i) = (std(MCOuts) / 0.75);
    end
    disp(size(OutVels))
    disp(size(OutError))
end