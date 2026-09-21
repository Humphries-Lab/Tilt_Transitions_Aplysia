function Key_paramters_all_rec(Colours,Pattern_ord)

load('.\Output_files\key_params_Neural_Recordings.mat','Cycle_period','Amplitude_all','Arching_all')
load('.\Output_files\Epochs_all_Neural_Recordings.mat','epochs_all')

N_rec=size(epochs_all,2);
Epochs_all=nan(N_rec,100);

 for i=1:size(epochs_all,2)
     Epochs_all(i,1:size(epochs_all{i},1))=epochs_all{i};
 end

Pattern=Epochs_all;
ngrps=max(Pattern,[],2);
ncycles=sum(Pattern>0,2);

% sort by number of transitions
[ngrps,idx]=sort(ngrps);
Pattern=Pattern(idx,:);
ncycles=ncycles(idx);
counter=0;

for i_grps=1:max(ngrps)
    [~,idx2]=sort(ncycles(ngrps==i_grps));
    idx(ngrps==i_grps)=idx(idx2+counter);
    Pattern(ngrps==i_grps,:)=Pattern(idx2+counter,:);
    counter=counter+sum(ngrps==i_grps);
end


Arching_all=Arching_all(idx,:);
Amplitude_all=Amplitude_all(idx,:);
Cycle_period=Cycle_period(idx,:);


% idx_crawl=repmat(double(ngrps<2),1,100);
% idx_crawl(idx_crawl==0)=nan;
% 
% 
% idx_middle=repmat(double(ngrps>=2 & ngrps<4),1,100);
% 
% 
% 
% idx_gallop=repmat(double(ngrps>=4),1,100);
% 

Nmax=20; % cycles for fitting, to be consistent with cycles in behaviour

%% linear regression over time
disp('--- Tilt ---')
subplot(6,6,22)
plot_regression(Arching_all,Nmax)
ylabel('Tilt')


disp('--- Amplitude ---')
subplot(6,6,28)

plot_regression(Amplitude_all,Nmax)
ylabel('Normalised Amplitude')


disp('--- Period ---')
subplot(6,6,34)

plot_regression(Cycle_period,Nmax)

ylabel('Cycle Period [s]')

%% analysing period of the first 20 cycles
%% first 10 cycles
f=fitlm((1:10)',mean(Cycle_period(:,1:10),'omitnan')');

disp(['Corr period first 10 cycles = ' num2str(corr((1:10)',[mean(Cycle_period(:,1:10),'omitnan')]'))])
disp([' p value slope period first 10 cycles ' num2str(f.Coefficients.pValue(2))])


%% cycles 11 to 20

f=fitlm((11:20)',mean(Cycle_period(:,11:20),'omitnan')');
disp(['Corr period cycles 11 to 20 = ' num2str(corr((11:20)',[mean(Cycle_period(:,11:20),'omitnan')]'))])
disp([' p value slope period cycles 11 to 20 ' num2str(f.Coefficients.pValue(2))])


%% figure

subplot(6,6,23)

Arch_C{:,1}=Arching_all(Pattern_ord==1);
Arch_C{:,2}=Arching_all(Pattern_ord>1 & Pattern_ord<=4);
Arch_C{:,3}=Arching_all(Pattern_ord>4);
tmp=violin(Arch_C,'facecolor',Colours([2 4 end],:),'xlabel',{'Gallop','Transition','Crawl'},'edgecolor','none');
box off
% Arch
[~,pval_Arch]=ttest2(Arch_C{:,1},Arch_C{:,3});
text(0.9,0.9,['p val =' num2str(pval_Arch)],'Units','normalized')

subplot(6,6,24)
histogram(Arching_all(Pattern_ord>0 & Pattern_ord<=5),'Normalization','Probability','Orientation', 'horizontal')
ylim([0 1])
box off

subplot(6,6,29)
Amp_C{:,1}=Amplitude_all(Pattern_ord==1);
Amp_C{:,2}=Amplitude_all(Pattern_ord>1 & Pattern_ord<=4);
Amp_C{:,3}=Amplitude_all(Pattern_ord>4);
tmp=violin(Amp_C,'facecolor',Colours([2 4 end],:),'xlabel',{'Gallop','Transition','Crawl'},'edgecolor','none');
box off
ylim([0 3])
% Amplitude
[~,pval_Amp]=ttest2(Amp_C{:,1},Amp_C{:,3});
text(0.9,0.9,['p val =' num2str(pval_Amp)],'Units','normalized')

%% histograms

subplot(6,6,30)
histogram(Amplitude_all(Pattern_ord>0 & Pattern_ord<=5),0:0.1:3,'Normalization','Probability','Orientation', 'horizontal')
ylim([0 3])
box off

subplot(6,6,35)
Per_C{:,1}=Cycle_period(Pattern_ord==1);
Per_C{:,2}=Cycle_period(Pattern_ord>1 & Pattern_ord<=4);
Per_C{:,3}=Cycle_period(Pattern_ord>4);
tmp=violin(Per_C,'facecolor',Colours([2 4 end],:),'xlabel',{'Gallop','Transition','Crawl'},'edgecolor','none');
box off
ylim([0 100])

% period
[~,pval_period]=ttest2(Per_C{:,1},Per_C{:,3});
text(0.9,0.9,['p val =' num2str(pval_period)],'Units','normalized')


subplot(6,6,36)
histogram(Cycle_period(Pattern_ord>0 & Pattern_ord<=5),'Normalization','Probability','Orientation', 'horizontal')
box off
ylim([0 100])


end


function plot_regression(Arching_all,Nmax)

hold on
xlim([0,50])

plot_std(1:100,mean(Arching_all,'omitnan'),std(Arching_all,'omitnan'),[0.5 0.5 0.5])


corr_arch = corr((1:Nmax)',[mean(Arching_all(:,1:Nmax),'omitnan')]');

f = fitlm((1:Nmax)',[mean(Arching_all(:,1:Nmax),'omitnan')]');
p_value_slope = f.Coefficients.pValue(2);
disp(['Corr arching = ' num2str(corr_arch)])
disp([' p value slope tilt ' num2str(p_value_slope)])

plot(1:Nmax, feval(f,(1:Nmax)),'g')
title(['r = ' num2str(corr_arch)])
text(0.9,0.9,num2str(p_value_slope),'Units','normalized')

end