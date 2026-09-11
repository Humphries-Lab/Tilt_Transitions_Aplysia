function Mtransitions=transitions_ocurrence(VideoName)
% transitions_ocurrence
% Calculates the transition matrix between locomotion modes.
%
% INPUTS
%   VideoName - Name of the video associated with the locomotion data.
%
% OUTPUTS
%   Mtransitions - 3x3 Matrix containing the number of transitions between
%                  locomotion modes.

Mtransitions=zeros(3,3);

%% read manual classification
info = xlsread(['Locomotion_' VideoName(1:end-4) '.xlsx']);

locomotion=info(:,4);
Ncycles=size(locomotion,1);
epochs=info(:,5);

%% transform transitions intro matrix
for i=1:Ncycles-1
    if epochs(i)>0 && epochs(i)<=3 && epochs(i+1)>0 && epochs(i+1)<=3
        Mtransitions(epochs(i),epochs(i+1))=Mtransitions(epochs(i),epochs(i+1))+1;
    end

end

end
