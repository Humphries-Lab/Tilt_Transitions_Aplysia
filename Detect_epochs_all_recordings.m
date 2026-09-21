function Detect_epochs_all_recordings
tic

do_plot=0;
% figure for LDS
if do_plot
    fig3=figure;
    figure(fig3)
    subplot(4,1,[3 4])
    plot([-0.02 0.02],[0 0],'k')
    plot([0 0],[-0.1 0.1],'k')
    xlim([-0.0005 0.0005])

    Colour_rec=Rainbow(nsessions);

end

%(colour_recording,nrec,rec_thresh)
%% this script searches stable epochs of dynamic activity in all sessions specified
rng('default')


%addpath('C:\Users\andrea.colins\OneDrive - Universidad Adolfo Ibanez\Documentos\GitHub\Common-Functions-Aplysia')

%addpath(genpath('C:/Users/Acer/Documents/Codes_from_papers/jPCA_ForDistribution/'))
%addpath(genpath('C:\Users\andrea.colins\OneDrive - Universidad Adolfo Ibanez\Office computer\codes_from_papers\jPCA_ForDistribution'))
warning('off','stats:pca:ColRankDefX')
warning('off','MATLAB:load:variableNotFound')

ff=dir('.\Neural_Recordings\*.mat');

NP10rec=8;% hardcoding the number of p10 recordings for simplicity

nsessions=size(ff,1);


params.bin=50; %ms
params.use_adaptive_filter=0;
params.do_plot=1;
params.normalisation=0;
params.start=1; % 0 from the beginning of recording, 1 from stim +5
params.varExpTh=80;
params.min_seg=10; % in s
%For young animals 5% is about right
% For older animals try 10%
params.rec_thresh=5;
params.varExpTh_cycle=80;


ndim=nan(nsessions,1);
nunits=nan(nsessions,1);
ndimJPCA=nan(nsessions,1);
varE_PCA=nan(nsessions,150);
ngrps=zeros(nsessions,1);

Cycle_period=nan(nsessions,100);
Amplitude_all=nan(nsessions,100);
Arching_all=nan(nsessions,100);
ndim_cycle=nan(nsessions,100);

Cycle_t=nan(nsessions,100);



pmax_lower=nan(nsessions,1);
pmax_re=nan(nsessions,1);
pmax_imag=nan(nsessions,1);
epochs_all=cell(nsessions,1);
epochs_LDS=cell(nsessions,1);




meanISI=nan(nsessions,1);
counter=1;

ip10=1;

p10_results_all = struct([]);

for i=1:nsessions
    session=ff(i).name;
    %%Detect epochs
    disp(['Starting recording ' num2str(i) ' of ' num2str(nsessions)])
    Data=Detect_epochs(['.\Neural_Recordings\' session],params);

    if isfield(Data,'p10')
        save(['.\Output_files\p10_results\' session(1:end-4) '_processed.mat' ],'Data')
        if ip10==1
            p10_results_all = repmat(Data.p10_results,NP10rec,1);
        else
            p10_results_all(ip10)=Data.p10_results;
        end
        ip10=ip10+1;
    end
    ngrps(i)=max(Data.grps);
    epochs_all{i}=Data.grps;


    %var_exp(i,1:numel(Data.jPCA_exp))=cumsum(Data.jPCA_exp);
    nunits(i)=numel(Data.vexplained);
    varE_PCA(i,1:nunits(i))=cumsum(Data.vexplained);
    ndimJPCA(i)=numel(Data.jPCA_exp);
    ndim(i)=Data.ndim./size(Data.total_matrix,1);
    %dim_before(i)=Data.dim_before;
    Nseg=numel(Data.segment_s);
    ndim_cycle(i,1:Nseg)=Data.ndim_cycle./size(Data.total_matrix,1);
    Cycle_period(i,1:Nseg)=Data.segment_s;
    % normalised amplitude
    Amplitude_all(i,1:Nseg)=Data.amplitude./Data.amplitude(1);
    % estimated amplitude
    %Amplitude_all(i,1:Nseg)=Data.amplitude*range(mean(Data.total_matrix));
    Arching_all(i,1:Nseg-1)=1-Data.Sxy(end,1:end-1);
    Cycle_t(i,1:numel(Data.startbin)-1)=(Data.startbin(2:end)+Data.startbin(1:end-1))/2;
    meanISI(i)=Data.meanISI;

    %pos(counter:counter+nunits(i)-1,:)=[Data.x' Data.y',ones(nunits(i),1)*i];
    %jpc3(counter:counter+nunits(i)-1,:)=Data.jPC3_coeffs;% this array is already weigthed by the variance
    counter=counter+nunits(i);

    if do_plot
        % LDS
        [max_eig_re,max_eig_imag,midT]=LDS_per_segment(Data,params);
        % this
        % epochs_LDS{i}=clustering_eigs(max_eig_re,midT,Data.startbin);

        %epochs_LDS(i,1:numel(grps_tmp))=grps_tmp;

        upto=900;
        [~,pmax_re(i)]=ttest(max_eig_re(midT<upto));
        [~,pmax_imag(i)]=ttest(max_eig_imag(midT<upto));
        [~,pmax_lower(i)]=ttest(max_eig_re(midT<upto),0,'tail','left');



        if contains(session,'Mar2916')
            subplot(4,1,1)
            hold on
            plot(midT,movmedian(max_eig_re,5/(midT(2)-midT(1)),'omitnan')) %% smoothing for 10 seconds
            plot([0 1000],[0 0],'b')
            hold off

            subplot(4,1,2)
            plot(midT,movmedian(max_eig_imag,5/(midT(2)-midT(1)),'omitnan'))

            Colour_rec(i,:)=[0 0 0];
        end


        subplot(4,1,[3 4])
        hold on
        nsamples=0.5*sqrt(sum(~isnan(max_eig_imag))); % 2 SEM
        %plot(max_eig_re,max_eig_imag,'.-k')
        errorbar(median(max_eig_re(midT<upto),'omitnan'),median(max_eig_imag(midT<upto),'omitnan'),std(max_eig_imag(midT<upto),'omitnan')./nsamples,'.','Color',Colour_rec(i,:))
        errorbar(median(max_eig_re(midT<upto),'omitnan'),median(max_eig_imag(midT<upto),'omitnan'),std(max_eig_re(midT<upto),'omitnan')./nsamples,'.','horizontal','Color',Colour_rec(i,:))

        if i==nsessions
            title([num2str(sum(pmax_re<0.05)) ' out of ' num2str(nsessions) ' are contracting/expanding (mean p-value) =' mean(pmax_re) ])
            disp([num2str(sum(pmax_re<0.05)) ' out of ' num2str(nsessions) ' are contracting/expanding (mean p-value) =' mean(pmax_re) ])
        end


    end

end



%% summary of epochs
current_path=pwd;
idxs=strfind(current_path,'\');
side=current_path(idxs(end)+1:end);


save(['.\Output_files\key_params_' side '.mat'],'Cycle_period','Amplitude_all','Arching_all','pmax_re','pmax_imag','pmax_lower','nunits')
save(['.\Output_files\Epochs_all_' side '.mat'],'epochs_all')
%save('.\Output_files\p10_results.mat','p10_results_all')
save(['.\Output_files\Epochs_LDS_all_' side '.mat'],'epochs_LDS')

disp(['Mean ISI between ' num2str(min(meanISI)) ' - ' num2str(max(meanISI))])

toc
end

