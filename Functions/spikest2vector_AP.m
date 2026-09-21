function [matrix,matrix_tmp]=spikest2vector_AP(spks,startt,endt,bin)
%% spikest2vector_AP transforms the spike times structure spks to a matrix of spike trains
%
%% Inputs
%
% spks is a [T,2] matrix in which the identity of the neuron (first column) and its spike
% time [s] (second column) is stored.
%
% startt is the time at which the final matrix starts [s]
%
% endt is the time at which the final matrix ends [s]
%
% bin is the bin size to bin in the final matrix into [ms]
%
%% Outputs
%
% matrix = matrix of dimensions [Neurons,Times]. Each element
% corresponds to the FR of neuron i at time j.
%
% matrix_tmp = is a binary marix of the same dimensions of matrix.
% An element of matrix_tmp equals 1 if there is at least one spike in that
% bin, and equals zero otherwise. matrix_tmp is created for debugging
% purposes.
%
%
% Andrea Colins Rodriguez
% 07/08/2025
%
% Update 02/03/2026
% Check that the start happens after the end of the recording
% 



if startt>endt
    disp('Start happens after the end of the recording:\n')
    disp(['Start: ' num2str(startt)])
    disp(['End: ' num2str(endt)])
    keyboard
    
end
% matrix rows contain units and columns represent t within trial
nunits=max(spks(:,1));

matrix_tmp=zeros(nunits,round((endt-startt)*1000));

if mod(round((endt-startt)*1000),bin)==0
    matrix=zeros(nunits,round((endt-startt)*1000/bin));
else
    rest=mod(round((endt-startt)*1000),bin);
    ncolumns=round((size(matrix_tmp,2)-rest)/bin);
    matrix=zeros(nunits,ncolumns);

end

for unit=1:nunits

    idx_unit=(spks(:,1)==unit);
    spks_tmp=spks(idx_unit,2);

    idxsp=((spks_tmp>=startt) & (spks_tmp<endt));
    tsp=round((spks_tmp(idxsp)-startt)*1000)+1;
    matrix_tmp(unit,tsp)=1;

    if numel(unique(tsp))<numel(tsp)
        N = histcounts(tsp,0:1:max(tsp));
        double_spike=find(N>1);
        %for debugging
        %        disp('double spike')
        %         plot(matrix_tmp(unit,:),'k')
        matrix_tmp(unit,double_spike)=N(double_spike);
        %         plot(matrix_tmp(unit,:),'r')
        %         pause

    end

    if bin==1
        matrix(unit,:)=matrix_tmp(unit,:);
    else
        if mod(round((endt-startt)*1000),bin)==0

            matrix(unit,:)=sum(reshape(matrix_tmp(unit,:)',bin,round((endt-startt)*1000/bin)),1);
        else
            tmp=matrix_tmp(unit,1:size(matrix_tmp,2)-rest);
            %         mod(size(tmp,2),bin)
            %         bin
            %         round(size(tmp,2)/bin)
            %         round((endt-startt)*1000/bin)
            matrix(unit,:)=sum(reshape(tmp',bin,ncolumns),1);
            clear tmp
        end
    end
end

end