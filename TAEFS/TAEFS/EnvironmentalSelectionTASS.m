function [A1,A2] = EnvironmentalSelectionTASS(Population, N1,alpha)
% The environmental selection of NSGA III

%------------------------------- Copyright --------------------------------
% Copyright (c) 2022 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------
PopDec     = Population.decs;
[~, index] = unique(PopDec, 'rows');
Population = Population(index);
PopObj     = Population.objs;
[~,uni] = unique(PopObj,'rows');
Population = Population(uni);

%% Delete duplicated solutions and non-dominated sorting
Obj = Population.objs;
theta = atan2(Obj(:,2),Obj(:,1));
[sorted_theta, indices] = sort(theta);

numG = ceil(size(Obj,1)*alpha);

A1 = Population(indices(1:numG));
A2 = Population(indices(numG+1:end));

if length(A1) > ceil(2*N1*alpha)
    [A1,~,~] = ESelection(A1,ceil(2*N1*alpha));
    [A2,~,~] = ESelection(A2,2*N1 - ceil(2*N1*alpha));
end


end


function varargout = ESelection(A1,N)

Population = A1;

Mask       = A1.decs;

PopObj = Population.objs;
[FrontNo,MaxFNo] = NDSort(PopObj,Population.cons,N);


Next = FrontNo < MaxFNo;
Selected = find(FrontNo < MaxFNo);

%% Truncate the solutions in the last front
Last = find(FrontNo==MaxFNo);
if isempty(Selected)
    Selected = ceil(rand()*N);
end
Choose = Truncation(PopObj(Selected,:),PopObj(Last,:),N);
Next1 = [Selected,Last];
Next(Next1(Choose)) = true;



%% Population for next generation
FrontNo = FrontNo(Next);

Population = Population(Next);
Mask       = Mask(Next,:);
varargout  = {Population,Mask,FrontNo};%Dec,
end


function Choose = Truncation(PopObj1,PopObj2,K)
% Select part of the solutions by truncation
PopObj = [PopObj1;PopObj2];
NN = size(PopObj,1);
Choose = false(1,NN);
N =  size(PopObj1,1);
Choose(1:N) = true;

Distance = inf(N);
for i = 1 : NN-1
    for j = i+1 : NN
        Distance(i,j) = norm(PopObj(i,:)-PopObj(j,:),2);
        Distance(j,i) = Distance(i,j);
    end
end


while sum(Choose) < K
    Remain   = find(~Choose);
    [~,Temp ]   = max(min(Distance(~Choose,Choose),[],2));
    Choose(Remain(Temp)) = true;
end
end