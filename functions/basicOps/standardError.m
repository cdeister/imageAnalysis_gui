function sem=standardError(dataaa,dim)

c=size(dataaa,dim);
s=std(dataaa,1,dim);
sem=s./sqrt(c-1);
end