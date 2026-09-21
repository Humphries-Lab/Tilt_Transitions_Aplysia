function Figure5_Parameters_match

figure

%Recording={'Mar2916_1.mat',...
%    'Jul2715_1_for_Mark.mat',...
%    'Jul0616_2.mat'};

Recording={'Aug1822_3.mat',...
    'Aug1822_4.mat',...
    'Jul0616_2.mat'};



figure

for i=1:length(Recording)
    Plot_neural_cycle_parameters(['.\Neural_Recordings\' Recording{i}],i)

end

disp('___________________________________________')
disp('___________Locomotion parameters___________')
disp('___________________________________________')

Figure5_behavioural

disp('___________________________________________')
disp('_________Neural cycle parameters___________')
disp('___________________________________________')

Figure5_Neural_summary



end

function Plot_neural_cycle_parameters(session,column)

%% Detect epochs of this recording
params.bin=50; %ms
params.use_adaptive_filter=0;
params.do_plot=1;
params.normalisation=0;
params.start=1; % 0 from the beginning of recording, 1 from stim +5
params.varExpTh=80;
params.min_seg=10; % in s
params.rec_thresh=5;
params.varExpTh_cycle=80;


Data=Detect_epochs(session,params);
%% PCA
subplot(8,3,column)
plot_PCA_over_time(Data,params)

%% Tilt 

subplot(8,3,column+3)
plot_parameter(Data,Data.tilt,params)

%% Amplitude
subplot(8,3,column+6)

plot_parameter(Data,Data.amplitude,params)

%% Period
subplot(8,3,column+9)
plot_parameter(Data,Data.segment_s,params)
ylim([0 80])
end

function plot_parameter(Data,parameter,params)
ax=gca;
xtimeb=cumsum([0;Data.segment_s(1:end-1)]);
hold on
    im=imagesc([1 Data.startbin(end)]*params.bin/1000,[0 max(parameter)],Data.group_bin');
    im.AlphaData=0.1;
    ylim([0  max(parameter)])
    colormap(ax,Data.colour_groups)
    plot(xtimeb,parameter)
    
end

function Figure5_Neural_summary
Ngrps=5;
colours=[1 1 1;plasma(Ngrps)];
colours(end,:)=[255,230,0]./255;

load('.\Output_files\Epochs_all_Neural_Recordings.mat','Pattern3')
Key_paramters_all_rec(colours,Pattern3)
end



function Figure5_behavioural

ff=dir('.\Output_files\*_tr.mat*');
p.epoch_colours=[125 125 125; 90 19 138;172 143 37; 26 161 149; 240 242 133]./255;%gray= no behaviour, purple= galloping, blue=transition,aqua= crawling, yellow=rolling

Mina_all=nan(1000,1);
ConR_all=nan(1000,1);
Period_all=nan(1000,1);
epochs_all=nan(1000,1);
nfiles=size(ff,1);

max_cycles=40;
meanArch=nan(nfiles,max_cycles);
meanPeriod=nan(nfiles,max_cycles);
meanCR=nan(nfiles,max_cycles);
Sign_slope=nan(nfiles,2);

counter=1;

for f=1:nfiles

    VideoName=ff(f).name(1:end-7);

    [Mina,ConR,Period,epochs,~,icycle]=Modes_features(VideoName);
    
    meanArch(f,icycle)=Mina';
    meanCR(f,icycle)=ConR';
    meanPeriod(f,icycle)=Period';
    f_tmp=fitlm(icycle,Period);
    

    Sign_slope(f,1:2)=[sign(f_tmp.Coefficients.Estimate(2)) f_tmp.Coefficients.pValue(2)];

    ncycles=numel(Mina);
    
    Mina_all(counter:counter+ncycles-1)=Mina;
    ConR_all(counter:counter+ncycles-1)=ConR;
    Period_all(counter:counter+ncycles-1)=Period;
    epochs_all(counter:counter+ncycles-1)=epochs;

    counter=counter+ncycles+1;

end

% number of videos which showed an increasing period
disp(['Number of videos which showed an increasing period ' num2str(sum(Sign_slope(:,1)==1)) ' of ' num2str(nfiles)])

% number of videos which showed an decreasing period
disp(['Number of videos which showed a decreasing period ' num2str(sum(Sign_slope(:,1)==-1))  ' of ' num2str(nfiles)])

deletenan=isnan(Mina_all);
Mina_all(deletenan)=[];
ConR_all(deletenan)=[];
Period_all(deletenan)=[];
epochs_all(deletenan)=[];

%% period outliers from video animal X
out_thr=mean(Period_all)+3*std(Period_all);
epochs_all(Period_all>out_thr)=[];
ConR_all(Period_all>out_thr)=[];
Mina_all(Period_all>out_thr)=[];
Period_all(Period_all>out_thr)=[];
meanPeriod(meanPeriod>out_thr)=nan;


%%% Violins of locomotion
subplot(6,6,20)
Arch{:,1}=Mina_all(epochs_all==1);
Arch{:,2}=Mina_all(epochs_all==2);
Arch{:,3}=Mina_all(epochs_all==3);
tmp = violin(Arch,'facecolor',p.epoch_colours(2:end,:),'xlabel',{'Gallop','Transition','Crawl'},'edgecolor','none');
ylabel('Arching')
hold on
plot([0 4],[0 0],'Color',[0.5 0.5 0.5])
box off

subplot(6,6,26)
Contr{:,1}=ConR_all(epochs_all==1);
Contr{:,2}=ConR_all(epochs_all==2);
Contr{:,3}=ConR_all(epochs_all==3);
tmp=violin(Contr,'facecolor',p.epoch_colours(2:end,:),'xlabel',{'Gallop','Transition','Crawl'},'edgecolor','none');

ylabel('Contraction rate [fraction]')
box off


subplot(6,6,32)

Per_C{:,1}=Period_all(epochs_all==1);
Per_C{:,2}=Period_all(epochs_all==2);
Per_C{:,3}=Period_all(epochs_all==3);

tmp = violin(Per_C,'facecolor',p.epoch_colours(2:end,:),'xlabel',{'Gallop','Transition','Crawl'},'edgecolor','none');
ylabel('Period [s]')
box off

%% histograms across all cycles 
subplot(6,6,21)
histogram(Mina_all,20,'Normalization','Probability','Orientation', 'horizontal')
box off
xlabel('Arching')


subplot(6,6,27)
histogram(ConR_all,20,'Normalization','Probability','Orientation', 'horizontal')
box off
xlabel('CR')

subplot(6,6,33)
histogram(Period_all,0:25,'Normalization','Probability','Orientation', 'horizontal')
box off
xlabel('CR')

%% statistical comparison of locomotion parameters from gallop to crawl

[~,p_arching]=ttest2(Mina_all(epochs_all==3),Mina_all(epochs_all==1));
[~,p_ConR]=ttest2(ConR_all(epochs_all==3),ConR_all(epochs_all==1));
[~,p_Period]=ttest2(Period_all(epochs_all==3),Period_all(epochs_all==1));

disp(['p-value arching (gallop vs crawl)  = ' num2str(p_arching)])
disp(['p-value contraction (gallop vs crawl)  = ' num2str(p_ConR)])
disp(['p-value period (gallop vs crawl)  = ' num2str(p_Period)])

%[sum(epochs_all==1) sum(epochs_all==2) sum(epochs_all==3)]

% %% Correlations (pooling all samples across modes)
% disp('----------- Correlations (pooling all samples across modes) -----------')
% disp(['Contraction rate vs arching = ' num2str(corr(ConR_all,Mina_all))])
% 
% conR_arch=[corr(ConR_all(epochs_all==1),Mina_all(epochs_all==1)),...
%     corr(ConR_all(epochs_all==2),Mina_all(epochs_all==2)),...
%     corr(ConR_all(epochs_all==3),Mina_all(epochs_all==3))];
% 
% disp(['Contraction rate vs arching  (gallop, transition, crawl)= ' num2str(conR_arch)])
% 
% disp(['Contraction rate vs Period = ' num2str(corr(ConR_all,Period_all))])
% 
% conR_Period=[corr(ConR_all(epochs_all==1),Period_all(epochs_all==1)),...
%     corr(ConR_all(epochs_all==2),Period_all(epochs_all==2)),...
%     corr(ConR_all(epochs_all==3),Period_all(epochs_all==3))];
% 
% disp(['Contraction rate vs period  (gallop, transition, crawl)= ' num2str(conR_Period)])
% 
% disp(['Arching vs Period = ' num2str(corr(Mina_all,Period_all))])
% 
% arch_Period=[corr(Mina_all(epochs_all==1),Period_all(epochs_all==1)),...
%     corr(Mina_all(epochs_all==2),Period_all(epochs_all==2)),...
%     corr(Mina_all(epochs_all==3),Period_all(epochs_all==3))];
% 
% disp(['Arching vs Period  (gallop, transition, crawl)= ' num2str(arch_Period)])
% 


%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Plotting locomotion parameters over time 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Arching
subplot(6,6,19)
hold on
plot_std(1:max_cycles,mean(meanArch,'omitnan'),std(meanArch,'omitnan'),[0.5 0.5 0.5])
MaxC=sum(sum(meanPeriod,'omitnan')>0);

f=fitlm((1:MaxC)',[mean(meanArch(:,1:MaxC),'omitnan')]');
plot(1:MaxC, feval(f,(1:MaxC)),'r')
title(['r = ' num2str(corr((1:MaxC)',mean(meanArch(:,1:MaxC),'omitnan')'),2)])
text(0.5,0.9,['pvalue = ' num2str(coefTest(f))],'Units','normalized')
box off
ylabel('Arching')


% Contraction
subplot(6,6,25)
hold on
plot_std(1:max_cycles,mean(meanCR,'omitnan'),std(meanCR,'omitnan'),[0.5 0.5 0.5])

f=fitlm((1:MaxC)',[mean(meanCR(:,1:MaxC),'omitnan')]');
plot(1:MaxC, feval(f,(1:MaxC)),'r')
title(['r = ' num2str(corr((1:MaxC)',mean(meanCR(:,1:MaxC),'omitnan')'),2)])
text(0.5,0.9,['pvalue = '  num2str(coefTest(f))],'Units','normalized')
box off
ylabel('Max Contraction')

% Period
subplot(6,6,31)
hold on
plot_std(1:max_cycles,mean(meanPeriod,'omitnan'),std(meanPeriod,'omitnan'),[0.5 0.5 0.5])
f=fitlm((1:MaxC)',[mean(meanPeriod(:,1:MaxC),'omitnan')]');
plot(1:MaxC, feval(f,(1:MaxC)),'r')
title(['r = ' num2str(corr((1:MaxC)',mean(meanPeriod(:,1:MaxC),'omitnan')'),2)])
text(0.5,0.9,['pvalue = ' num2str(coefTest(f))],'Units','normalized')
box off
xlabel('N cycle')
ylabel('Cycle Period [s]')
ylim([0 25])

end
