function rasterplot_groups(spikes,bin,G,cmap)
%% rasterplot_groups plots the raster of the population 
time = (1:size(spikes,2))*bin/1000;
for iunit=1:size(spikes,1)
    plot(time,spikes(iunit,:)+iunit,'Color',cmap(G(iunit),:))
    %idx=find(spikes(iunit,:))*bin/1000; 
    %plot(idx,ones(numel(idx),1)*iunit,'Color',cmap(G(iunit),:),'MarkerSize',1)
    hold on
end

end