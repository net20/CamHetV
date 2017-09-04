function [LeftArg, RightArg, BottomArg, TopArg] = ...
    BoundArgs (Times, Vels, ROI)
RoiPos = getPosition(ROI);
RoiSize = size(RoiPos);
if all(RoiSize == [1 4])
    % Rectangular ROI
    LeftArg = find(Times > RoiPos(1), 1, 'first');
    RightArg = find(Times < (RoiPos(1) + RoiPos(3)), 1, 'last');
    BottomArg = find(Vels > RoiPos(2), 1, 'first');
    TopArg = find(Vels < (RoiPos(2) + RoiPos(4)), 1, 'last');
else
    % Polygonal ROI
    LeftPos = min(RoiPos(:,1));
    RightPos = max(RoiPos(:,1));
    BottomPos = min(RoiPos(:,2));
    TopPos = max(RoiPos(:,2));
    LeftArg = find(Times > LeftPos, 1, 'first');
    RightArg = find(Times < RightPos, 1, 'last');
    BottomArg = find(Vels > BottomPos, 1, 'first');
    TopArg = find(Vels < TopPos, 1, 'last');
end

if (LeftArg > 1)
    LeftArg = LeftArg - 1;
end
if (BottomArg > 1)
    BottomArg = BottomArg - 1;
end
if (RightArg < length(Times))
    RightArg = RightArg + 1;
end
if (TopArg < length(Vels))
    TopArg = TopArg + 1;
end
end