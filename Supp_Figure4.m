function Supp_Figure4


load('.\Output_files\Epochs_LDS_all.mat','epochs_LDS','summary_eigs','nsamples','example_t','example_eig_re','example_eig_im')

nrec=numel(nsamples);
Colour_rec=Rainbow(nrec);


fig3=figure;
figure(fig3)
subplot(6,2,1)
hold on
plot(example_t,example_eig_re,'k')
plot([0 1000],[0 0],'b')
hold off

subplot(6,2,3)
plot(example_t,example_eig_im,'k')
box off

% figure for LDS

subplot(6,2,[2 4])
hold on
plot([-0.02 0.02],[0 0],'k')
plot([0 0],[-0.1 0.1],'k')
xlim([-0.0005 0.0005])


for irec=1:nrec


    %Colour_rec(irec,:)=[0 0 0];

    errorbar(summary_eigs(irec,1),summary_eigs(irec,2),summary_eigs(irec,3)./nsamples(irec),'.','Color',Colour_rec(irec,:))
    errorbar(summary_eigs(irec,1),summary_eigs(irec,2),summary_eigs(irec,4)./nsamples(irec),'.','horizontal','Color',Colour_rec(irec,:))
end


load('.\Output_files\Epochs_LDS_all.mat','epochs_LDS')
compare_Neural2Behaviour(epochs_LDS)
end