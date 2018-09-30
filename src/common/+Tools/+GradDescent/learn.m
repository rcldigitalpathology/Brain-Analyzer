% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Custom made gradient descent model used to optimize parameters. If you
% are going to use this, make sure you have a good understanding of the
% parameters and that you correctly set the cost function in the private
% folder

%Example: Tools.GradDescent.learn('union', 'labeller1', 'train')


function [P_f, C ] = learn(label_set, prediction_set,set_type)

    LEARNING_RATE = 0.05;

    %iterations is number of iterations
    %p_jump is the scale of the basic jump unit for each parameters
    %P_o is the initial parameters
    %bounds are the min and max bounds of each parameters
    %step_length represents the maximum step traversal represented as a
    %   decimal percentage of bound size
   
    P_o = [10,0.05];% initialization param
    p_jump = [2,0.01];% smallest unit that each of the parameter jumps
    max = [100,0.5];% bounds
    min = [0,0]; % bound
    bounds = [min; max;];
    step_length = ones(length(P_o),1)*LEARNING_RATE; %SLOWLY LOWER THIS AFTER
    
    iterations = 5;

    P = zeros(iterations,size(P_o,2));
    P(1,:) = P_o; %initial parameters
    
    C = zeros(iterations,1);
    G = zeros(size(P_o,2),1);
    
    B = bounds(2,:) - bounds(1,:);
    
    for i=1:iterations
       [the_cost,parameter_labels,TP,FP,FN] = cost(P(i,:),label_set, prediction_set,set_type);
       C(i) = the_cost;
       
       fprintf('\n\nXXXXXXXXXX ITERATION:%d XXXXXXXXXX\n',i-1);
       for k=1:length(P(i,:))
            fprintf('%s: %f\n',parameter_labels{k},P(i,k));
       end
       fprintf('\n');
       fprintf('Cost: %f\n',C(i));
       fprintf('TP: %d, FP: %d, FN: %d',TP,FP,FN);
       fprintf('\n\nXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n');
       
       for j = 1:size(P_o,2) %calculate gradients
           b=zeros(1,size(p_jump,2));
           b(j) = 1;
           dP = b.*p_jump;
           G(j) = (cost(P(i,:)+dP,label_set, prediction_set,set_type)-C(i))/(sum(dP));
       end
       G = G.*B'; %to correct for gradient biasing
       G = G.*B'; %to correct for how parameters are adjusted
       
       if (norm(G) == 0)
           fprintf('hit a gradient 0 point\n');
           break;
       end
       
       G = (G).*step_length'/norm(G./B');
       
       if (i == iterations)
           P_f = P(i,:);
           break;
       end
       
       P(i+1,:) = P(i,:) - G';
       
       for j = 1:size(P_o,2)
          if (P(i+1,j) < bounds(1,j))
             P(i+1,j) = bounds(1,j); 
          end
          if (P(i+1,j) > bounds(2,j))
             P(i+1,j) = bounds(2,j);
          end
       end
    end
end

