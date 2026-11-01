function Main_Reproduce_Figures


addpath(genpath('.\Functions'))

Detect_epochs_all_recordings

Figure1_Transitions_match

Figure2_Key_Locomotion_Parameters

Figure3_Locomotion_Transitions

Figure4_Model

Figure5_Parameters_match

Figures6_and_7_motor_output

%%%%%%%%%%%%%%%%%%%%%%%%
%% Supplementary figures
%%%%%%%%%%%%%%%%%%%%%%%%

% Because supplementary figure 1 and 2 are schematics, they're not produced
% here

Supp_Figure3 

Supp_Figure4

%%%%%%%%%%%%%%%%%%%%%%%%
%% Supplementary videos
%%%%%%%%%%%%%%%%%%%%%%%%
%% Supp  video 1 
% sudden 
SuddenTransition='5gc_short.avi';

Play_Video(SuddenTransition)

%% Supp  video 2
% increasing 

IncreasingArching='animal_F_time_30_480_850.mp4';
Play_Video(IncreasingArching)

%% Supp  video 3 
% smooth 
SmoothTransition='00079_6.avi';
Play_Video(SmoothTransition)

%% Supp video 4 
VideoName = '00081_5.avi';
Supp_video_4(VideoName)


%% Supp video 5: PC1  vs contraction
nPC = 1;
Create_video_PCs(VideoName,nPC)

%% Supp video 6: PC 2 vs arching
nPC = 2;
Create_video_PCs(VideoName,nPC)

%% Supp. video 7: model simulation
Figure4_Model(0,1)
end