function [similarity,coeff_1,ndim_exp,varExpTh]=overlap_similarity(total_matrix_1,startbin,do_plot,show_progress)
nsegments=numel(startbin)-1;
minvarexp=zeros(nsegments,1);
ndim_exp=zeros(nsegments,1);
coeff_1=nan(size(total_matrix_1,2),size(total_matrix_1,2),nsegments);
explained_all=ones(size(total_matrix_1,2),nsegments)*100;

%% check inputs bins are corrects
if any(mod(startbin,1) ~= 0)
    startbin
    disp('Some of the indices are not integers')
    keyboard
end

if do_plot
    figure
    isquare=ceil(sqrt(nsegments));
end
%% Define subspaces
for nseg=1:nsegments
    t1_bin=startbin(nseg);
    t2_bin=startbin(nseg+1)-1;
    %[nsegments nseg t2_bin-t1_bin segment_s(nseg) nunits]
    [coeff_tmp,sc,~,~,explained] = pca(total_matrix_1(t1_bin:t2_bin,:));
    coeff_1(:,1:size(coeff_tmp,2),nseg)=coeff_tmp;
    explained_all(1:size(coeff_tmp,2),nseg)=explained;
    %segments_bin(t1_bin:t2_bin)=nseg;
    if do_plot
    %Show individual segments
    
            subplot(isquare,isquare,nseg)
            plot(sc(:,1),sc(:,2))
            title(num2str(nseg))
    
    end
    % ensure it is using at least 2D
%     if nseg>20
%      minvarexp(nseg)
%      
%     [t1_bin t2_bin]
%      sum(explained(1:2))
% 
%     end
    minvarexp(nseg)=sum(explained(1:2));
    
    
end
varExpTh=max(minvarexp);

for nseg=1:nsegments
ndim_exp(nseg)=find(cumsum(explained_all(:,nseg))>=varExpTh,1,'First');
end
%% Define similarity matrix
similarity=nan(nsegments,nsegments);
for i=1:nsegments
    t1_bin=startbin(i);
    t2_bin=startbin(i+1)-1;
    cov_tmp=cov(total_matrix_1(t1_bin:t2_bin,:));
    singv=flipud(eig(cov_tmp));
    for j=1:nsegments
        
        similarity(i,j)=shared_variance_v2(cov_tmp,coeff_1(:,1:ndim_exp(j),j),singv,ndim_exp(j));

    end
    if show_progress 
        disp(['Cycle i = ' num2str(i) ' from ' num2str(nsegments)])
    end
end


end