clc; clear; close all;

N=500; K=2; p=0.3;
beta=0.4; gamma=0.2;
numMC=50;

G = small_world_generator(N,K,p);

[avg_peak, CI_low, CI_high] = monte_carlo(G,beta,gamma,numMC);

fprintf('Average Peak = %.2f\n',avg_peak);
fprintf('95%% CI = [%.2f , %.2f]\n',CI_low,CI_high);
