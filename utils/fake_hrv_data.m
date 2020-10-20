%-------------------------------------------------------------------------------
% fake_hrv_data: generate the structured array with RR peak information 
%                (noise only, not in anyway realistic)
%
% Syntax: rr_peaks_st = fake_hrv_data(N_babies, N)
%
% Inputs: 
%     N_babies - number of babies/subjects to include (default=2)
%     N        - number of samples (default=7200)
%     db_plot  - plot (default=false)
%
% Outputs: 
%     rr_peaks_st - structured array, with fields:
%                   code: baby ID (e.g. ID_1)
%                   rr_interval: time between consecutive R-peaks
%                   rr_peaks: time of RR peaks (derived fom 'rr_interval')
%
% Example:
%     
%     rr_test_st = fake_hrv_data(5, 7000, true);
% 

% John M. O' Toole, University College Cork
% Started: 20-10-2020
%
% last update: Time-stamp: <2020-10-20 13:41:44 (otoolej)>
%-------------------------------------------------------------------------------
function rr_peaks_st = fake_hrv_data(N_babies, N, db_plot)
if(nargin < 1 || isempty(N_babies)), N_babies = 2; end
if(nargin < 2 || isempty(N)), N = 3600 * 2; end
if(nargin < 3 || isempty(db_plot)), db_plot = false; end


%  generate structured array:
for n = 1:N_babies
    rr_peaks_st(n).code = ['ID_' num2str(n)];
    
    %  coloured Gaussian noise + uniform noise to generate the time between 2 R-R peaks:
    rr_peaks_st(n).rr_interval = abs(0.5 + rand(1, N)./100 + cumsum(randn(1, N))./1000);

    % then the non-uniformed sampled time index:
    rr_peaks_st(n).rr_peaks(1) = 0;
    rr_peaks_st(n).rr_peaks(2:(N + 1)) = cumsum(rr_peaks_st(n).rr_interval);
end


if(db_plot)
    set_figure(2);
    plot([rr_peaks_st(1).rr_peaks(1:end - 1)] ./ 60, rr_peaks_st(1).rr_interval, '-o');
    xlabel('time (minutes)');
    ylabel('RR interval (seconds)');
end




