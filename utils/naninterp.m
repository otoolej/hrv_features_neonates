function [X,inan]=naninterp(X,method)
%---------------------------------------------------------------------
% From Matlab-Central: fill 'gaps' in data (marked by NaN) 
% by interpolating
%---------------------------------------------------------------------
if(nargin<2 || isempty(method)), method='linear'; end


inan=find(isnan(X));
if(isempty(inan))
  return;
elseif(length(inan)==1)
  if(inan>1)
    X(inan)=X(inan-1);
  else
    X(inan)=X(inan+1);
  end
else
    try
        X(inan)=interp1(find(~isnan(X)), X(~isnan(X)), inan, method);
    catch
        error('linear interpolation with NaNs');
    end
end

