function p10_results=P10_predictions(xtime,xtimeb,p10,cycleGan,AmpGan,tilt,FR,params)
%P10_PREDICTIONS Extract P10 features and compare them with ganglion data.
%
%   P10_RESULTS = P10_PREDICTIONS(XTIME,XTIMEB,P10,CYCLEGAN,AMPGAN,TILT,FR,
%   PARAMS) extracts amplitude and period features from the P10 signal and
%   compares them with corresponding ganglion measurements.
%
%   The P10 amplitude is estimated from the envelope of the firing-rate
%   signal. Its cycle period is estimated from a spectrogram and the
%   associated time-frequency ridge. The resulting P10 measures are then
%   interpolated onto a common time axis to quantify their correlation
%   with ganglion amplitude and rotation period.
%
%   Cycle-level amplitude, period, tilt, and firing-rate measurements are
%   also extracted and stored in P10_RESULTS. These measurements provide a
%   common representation for comparing P10 activity with the corresponding
%   ganglion features across individual cycles.
%
%   INPUTS
%       xtime    - Time vector associated with the P10 firing-rate signal.
%
%       xtimeb   - Time points defining the boundaries of the ganglion
%                  cycles.
%
%       p10      - P10 firing-rate signal.
%
%       cycleGan - Ganglion rotation period for each cycle.
%
%       AmpGan   - Ganglion amplitude for each cycle.
%
%       tilt     - Ganglion tilt measurement for each cycle.
%
%       FR       - Ganglion firing-rate signal.
%
%       params   - Structure containing acquisition parameters. The field
%                  PARAMS.BIN specifies the temporal binning used to convert
%                  between samples and seconds.
%
%   OUTPUTS
%       p10_results - Structure containing the original signals, extracted
%                     P10 features, cycle-level measurements, and
%                     correlation statistics.
%
%                     The main fields are:
%
%                     p10                 - Input P10 firing-rate signal.
%                     xtime               - Input P10 time vector.
%                     xtimeb              - Ganglion cycle boundaries.
%                     Ncycles             - Number of ganglion cycles.
%                     AmpGan              - Normalised ganglion amplitude.
%                     tilt                - Ganglion tilt.
%                     envp10              - P10 firing-rate envelope.
%                     corr_amplitude_p10  - Correlation between P10
%                                           envelope and ganglion amplitude.
%                     corr_tilt_p10       - Correlation between P10
%                                           envelope and ganglion tilt.
%                     corr_period_p10     - Correlation between P10 and
%                                           ganglion rotation periods.
%                     mean_per_p10        - Median absolute difference
%                                           between the interpolated
%                                           P10 and ganglion periods.
%                     Period              - Cycle-level P10 and ganglion
%                                           period measurements.
%                     Amplitude           - Cycle-level P10 and ganglion
%                                           amplitude measurements.
%                     Tilt                - Cycle-level P10 amplitude and
%                                           ganglion tilt measurements.
%                     FR_gang             - Cycle-level P10 amplitude and
%                                           ganglion firing-rate measurements.
%                     Cycle_P10           - P10 period estimated from the
%                                           time-frequency ridge.
%                     tp10                - Time vector associated with
%                                           the estimated P10 period.
%                     cycleGan            - Ganglion rotation periods.
%
%   NOTES
%       Estimation of the P10 envelope uses ENVELOPE and therefore requires
%       the Signal Processing Toolbox.
%
%       The period estimate is obtained from a spectrogram evaluated over
%       candidate periods between 2 and 100 seconds. The time-frequency
%       ridge is then converted to period.
%
%       The function requires FIND_P10AMPCYCLE, defined below, to obtain
%       cycle-level P10 amplitude, period, and ganglion firing-rate
%       measurements.
%
%   EXAMPLE
%       p10_results = P10_predictions(xtime,xtimeb,p10,cycleGan,AmpGan,...
%           tilt,FR,params)

fs=1000/params.bin;
sample_segmentS=150;
Ncycles=numel(xtimeb)-1;
FR=FR(:);

%% Compute the amplitude of P10 as the envelope of the firing rate
meanP=mean(cycleGan);
envp10=envelope(p10,round(meanP*fs),'peaks');

%% Compute the cycle period using the power spectrum

nfft=1./(100:-1:2);
window = fs*sample_segmentS;
noverlap=fs*(sample_segmentS-1);
[~,f10,tp10,p102]=spectrogram(p10-mean(p10),window,noverlap,nfft,fs,'yaxis');
fridge = tfridge(p102,f10,0.5);
Cycle_P10=1./fridge;

%% save results in structure for postprocessing
p10_results.p10=p10;
p10_results.xtime=xtime;
p10_results.xtimeb=xtimeb;
p10_results.Ncycles=Ncycles;
p10_results.AmpGan=AmpGan/mean(AmpGan);
p10_results.tilt = tilt;
p10_results.envp10 = envp10;


%% Interpolate to calculate the correlation between the ganglion amplitude and P10 amplitude
xtimec=0:1:floor(xtimeb(end)/60)*60;
areaSinterpol = spline(xtimeb(1:Ncycles),AmpGan,xtimec)';
Tiltinterpol = spline(xtimeb(1:Ncycles),tilt,xtimec)';
envp10interpol = spline(xtime,envp10,xtimec)';

%% save
p10_results.corr_amplitude_p10=corr(areaSinterpol,envp10interpol);
p10_results.corr_tilt_p10=corr(Tiltinterpol,envp10interpol);



%% Interpolate to calculate the correlation between the period of ganglion and P10
rotSinterpol = spline(xtimeb(1:Ncycles),cycleGan,xtimec)';
fp10interpol = spline(tp10,Cycle_P10,xtimec)';

% save

p10_results.corr_period_p10=corr(rotSinterpol,fp10interpol);
p10_results.mean_per_p10=median(abs(rotSinterpol-fp10interpol));


% compute results per cycle
[AmpP10,PerP10,FR_gang]=find_p10Ampcycle(p10,Cycle_P10,tp10,xtimeb,xtime, FR,params);

Ncyc=numel(AmpP10);

% save
p10_results.Period=[PerP10,cycleGan(1:Ncyc)];
p10_results.Amplitude=[AmpP10,AmpGan(1:Ncyc)];
p10_results.Tilt=[AmpP10,tilt(:)];
p10_results.FR_gang=[AmpP10,FR_gang(:)];

p10_results.Cycle_P10 = Cycle_P10;
p10_results.tp10 = tp10;
p10_results.cycleGan = cycleGan;


end

function [peaks,PerP10,FR_gang]=find_p10Ampcycle(p10,Cycle_Per,tp10,cycleT,xtime,FR,params)
%FIND_P10AMPCYCLE Extract cycle-level P10 and ganglion features.
%
%   [PEAKS,PERP10,FR_GANG] = FIND_P10AMPCYCLE(P10,CYCLE_PER,TP10,CYCLET,
%   XTIME,FR,PARAMS) extracts the maximum P10 firing rate, median P10
%   period, and maximum ganglion firing rate within each cycle defined by
%   CYCLET.
%
%   INPUTS
%       p10      - P10 firing-rate signal.
%       Cycle_Per - P10 period estimate as a function of TP10.
%       tp10     - Time vector associated with CYCLE_PER.
%       cycleT   - Cycle boundaries in seconds.
%       xtime    - Time vector associated with FR.
%       FR       - Ganglion firing-rate signal.
%       params   - Structure containing the temporal bin size in
%                  PARAMS.BIN.
%
%   OUTPUTS
%       peaks    - Maximum P10 firing rate within each cycle.
%       PerP10   - Median P10 period within each cycle.
%       FR_gang  - Maximum ganglion firing rate within each cycle.

cycleS=cycleT;
cycleT=round(cycleT*1000/params.bin);
Ncycles=numel(cycleT)-1;
peaks=nan(Ncycles,1);
PerP10=nan(Ncycles,1);
FR_gang=nan(Ncycles,1);
cyclestart=cycleT(1:end-1);
cyclesend=cycleT(2:end);
cyclestart(1)=1;

for icycle=1:Ncycles
    peaks(icycle)=max(p10(cyclestart(icycle):cyclesend(icycle)));
    idx=cycleS(icycle)<=tp10 & tp10<=cycleS(icycle+1);
    PerP10(icycle)=median(Cycle_Per(idx));

    idxFR=cycleS(icycle)<=xtime & xtime <=cycleS(icycle+1);
    FR_gang(icycle)=max(FR(idxFR));
end


end
