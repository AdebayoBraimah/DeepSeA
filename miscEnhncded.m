dicomdir = '/Volumes/ADEBAYO_4/KimtoAdebayo/IRC210H_GUF_PILOT_BREAST_IMAGING/IRC210H_30096/20150828/301_1_1_1_T1W_3D_015082818524124359';
dicomdir = '/Volumes/ADEBAYO_4/KimtoAdebayo/Breast_Density/IRC10_BREASTTEST_22AUG2013/20130822/701_T1_WO_FAT_SAT_W_2NSA_013082214175964653';

% num_dicom % set conditional here...

% num_dicom corresponds to the number of slices
% and as such, in enhanced dicoms, the variable
% NumberOfFrames corresponds to the same variable 
% as well.

if ( num_dicom == 1)
    dicomfile = dicomlist(1).name;
    dicomheader = dicominfo(fullfile(dicomdir, dicomfile));
    % sliceLocations = zeros(num_dicom,1);
    sliceLocations = zeros(dicomheader.NumberOfFrames,1);
    sliceLocations(1) = dicomheader.NumberOfFrames;
    
    % iterate through slices
    num_dicom = dicomheader.NumberOfFrames;
    
    % defer dicom fidelity checks
    slices = zeros(dicomheader.Rows, dicomheader.Columns,num_dicom);
    % read images
    for i = 1:num_dicom
        fprintf('\b\b\b%03d', num_dicom, 1);
        dicomfile = dicomlist().name;
        imgdata = dicomread(fullfile(dicomdir, dicomfile));
        if isempty(imgdata)
            error('DICOM file %s is empty!', dicomfile);
        else
            slices(:,:,i) = imgdata(:,:,1,i);
        end
    end
    % find:
    % - dicomheader.PixelSpacing, info.PixelSpacing
    % dicomheader.SliceThickness, info.SliceThickness
    
    