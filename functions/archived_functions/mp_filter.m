function filt_data = mp_filter(data, fs, fc)
    %%mp_filter filters DATA columns using a fourth-order butterworth lowpass filter
    %%with the desired cutoff frequency (fc) and sampling rate (fs).
    %INPUTS: data: unfiltered mp data
    %        fc (cutoff frequency, Hz)
    %        fs (sampling rate, Hz)

    w = fc/(fs/2);
    [b,a] = butter(4,w);
    filt_data = filtfilt(b,a,data);
end