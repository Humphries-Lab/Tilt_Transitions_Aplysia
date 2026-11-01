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