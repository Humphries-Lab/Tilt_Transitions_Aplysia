function medianISI=median_ISI(spks,tstim)
%% mean_ISI computes the mean Inter-Spike-Interval of the neurons in spks
%% Inputs
%
% spks is a [T,2] matrix in which the identity of the neuron (first column) and its spike
% time [s] (second column) is stored.  
%
% tstim is the time of stimulation [s]. ISIs are only computed after this
% event 
% 
%% Outputs
%
% medianISI is the median Inter-Spike-Interval of the population after the stimulus.
%
% Andrea Colins Rodriguez
% 07/08/2025



nunits=max(spks(:,1));
%ISI_unit=zeros(1,nunits);
ISI_unit=[];
spks(tstim>=spks(:,2),:)=[];
for i=1:nunits
    idx_unit=(spks(:,1)==i);
    ISI=diff(spks(idx_unit,2));
    %original version
    %ISI_unit(i)=median(ISI);
    
    %from Mark's code
    ISI_unit=[ISI_unit;ISI];
end
%original version
%meanISI=mean(ISI_unit)/sqrt(12);

%from Mark's code
medianISI=median(ISI_unit);
end