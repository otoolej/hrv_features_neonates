function tinn=triangular_interp_RR(rr_interval, bin_width)
%---------------------------------------------------------------------
% estimate TINN function
%
% assumes that rr_interval is in seconds
% bin_width is histogram bin width (in seconds)
%
% TINN is best fit of triangular function to histogram 
%
% triangular function defined as: (N, 0) to (X, k) to (M, 0)
% where M>N and X=mode and k=frequency of mode
%

% lifted from: https://github.com/MarcusVollmer/HRV/
% Copyright (c) 2015-2020 Marcus Vollmer; see LICENSE_TINN.md
%---------------------------------------------------------------------
if(nargin<2 || isempty(bin_width)),  bin_width=1/128; end


TI_N=@(N, h) sum((interp1([N length(h)], [0 max(h)], N:length(h))-h(N:length(h))).^2)+sum(h(1:N-1).^2);
TI_M=@(M, h) sum((interp1([1 M], [max(h) 0], 1:M)-h(1:M)).^2)+sum(h(M+1:end).^2);

h=histc(rr_interval, 0:bin_width:3);

% find the location of the mode:
X=find(h==max(h), 1);

% search for N and M for triangular interpolation
if(find(h~=0, 1)<X-1)
    n_fit=NaN(X-1, 1);
    for n=1:X-1
        n_fit(n) = TI_N(n, h(1:X));
    end
    N = find(n_fit==nanmin(n_fit), 1);
else
    N=X-1;
end

if(X<find(h~=0, 1, 'last'))
    m_fit=NaN(length(h)-X, 1);
    for n=1:(length(h)-X)
        m_fit(n)=TI_M(n+1, h(X:end));
    end
    M=find(m_fit==nanmin(m_fit), 1, 'last')+X;
else
    M=X+1;
end

tinn=(M-N)*bin_width;

% convert to milliseconds:
tinn=tinn*1000;
