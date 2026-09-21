function [grps,G]=clustering(Sxy)
% delete negative values
Sxy(Sxy < 0) = 0;
% Make diagonal equal zero
Sxy(eye(size(Sxy,1))==1) = 0;
% Make sure is symmetric
Sxy=(Sxy+Sxy.')/2;


dists={'sqEuclidean'};
%dists={'correlation'};
rpts=200;

%% clustering!!
[~,~,grps] = allevsplitConTransitive(Sxy,dists,rpts);
ngrps=max(grps);

[G,~,Sin,Sout] = sortbysimilarity([(1:size(grps,1))' grps],Sxy);
%to do:  sort by average Sout (not per group)
[~,idxtmp]=sort(Sout,'descend');
G=G(idxtmp,:);
Sin=Sin(idxtmp);
grps2=G(:,2);
%sort by groups
[~,idx_sort]=sort(grps2,'descend');
%G(:,1)=G(idx_sort,1);
G=G(idx_sort,:);
size_grps=zeros(ngrps,1);
Sin=Sin(idx_sort);

for s=1:ngrps
    idx_group=find(grps2(idx_sort)==s);
    size_grps(s)=numel(idx_group);
    [~,tmp_idx]=sort(Sin(idx_group),'descend');
    G(idx_group,1)=G(idx_group(tmp_idx),1);
end

end