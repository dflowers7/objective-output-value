function obj = objectiveOutputValue(yindex, time, name)

if nargin < 3
    name = 'Output Value';
end

obj.Type = 'Objective.Data.OutputValue';
obj.Name = name;
obj.Continuous = false;

obj.tF = max([0,time]);
obj.DiscreteTimes = time;

obj.G = @G;
obj.dGdy = @dGdy;
obj.d2Gdy2 = @d2Gdy2;

obj = pastestruct(objectiveZero(), obj);

    function [val, discrete_times] = G(int)
        val = evaluate_sol(yindex, time, int);
        % Also return measurement time
        discrete_times = time;
    end

    function val = dGdy(t,int)
        val = zeros(int.ny,1);
        if t == time
            val(yindex) = 1;
        end
    end

    function val = d2Gdy2(t,int)
        val = zeros(int.ny);
    end

end

function ybar = evaluate_sol(outputlist, timelist, int)
n = numel(outputlist);
y_all = int.y;
t_all = int.t;

ybar = zeros(n,1);
for i = 1:n
    ind = t_all == timelist(i);
    ybar(i) = y_all(outputlist(i),ind);
end
end