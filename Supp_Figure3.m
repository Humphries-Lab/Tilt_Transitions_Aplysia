function Supp_Figure_3 
warning('off','stats:pca:ColRankDefX')

fsupp=figure;

Recording={'Jul2815_1.mat',...
   'Jul0616_2.mat',...
   'Jul1119_1.mat',...
   'Mar2316_1.mat'};

figure(fsupp)

for i=1:length(Recording)
    Plot_neural_cycle_parameters_extended(['.\Neural_Recordings\' Recording{i}],i)

end

end

function Plot_neural_cycle_parameters_extended(session,column)

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
subplot(6,4,column)
plot_PCA_over_time(Data,params)

%% Amplitude
subplot(6,4,column+4)
plot_parameter(Data,Data.amplitude,params)


%% Period
subplot(6,4,column+8)
plot_parameter(Data,Data.segment_s,params)
ylim([0 100])

%% Tilt 

subplot(6,4,column+12)
plot_parameter(Data,Data.tilt,params)



%% Similarity matrix
subplot(6,4,column+16)
imagesc(Data.Sxy)
colormap(gca,'gray')
xlabel('N cycle')
ylabel('N cycle')
clim([0 1])
axis square
box off
colorbar 

%% PCA coloured
subplot(6,4,column+20)
plot_PCA_3d_transitions(Data)
end