function y = j211filtfilt(cfc,samplerate,x)
%usage of this function is as follows:
% y = j211filt( cfc, samplerate, x)
% where cfc is the channel filter class, which should be
% 60, 180, 600, or 1000 Hz.  The filter class corresponds
% roughly to the cutoff of the filter.
% samplerate is the sampling rate of the signal in Hz,
% usually around 10000.
% x is the data to be filtered.
% when y is specified, the output of the filter is put
% in the variable y.
T=1/samplerate;	%sample period in seconds
% T = 1/sampling rate in Hz ...
wd=2*pi*cfc*2.0775; %cfc = channel filter class
wa=sin(wd*T/2)/cos(wd*T/2);
a0=wa^2/(1.0+sqrt(2)*wa+wa^2);
a1=2*a0;
a2=a0;
b0=1;
b1=-2*(wa^2-1)/(1+sqrt(2)*wa+wa^2);
b2=(-1+sqrt(2)*wa-wa^2)/(1+sqrt(2)*wa+wa^2);
b=[b0 -b1 -b2]; %coefficients for filter from SAE J211
a=[a0  a1  a2]; %coefficients for filter from SAE J211
y=filtfilt(a,b,x);
end


