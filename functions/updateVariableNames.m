nn=who;
sessionName='_L23_01Aug';

for n=1:numel(nn)
    evalin('base',[nn{n} sessionName '=' nn{n} ';']);
    clear(nn{n})
end
clear nn
clear n
save([sessionName '.mat'])
clear sessionName
clear all