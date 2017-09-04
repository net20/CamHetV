function varargout = SpectGui(varargin)
% SPECTGUI MATLAB code for SpectGui.fig
%      SPECTGUI, by itself, creates a new SPECTGUI or raises the existing
%      singleton*.
%
%      H = SPECTGUI returns the handle to a new SPECTGUI or the handle to
%      the existing singleton*.
%
%      SPECTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPECTGUI.M with the given input arguments.
%
%      SPECTGUI('Property','Value',...) creates a new SPECTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SpectGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SpectGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SpectGui

% Last Modified by GUIDE v2.5 19-Sep-2013 18:36:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SpectGui_OpeningFcn, ...
                   'gui_OutputFcn',  @SpectGui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SpectGui is made visible.
function SpectGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SpectGui (see VARARGIN)

set(hObject, 'Colormap', jet(256));
set(hObject, 'Toolbar', 'figure');
set(handles.SpectAxes, 'NextPlot', 'add');
% Choose default command line output for SpectGui
handles.output = hObject;
handles.GotData = 0;
handles.WindowLength = 0;
handles.NOver = 0;
handles.PadTo = 0;
handles.SampleFreq = 0;
handles.LaserWave = 0;
handles.UpshPlot = 0;
handles.SpectImage = 0;
handles.DataPlot = 0;
handles.LoadType = 0;
handles.StartTime = nan;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SpectGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SpectGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
    FileName = get(hObject, 'String');
    if (handles.LoadType ~= 0)
        FileName = [handles.PathName filesep FileName];
    end
    if (handles.GotData && strcmp(handles.FileName, FileName))
        % Already got the data for this file; no need to load again
        return
    else
        set(hObject, 'BackgroundColor', 'yellow');
        drawnow;
        set(hObject, 'Interruptible', 'off');
        handles.GotData = 0;
        guidata(hObject, handles);
        handles.FileName = FileName;
        try
            switch handles.LoadType
                case 0 % manual filename input
                    if strcmp(FileName(end-2:end), 'csv')
                        handles.TimeData = csvread(FileName, 0, 4);
                    else
                        S = load(FileName);
                        handles.TimeData = S.TimeData;
                    end
                case 1 % Tek CSV
                    TimeDataRaw = csvread(FileName, 0, 4);
                    handles.TimeData = TimeDataRaw(:,1);
                    StartTime = csvread(FileName, 0, 3, [0 3 0 3]);
                    fileId = fopen(FileName,'r');
                    CrudeData = textscan(fileId, '%s %f %s %f %f', 6, ...
                        'delimiter', ',');
                    FileData = CrudeData{1,2};
                    SampleRate = FileData(2).^-1;
                    set(handles.SampFreq,...
                        'String',num2str(SampleRate,'%.8g'));
                    set(handles.StartT,...
                        'String',num2str(StartTime,'%.8g'));
                case 2 % Matlab
                    S = load(FileName);
                    handles.TimeData = S.TimeData;
                case 3 % Tek WFM
                    [y, t, info, ~, ~] = wfm2read(FileName);
                    set(handles.SampFreq,...
                        'String',num2str(info.samplingrate, '%.8g'));
                    handles.TimeData = y;
                    StartTime = t(1);
                    set(handles.StartT,...
                        'String',num2str(StartTime, '%.8g'));
            end
            set(hObject, 'BackgroundColor', 'green');
            handles.GotData = 1;
        catch
            set(hObject, 'BackgroundColor', 'red');
            handles.GotData = 0;
        end
        set(hObject, 'Interruptible', 'on');
        BaseName = FileName(1:find(FileName == '.', 1, 'last')-1);
        set(handles.SaveFileBox, 'String', [BaseName '-data']);
    end
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BrowseFile.
function BrowseFile_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [FileName,PathName,FilterIndex] = uigetfile({'*.csv','Tektronix CSV';...
        '*.mat','Matlab data file';...
        '*.wfm','Tektronix WFM'});
    if (FilterIndex ~= 0)
        handles.PathName = PathName;
        handles.LoadType = FilterIndex;
        set(handles.edit1, 'String', FileName)
        drawnow;
        guidata(hObject, handles);
        edit1_Callback(handles.edit1, eventdata, handles)
    end


function WinLen_Callback(hObject, eventdata, handles)
% hObject    handle to WinLen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WinLen as text
%        str2double(get(hObject,'String')) returns contents of WinLen as a double
    WindowLength = str2num(['uint64(',get(hObject, 'String'),')']);
    if (isempty(WindowLength))
        set(hObject, 'String', num2str(handles.WindowLength));
    else
        handles.WindowLength = WindowLength;
        set(hObject, 'String', num2str(WindowLength));
        set(hObject, 'BackgroundColor', 'white');
        guidata(hObject, handles);
        if (isempty(get(handles.PadLen, 'String')))
            Pow2 = 1;
            while (Pow2 < WindowLength)
                Pow2 = Pow2 * 2;
            end
            set(handles.PadLen, 'String', num2str(Pow2));
            PadLen_Callback(handles.PadLen, eventdata, handles);
        end
        if (isempty(get(handles.NOverlap, 'String')))
            set(handles.NOverlap, ...
                'String', num2str(uint64(WindowLength * 7 / 8)));
            NOverlap_Callback(handles.NOverlap, eventdata, handles);
        end
    end


% --- Executes during object creation, after setting all properties.
function WinLen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WinLen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NOverlap_Callback(hObject, eventdata, handles)
% hObject    handle to NOverlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NOverlap as text
%        str2double(get(hObject,'String')) returns contents of NOverlap as a double
    NOver = str2num(['uint64(',get(hObject, 'String'),')']);
    if (isempty(NOver))
        set(hObject, 'String', num2str(handles.NOver));
    else
        if (NOver >= handles.WindowLength)
            set(hObject, 'BackgroundColor', 'red');
        else
            set(hObject, 'BackgroundColor', 'white');
        end
        set(hObject, 'String', NOver);
        handles.NOver = NOver;
        guidata(hObject, handles);
    end

% --- Executes during object creation, after setting all properties.
function NOverlap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NOverlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PadLen_Callback(hObject, eventdata, handles)
% hObject    handle to PadLen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PadLen as text
%        str2double(get(hObject,'String')) returns contents of PadLen as a double
    PadTo = str2num(['uint64(',get(hObject, 'String'),')']);
    if (isempty(PadTo))
        set(hObject, 'String', num2str(handles.PadTo));
    else
        if (PadTo < handles.WindowLength)
            set(hObject, 'BackgroundColor', 'red');
        else
            Pow2 = 1;
            while (Pow2 < PadTo)
                Pow2 = Pow2 * 2;
            end
            if (Pow2 ~= PadTo)
                set(hObject, 'BackgroundColor', 'yellow');
            else
                set(hObject, 'BackgroundColor', 'white');
            end
            set(hObject, 'String', PadTo);
            handles.PadTo = PadTo;
            guidata(hObject, handles);
        end
    end

% --- Executes during object creation, after setting all properties.
function PadLen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PadLen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SampFreq_Callback(hObject, eventdata, handles)
% hObject    handle to SampFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SampFreq as text
%        str2double(get(hObject,'String')) returns contents of SampFreq as a double
SampleFreq = str2double(get(hObject, 'String'));
if isnan(SampleFreq)
    set(hObject, 'String', num2str(handles.SampleFreq));
else
    handles.SampleFreq = SampleFreq;
    set(hObject, 'BackgroundColor', 'white');
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function SampFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SampFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function StartT_Callback(hObject, eventdata, handles)
% hObject    handle to StartT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartT as text
%        str2double(get(hObject,'String')) returns contents of StartT as a double
StartTime = str2double(get(hObject, 'String'));
if isnan(StartTime)
    set(hObject, 'String', num2str(handles.StartTime));
else
    handles.StartTime = StartTime;
    set(hObject, 'BackgroundColor', 'white');
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function StartT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in CalcSpectrogram.
function CalcSpectrogram_Callback(hObject, eventdata, handles)
% hObject    handle to CalcSpectrogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'Interruptible', 'off');
set(hObject, 'String', 'Calculating...');
set(hObject, 'Enable', 'off');
FailOut = 0;
if (handles.GotData == 0)
    FailOut = 1;
    set(handles.edit1, 'BackgroundColor', 'red');
end

if (handles.WindowLength == 0)
    if isempty(get(handles.WinLen, 'String'))
        set(handles.WinLen, 'BackgroundColor', 'red');
        FailOut = 1;
    else
        WinLen_Callback(handles.WinLen, eventdata, handles);
        handles = guidata(hObject);
        if (handles.WindowLength == 0)
            set(handles.WinLen, 'BackgroundColor', 'red');
            FailOut = 1;
        end
    end
end

if (handles.NOver == 0)
    if isempty(get(handles.NOverlap, 'String'))
        set(handles.NOverlap, 'BackgroundColor', 'red');
        FailOut = 1;
    else
        NOverlap_Callback(handles.NOverlap, eventdata, handles);
        handles = guidata(hObject);
        if (handles.NOver == 0)
            set(handles.NOverlap, 'BackgroundColor', 'red');
            FailOut = 1;
        end
    end
end

if (handles.PadTo == 0)
    if isempty(get(handles.PadLen, 'String'))
        set(handles.PadLen, 'BackgroundColor', 'red');
        FailOut = 1;
    else
        PadLen_Callback(handles.PadLen, eventdata, handles);
        handles = guidata(hObject);
        if (handles.PadTo == 0)
            set(handles.PadLen, 'BackgroundColor', 'red');
            FailOut = 1;
        end
    end
end

if (handles.SampleFreq == 0)
    if isempty(get(handles.SampFreq, 'String'))
        set(handles.SampFreq, 'BackgroundColor', 'red');
        FailOut = 1;
    else
        SampFreq_Callback(handles.SampFreq, eventdata, handles);
        handles = guidata(hObject);
        if (handles.SampleFreq == 0)
            set(handles.SampFreq, 'BackgroundColor', 'red');
            FailOut = 1;
        end
    end
end

if (handles.LaserWave == 0)
    if isempty(get(handles.LasFreq, 'String'))
        set(handles.LasFreq, 'BackgroundColor', 'red');
        FailOut = 1;
    else
        LasFreq_Callback(handles.LasFreq, eventdata, handles);
        handles = guidata(hObject);
        if (handles.LaserWave == 0)
            set(handles.LasFreq, 'BackgroundColor', 'red');
            FailOut = 1;
        end
    end
end

if isnan(handles.StartTime)
    if isempty(get(handles.StartT, 'String'))
        set(handles.StartT, 'BackgroundColor', 'red');
        FailOut = 1;
    else
        StartT_Callback(handles.StartT, eventdata, handles);
        handles = guidata(hObject);
        if isnan(handles.StartTime)
            set(handles.StartT, 'BackgroundColor', 'red');
            FailOut = 1;
        end
    end
end

if (FailOut == 0)
    drawnow;
    [S, F, T, P] = spectrogram(handles.TimeData, ...
        gausswin(double(handles.WindowLength), 1.9143*sqrt(2*pi)), ...
        double(handles.NOver), double(handles.PadTo), handles.SampleFreq);
    F = F * 0.5 * handles.LaserWave;
    T = T + handles.StartTime;
    handles.DispP = IndexSpect(P,256);
    handles.Vels = F;
    handles.Times = T;
    handles.Spect = S;
    if (handles.SpectImage == 0)
        handles.SpectImage = image('Parent', handles.SpectAxes, ...
            'CData', handles.DispP, ...
            'CDataMapping', 'direct', ...
            'XData', [T(1) T(end)], ...
            'YData', [F(1) F(end)]);
    else
        set(handles.SpectImage, 'CData', handles.DispP);
        set(handles.SpectImage, 'XData', [T(1) T(end)]);
        set(handles.SpectImage, 'YData', [F(1) F(end)]);
        drawnow;
    end
    guidata(hObject, handles);
end

set(hObject, 'Interruptible', 'on');
set(hObject, 'String', 'Calculate');
set(hObject, 'Enable', 'on');
        

function LasFreq_Callback(hObject, eventdata, handles)
% hObject    handle to LasFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LasFreq as text
%        str2double(get(hObject,'String')) returns contents of LasFreq as a double
LaserWave = str2double(get(hObject, 'String'));
if isnan(LaserWave)
    set(hObject, 'String', num2str(handles.LaserFreq));
else
    handles.LaserWave = LaserWave;
    set(hObject, 'BackgroundColor', 'white');
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function LasFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LasFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on LasFreq and none of its controls.
function LasFreq_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to LasFreq (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in DefROI.
function DefROI_Callback(hObject, eventdata, handles)
% hObject    handle to DefROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.PolyROI = impoly(handles.SpectAxes);
set(handles.ROIDefinedInd, 'Value', 1);
guidata(hObject, handles);


% --- Executes on button press in ROIDefinedInd.
function ROIDefinedInd_Callback(hObject, eventdata, handles)
% hObject    handle to ROIDefinedInd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ROIDefinedInd


% --- Executes on button press in InterpCBox.
function InterpCBox_Callback(hObject, eventdata, handles)
% hObject    handle to InterpCBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of InterpCBox


% --- Executes on button press in ErrorCBox.
function ErrorCBox_Callback(hObject, eventdata, handles)
% hObject    handle to ErrorCBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ErrorCBox



function MCRunsInput_Callback(hObject, eventdata, handles)
% hObject    handle to MCRunsInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MCRunsInput as text
%        str2double(get(hObject,'String')) returns contents of MCRunsInput as a double


% --- Executes during object creation, after setting all properties.
function MCRunsInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MCRunsInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in NoiseRegionBut.
function NoiseRegionBut_Callback(hObject, eventdata, handles)
% hObject    handle to NoiseRegionBut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.NoiseROI = imrect(handles.SpectAxes);
set(handles.NoiseDefinedInd, 'Value', 1);
guidata(hObject, handles);


% --- Executes on button press in NoiseDefinedInd.
function NoiseDefinedInd_Callback(hObject, eventdata, handles)
% hObject    handle to NoiseDefinedInd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NoiseDefinedInd


% --- Executes on button press in ExtractDataButton.
function ExtractDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to ExtractDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'Interruptible', 'off');
set(hObject, 'String', 'Extracting...');
set(hObject, 'Enable', 'off');
HaveNoise = get(handles.NoiseDefinedInd, 'Value');
HaveROI = get(handles.ROIDefinedInd, 'Value');
Errors = get(handles.ErrorCBox, 'Value');
Interp = get(handles.InterpCBox, 'Value');
MCRuns = str2double(get(handles.MCRunsInput, 'String'));

if HaveROI
    drawnow;
    if HaveNoise
        Noise = handles.NoiseROI;
    else
        Noise = 0;
    end
    handles.FoundData = PDVAnalyse(abs(handles.Spect), handles.Times, ...
        handles.Vels, Errors, Interp, MCRuns, ...
        Noise, handles.PolyROI);
    if (handles.DataPlot == 0)
        handles.DataPlot = plot(handles.FoundData(:,1),...
            handles.FoundData(:,2),...
            'Parent', handles.SpectAxes);
    else
        set(handles.DataPlot, 'XData', handles.FoundData(:,1));
        set(handles.DataPlot, 'YData', handles.FoundData(:,2));
        drawnow;
    end
    set(handles.SaveDataBtn, 'Enable', 'on');
    guidata(hObject, handles);
end

set(hObject, 'Interruptible', 'on');
set(hObject, 'String', 'Extract data');
set(hObject, 'Enable', 'on');

function SaveFileBox_Callback(hObject, eventdata, handles)
% hObject    handle to SaveFileBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SaveFileBox as text
%        str2double(get(hObject,'String')) returns contents of SaveFileBox as a double


% --- Executes during object creation, after setting all properties.
function SaveFileBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaveFileBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in SaveDataBtn.
function SaveDataBtn_Callback(hObject, eventdata, handles)
% hObject    handle to SaveDataBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FileName = get(handles.SaveFileBox, 'String');
if exist(FileName, 'file')
    OverwriteButton = questdlg('Output file already exists.  Overwrite?', ...
        'Confirmation request', 'Yes', 'No', 'No');
    switch OverwriteButton
        case 'Yes'
            Cancelled = 0;
        case 'No'
            Cancelled = 1;
    end
else
    Cancelled = 0;
end

if ~Cancelled
    OutData = handles.FoundData;
    save(FileName, 'OutData', '-ascii', '-double', '-tabs');
end


% --- Executes on button press in UpshROIButt.
function UpshROIButt_Callback(hObject, eventdata, handles)
% hObject    handle to UpshROIButt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.UpshROI = imrect(handles.SpectAxes);
set(handles.UpshRoiDefdCheck, 'Value', 1);
guidata(hObject, handles);


% --- Executes on button press in UpshRoiDefdCheck.
function UpshRoiDefdCheck_Callback(hObject, eventdata, handles)
% hObject    handle to UpshRoiDefdCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UpshRoiDefdCheck


% --- Executes on button press in RemUpshGoButt.
function RemUpshGoButt_Callback(hObject, eventdata, handles)
% hObject    handle to RemUpshGoButt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
HaveRoi = get(handles.UpshRoiDefdCheck, 'Value');
if (HaveRoi)
    set(hObject, 'Interruptible', 'off');
    set(hObject, 'String', 'Working...');
    set(hObject, 'Enable', 'off');
    DetectedData = PDVAnalyse(abs(handles.Spect), handles.Times, ...
        handles.Vels, 2, 1, 0, 0, handles.UpshROI);
    if (handles.UpshPlot == 0)
        handles.UpshPlot = plot(handles.SpectAxes, ...
            DetectedData(:,1), DetectedData(:,3));
    else
        set(handles.UpshPlot, 'XData', DetectedData(:,1));
        set(handles.UpshPlot, 'YData', DetectedData(:,3));
    end
    Height = mean(DetectedData(~isnan(DetectedData(1:end,2)),2));
    Position = mean(DetectedData(~isnan(DetectedData(1:end,3)),3));
    Width = mean(DetectedData(~isnan(DetectedData(1:end,4)),4));
    SubVals = feval(fittype('gauss1'), ...
        Height, Position, Width, ...
        handles.Vels);
    [FirstTArg, LastTArg, ~, ~] = ...
        BoundArgs(handles.Times, handles.Vels, handles.UpshROI);
    handles.Spect(:,FirstTArg:LastTArg) = ...
        SubMagnitude(handles.Spect(:,FirstTArg:LastTArg), SubVals);
    handles.DispP = IndexSpect(abs(handles.Spect),256);
    set(handles.SpectImage, 'CData', handles.DispP);
    set(handles.UpshReadout, 'String', num2str(Position));
    set(hObject, 'Interruptible', 'on');
    set(hObject, 'String', 'Remove upshift');
    set(hObject, 'Enable', 'on');
    guidata(hObject, handles);
end

function UpshReadout_Callback(hObject, eventdata, handles)
% hObject    handle to UpshReadout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of UpshReadout as text
%        str2double(get(hObject,'String')) returns contents of UpshReadout as a double


% --- Executes during object creation, after setting all properties.
function UpshReadout_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UpshReadout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in FigureBreakoutButton.
function FigureBreakoutButton_Callback(hObject, eventdata, handles)
% hObject    handle to FigureBreakoutButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f = figure();
exes = get(handles.SpectAxes, 'XLim').*1e6;
whys = get(handles.SpectAxes, 'YLim');
cm = get(get(handles.SpectAxes,'Parent'), 'ColorMap');
a = axes('Parent', f, ...
         'XLim', exes, ...
         'YLim', whys, ...
         'XLimMode', 'manual', ...
         'YLimMode', 'manual', ...
         'Layer', 'top', ...
         'Box', 'on');
set(get(a,'XLabel'), 'String', 'Time / us');
set(get(a,'YLabel'), 'String', 'Velocity / ms-1');
set(f, 'Color', 'white');
set(f, 'ColorMap', cm);
image('Parent', a, ...
      'CData', handles.DispP, ...
      'CDataMapping', 'direct', ...
      'XData', [handles.Times(1) handles.Times(end)].*1e6, ...
      'YData', [handles.Vels(1) handles.Vels(end)]);