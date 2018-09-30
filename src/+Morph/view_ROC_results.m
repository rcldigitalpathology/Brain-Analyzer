% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis

% Views cross validation results on binary morphology classification

[file,path] = uigetfile('+Morph/results/*.mat','Open result to view');

load([path,file],'A1','A2');

figure;
plot(A1,A2,'LineWidth',4);
title({'Morphology Binary Classification Accuracy'},'FontSize',20);
xlabel('Class A Accuracy','FontSize',15);
ylabel('Class B Accuracy','FontSize',15);

ylim([0.5, 1]); 
xlim([0.5, 1]);

grid on;