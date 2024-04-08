function [Off1, Off2] = OperatorTASG(Problem, A1, A2)
%
A = [A1,A2];
Mask0 = A.decs;
Vote = sum(Mask0,1);

w = 0.5*(1-cos((1- Problem.FE/Problem.maxFE)*pi));


[value, index] = sort(Vote,'descend');

Zchoose = false(1,Problem.D);
Zchoose(index(1:ceil(w*end))) = true;


Mask1 = A1.decs;
Dec1  = A1.adds;


[N,D] = size(Dec1);
bound = [zeros(1,D);ones(1,D)];
for i = 1:N

    l = rand;
    if l <= 1/3
        F  = .6;
    elseif l <= 2/5
        F= 0.8;
    else
        F = 1.0;
    end

    l=rand;
    if l <= 1/3
        CR  = .1;
    elseif l <= 2/3
        CR = 0.2;
    else
        CR = 1.0;
    end


    indexset = 1:N;
    indexset(i)=[];
    r1=floor(rand*(N-1))+1;
    xr1=indexset(r1);
    indexset(r1)=[];
    r2=floor(rand*(N-2))+1;
    xr2=indexset(r2);
    indexset(r2)=[];
    r3=floor(rand*(N-3))+1;
    xr3=indexset(r3);


    v = Dec1(i,:) + F*(Dec1(xr3,:) - Dec1(i,:)) + F*(Dec1(xr1,:)-Dec1(xr2,:));
    v = Repair(v, bound);
    Mask_v = false(1,D);
    Mask_v(v>=0.5) = true;

    Mask_v = Mask_v.*Zchoose;
    v = v.*Zchoose;

    t = rand(1,D) <CR;
    j_rand = floor(rand * D) + 1;
    t(1, j_rand) = 1;

    t_ = 1 - t;
    trial1(i,:) = t .* v + t_ .* Dec1(i,:);
    trial_mask1(i,:) = t .* Mask_v + t_ .* Mask1(i,:);

end

Off1 =  Problem.Evaluation(trial_mask1,trial1);

% for A2 reduction


Mask = A2.decs;
Dec = A2.adds;
Obj = A2.objs;
[N,D] = size(Dec);

[FrontNO] = NDSort(Obj,N);
NDS = find(FrontNO == 1);
bound = [zeros(1,D);ones(1,D)];

for i = 1:N


    l=rand;
    if l <= 1/3
        F  = .6;
    elseif l <= 2/3
        F= 0.8;
    else
        F = 1.0;
    end

    l=rand;
    if l <= 1/3
        CR  = .1;
    elseif l <= 2/3
        CR = 0.2;
    else
        CR = 1.0;
    end

    indexset=1:N;
    indexset(i)=[];
    r1=floor(rand*(N-1))+1;
    xr1=indexset(r1);
    indexset(r1)=[];
    r2=floor(rand*(N-2))+1;
    xr2=indexset(r2);
    indexset(r2)=[];
    r3=floor(rand*(N-3))+1;
    xr3=indexset(r3);
    indexset(r3)=[];
    r4=floor(rand*(N-4))+1;
    xr4=indexset(r4);


    AAA = Obj(NDS,:);
    [aaa,index ] =sort(Obj(NDS,1));
    index1 = index(ceil(end/2):end);

    best =NDS(index1 (floor(rand()*size(index1,2))+1));

    try
        v = Dec(xr1,:) + F*(Dec(best,:) - Dec(xr2,:)) + F*(Dec(xr3,:) - Dec(xr4,:));

    catch
        v = Dec(xr1,:) + F*(Dec(best,:) - Dec(xr2,:)) + F*(Dec(xr3,:) - Dec(xr4,:));
    end

    v = Repair(v, bound);

    Mask_v = false(1,D);
    Mask_v(v>=0.5) = true;


    t = rand(1,D) < CR;
    j_rand = floor(rand * D) + 1;
    t(1, j_rand) = 1;

    t_ = 1 - t;
    trial2(i,:) = t .* v + t_ .* Dec(i,:);
    trial_mask2(i,:) = t .* Mask_v + t_ .* Mask(i,:);


end

Off2 =  Problem.Evaluation(trial_mask2,trial2);



end