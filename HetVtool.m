function [ varargout ] = HetVtool( varargin )
%HETVTOOL Summary of this function goes here
%   Detailed explanation goes here
    nargin = size(varargin, 2);
    if (nargin > 0)
        SourceFile = varargin{1};
    else
        SourceFile = uigetfile;
    end
    if strcmp(SourceFile(end-2:end), 'csv')
        InFileID = fopen(SourceFile, 'r');
        C = textscan(InFileID, '%*s %*s %*s %*s %f', 'Delimiter', ',');
        TimeData = C{1};
        fclose(InFileID);
    else
        load(SourceFile);
    end
    OutWindow = figure('Position', [100 100 800 600], 'Resize', 'off');
    SpectView = axes('Units', 'Pixels', ...
        'Position', [75 50 400 400], ...
        'TickDir', 'out');
    
    varargout(1) = {SourceFile};
end