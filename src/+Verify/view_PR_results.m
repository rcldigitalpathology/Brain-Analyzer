% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Views precision recall curve of the automated algorithm

[file,path] = uigetfile('+Verify/results/*.mat','Select a PR analysis');

load(strcat(path,file),'precisions','recalls');

plot(recalls,precisions,'LineWidth',4);
title({'Cell Detection Accuracy'},'FontSize',20);
xlabel('Sensitivity','FontSize',15);
ylabel('Precision','FontSize',15);

ylim([0.5, 1]); 
xlim([0, 1]);
[precisions recalls]

grid on;