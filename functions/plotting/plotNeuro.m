figure
hold all
plot(mean(batchSmooth(trials.stDfsB(:,gain.hitTrials_1,cellNum)),2))
plot(mean(batchSmooth(trials.stDfsB(:,gain.hitTrials_2,cellNum)),2))
plot(mean(batchSmooth(trials.stDfsB(:,gain.hitTrials_3,cellNum)),2))
plot(mean(batchSmooth(trials.stDfsB(:,gain.hitTrials_4,cellNum)),2))
plot(mean(batchSmooth(trials.stDfsB(:,gain.hitTrials_5,cellNum)),2))
