%-------------------------------------------------------------------------------
% find_closest: find closet value v in vector x
%
% Syntax: [c, idx] = find_closest(x, v)
%
% Inputs: 
%     x, v - 
%
% Outputs: 
%     [c, idx] - 
%
% Example:
%     
%

% John M. O' Toole, University College Cork
% Started: 02-04-2019
%
% last update: Time-stamp: <2019-04-02 11:46:52 (otoolej)>
%-------------------------------------------------------------------------------
function [c, idx] = find_closest(x, v)
%---------------------------------------------------------------------
% find value in array 'x' closest to value 'v'
%---------------------------------------------------------------------
[~,idx]=min( abs(x-v) );
c=x(idx);

