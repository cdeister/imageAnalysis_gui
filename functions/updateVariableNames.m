nn=who;
sessionName='_cdSom5_21Aug';

for n=1:numel(nn)
    evalin('base',[nn{n} sessionName '=' nn{n} ';']);
    clear(nn{n})
end
clear nn