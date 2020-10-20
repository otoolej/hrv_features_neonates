%-------------------------------------------------------------------------------
% hrv_features: generate standard HRV features from RR interval time series
%
% Syntax: hrv_feats_st=hrv_features(rr_peaks_st)
%
% Inputs: 
% 
%     rr_peaks_st - structured array, with fields:
%                   code: baby ID (e.g. ID_1)
%                   rr_interval: time between consecutive R-peaks
%                   rr_peaks: time of RR peaks (derived fom 'rr_interval')
%      params     - parameters (defaults in hrv_EAR.m)
%
% Outputs: 
%     hrv_feats_avg_tb    - table of features averaged (median) over the total HRV
%     hrv_feats_epochs_tb - table of features for each epoch 
%
% Example:
%     rr_test_st = fake_hrv_data();
%     [hrv_avg_tb, hrv_epochs_tb] = hrv_features(rr_test_st);
% 
%     disp(head(hrv_avg_tb));
%

% John M. O' Toole, University College Cork
% Started: 02-11-2017
%
% last update: Time-stamp: <2020-10-20 17:46:58 (otoolej)>
%-------------------------------------------------------------------------------
function [hrv_feats_avg_tb, hrv_feats_epoch_tb] = hrv_features(rr_peaks_st, params)
if(nargin < 1 || isempty(rr_peaks_st)), rr_peaks_st=[]; end
if(nargin < 2 || isempty(params)), params = hrv_EAR; end

DBverbose = 0;




% empty table for the features:
hrv_feats_avg_tb = array2table(NaN(length(rr_peaks_st), length(params.hrv_vars)), ...
                               'VariableNames', params.hrv_vars);
hrv_feats_ID_info = cell2table(cell(length(rr_peaks_st), 1), 'VariableNames', {'code'});
hrv_feats_avg_tb = [hrv_feats_ID_info hrv_feats_avg_tb];
istart_feat_tb = width(hrv_feats_avg_tb) - length(params.hrv_vars);
hrv_feats_epoch_tb = [];


%---------------------------------------------------------------------
% iterate for each baby
%---------------------------------------------------------------------
for n=1:length(rr_peaks_st)
    hrv_feats_avg_tb.code(n) = {rr_peaks_st(n).code};
    if(DBverbose)
        fprintf('baby = %s\n', rr_peaks_st(n).code);    
    end

    
    % segment into epochs:
    N = length(rr_peaks_st(n).rr_interval);    
    if(~isempty(params.L_hrv_epoch))
        time_epochs = buffer(rr_peaks_st(n).rr_peaks(1):rr_peaks_st(n).rr_peaks(end), ...
                             params.L_hrv_epoch, ...
                             params.L_hrv_epoch * (params.L_overlap / 100), 'nodelay');
        time_epochs(time_epochs(:, end) == 0, end) = max(time_epochs(:, end));
        
        N_epochs = size(time_epochs, 2);
    else
        time_epochs =  rr_peaks_st(n).rr_peaks([1 end]);
        N_epochs = 1;
    end
    
    % create table for HRV features per epoch
    hrv_feats  = array2table(NaN(N_epochs, length(params.hrv_vars)), ...
                             'VariableNames', params.hrv_vars);

    % iterative over all epochs:
    start_time_secs = zeros(1, N_epochs);
    for p = 1:N_epochs
        % extract the epoch:
        [~, istart] = find_closest(rr_peaks_st(n).rr_peaks, time_epochs(1, p));
        [~, iend] = find_closest(rr_peaks_st(n).rr_peaks, time_epochs(end, p));        
        
        if(DBverbose)
            fprintf('start time = %.2f; end time = %.2f\n', rr_peaks_st(n).rr_peaks(istart) / 60, ...
                    rr_peaks_st(n).rr_peaks(iend) / 60);
        end
        start_time_secs(p) = rr_peaks_st(n).rr_peaks(istart);
            
        rr_peaks_epoch = rr_peaks_st(n).rr_peaks(istart:iend);
        rr_int_epoch = rr_peaks_st(n).rr_interval(istart:(iend - 1));        
        

        % epoch must be sufficient long and <50% NaNs:
        if(((rr_peaks_epoch(end) - rr_peaks_epoch(1)) > (params.L_hrv_epoch / 2)) && ...
           (length(find(isnan(rr_int_epoch))) / length(rr_int_epoch)) < 0.5)
            
            % convert RR interval to milliseconds:
            rr_int_epoch = rr_int_epoch .* 1000;
            
            %---------------------------------------------------------------------
            % 1. mean, SD features
            %---------------------------------------------------------------------
            hrv_feats.mean_NN(p) = nanmean(rr_int_epoch);
            hrv_feats.SD_NN(p) = nanstd(rr_int_epoch);        
            
            %---------------------------------------------------------------------
            % 2. interpolate series to uniform time sampling for spectral analysis
            %---------------------------------------------------------------------
            ttime = rr_peaks_epoch(2:end);
            rr_int = rr_int_epoch;
            
            % trim NaNs at the start and end (as don't want to extrapolate):
            % and then interpolate NaNs
            [rr_int, ttime] = trim_nans_start_end(rr_int, ttime);
            rr_int = naninterp(rr_int, 'pchip');
            
            % interpolate to uniform time-series
            new_ttime = ttime(1):(1/params.hrv_Fs_interp):ttime(end);
            rr_int_interp = interp1(ttime, rr_int, new_ttime, 'pchip');
            

            % generate periodogram:
            [pxx, freq, f_scale] = gen_periodgram(rr_int_interp', params.hrv_Fs_interp);
            % and estimate the power in each frequency band:
            pxx_sum=power_freqband(pxx, params.hrv_freq_bands, f_scale, freq);
            
            % absolute and relative spectral power measures:
            hrv_feats.VLF_power(p) = pxx_sum(1);
            hrv_feats.LF_power(p) = pxx_sum(2);    
            hrv_feats.HF_power(p) = pxx_sum(3);    
            hrv_feats.LF_HF_ratio(p) = pxx_sum(2)/pxx_sum(3);
            
            %---------------------------------------------------------------------
            % 3. TINN function
            %---------------------------------------------------------------------
            hrv_feats.TINN(p) = triangular_interp_RR(rr_int_interp./1000, 1/128);
        end
    end
    
    hrv_feats_avg_tb{n, (istart_feat_tb + 1):end} = nanmedian(hrv_feats{:, 1:end}, 1); 
    
    if(nargout > 1)
        hrv_feats.baby_ID(:) = string(hrv_feats_avg_tb.code(n));
        hrv_feats.start_time_secs(:) = start_time_secs;
        hrv_feats_epoch_tb = [hrv_feats_epoch_tb; hrv_feats];
    end

end


writetable(hrv_feats_avg_tb, params.HRV_FEAT_CSV);
writetable(hrv_feats_epoch_tb, params.HRV_FEAT_EPOCHS_CSV);





function [pxx, freq, f_scale]=gen_periodgram(x, Fs)
%---------------------------------------------------------------------
% Periodogram
%---------------------------------------------------------------------
X=abs(fft(x)).^2;

% +ve frequencies only:
N=length(X); Nh=floor(N/2); Nfreq=N;
X=X(1:Nh+1)';

pxx=X./(Fs*N);

f_scale=(Nfreq/Fs);
freq=(0:(N-1))./f_scale;

    




function spec_pow=power_freqband(pxx, freq_bands, f_scale, fp)
%---------------------------------------------------------------------
% estimate the power in different frequency bands
%---------------------------------------------------------------------
N_bands=size(freq_bands, 1);
spec_pow=NaN(1, N_bands);
Nh=length(pxx);


for p=1:N_bands
    if(p==1)
        istart=ceil(freq_bands(p, 1)*f_scale);
    else
        if(isempty(ibandpass))
            istart = [];
        else
            istart=ibandpass(end);            
        end
    end
    ibandpass=istart:floor(freq_bands(p, 2)*f_scale);        
    ibandpass=ibandpass+1;
    ibandpass(ibandpass<1)=1; ibandpass(ibandpass>Nh)=Nh;    
    
    spec_pow(p)=mean( pxx(ibandpass) );
end


