% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Displays a calculated model assessment plot
% Requires saving a plot with save_model_assessment.m

load_name = '+ML/results/assess_models_intermediate_5.mat';

load(load_name,'result');
figure;
hold on;
title('Classification Model Comparison','FontSize',20);
xlabel('Sensitivity','FontSize',15);
ylabel('Precision','FontSize',15);
ylim([0.5, 1]); 
xlim([0, 1]);

grid on;

plot(result(:,2,1),result(:,1,1),'DisplayName','Logistic Regression Ensemble','LineWidth',3);
plot(result(:,2,2),result(:,1,2),'DisplayName','SVM','LineWidth',3);
plot(result(:,2,3),result(:,1,3),'DisplayName','Random Forest','LineWidth',3);
plot(result(:,2,4),result(:,1,4),'DisplayName','Adaboost','LineWidth',3);
plot(result(:,2,5),result(:,1,5),'DisplayName','Fully Trained Neural Network','LineWidth',3);

lgd = legend('show');
lgd.FontSize = 18;