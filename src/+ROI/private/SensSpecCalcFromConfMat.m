function [SensVec, SpecVec, AccVec, ClassWeight] = SensSpecCalcFromConfMat(ConfMat, ClassVec)
% calculates sensitivity and specificity of a classifier, and returns the class weight as well (its proportion within all classes)
% ClassVec is the (optional) possible classes vector. Otherwise it is taken as the classes available in TrueClass.
% Guy Nir, University of British Columbia, Vancouver, 2017

if (nargin < 2) % ClassVec as an input may help in case not all possible classes are available in TrueClass...
    ClassVec = 1:size(ConfMat,1);
end
class_num = length(ClassVec);
true_pos = zeros(class_num,1);
true_neg = zeros(class_num,1);
flse_pos = zeros(class_num,1);
flse_neg = zeros(class_num,1);
total_pos = zeros(class_num,1);
total_neg = zeros(class_num,1);
SensVec = zeros(class_num,1);
SpecVec = zeros(class_num,1);
AccVec = zeros(class_num,1);

for class_indx = 1:class_num
    true_pos(class_indx) = ConfMat(ClassVec(class_indx),ClassVec(class_indx));
    true_neg(class_indx) = sum(sum(ConfMat(ClassVec,ClassVec))) - sum(ConfMat(ClassVec(class_indx),ClassVec)) - sum(ConfMat(ClassVec,ClassVec(class_indx))) + ConfMat(ClassVec(class_indx),ClassVec(class_indx));
    flse_pos(class_indx) = sum(ConfMat(ClassVec,ClassVec(class_indx))) - ConfMat(ClassVec(class_indx),ClassVec(class_indx));
    flse_neg(class_indx) = sum(ConfMat(ClassVec(class_indx),ClassVec)) - ConfMat(ClassVec(class_indx),ClassVec(class_indx));
    total_pos(class_indx) = true_pos(class_indx) + flse_neg(class_indx);
    total_neg(class_indx) = true_neg(class_indx) + flse_pos(class_indx);
    SensVec(class_indx) = true_pos(class_indx) / (total_pos(class_indx) + eps); % sensitivity (a.k.a. true positive rate) -- higher (1) is better
    SpecVec(class_indx) = true_neg(class_indx) / (total_neg(class_indx) + eps); % specificity (a.k.a. true negative rate) -- higher (1) is better
    AccVec(class_indx) = (true_pos(class_indx) + true_neg(class_indx)) / (total_pos(class_indx) + total_neg(class_indx) + eps); % accuracy -- higher (1) is better
end % for class_indx

% class_weight = (total_pos(:)>0) / sum(total_pos(:)>0,1);
% SensMean = sum(class_weight.*SensVec,1);
% SpecMean = sum(class_weight.*SpecVec,1);

ClassWeight = total_pos(:) ./ (total_pos(:) + total_neg(:) + eps); % proportion of the class within all classes. denom is same as sum(ConfMat(:))...
% SensMeanWeight = sum(class_weight.*SensVec,1);
% SpecMeanWeight = sum(class_weight.*SpecVec,1);

% class_weight = total_pos(2:end) ./ sum(total_pos(2:end),1);
% mean_sens_spec_weighted_no_norm_tissue = sum([class_weight,class_weight].*[SensVec,SpecVec](2:end,:),1);
% SensMeanWeightExclZero = sum(class_weight.*SensVec,1);
% SpecMeanWeightExclZero = sum(class_weight.*SpecVec,1);
return
