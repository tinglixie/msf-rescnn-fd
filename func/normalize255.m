% Normalize to 0~1
function [ Out ] = normalize255(In)  
ymax=255;
ymin=0;  
xmax = max(max(In));   
xmin = min(min(In));  
Out = round((ymax-ymin)*(In-xmin)/(xmax-xmin) + ymin);
end  

