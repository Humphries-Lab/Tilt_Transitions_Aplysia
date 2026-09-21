function Data=Detect_epochs(session,params)
do_plot=0;
load(session,'spks','stim_time','spks_p10')

stim=round((str2double(stim_time(1))))*60;% in s
session_end=floor(max(spks(:,2)));

%From stimulus
if params.start
    matrix=spikest2vector_AP(spks,stim+10,session_end,params.bin);
else
    matrix=spikest2vector_AP(spks,0,session_end,params.bin);
end

min_spikes=5*size(matrix,2)*params.bin/1000/60; %min spikes per min
spPerN=sum(matrix,2);

matrix(spPerN<min_spikes,:)=[];
%nunits=size(matrix,1);

meanISI=median_ISI(spks,stim);% in seconds
sig=round(meanISI*1000/params.bin);%in bins
[total_matrix_1,shiftbase]=filter_spikes(sig,matrix);



if exist('spks_p10','var')
    if params.start
        p10=spikest2vector_AP(spks_p10,stim+10,session_end,params.bin);
    else
        p10=spikest2vector_AP(spks_p10,0,session_end,params.bin);
    end

    meanISI_p10=median_ISI(spks,stim)+0.5;
    sig=round(meanISI_p10*1000/params.bin);%in bins
    [p10,shiftbase2]=filter_spikes(sig,p10);
    if shiftbase>shiftbase2
        p10=p10((1:size(total_matrix_1,2)));
    else
        p10=p10(1:end);
        total_matrix_1=total_matrix_1(:,1:numel(p10));
    end

end

%% normalisation
if params.normalisation
    total_matrix_1=total_matrix_1'./repmat(range(total_matrix_1'+10),size(total_matrix_1,2),1);

else
    total_matrix_1=total_matrix_1';
end

%% testing method to detect cycles
[segment_s,startbin,ndim_cycle]=detect_cycle_JPCA_v2(total_matrix_1,params.min_seg,params.bin,params.rec_thresh,0);
nsegments=numel(segment_s);
%% test how much of the structure is rotational using JPCA
[~,Summary,scorestruct]=is_rotational(total_matrix_1,0);

xtime=(1:size(total_matrix_1,1))*params.bin/1000;
xtimeb=cumsum([0;segment_s(1:end-1)]);

% PCA for the whole recording for didactic reasons
[coeffs,scores,~,~,explained_all] = pca(total_matrix_1);
Data.ndim=find(cumsum(explained_all)>params.varExpTh,1,'First');
Data.vexplained=explained_all;

%% create similarity matrix
show_progress=0;
similarity=overlap_similarity(total_matrix_1,startbin,0,show_progress);

if do_plot

    
    ax4=subplot(5,2,2);
    imagesc(similarity)
    axis square
    hold on
    if params.start==0
        plot([stim stim],[0 xtime(end)],'r')
        plot([0 xtime(end)],[stim stim],'r')
    end
    set(gca,'Ydir','normal')
    box off
    colorbar
    colormap(ax4,gray)
    %title(['mean rot period = ' num2str(mean(segment_s)) ' [s]'])
    xlabel('N segment')
    ylabel('N segment')

end


%% Clustering
%% Cluster neurons first

%[units_clusters,~]=clustering(corr(total_matrix_1));
%[G1(:,2),G1(:,1)]=sort(units_clusters);

% colour_neurons_group=bone(max(G1(:,2))+4);
% colour_neurons_group(end-3:end,:)=[];
% colour_neurons_group=colour_neurons_group(randperm(max(G1(:,2))),:);
% total_matrix_1=total_matrix_1(:,G1(:,1));
% matrix=matrix(G1(:,1),:);


%% Cluster segments
grps=clustering(similarity);
tilt=1-similarity(end,:);

grps=grps(:,1);
ngroups=max(grps);


%% if no transitions found then it's only one epoch
if ngroups==0
    grps=ones(nsegments,1);
    ngroups=1;
end

colour_group=plasma(ngroups);
colour_group(end,:)=[255,230,0]./255;

%% transform the index group into an indicator of the corresponding group for each second of the recording
group_bin=nan(startbin(end)-1,1);
area_segment=nan(nsegments,1);
for s=1:nsegments
    t1_bin=startbin(s);
    t2_bin=startbin(s+1)-1;
    group_bin(t1_bin:t2_bin)=grps(s);
    area_segment(s)=sqrt(area_closed_curve(scorestruct.proj(t1_bin:t2_bin,1),scorestruct.proj(t1_bin:t2_bin,2))/pi);

end


if exist('p10','var')


     p10_results=P10_predictions(xtime,[xtimeb;sum(segment_s)],p10,segment_s,area_segment,tilt,mean(total_matrix_1,2),params);
  
     [phase_diff,R_tilt,std_phase,tiltax]=P10_and_tilt(scorestruct.proj,group_bin,p10,tilt,startbin);

    p10_results.phase_diff=phase_diff;
    p10_results.R_tilt=R_tilt;
    p10_results.std_phase=std_phase;
    p10_results.Var_jPCs = Summary.varCaptEachJPC;
    p10_results.jscores = scorestruct.proj;
    p10_results.nepochs=ngroups;
    p10_results.tiltax=tiltax;
    Data.p10_results=p10_results;
    Data.p10=p10;
end

Data.scores=scores;
Data.coeffs=coeffs;
%Data.clusters=G1(:,2);
Data.matrix=matrix;
Data.group_bin=group_bin;
Data.total_matrix=total_matrix_1';
%Data.colour_neurons=colour_neurons_group;
Data.colour_groups=colour_group;
Data.Sxy=similarity;
Data.grps=grps;
Data.jPCA_exp=Summary.varCaptEachJPC;
Data.startbin=startbin;
Data.segment_s=segment_s;
Data.amplitude=area_segment;
Data.ndim_cycle=ndim_cycle;
Data.meanISI=meanISI;
Data.tilt=tilt;
%Data.jPC3_coeffs=Summary.jPCs_highD(G1(:,1),1:3).*repmat(Summary.varCaptEachJPC(1:3),nunits,1);

end
