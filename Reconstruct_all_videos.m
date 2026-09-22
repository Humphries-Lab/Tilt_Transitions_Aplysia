function Reconstruct_all_videos

ff=dir('.\Output_files\*_tr.mat*');
nsessions=size(ff,1);
Good_fit=nan(nsessions,1);

for iVideo=1:nsessions

    if iVideo==10
        continue
    end

 VideoName=ff(iVideo).name(1:end-7);
load(['.\Output_files\' VideoName '_tr.mat'],'p','All_f','coeffs','scores')
   % if strcmp(VideoName,'00081_5.avi')
   %      do_plot=1;
   %  else
         do_plot=0;
   %  end
meanFrame=mean(All_f);
tic
Good_fit(iVideo)=Reconstruct_video(coeffs(:,1:2),scores(:,1:3),meanFrame,All_f,p,do_plot);
toc
end
disp(['Mean goodness of fit across videos = ' num2str(mean(Good_fit,'omitnan')) ' +- ' num2str(std(Good_fit,'omitnan'))])
end