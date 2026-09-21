function grps=clustering_eigs(max_eig_re,midT,startbin)
%% 1. for each cycle take the average eig
Ncycles=numel(startbin)-1;

Tcycle=startbin*50/1000;
eig_av=nan(Ncycles,1);
for i=1:Ncycles
    this_cycle=midT>=Tcycle(i) & midT<Tcycle(i+1);
    eig_av(i)=mean(real(max_eig_re(this_cycle)),'omitnan')*(startbin(i+1)-startbin(i));
end
idx_clustering=find(~isnan(eig_av));
%% 2. convert everything to percentage
CR=exp(eig_av) * 100 - 100;
%% 3. create similarity matrix 
S=nan(numel(idx_clustering));
for i=1:numel(idx_clustering)
    S(i,:)=(100-abs(CR(idx_clustering)'-CR(idx_clustering(i))))/100;
end
%% 4. clustering
[grps,~]=clustering(S);
grps=grps(:,1);

% figure
% plot(grps)
end