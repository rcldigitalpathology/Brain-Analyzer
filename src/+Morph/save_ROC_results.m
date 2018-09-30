% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis

% Calculates cross validation results on binary morphology classification

[file,path] = uiputfile('+Morph/results/*.mat','Save results as');

tic;
[features,labels] = Morph.extract_data();
toc

labels(labels==2) = 1;
labels(labels==3) = 4;

t = templateSVM('Standardize',1);

N = size(features,1);
k = N;
ITERATIONS=10;

A1=[];
A2=[];
 
N_THRESH = 20;
for b=1:N_THRESH
    THRESH = (b-1)/(N_THRESH-1);
    Yprob = [];
    P = [];
    Y = [];

    for j=1:ITERATIONS
        B = reshape(randperm(N),[N/k,k]);
        for i=1:k
            xtest = features(B(:,i),:);
            ytest = labels(B(:,i));

            xtrain = features(setdiff(1:N,B(:,i)),:);
            ytrain = labels(setdiff(1:N,B(:,i)));

            Mdl = fitcecoc(xtrain,ytrain,'Learners',t);

    %       P = [P; predict(Mdl,xtest)];
            Y = [Y; ytest];  
            [~,p] = predict( Mdl, xtest);
            Yprob = [Yprob; p]; 
        end
    end

    Yprob = (-Yprob(:,1)/(max(-Yprob(:,1))));

    Ybool = Yprob > THRESH;
    for n=1:length(Ybool)
        if Ybool(n) == 1
            P(n) = 4;
        elseif Ybool(n) ==0
            P(n) = 1;
        end
    end

    confMat = confusionmat(Y, P);
    result = bsxfun(@rdivide,confMat,sum(confMat,2));
    
    A1=[A1; result(1,1)];
    A2=[A2; result(2,2)];
    fprintf('Done %d of %d points\n',b,N_THRESH);
end

save(strcat(path,file),'A1','A2');



