function sem=standardError(dataaa)

c=numel(dataaa);
s=std(dataaa);
sem=s./sqrt(c-1);
end