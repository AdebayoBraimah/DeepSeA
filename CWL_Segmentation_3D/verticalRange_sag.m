function [validRow] = verticalRange_sag(mask3D)
%[validRow] = VERTICALRANGE_SAG(mask3D)
%   �˴���ʾ��ϸ˵��

linearInd = find(mask3D);
[rowSub,~,~] = ind2sub(size(mask3D), linearInd);
validRow = min(rowSub):max(rowSub);

end

