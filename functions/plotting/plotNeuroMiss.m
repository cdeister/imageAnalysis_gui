figure
hold all
plot(mean(batchSmooth(trials.stDfsB(:,gain.missTrials_1,cellNum)),2))
plot(mean(batchSmooth(trials.stDfsB(:,gain.missTrials_2,cellNum)),2))
plot(mean(batchSmooth(trials.stDfsB(:,gain.missTrials_3,cellNum)),2))
plot(mean(batchSmooth(trials.stDfsB(:,gain.missTrials_4,cellNum)),2))
plot(mean(batchSmooth(trials.stDfsB(:,gain.missTrials_5,cellNum)),2))
