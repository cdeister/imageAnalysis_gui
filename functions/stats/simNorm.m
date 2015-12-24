function [out]=simNorm(dist)

% this returns a fake Normal distribution that matches the parameters of
% your input distribution (dist).

out=normrnd(mean(dist),std(dist),size(dist));

end