clc; clear; close all;

rng(1);

% Set the figure style
set(groot,'defaultFigureColor','w');
set(groot,'defaultAxesColor','w');
set(groot,'defaultAxesXColor','k');
set(groot,'defaultAxesYColor','k');
set(groot,'defaultTextColor','k');
set(groot,'defaultAxesFontSize',11);
set(groot,'defaultAxesFontWeight','normal');
set(groot,'defaultLineLineWidth',1.5);

%% Load the SNAP dataset

edges = load('facebook_combined.txt');

% SNAP node numbering starts from 0
% MATLAB indexing starts from 1
G_snap = graph(edges(:,1)+1, edges(:,2)+1);

fprintf('\n=== SNAP NETWORK INFO ===\n');
fprintf('Number of Nodes: %d\n', numnodes(G_snap));
fprintf('Number of Edges: %d\n', numedges(G_snap));

%% Calculate SNAP network metrics

% Average Degree
deg_snap = degree(G_snap);
avg_deg_snap = mean(deg_snap);

% Clustering Coefficient
A_snap = adjacency(G_snap);
N_snap = numnodes(G_snap);
C_snap = zeros(N_snap,1);

for u = 1:N_snap
    neigh = find(A_snap(u,:));
    k = length(neigh);
    if k >= 2
        sub = A_snap(neigh,neigh);
        actual = sum(sub(:))/2;
        possible = k*(k-1)/2;
        C_snap(u) = actual/possible;
    end
end

clustering_snap = mean(C_snap);

% Average Path Length
D_snap = distances(G_snap);
D_snap(D_snap==Inf) = NaN;
avg_path_snap = mean(D_snap(~isnan(D_snap) & D_snap>0));

fprintf('\n=== SNAP STRUCTURAL METRICS ===\n');
fprintf('Average Degree: %.2f\n', avg_deg_snap);
fprintf('Clustering Coefficient: %.4f\n', clustering_snap);
fprintf('Average Path Length: %.4f\n', avg_path_snap);

%% Run SIR on the SNAP network

beta = 0.4;
gamma = 0.2;

R0_snap = beta / gamma;

fprintf('\n=== SNAP EPIDEMIC PARAMETERS ===\n');
fprintf('Infection Rate (beta) = %.2f\n', beta);
fprintf('Recovery Rate (gamma) = %.2f\n', gamma);
fprintf('Basic Reproduction Number (R0) = %.2f\n', R0_snap);

if abs(R0_snap - 1) < 0.01
    fprintf('R0 ≈ 1 → Epidemic at critical threshold\n');
elseif R0_snap > 1
    fprintf('R0 > 1 → Epidemic spreads\n');
else
    fprintf('R0 < 1 → Epidemic dies out\n');
end


N_snap = numnodes(G_snap);

S = ones(N_snap,1);
I = zeros(N_snap,1);
R = zeros(N_snap,1);

initial = randi(N_snap);
S(initial) = 0;
I(initial) = 1;

S_curve = [];
I_curve = [];
R_curve = [];

while any(I)

    newI = I;
    newR = R;

    for i = 1:N_snap
        if I(i) == 1
            neighbors_i = neighbors(G_snap,i);

            for nb = neighbors_i'
                if S(nb) == 1 && rand < beta
                    newI(nb) = 1;
                    S(nb) = 0;
                end
            end

            if rand < gamma
                newI(i) = 0;
                newR(i) = 1;
            end
        end
    end

    I = newI;
    R = newR;

    S_curve = [S_curve sum(S)];
    I_curve = [I_curve sum(I)];
    R_curve = [R_curve sum(R)];
end

peak_snap = max(I_curve);
fprintf('\nSNAP Single Run Peak Infection: %d\n', peak_snap);

figure;
set(gcf,'Color','w');

hold on;

plot(S_curve,'k-','LineWidth',1.8);
plot(I_curve,'k--','LineWidth',1.8);
plot(R_curve,'k:','LineWidth',1.8);

% Show the SIR legend
lgd = legend({'Susceptible','Infected','Recovered'}, ...
    'Location','northeast');
set(lgd,'TextColor','k','FontSize',11);
legend boxoff;

% Axis labels
xlabel('Time Step','FontSize',13,'FontWeight','bold','Color','k');
ylabel('Number of Nodes','FontSize',13,'FontWeight','bold','Color','k');

% Set the axes
set(gca,...
    'Color','w',...
    'XColor','k',...
    'YColor','k',...
    'FontSize',11,...
    'LineWidth',1.2);

grid on;
set(gca,'GridColor',[0.85 0.85 0.85]);
set(gca,'GridAlpha',0.6);

box on;
%% Run the SNAP Monte Carlo simulation

beta = 0.4;
gamma = 0.2;

R0_snap = beta / gamma;
fprintf('\nSNAP Monte Carlo R0 = %.2f\n', R0_snap);

numMC = 50;    
peak_snap = zeros(numMC,1);
time_snap = zeros(numMC,1);
final_snap = zeros(numMC,1);

N_snap = numnodes(G_snap);

for mc = 1:numMC



    S = ones(N_snap,1);
    I = zeros(N_snap,1);
    R = zeros(N_snap,1);

    initial = randi(N_snap);
    S(initial) = 0;
    I(initial) = 1;

    peakI = 0;
    peak_time = 0;
    t = 0;

    while any(I)
t = t + 1;
        newI = I;
        newR = R;

        for i = 1:N_snap
            if I(i) == 1
                neighbors_i = neighbors(G_snap,i);

                for nb = neighbors_i'
                    if S(nb) == 1 && rand < beta
                        newI(nb) = 1;
                        S(nb) = 0;
                    end
                end

                if rand < gamma
                    newI(i) = 0;
                    newR(i) = 1;
                end
            end
        end

        I = newI;
        R = newR;

        if sum(I) > peakI
            peakI = sum(I);
            peak_time = t;
        end
    end

    peak_snap(mc) = peakI;
    time_snap(mc) = peak_time;
    final_snap(mc) = sum(R);

end

%% Calculate SNAP Monte Carlo statistics

n = numMC;

% Peak
avg_peak_snap = mean(peak_snap);
std_peak_snap = std(peak_snap);
margin_peak_snap = 1.96 * (std_peak_snap / sqrt(n));
CI_peak_low_snap = avg_peak_snap - margin_peak_snap;
CI_peak_high_snap = avg_peak_snap + margin_peak_snap;

% Time to Peak
avg_time_snap = mean(time_snap);
std_time_snap = std(time_snap);
margin_time_snap = 1.96 * (std_time_snap / sqrt(n));
CI_time_low_snap = avg_time_snap - margin_time_snap;
CI_time_high_snap = avg_time_snap + margin_time_snap;

% Final Size
avg_final_snap = mean(final_snap);
std_final_snap = std(final_snap);
margin_final_snap = 1.96 * (std_final_snap / sqrt(n));
CI_final_low_snap = avg_final_snap - margin_final_snap;
CI_final_high_snap = avg_final_snap + margin_final_snap;

fprintf('\n=== SNAP MONTE CARLO RESULTS ===\n');
fprintf('Peak Infection = %.2f ± %.2f (95%% CI: [%.2f , %.2f])\n', ...
    avg_peak_snap, std_peak_snap, CI_peak_low_snap, CI_peak_high_snap);

fprintf('Time to Peak = %.2f ± %.2f (95%% CI: [%.2f , %.2f])\n', ...
    avg_time_snap, std_time_snap, CI_time_low_snap, CI_time_high_snap);

fprintf('Final Epidemic Size = %.2f ± %.2f (95%% CI: [%.2f , %.2f])\n', ...
    avg_final_snap, std_final_snap, CI_final_low_snap, CI_final_high_snap);

%% Create the SNAP results table

SNAP_Table = table( ...
    avg_peak_snap, std_peak_snap, CI_peak_low_snap, CI_peak_high_snap, ...
    avg_time_snap, std_time_snap, CI_time_low_snap, CI_time_high_snap, ...
    avg_final_snap, std_final_snap, CI_final_low_snap, CI_final_high_snap);

SNAP_Table.Properties.VariableNames = { ...
    'Avg_Peak','Std_Peak','CI_Peak_Low','CI_Peak_High', ...
    'Avg_Time','Std_Time','CI_Time_Low','CI_Time_High', ...
    'Avg_Final','Std_Final','CI_Final_Low','CI_Final_High'};

disp(SNAP_Table);


%% Find important SNAP nodes

deg_vals = degree(G_snap);
[max_deg, node_deg] = max(deg_vals);

bet_vals = centrality(G_snap,'betweenness');
[max_bet, node_bet] = max(bet_vals);

fprintf('\n=== SNAP CENTRALITY ===\n');
fprintf('Highest Degree Node: %d (Degree = %d)\n', node_deg, max_deg);
fprintf('Highest Betweenness Node: %d (Value = %.2f)\n', node_bet, max_bet);

%% Test different centrality interventions

beta = 0.4;
gamma = 0.2;
numMC = 50;              % keep smaller for large network
remove_fraction = 0.05;
num_remove = round(remove_fraction * numnodes(G_snap));

cases = ["No Removal", "Random Removal", ...
         "Degree Removal", "Betweenness Removal"];

avg_peak_snap_case = zeros(4,1);
CI_low_snap_case = zeros(4,1);
CI_high_snap_case = zeros(4,1);

for c = 1:4

    peak_values = zeros(numMC,1);

    for mc = 1:numMC


        G_temp = G_snap;

        % Apply the selected removal strategy
        nodes_to_remove = [];

        if c == 2
            nodes_to_remove = randperm(numnodes(G_temp), num_remove);
        elseif c == 3
            deg_vals = degree(G_temp);
            [~, idx] = sort(deg_vals,'descend');
            nodes_to_remove = idx(1:num_remove);
        elseif c == 4
            bet_vals = centrality(G_temp,'betweenness');
            [~, idx] = sort(bet_vals,'descend');
            nodes_to_remove = idx(1:num_remove);
        end

        if c ~= 1
            G_temp = rmnode(G_temp, nodes_to_remove);
        end

        N_mod = numnodes(G_temp);

        % Run SIR
        S = ones(N_mod,1);
        I = zeros(N_mod,1);
        R = zeros(N_mod,1);

        initial = randi(N_mod);
        S(initial) = 0;
        I(initial) = 1;

        peakI = 0;

        while any(I)

            newI = I;
            newR = R;

            for i = 1:N_mod
                if I(i) == 1
                    neighbors_i = neighbors(G_temp,i);

                    for nb = neighbors_i'
                        if S(nb) == 1 && rand < beta
                            newI(nb) = 1;
                            S(nb) = 0;
                        end
                    end

                    if rand < gamma
                        newI(i) = 0;
                        newR(i) = 1;
                    end
                end
            end

            I = newI;
            R = newR;

            peakI = max(peakI, sum(I));
        end

        peak_values(mc) = peakI;

    end

    avg_peak_snap_case(c) = mean(peak_values);
    std_snap_case = std(peak_values);
    margin = 1.96 * (std_snap_case / sqrt(numMC));

    CI_low_snap_case(c) = avg_peak_snap_case(c) - margin;
    CI_high_snap_case(c) = avg_peak_snap_case(c) + margin;

end

%% Plot the intervention comparison

figure;
set(gcf,'Color','w');

b = bar(avg_peak_snap_case,...
    'FaceColor',[0.75 0.75 0.75],...
    'EdgeColor','k',...
    'LineWidth',1.2);

hold on;

errorbar(1:4, avg_peak_snap_case, ...
    avg_peak_snap_case - CI_low_snap_case, ...
    CI_high_snap_case - avg_peak_snap_case, ...
    'k','LineStyle','none','LineWidth',1.2);

xticks(1:4)
xticklabels({'None','Random','Degree','Betweenness'})
set(gca,'FontWeight','bold')

% Axis label
ylabel('Average Peak Infection',...
    'FontSize',13,...
    'FontWeight','bold',...
    'Color','k');

set(gca,...
    'Color','w',...
    'XColor','k',...
    'YColor','k',...
    'FontSize',11,...
    'LineWidth',1.2);

grid on;
set(gca,'GridColor',[0.85 0.85 0.85]);
set(gca,'GridAlpha',0.6);

box on;
%% Create the SNAP centrality table

SNAP_Centrality_Table = table(cases', avg_peak_snap_case);

SNAP_Centrality_Table.Properties.VariableNames = ...
    {'Strategy','Avg_Peak_Infection'};

disp(SNAP_Centrality_Table);

%% Save the SNAP results for comparison

SNAP_Comparison_Table = table( ...
    N_snap, ...
    avg_deg_snap, ...
    clustering_snap, ...
    avg_path_snap, ...
    avg_peak_snap, ...
    avg_peak_snap/N_snap*100, ...
    avg_time_snap, ...
    avg_final_snap, ...
    avg_final_snap/N_snap*100);

SNAP_Comparison_Table.Properties.VariableNames = { ...
    'N', ...
    'Avg_Degree', ...
    'Clustering', ...
    'Avg_Path_Length', ...
    'Avg_Peak', ...
    'Peak_Percent', ...
    'Avg_Time_to_Peak', ...
    'Avg_Final_Size', ...
    'Final_Percent'};

disp(SNAP_Comparison_Table);

writetable( ...
    SNAP_Comparison_Table, ...
    'SNAP_Comparison_Results.csv');

fprintf('\nSNAP comparison results saved successfully.\n');
