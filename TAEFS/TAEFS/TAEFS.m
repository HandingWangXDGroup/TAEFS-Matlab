classdef TAEFS < ALGORITHM
    %<multi> <real/integer/binary> <large/none> <constrained/none>
    % Feature selection using two archive
    methods
        function main(Algorithm, Problem)

            alpha = 0.5;
            phi = 10;

            Mask = false(2*Problem.N,Problem.D);
            for i =  1:2*Problem.N
                Mask(i,randperm(end,ceil(rand.^2*end))) = true;
            end

            Pop = double(Mask);
            Pop (Pop == 0) = rand(size(Pop(Pop == 0)))*0.5;
            Pop (Pop == 1) = 0.5+rand(size(Pop(Pop == 1)))*0.5;
            Sample = Problem.Evaluation(Mask,Pop);

            Obj = Sample.objs;
            theta = atan2(Obj(:,2),Obj(:,1));
            [sorted_theta, indices] = sort(theta);
            numG = ceil(size(Obj,1)*alpha);

            A1 = Sample(indices(1:numG));
            A2 = Sample(indices(numG+1:end));


            Population = Sample;
            k = 0;
            while Algorithm.NotTerminated(Population)

                k = k +1;
                [Fn_off, Pe_off]= OperatorTASG(Problem, A1, A2);

                if mod(k,phi) == 0

                    Population = EnvironmentalSelectionTASS_01([Fn_off, Pe_off,A1,A2], 2*Problem.N,alpha);
                    Obj = Population.objs;
                    theta = atan2(Obj(:,2),Obj(:,1));
                    [sorted_theta, indices] = sort(theta);
                    numG = ceil(size(Obj,1)*alpha);
                    A1 = Population(indices(1:numG));
                    A2 = Population(indices(numG+1:end));
                else
                    [A1,A2] = EnvironmentalSelectionTASS([Fn_off, A1,Pe_off,A2], Problem.N,alpha);

                end

                Population = [A1,A2];
            end


        end




    end

end