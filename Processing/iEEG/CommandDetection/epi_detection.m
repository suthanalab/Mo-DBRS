%Simple first-order detection of epileptic activity
%Returns indices when values are higher than set thresholds, we discarded batches that had any detection from further analysis.
function [epi_idx] = epi_detection(data_batch, Fs)

    data_zs = zscore(data_batch);
    data_std = std(data_zs);
    threshold_env = 5 * data_std;
    threshold_filt = 6 * data_std;

    [yupper, ] = envelope(data_zs);
    env = yupper;
    env_idx = env > threshold_env;
    
    bpFilt = designfilt('bandpassfir','FilterOrder',20, ...
         'CutoffFrequency1',25,'CutoffFrequency2',80, ...
         'SampleRate', Fs);
     
    data_filt = filtfilt(bpFilt, data_zs);
    env_filt = abs(data_filt) > threshold_filt;
    
    epi_idx = env_idx | env_filt;

end

