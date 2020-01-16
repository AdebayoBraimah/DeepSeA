function breastSegSetup(dicomDir, resultsDir, subID, varargin)
%BREASTSEG
% function description
% 
% Required arguments
% - dicomDir: path to the directory that contains that subject's T1w
%               non-fat suppressed image.
% - resultsDir: Output directory to store the corresponding images and
%               information for that subject.
% - subID: Unique subject identifier (can contain strings and integers)
% 
% Optional arguments
% - 'orientation' ['ax','sag']: image orientation of input MR image.
%               Default: 'ax'
% - 'vs' [float/double]: isotropic voxel size (mm) for whole breast
%               segmentation. Recommended values are 1 & 0.5 (mm).
%               Default: 1
% - latBnds [true/false]: Define lateral bounding planes of the breasts.
%               Note: Should be true for 'sag' and false for 'ax'.
%               Default: false
% - botBnds [true/false]: Define inferior bounding plane (this excludes 
%               excessive body fat at the abdomen).
%               Default: false
% - medBnds [true/false]: Define medial bounds that divide the breast.
%               Default: false
% 
% Additional help information can be found from the original source code
% and wholeBreastSegment.m

% Enable environmental variables and paths
MR_startup;

% Parse optional arguments
p = inputParser;
addParameter(p, 'orientation', '', @ischar);
addParameter(p, 'vs', []); % isotropic voxel size in mm
addParameter(p, 'latBnds', [], @islogical);
addParameter(p, 'botBnds', false, @islogical);
addParameter(p, 'medBnds', false, @islogical);

parse(p, varargin{:});

orientation = p.Results.orientation;
vs = p.Results.vs;
latBnds = p.Results.latBnds;
botBnds = p.Results.botBnds;
medBnds = p.Results.medBnds;

% Determine image orientation (if specified)
if ~isempty(orientation) % if user gives imaging orientation
    if strcmpi(orientation, 'ax')
        orientation = 'ax';
    elseif strcmpi(Orientation, 'sag')
        orientation = 'sag';
    else
        error('Unexpected imaging orientation. The input breast MRI must be either axial or sagittal.');
    end
end

% Determine voxel size (if not specified)
if isempty(vs)
    vs = 1;
end

% Perform Breast Segmentation
segdata = wholeBreastSegment(dicomDir,resultsDir,subID,...
    'Orientation',orientation,'VoxelSize',vs,...
    'LateralBounds',latBnds,'BottomBound',botBnds,...
    'MedialBounds',medBnds);

% Exit once finished
% exit

end