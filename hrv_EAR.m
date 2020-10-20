classdef hrv_EAR
    properties (Constant)
        
        %---------------------------------------------------------------------
        % directories
        %---------------------------------------------------------------------
        DATA_DIR = [fileparts(mfilename('fullpath')) filesep 'data' filesep];
        
        %---------------------------------------------------------------------
        % files
        %---------------------------------------------------------------------
        HRV_FEAT_CSV = [hrv_EAR.DATA_DIR 'hrv_features_v1.csv'];        
        HRV_FEAT_EPOCHS_CSV = [hrv_EAR.DATA_DIR 'hrv_features_epochs_v1.csv'];            
        
        %---------------------------------------------------------------------
        % HRV parameters
        %---------------------------------------------------------------------
        hrv_Fs_interp = 256;
        % frequency bands for neonates:
        hrv_freq_bands = [0.01 0.04; 0.04 0.2; 0.2 2];
        
        
        % limit max. RR interval (to remove artefacts)
        %  to turn off: max_rr_interval = [];
        max_rr_interval = 2;
        
        % if want to segment the HRV and estimate parameters on each segment:
        % (in seconds); set to /L_hrv_epoch = [];/ to use full length
        L_hrv_epoch = 5 * 60;
        L_overlap = 50; % in percentage

        
        hrv_vars = {'mean_NN', 'SD_NN', 'VLF_power', 'LF_power', 'HF_power', ...
                    'LF_HF_ratio', 'TINN'};
        
    end
end
