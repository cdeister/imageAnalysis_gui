function [shuffledTs]=shuffleTrialsSimp(trials)


rng('shuffle')
for n=1:numel(trials)
    a=randi(numel(trials));
    shuffledTs(:,n)=trials(a);
end

end