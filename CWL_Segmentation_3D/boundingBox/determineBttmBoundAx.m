function [validSlc] = determineBttmBoundAx(masks,slices,spacing,validSlc,coreMethod,visualize)
%DETERMINEBTTMBOUNDAX �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��

% parse inputs
if ~exist('visualize', 'var')
    visualize = false;
end

% re-arrange data in sagittal view
masks = reformatAx2Sag(masks);
slices = reformatAx2Sag(slices);
spacing = [spacing(3) spacing(1) spacing(2)];
% positive direction of the sagittal rows is the negative direction of the axial slices
validRow = size(masks,1) - validSlc(end:-1:1) + 1; 

% then call the designated sagittal method
validRow = coreMethod(masks,slices,spacing,validRow,visualize);

validSlc = size(masks,1) - validRow(end:-1:1) + 1;

end

