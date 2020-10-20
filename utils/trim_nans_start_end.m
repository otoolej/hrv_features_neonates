function [data,time]=trim_nans_start_end(data,time)
%---------------------------------------------------------------------
% remove blocks of continuous NaNs at start and end of sequence
%---------------------------------------------------------------------
istart=find(~isnan(data),1,'first');
iend=find(~isnan(data),1,'last');
data=data(istart:iend);
if(nargin>1)
    time=time(istart:iend);  
else
    time=[];
end
