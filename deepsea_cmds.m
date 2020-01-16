% this works, remember to remove ._MR file at the beginning in the
% directory
segdata = wholeBreastSegment('/Volumes/ADEBAYO_4/KimtoAdebayo/Breast_Density/IRC10_BREASTTEST_22AUG2013/20130822/701_T1_WO_FAT_SAT_W_2NSA_013082214175964653','Results/','Orientation', 'ax','LateralBounds', true,'VoxelSize',1.2)
% segdata = wholeBreastSegment('/Volumes/ADEBAYO_4/KimtoAdebayo/Breast_Density/IRC10_BREASTTEST_22AUG2013/20130822/701_T1_WO_FAT_SAT_W_2NSA_013082214175964653','Results/','LateralBounds', true)
% test cmd
% segdata = wholeBreastSegment('/Volumes/ADEBAYO_4/Repo/Scripts/BreastImaging/DeepSeA/demoData/AX_T1_BILAT','Results/','LateralBounds', true)

segdata = wholeBreastSegment('/Volumes/ADEBAYO_4/KimtoAdebayo/IRC210H_GUF_PILOT_BREAST_IMAGING/IRC210H_30096/20150828/301_1_1_1_T1W_3D_015082818524124359',...
    'Results/','Orientation', 'ax','LateralBounds', true,'VoxelSize',1.2)
% % 
filename = '/Volumes/ADEBAYO_4/KimtoAdebayo/Breast_Density/IRC10_BREASTTEST_22AUG2013/20130822/701_T1_WO_FAT_SAT_W_2NSA_013082214175964653';
filename = matlab.images.internal.stringToChar(filename);
fileDetails = dicom_getFileDetails(filename);

dicomlist = dir(fullfile(filename, '*.dcm'));

dicomfile = dicomlist(1).name;
dicomheader = dicominfo(fullfile(filename, dicomfile));