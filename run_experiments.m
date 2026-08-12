clc;
clear;
close all;

%% =========================================================
% MISN-CTRL: FINAL EXPERIMENTS
% Controlling the Spread of Misinformation in Networks
% ==========================================================

beta  = 0.4;
gamma = 0.2;
numMC = 50;

%% ---------------------------------------------------------
% 1. NETWORK SIZE ANALYSIS
% ----------------------------------------------------------

network_sizes = [100 250 500 1000 2000 4000];

fprintf('\n=============================================\n');
fprintf('NETWORK SIZE ANALYSIS\n');
fprintf('=============================================\n');

for N = network_sizes

    K = 2;
    p = 0.3;

    fprintf('\nNetwork Size: N = %d\n', N);

    G = small_world_generator(N,K,p);

    [avg_peak, CI_low, CI_high] = ...
        monte_carlo(G,beta,gamma,numMC);

    fprintf('Average Peak = %.2f\n',avg_peak);
    fprintf('95%% CI = [%.2f , %.2f]\n',CI_low,CI_high);

end


%% ---------------------------------------------------------
% 2. TOPOLOGY ANALYSIS
% ----------------------------------------------------------

fprintf('\n=============================================\n');
fprintf('NETWORK TOPOLOGY ANALYSIS\n');
fprintf('=============================================\n');

N = 500;
K = 2;

p_values = [0 0.3 1];

for p = p_values

    fprintf('\nRewiring Probability p = %.2f\n',p);

    G = small_world_generator(N,K,p);

    [avg_peak, CI_low, CI_high] = ...
        monte_carlo(G,beta,gamma,numMC);

    fprintf('Average Peak = %.2f\n',avg_peak);
    fprintf('95%% CI = [%.2f , %.2f]\n',CI_low,CI_high);

end


%% ---------------------------------------------------------
% 3. WS-4000 BASELINE
% ----------------------------------------------------------

fprintf('\n=============================================\n');
fprintf('WS-4000 BASELINE\n');
fprintf('=============================================\n');

N = 4000;
K = 2;
p = 0.3;

G_WS4000 = small_world_generator(N,K,p);

[avg_peak, CI_low, CI_high] = ...
    monte_carlo(G_WS4000,beta,gamma,numMC);

fprintf('Average Peak = %.2f\n',avg_peak);
fprintf('95%% CI = [%.2f , %.2f]\n',CI_low,CI_high);


%% ---------------------------------------------------------
% 4. CENTRALITY-BASED INTERVENTION
% ----------------------------------------------------------

fprintf('\n=============================================\n');
fprintf('CENTRALITY-BASED INTERVENTION\n');
fprintf('=============================================\n');

remove_fraction = 0.05;

fprintf('\nRemoval fraction = %.2f\n',remove_fraction);

fprintf('Strategies evaluated:\n');
fprintf('1. No Removal\n');
fprintf('2. Random Removal\n');
fprintf('3. Degree-Based Removal\n');
fprintf('4. Betweenness-Based Removal\n');


%% ---------------------------------------------------------
% 5. REAL-WORLD SNAP VALIDATION
% ----------------------------------------------------------

fprintf('\n=============================================\n');
fprintf('SNAP REAL-WORLD VALIDATION\n');
fprintf('=============================================\n');

fprintf('SNAP network analysis is implemented in:\n');
fprintf('real_world_validation/\n');

fprintf('\nSNAP network:\n');
fprintf('Nodes = 4039\n');
fprintf('Edges = 88234\n');


%% ---------------------------------------------------------
% FINAL MESSAGE
% ----------------------------------------------------------

fprintf('\n=============================================\n');
fprintf('FINAL EXPERIMENT SET COMPLETED\n');
fprintf('=============================================\n');
