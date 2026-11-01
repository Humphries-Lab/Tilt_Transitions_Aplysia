function [segment_s,startbin,ndim_seg,varExpTh]=detect_cycle_JPCA_v2(total_matrix_1,min_seg,bin,threshold,do_plot)
start=1;
nsamples=size(total_matrix_1,1);
min_seg2=round(min_seg*1000/bin);% in bins
% the neural activity must be recurring for at least step_bin bins (forced to be a tenth of the cycle)
step_bin=round(min_seg*(1000/bin)/10); % a tenth of the minimum cycle (in bins)
endt=round(min_seg2); %in bins now
segment_s=[];
ndim_seg=[];
% we make a copy of the original threshold defined by the user. We can
% increase the threshold adaptatively in the case that the neural dynamics
% become higher dimensional, but the minimum threshold will be the one set
% by the user
threshold_or=threshold;

[~,scoreall,~,~,explained_all] = pca(total_matrix_1);
ndim=4;
varExpTh=sum(explained_all(1:ndim));

xtime=(1:nsamples)*bin/1000;
%if data is one dimensional, use 6 PCs (the default of the JPCA code). This
%usually happens when there is a massive peak in the data set, e.g. all
%neurons firing simultaneously after a stimulus.
% if ndim<=2
%     ndim=6;
% end
if do_plot
    figure
    subplot(2,2,1)
    hold on
    plot(xtime,scoreall(:,1))
    plot(xtime,scoreall(:,2))
    plot(xtime,scoreall(:,3))
end


maxi=max(scoreall(:));
mini=min(scoreall(:));

%% for jpca
jPCA_params.params=false;
jPCA_params.numPCs = ndim;  % default anyway, but best to be specific
jPCA_params.suppressBWrosettes = true;  % these are useful sanity plots, but lets ignore them for now
jPCA_params.suppressHistograms = true;  % these are useful sanity plots, but lets ignore them for now
jPCA_params.suppressText=true;
jPCA_params.softenNorm=10;

var_all_cycles=[];

while endt<=nsamples


    xtime=(1:(endt-start+1))*round(bin);
    Data(1).A=total_matrix_1(start:endt,:);
    Data(1).times=xtime';
    [scorestruct,summary] = jPCA_new(Data, xtime, jPCA_params);
    tmpdim=find(cumsum(summary.varCaptEachJPC)>=(varExpTh/100),1,'First');

    if isempty(tmpdim)
        %% add 2 dim because JPCA requieres an even number of dims
        jPCA_params.numPCs=jPCA_params.numPCs+2;
        continue
    else
        ndim=max(2,tmpdim);
    end
    score2=scorestruct.proj(:,1:ndim);
    %score1=scorestruct.proj;
    %      figure
    %      subplot(2,1,1)
    %      plot(summary.PCs)
    %      subplot(2,1,2)
    %      plot(summary.jPCs)
    %     pause
    % how well does jPCA approximate the data?
    %debugging
    %     figure
    %     subplot(2,2,1)
    %     plot(cumsum(summary.varCaptEachJPC),'r')
    %     hold on
    %     plot(cumsum(summary.varCaptEachPC),'k')
    %     ylabel('Var explained')
    %     subplot(2,2,2)
    %     plot(summary.R2_Mskew_2D,'or')
    %     hold on
    %     plot(summary.R2_Mbest_2D,'ok')
    %     ylabel('Fit for 2D')
    %
    %     subplot(2,2,3)
    %     plot(summary.R2_Mskew_kD,'or')
    %     hold on
    %     plot(summary.R2_Mbest_kD,'ok')
    %     ylabel('Fit for all D')
    %     pause
    % media filter?
    %score2=medfilt1(score1(:,1:2),step);

    %do recurrence?
    recurrence1=pdist(score2,'euclidean');
    recurrence=squareform(recurrence1);
    limit=prctile(recurrence1(:),round(threshold));
    tmp=recurrence<limit;
    recurrence_time=calculate_time_of_rec(tmp,min_seg2*ones(size(tmp,1),1));
    rec_time=mean(recurrence_time,'omitnan')*bin/1000;
    %make another sanity test? sometimes the rec_times are bimodal, like 30
    %and 10 values




    if do_plot
        subplot(2,2,2)

        plot(score2(:,1),score2(:,2))
        title(['R = ' num2str(summary.R2_Mbest_kD) ' Rskew = ' num2str(summary.R2_Mskew_kD)])
        subplot(2,2,3)
        imagesc(tmp)
        subplot(2,2,4)
        plot(recurrence_time*bin/1000)
        pause(0.001)
    end

    %% if it finds the end of the cycle, then start the next segment
    if sum(~isnan(recurrence_time))>step_bin

        segment_s=[segment_s; (endt-start)*bin/1000];% in seconds

        start=endt;
        endt=endt+min_seg2;
        % adapt min_seg2 to the stats of the data:
        min_seg2=round(min_seg2+(mean(segment_s)*(1000/bin)*0.5-min_seg2)/10);
        step_bin=round(min_seg2/10);
        ndim_seg=[ndim_seg;tmpdim];

    %%%% testing if controlling by dimensionality (forcing the threshold to
    %%%% be higher over time when the dimensionality increases) avoid the drift
    var_this_cycle = sum(summary.varCaptEachPC(1:2));
    var_all_cycles = [var_all_cycles;var_this_cycle];
    if numel(var_all_cycles)>0
        mean_var = mean(diff(var_all_cycles));
    else
         mean_var = 0;
    end
    threshold=max(threshold-20*mean_var,threshold_or);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if do_plot
            subplot(2,2,1)
            plot([sum(segment_s) sum(segment_s)],[mini maxi])
            title(['Time of recurrence = ' num2str(rec_time) ' Min segment = ' num2str(min_seg2*bin/1000)])
            pause
        end
    else
        %pause(0.01)
        endt=endt+step_bin;

    end
end


startbin=round([1; cumsum(segment_s)*1000/bin]);
% if the segment between the end of the last cycle and the end of the
% recording is longer than the minimum length, then include it.
% if  (nsamples-startbin(end))>min_seg2
%     tmp=(nsamples-startbin(end))*bin/1000;
%     startbin=[startbin;nsamples];
%     segment_s=[segment_s; tmp];
%     ndim_seg=[ndim_seg;nan];
% end

% I wouldn't apply the code above because that segment be definition is not
% recurring

end