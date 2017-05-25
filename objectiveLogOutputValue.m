function obj = objectiveLogOutputValue(yindex, time, name, returnnegativevalue)

if nargin < 4
    returnnegativevalue = false;
    if nargin < 3
        name = 'Output Value';
    end
end

obj.Type = 'Objective.Data.OutputValue';
obj.Name = name;
obj.Continuous = false;

obj.tF = max([0,time]);
obj.DiscreteTimes = time;

if returnnegativevalue
    negativemult = -1;
else
    negativemult = 1;
end

obj.G = @G;
obj.dGdy = @dGdy;
obj.d2Gdy2 = @d2Gdy2;
obj.dGdT = @dGdT;

obj = pastestruct(objectiveZero(), obj);

    function [val, discrete_times] = G(int)
        val = negativemult*log(evaluate_sol(yindex, time, int));
        % Also return measurement time
        discrete_times = time;
    end

    function val = dGdy(t,int)
        val = zeros(int.ny,1);
        if t == time
            yval = evaluate_sol(yindex, time, int);
            val(yindex) = negativemult./yval;
        end
    end

    function val = dGdT(int)
        [ybar,dybardT] = evaluate_sol(yindex, time, int);
        val = negativemult./ybar.*dybardT(:);
    end

    function val = d2Gdy2(t,int)
        val = zeros(int.ny);
        if t == time
            yval = evaluate_sol(yindex, time, int);
            val(yindex,yindex) = -negativemult./yval.^2;
        end
    end

end

function [ybar,dybardT] = evaluate_sol(outputlist, timelist, int)
n = numel(outputlist);
y_all = int.y;
t_all = int.t;

ybar = zeros(n,1);
for i = 1:n
    ind = t_all == timelist(i);
    ybar(i) = y_all(outputlist(i),ind);
end

if nargout > 1
    ny = int.ny;
    nT = int.nT;
    dybardT = zeros(n,nT);
    dydT_all = int.dydT;
    for i = 1:n
        ind = t_all == timelist(i);
        yis = sub2ind([ny, nT], repmat(outputlist(i),1,nT), 1:nT);
        dybardT(i,:) = dydT_all(yis,ind);
    end
end
end