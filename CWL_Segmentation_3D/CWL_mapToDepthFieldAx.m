function [d_field] = CWL_mapToDepthFieldAx(CWL_map)
%[d_field]=CWL_MAPTO_D_FIELDAX(CWL_map) �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��

[~,col,slc] = size(CWL_map);

d_field = zeros(col,slc);
for k = 1:slc
    [R,C]=find(CWL_map(:,:,k));
    d_field(C,k)=R;
end

end

