function [diffMap,CWL_ROI] = colwiseLearn(the_col,the_slc,d_field,half_height,half_width,paddedVol,respMap,CWL_ROI,reducedROI,gloTemp)
%[diffMap,CWL_ROI]=COLWISELEARN(the_col,the_slc,d_field,half_height,half_width,paddedVol,respMap,CWL_ROI,reducedROI,gloTemp)
%   Detailed explanation goes here

w = [0 0 0 0 0];
template = zeros(2*half_height+1,2*half_width+1);
% search for a neareast neighbor in the four upright directions
[nc,ns] = search_4neareastNeighbors(d_field,the_col,the_slc);
for m = 1:4
    if ~isempty(nc{m}) && ~isempty(ns{m})
        padded_slice = paddedVol(:,:,half_width+ns{m});
        % extract template right here
        temp_temp = padded_slice( d_field(nc{m},ns{m})+(0:2*half_height), nc{m}+(0:2*half_width) );
        % weighted by response strength & distance
        w(m) = respMap(d_field(nc{m},ns{m}),nc{m},ns{m}) / (1+abs(the_col-nc{m})+abs(the_slc-ns{m}));
        template = template + w(m)*temp_temp;
    end
end
padded_slice = paddedVol(:,:,half_width+the_slc);
if d_field(the_col,the_slc)
    % if the current location has a valid depth itself, that should
    % be counted as well    
    temp_temp = padded_slice( d_field(the_col,the_slc)+(0:2*half_height), the_col+(0:2*half_width) );
    w(5) = respMap(d_field(the_col,the_slc),the_col,the_slc);
    template = template + w(5)*temp_temp;
    
    % also reduce CWL_ROI to speed up a little bit
    CWL_ROI = CWL_ROI & reducedROI;
end
if any(w)
    template = template/sum(w);
else
    warning('CWL_localiseAx:colwiseLearn:noValidNeighbor', ['No valid neighbor ' ...
        'found (including itself) and/or all zeros reponse: using globally adapted template.'])
    template = gloTemp;
end
%         % visual display codes that generate figure for paper
%        if k==17 && i==44
%             figure('Name',num2str(i));
%             imagesc(template);
%             colormap(gray);
%             axis image off
%         end

% col-wise filtering
% first extract effective rows
candi = find(CWL_ROI);
diffMap = ones(size(CWL_ROI));
for i = candi'
    jpatch = padded_slice( i+(0:2*half_height), the_col+(0:2*half_width) );
    % calculate difference
    diffMap(i) = norm(template(:)-jpatch(:));
end

end

