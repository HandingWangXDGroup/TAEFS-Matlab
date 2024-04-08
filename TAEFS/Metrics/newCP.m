function score = newCP(Population,P2, Problem)
% <min> <multi/many> <real/integer/label/binary/permutation> <large/none> <constrained/none> <expensive/none> <multimodal/none> <sparse/none> <dynamic/none> <robust/none>
% Minimal classification error rate (the solution with the MCER on the 
% training set and apply it on the tet set)

%------------------------------- Reference --------------------------------
% C. A. Coello Coello and N. C. Cortes, Solving multiobjective optimization
% problems using an artificial immune system, Genetic Programming and
% Evolvable Machines, 2005, 6(2): 163-190.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2021 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

PopDec = P2.decs;

K = 5;
% ValidationNum = 5;
PopDec = logical(PopDec);
Obj = zeros(size(PopDec,1),2);
for k = 1:1
for i = 1:size(PopDec,1)
    sumAccuracyRatio = [];
%     index_instance = DataDec(k,:);
    TrainIn = Problem.useTrainIn;
    TrainOut = Problem.useTrainOut;
    
    indices  = Problem.useindices;
    for fold = 1:5
        test  =  (indices == fold);
        train = ~test;
        TrainInsub = TrainIn(train,:);
        TrainOutsub = TrainOut(train,:);
        ValidInsub = TrainIn(test,:);
        ValidOutsub = TrainOut(test,:);

        [~, Rank] = sort(pdist2(ValidInsub(:, PopDec(i, :)), TrainInsub(:, PopDec(i, :))), 2);
        [~, Out]  = max(hist(double(TrainOutsub(Rank(:, 1:K))'), double(Problem.useCategory)), [], 1);
        Out       = Problem.useCategory(Out);
        BalanceAccuracy = 0;
        for t = 0:size(Problem.useCategory,1)-1
            index = Out == t;
            if sum(index) > 0
                try
                BalanceAccuracy = BalanceAccuracy + mean(Out(index)==ValidOutsub(index)); 
                catch
                BalanceAccuracy = BalanceAccuracy + mean(Out(index)==ValidOutsub(index)); 
                end
            end
        end
        sumAccuracyRatio = [sumAccuracyRatio, BalanceAccuracy./size(Problem.useCategory, 1)];

    end
     LCB = min(sumAccuracyRatio);%;mean(sumAccuracyRatio)-(max(sumAccuracyRatio)-min(sumAccuracyRatio));
     AccuracyRatio = LCB;
     errorRatio    = 1 - AccuracyRatio;

     switch Problem.M
         case 1    % Single-objective feature selection
             alpha = 1e-6;
             Obj(i, 1) = errorRatio.*(1-alpha) + mean(PopDec(i, :)).*alpha;
         case 2    % Bi-objective feature selection
            Obj(i, 1) = errorRatio;
            Obj(i, 2) = mean(PopDec(i, :));
     end
                  
end
end

    PopObj = Obj;
    [~, row] = min(PopObj(:,1));
    PopObj2 = Population.objs;
     [~, row2] = min(PopObj2(:,1));
    score = PopObj2(row,1);
end
