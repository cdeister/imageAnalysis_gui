function sem=standardError(dataaa,dim)

% simple SEM (sample corrected, becuase if you have the population you
% probably care about STD or VAR anyway)
% cdeister@brown.edu

c=size(dataaa,dim);
s=nanstd(dataaa,1,dim);
sem=s./sqrt(c-1);
end