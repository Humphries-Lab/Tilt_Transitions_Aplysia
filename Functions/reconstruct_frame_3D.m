function reconstruct_frame_3D(coeffs,scores,All_f,p,nPC)
meanFrame=mean(All_f);
%Simulations: Generate data from PCA

%nPC=1;

%% Simulate single frame
% nframe=700;
% inputs=scores(nframe,1:20);
% im=reshape(All_f(nframe,:)',p.HB,p.WB);
% 
% colormap(flipud(colormap('gray')))
% Reconstruct_gallop_crawl(coeffs(:,1:20),scores,inputs,meanFrame,p)
% subplot(1,3,1)
% imagesc(im)

%% Simulate moving along PC1
  t=linspace(min(scores(:,nPC)),max(scores(:,nPC)),40)';
  t=[t;flipud(t)];
  inputs=zeros(numel(t),3);
  inputs(:,nPC)=t;
 Reconstruct_gallop_crawl(coeffs(:,1:3),scores,inputs,meanFrame,p,nPC)

%% Simulate moving along PC2
%   t=linspace(min(scores(:,2)),max(scores(:,2)),40)';
%   t=[t;flipud(t)];
%   inputs=[t*0,t,t*0];
%  Reconstruct_gallop_crawl(coeffs(:,1:3),scores,inputs,meanFrame,p)

% %% Simulate moving along PC3
%   t=linspace(min(scores(:,3)),max(scores(:,3)),40)';
%   t=[t;flipud(t)];
%   inputs=[t*0,t*0,t];
%  Reconstruct_gallop_crawl(coeffs(:,1:3),scores,inputs,meanFrame,p)
 
 %% Simulate moving along PC4
%   t=linspace(min(scores(:,4)),max(scores(:,4)),40)';
%   t=[t;flipud(t)];
%   inputs=[t*0,t*0,t*0,t];
%  Reconstruct_gallop_crawl(coeffs(:,1:4),scores,inputs,meanFrame,p)

%% Simulate gallop and crawl
%  t=0:0.1:100;
%  t2=sin(t-5)'*max(scores(:,2))-5;
%  t2(500:end)=0;
%  inputs=[sin(t)'*max(scores(:,1))+10,t2,sin(t-10)'+5];
%  Reconstruct_gallop_crawl(coeffs(:,1:3),scores,inputs,meanFrame,p)

end