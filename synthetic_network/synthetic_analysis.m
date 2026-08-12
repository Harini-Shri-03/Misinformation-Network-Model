clc; clear; close all;
rng(1);

%% STEP 1: Build Small-World Network (500 Nodes)

N = 4000;
K = 2;
p = 0.3;

A = zeros(N);

% Ring lattice
for i = 1:N
    for j = 1:K
        right = mod(i-1 + j, N) + 1;
        left  = mod(i-1 - j, N) + 1;

        A(i,right) = 1;
        A(right,i) = 1;
        A(i,left) = 1;
        A(left,i) = 1;
    end
end

% Rewiring
for i = 1:N
    for j = 1:K
        neighbor = mod(i-1 + j, N) + 1;

        if rand < p
            A(i,neighbor) = 0;
            A(neighbor,i) = 0;

            possible = setdiff(1:N, [i find(A(i,:))]);
            new_node = possible(randi(length(possible)));

            A(i,new_node) = 1;
            A(new_node,i) = 1;
        end
    end
end

G = graph(A);

figure;
set(gcf,'Color','w');

plot(G,'NodeColor','k','EdgeColor',[0.6 0.6 0.6]);
axis off;

%% STEP 2: STRUCTURAL METRICS (500 Nodes)

% Average Degree
deg = degree(G);
avg_degree = mean(deg);

% Clustering Coefficient
A_mat = adjacency(G);
C = zeros(N,1);

for u = 1:N
    neigh = find(A_mat(u,:));
    k = length(neigh);

    if k >= 2
        sub = A_mat(neigh, neigh);
        actual = sum(sub(:)) / 2;
        possible = k*(k-1)/2;
        C(u) = actual / possible;
    end
end

clustering = mean(C);

% Average Path Length
D = distances(G);
D(D==Inf) = NaN;
avg_path = mean(D(~isnan(D) & D>0));

fprintf('\n=== STRUCTURAL METRICS (500 Nodes) ===\n');
fprintf('Average Degree: %.2f\n', avg_degree);
fprintf('Clustering Coefficient: %.4f\n', clustering);
fprintf('Average Path Length: %.4f\n', avg_path);

%% STEP 3: SINGLE SIR SIMULATION (500 Nodes)

beta = 0.4;
gamma = 0.2;

R0 = beta / gamma;


fprintf('\n=== EPIDEMIC PARAMETERS ===\n');
fprintf('Infection Rate (beta) = %.2f\n', beta);
fprintf('Recovery Rate (gamma) = %.2f\n', gamma);
fprintf('Basic Reproduction Number (R0) = %.2f\n', R0);


S = ones(N,1);
I = zeros(N,1);
R = zeros(N,1);

initial = randi(N);
S(initial) = 0;
I(initial) = 1;

S_curve = [];
I_curve = [];
R_curve = [];

while any(I)

    newI = I;
    newR = R;

    for i = 1:N
        if I(i) == 1
            neighbors_i = neighbors(G,i);

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

peak_infection = max(I_curve);
fprintf('\nSingle Run Peak Infection (500 nodes): %d\n', peak_infection);

figure;
set(gcf,'Color','w');
hold on;

plot(S_curve,'k-','LineWidth',1.8);
plot(I_curve,'k--','LineWidth',1.8);
plot(R_curve,'k:','LineWidth',1.8);

lgd = legend({'Susceptible','Infected','Recovered'}, ...
    'Location','northeast');
set(lgd,'TextColor','k','FontSize',11);
legend boxoff;

xlabel('Time Step','FontWeight','bold','FontSize',12);
ylabel('Number of Nodes','FontWeight','bold','FontSize',12);

set(gca,'Color','w','XColor','k','YColor','k', ...
    'FontSize',11,'LineWidth',1.2,'FontWeight','bold');

grid on;
set(gca,'GridColor',[0.85 0.85 0.85],'GridAlpha',0.6);
box on;

%% STEP 4: MONTE CARLO SIMULATION (500 Nodes)

numMC = 50;          % number of independent runs
peak_values = zeros(numMC,1);
time_to_peak = zeros(numMC,1);
final_values = zeros(numMC,1);

for mc = 1:numMC

   

    % Initialize states
    S = ones(N,1);
    I = zeros(N,1);
    R = zeros(N,1);

    initial = randi(N);
    S(initial) = 0;
    I(initial) = 1;
   
    t = 0; 
    peakI = 0;
    peak_time = 0;

    while any(I)
         t = t + 1;
        newI = I;
        newR = R;

        for i = 1:N
            if I(i) == 1
                neighbors_i = neighbors(G,i);

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

        currentI = sum(I);
        if currentI > peakI
            peakI = currentI;
            peak_time = t;
        end
    end

    peak_values(mc) = peakI;
    time_to_peak(mc) = peak_time;
    final_values(mc) = sum(R);

end

%% SYNTHETIC MONTE CARLO STATISTICS

n = numMC;

% ---- Peak Infection ----
avg_peak = mean(peak_values);
std_peak = std(peak_values);
margin_peak = 1.96 * (std_peak / sqrt(n));
CI_peak_low = avg_peak - margin_peak;
CI_peak_high = avg_peak + margin_peak;

% ---- Time to Peak ----
avg_time = mean(time_to_peak);
std_time = std(time_to_peak);
margin_time = 1.96 * (std_time / sqrt(n));
CI_time_low = avg_time - margin_time;
CI_time_high = avg_time + margin_time;

% ---- Final Epidemic Size ----
avg_final = mean(final_values);
std_final = std(final_values);
margin_final = 1.96 * (std_final / sqrt(n));
CI_final_low = avg_final - margin_final;
CI_final_high = avg_final + margin_final;

%% CREATE SYNTHETIC RESULTS TABLE

Synthetic_Table = table( ...
    avg_peak, std_peak, CI_peak_low, CI_peak_high, ...
    avg_time, std_time, CI_time_low, CI_time_high, ...
    avg_final, std_final, CI_final_low, CI_final_high);

Synthetic_Table.Properties.VariableNames = { ...
    'Avg_Peak','Std_Peak','CI_Peak_Low','CI_Peak_High', ...
    'Avg_Time','Std_Time','CI_Time_Low','CI_Time_High', ...
    'Avg_Final','Std_Final','CI_Final_Low','CI_Final_High'};

disp(Synthetic_Table);

fprintf('\n=== SYNTHETIC MONTE CARLO RESULTS ===\n');
fprintf('Peak Infection = %.2f ± %.2f (95%% CI: [%.2f , %.2f])\n', ...
    avg_peak, std_peak, CI_peak_low, CI_peak_high);

fprintf('Time to Peak = %.2f ± %.2f (95%% CI: [%.2f , %.2f])\n', ...
    avg_time, std_time, CI_time_low, CI_time_high);

fprintf('Final Epidemic Size = %.2f ± %.2f (95%% CI: [%.2f , %.2f])\n', ...
    avg_final, std_final, CI_final_low, CI_final_high);


%% STEP 5: PARAMETER SENSITIVITY (VARY beta)

beta_values = [0.2 0.4 0.6];
numMC = 50;

avg_peaks = zeros(length(beta_values),1);
std_peaks = zeros(length(beta_values),1);
CI_low = zeros(length(beta_values),1);
CI_high = zeros(length(beta_values),1);

for b = 1:length(beta_values)

    beta = beta_values(b);
    R0 = beta / gamma;

    fprintf('\n---------------------------------\n');
    fprintf('beta = %.2f | R0 = %.2f\n', beta, R0);

    if abs(R0 - 1) < 0.01
        fprintf('R0 ≈ 1 → Epidemic at critical threshold\n');
    elseif R0 > 1
        fprintf('R0 > 1 → Epidemic spreads\n');
    else
        fprintf('R0 < 1 → Epidemic dies out\n');
    end

    beta = beta_values(b);
    peak_values = zeros(numMC,1);

    for mc = 1:numMC

       

        % Initialize SIR
        S = ones(N,1);
        I = zeros(N,1);
        R = zeros(N,1);

        initial = randi(N);
        S(initial) = 0;
        I(initial) = 1;

        peakI = 0;

        while any(I)

            newI = I;
            newR = R;

            for i = 1:N
                if I(i) == 1
                    neighbors_i = neighbors(G,i);

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

            currentI = sum(I);
            if currentI > peakI
                peakI = currentI;
            end
        end

        peak_values(mc) = peakI;
    end

    % Statistics
    avg_peaks(b) = mean(peak_values);
    std_peaks(b) = std(peak_values);

    margin = 1.96 * (std_peaks(b) / sqrt(numMC));
    CI_low(b) = avg_peaks(b) - margin;
    CI_high(b) = avg_peaks(b) + margin;

end

%% Plot Results

figure;
set(gcf,'Color','w');

errorbar(beta_values, avg_peaks, ...
    avg_peaks - CI_low, CI_high - avg_peaks, ...
    'ko-','LineWidth',1.8,'MarkerFaceColor','k');

xlabel('\beta','FontWeight','bold','FontSize',12);
ylabel('Average Peak Infection','FontWeight','bold','FontSize',12);

set(gca,'Color','w','XColor','k','YColor','k', ...
    'FontSize',11,'LineWidth',1.2,'FontWeight','bold');

grid on;
set(gca,'GridColor',[0.85 0.85 0.85],'GridAlpha',0.6);
box on;

%% STEP 6: R0 Sensitivity Analysis

gamma = 0.2;
beta_R0_values = 0.1:0.1:0.6;   % more detailed range
numMC = 30;                  % reduce runs for speed

R0_values = beta_R0_values / gamma;
avg_peak_R0 = zeros(length(beta_R0_values),1);

for b = 1:length(beta_R0_values)
    beta = beta_R0_values(b);
    peak_values = zeros(numMC,1);

    for mc = 1:numMC

        

        S = ones(N,1);
        I = zeros(N,1);
        R = zeros(N,1);

        initial = randi(N);
        S(initial)=0; I(initial)=1;

        peakI = 0;

        while any(I)
            newI=I; newR=R;

            for i=1:N
                if I(i)==1
                    neigh=neighbors(G,i);
                    for nb=neigh'
                        if S(nb)==1 && rand<beta
                            newI(nb)=1; S(nb)=0;
                        end
                    end
                    if rand<gamma
                        newI(i)=0; newR(i)=1;
                    end
                end
            end

            I=newI; R=newR;
            peakI=max(peakI,sum(I));
        end

        peak_values(mc)=peakI;
    end

    avg_peak_R0(b)=mean(peak_values);
end

%% Plot R0 vs Peak Infection

figure;
set(gcf,'Color','w');

plot(R0_values, avg_peak_R0,'ko-','LineWidth',1.8,'MarkerFaceColor','k');

xlabel('Basic Reproduction Number R_0','FontWeight','bold','FontSize',12);
ylabel('Average Peak Infection','FontWeight','bold','FontSize',12);

set(gca,'Color','w','XColor','k','YColor','k', ...
    'FontSize',11,'LineWidth',1.2,'FontWeight','bold');

grid on;
set(gca,'GridColor',[0.85 0.85 0.85],'GridAlpha',0.6);
box on;

%% STEP 7: NETWORK TOPOLOGY COMPARISON (VARY p)

beta = 0.4;
p_values = [0 0.3 1];
numMC = 50;

avg_peaks_p = zeros(length(p_values),1);
std_peaks_p = zeros(length(p_values),1);
CI_low_p = zeros(length(p_values),1);
CI_high_p = zeros(length(p_values),1);

for pp = 1:length(p_values)
    
    p = p_values(pp);
    peak_values = zeros(numMC,1);
    
    for mc = 1:numMC
        
        
        
        %% Build Small-World Network for this p
        A = zeros(N);
        
        % Ring lattice
        for i = 1:N
            for j = 1:K
                right = mod(i-1 + j, N) + 1;
                left  = mod(i-1 - j, N) + 1;
                
                A(i,right) = 1;
                A(right,i) = 1;
                A(i,left) = 1;
                A(left,i) = 1;
            end
        end
        
        % Rewiring
        for i = 1:N
            for j = 1:K
                neighbor = mod(i-1 + j, N) + 1;
                
                if rand < p
                    A(i,neighbor) = 0;
                    A(neighbor,i) = 0;
                    
                    possible = setdiff(1:N, [i find(A(i,:))]);
                    new_node = possible(randi(length(possible)));
                    
                    A(i,new_node) = 1;
                    A(new_node,i) = 1;
                end
            end
        end
        
        G_temp = graph(A);
        
        %% Run SIR
        
        S = ones(N,1);
        I = zeros(N,1);
        R = zeros(N,1);
        
        initial = randi(N);
        S(initial) = 0;
        I(initial) = 1;
        
        peakI = 0;
        
        while any(I)
            
            newI = I;
            newR = R;
            
            for i = 1:N
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
            
            currentI = sum(I);
            if currentI > peakI
                peakI = currentI;
            end
        end
        
        peak_values(mc) = peakI;
        
    end
    
    % Statistics
    avg_peaks_p(pp) = mean(peak_values);
    std_peaks_p(pp) = std(peak_values);
    
    margin = 1.96 * (std_peaks_p(pp) / sqrt(numMC));
    CI_low_p(pp) = avg_peaks_p(pp) - margin;
    CI_high_p(pp) = avg_peaks_p(pp) + margin;
    
end

%% Plot Results
figure;
set(gcf,'Color','w');

b = bar(avg_peaks_p);
b.FaceColor = [0.7 0.7 0.7];
b.EdgeColor = 'k';

hold on;

errorbar(1:length(p_values), avg_peaks_p, ...
    avg_peaks_p - CI_low_p, ...
    CI_high_p - avg_peaks_p, ...
    'k','LineStyle','none','LineWidth',1.2);

xticks(1:length(p_values));
xticklabels({'p=0','p=0.3','p=1'});
set(gca,'FontWeight','bold');

ylabel('Average Peak Infection','FontWeight','bold','FontSize',12);

set(gca,'Color','w','XColor','k','YColor','k', ...
    'FontSize',11,'LineWidth',1.2);

grid on;
set(gca,'GridColor',[0.85 0.85 0.85],'GridAlpha',0.6);
box on;

fprintf('\n=== NETWORK TOPOLOGY RESULTS ===\n');
for pp = 1:length(p_values)
    fprintf('p = %.2f | Avg Peak = %.2f | CI = [%.2f , %.2f]\n', ...
        p_values(pp), avg_peaks_p(pp), CI_low_p(pp), CI_high_p(pp));
end

%% STEP 8: CENTRALITY-BASED INTERVENTION

beta = 0.4;
gamma = 0.2;
numMC = 50;
remove_fraction = 0.05;
num_remove = round(remove_fraction * N);

cases = ["No Removal", "Random Removal", ...
         "Degree Removal", "Betweenness Removal"];

avg_peak_case = zeros(4,1);
CI_low_case = zeros(4,1);
CI_high_case = zeros(4,1);
avg_final_case = zeros(4,1);

for c = 1:4
    
    peak_values = zeros(numMC,1);
    final_values = zeros(numMC,1);
    
    for mc = 1:numMC
        
        
        
        % Build small-world (p = 0.3)
        p = 0.3;
        A = zeros(N);
        
        for i = 1:N
            for j = 1:K
                right = mod(i-1 + j, N) + 1;
                left  = mod(i-1 - j, N) + 1;
                A(i,right)=1; A(right,i)=1;
                A(i,left)=1; A(left,i)=1;
            end
        end
        
        for i = 1:N
            for j = 1:K
                neighbor = mod(i-1 + j, N) + 1;
                if rand < p
                    A(i,neighbor)=0; A(neighbor,i)=0;
                    possible = setdiff(1:N,[i find(A(i,:))]);
                    new_node = possible(randi(length(possible)));
                    A(i,new_node)=1; A(new_node,i)=1;
                end
            end
        end
        
        G_temp = graph(A);
        
        % --- Apply removal strategy ---
        nodes_to_remove = [];
        
        if c == 2
            nodes_to_remove = randperm(N, num_remove);
        elseif c == 3
            deg_vals = degree(G_temp);
            [~, idx] = sort(deg_vals,'descend');
            nodes_to_remove = idx(1:num_remove);
        elseif c == 4
            bet_vals = centrality(G_temp,'betweenness');
            [~, idx] = sort(bet_vals,'descend');
            nodes_to_remove = idx(1:num_remove);
        end
        
        % Remove nodes
        G_mod = rmnode(G_temp, nodes_to_remove);
        N_mod = numnodes(G_mod);
        
        % Run SIR
        S = ones(N_mod,1);
        I = zeros(N_mod,1);
        R = zeros(N_mod,1);
        
        initial = randi(N_mod);
        S(initial)=0; I(initial)=1;
        
        peakI = 0;
        
        while any(I)
            newI = I; newR = R;
            for i = 1:N_mod
                if I(i)==1
                    neighbors_i = neighbors(G_mod,i);
                    for nb = neighbors_i'
                        if S(nb)==1 && rand < beta
                            newI(nb)=1; S(nb)=0;
                        end
                    end
                    if rand < gamma
                        newI(i)=0; newR(i)=1;
                    end
                end
            end
            I=newI; R=newR;
            peakI = max(peakI,sum(I));
        end
        
        peak_values(mc)=peakI;
        final_values(mc)=sum(R);
    end
    
    avg_peak_case(c)=mean(peak_values);
    std_case=std(peak_values);
    margin=1.96*(std_case/sqrt(numMC));
    CI_low_case(c)=avg_peak_case(c)-margin;
    CI_high_case(c)=avg_peak_case(c)+margin;
    avg_final_case(c)=mean(final_values);
end

%% Reduction Percentages

baseline_peak = avg_peak_case(1);
baseline_final = avg_final_case(1);

fprintf('\n=== SYNTHETIC REDUCTIONS ===\n');

for c = 2:4
    peak_reduction = ((baseline_peak - avg_peak_case(c)) / baseline_peak) * 100;
    final_reduction = ((baseline_final - avg_final_case(c)) / baseline_final) * 100;

    fprintf('%s:\n', cases(c));
    fprintf('Peak Reduction = %.2f %%\n', peak_reduction);
    fprintf('Final Size Reduction = %.2f %%\n\n', final_reduction);
end

%% Plot Intervention Comparison

figure;
set(gcf,'Color','w');

b = bar(avg_peak_case,'FaceColor',[0.75 0.75 0.75],'EdgeColor','k');
hold on;

errorbar(1:4, avg_peak_case, ...
    avg_peak_case - CI_low_case, ...
    CI_high_case - avg_peak_case, ...
    'k','LineStyle','none','LineWidth',1.2);

xticks(1:4);
xticklabels({'None','Random','Degree','Betweenness'});
set(gca,'FontWeight','bold');

ylabel('Average Peak Infection','FontWeight','bold','FontSize',12);

set(gca,'Color','w','XColor','k','YColor','k', ...
    'FontSize',11,'LineWidth',1.2);

grid on;
set(gca,'GridColor',[0.85 0.85 0.85],'GridAlpha',0.6);
box on;
figure;

subplot(1,3,1);
errorbar(beta_values(:), avg_peaks(:), ...
    avg_peaks(:)-CI_low(:), CI_high(:)-avg_peaks(:), 'o-');
title('\beta Sensitivity');
xlabel('\beta');
ylabel('Peak Infection');

subplot(1,3,2);
bar(avg_peaks_p);
title('Topology Effect');
xticklabels({'p=0','p=0.3','p=1'});

subplot(1,3,3);
bar(avg_peak_case);
title('Centrality Intervention');
xticklabels(cases);

%% STEP 9: NETWORK SIZE ANALYSIS


fprintf('\n\n');
fprintf('=========================================================\n');
fprintf('        STEP 9: NETWORK SIZE ANALYSIS\n');
fprintf('=========================================================\n');


%% ---------------------------------------------------------
% STEP 9A: PARAMETERS
% ---------------------------------------------------------

rng(1);

% Network sizes to investigate
N_values = [100 250 500 1000 2000 4000];

% Watts-Strogatz parameters
K = 2;
p = 0.3;

% SIR parameters
beta = 0.4;
gamma = 0.2;

% Monte Carlo simulations
numMC = 50;

% Number of network sizes
numSizes = length(N_values);


%% ---------------------------------------------------------
% STEP 9B: PRE-ALLOCATE RESULTS
% ---------------------------------------------------------

% Structural metrics
avg_degree_size = zeros(numSizes,1);
clustering_size = zeros(numSizes,1);
avg_path_size = zeros(numSizes,1);

% Peak infection
avg_peak_size = zeros(numSizes,1);
std_peak_size = zeros(numSizes,1);
CI_low_peak_size = zeros(numSizes,1);
CI_high_peak_size = zeros(numSizes,1);

% Time to peak
avg_time_size = zeros(numSizes,1);
std_time_size = zeros(numSizes,1);

% Final epidemic size
avg_final_size = zeros(numSizes,1);
std_final_size = zeros(numSizes,1);


%% ---------------------------------------------------------
% STEP 9C: LOOP THROUGH NETWORK SIZES
% ---------------------------------------------------------

for s = 1:numSizes

    N = N_values(s);

    fprintf('\n');
    fprintf('---------------------------------------------------------\n');
    fprintf('NETWORK SIZE: N = %d\n', N);
    fprintf('---------------------------------------------------------\n');


    %% -----------------------------------------------------
    % 9C-1: BUILD WATTS-STROGATZ NETWORK
    % -----------------------------------------------------

    A = zeros(N);

    % Create ring lattice
    for i = 1:N

        for j = 1:K

            right = mod(i-1 + j, N) + 1;
            left  = mod(i-1 - j, N) + 1;

            A(i,right) = 1;
            A(right,i) = 1;

            A(i,left) = 1;
            A(left,i) = 1;

        end

    end


    % Rewiring
    for i = 1:N

        for j = 1:K

            neighbor = mod(i-1 + j, N) + 1;

            if rand < p

                % Remove original edge
                A(i,neighbor) = 0;
                A(neighbor,i) = 0;

                % Find possible new nodes
                possible = setdiff( ...
                    1:N, ...
                    [i find(A(i,:))]);

                if ~isempty(possible)

                    new_node = ...
                        possible(randi(length(possible)));

                    % Add new edge
                    A(i,new_node) = 1;
                    A(new_node,i) = 1;

                end

            end

        end

    end


    % Create MATLAB graph
    G = graph(A);


    %% -----------------------------------------------------
    % 9C-2: CALCULATE STRUCTURAL METRICS
    % -----------------------------------------------------

    % Average Degree
    deg = degree(G);

    avg_degree_size(s) = mean(deg);


    % -----------------------------------------------------
    % Clustering Coefficient
    % -----------------------------------------------------

    A_mat = adjacency(G);

    C = zeros(N,1);

    for u = 1:N

        neigh = find(A_mat(u,:));

        k_node = length(neigh);

        if k_node >= 2

            sub = A_mat(neigh,neigh);

            actual = sum(sub(:)) / 2;

            possible_links = ...
                k_node * (k_node - 1) / 2;

            C(u) = actual / possible_links;

        end

    end

    clustering_size(s) = mean(C);


    % -----------------------------------------------------
    % Average Path Length
    % -----------------------------------------------------

    D = distances(G);

    D(D == Inf) = NaN;

    valid_distances = ...
        D(~isnan(D) & D > 0);

    avg_path_size(s) = ...
        mean(valid_distances);


    %% Display structural results

    fprintf('Average Degree          = %.4f\n', ...
        avg_degree_size(s));

    fprintf('Clustering Coefficient  = %.4f\n', ...
        clustering_size(s));

    fprintf('Average Path Length     = %.4f\n', ...
        avg_path_size(s));


    %% -----------------------------------------------------
    % 9C-3: MONTE CARLO SIR SIMULATION
    % -----------------------------------------------------

    peak_values = zeros(numMC,1);

    time_to_peak_values = zeros(numMC,1);

    final_values = zeros(numMC,1);


    for mc = 1:numMC

        % Initial SIR states
        S = ones(N,1);
        I = zeros(N,1);
        R = zeros(N,1);


        % Random initial infected node
        initial = randi(N);

        S(initial) = 0;
        I(initial) = 1;


        t = 0;

        peakI = 0;
        peak_time = 0;


        %% SIR simulation

        while any(I)

            t = t + 1;

            newI = I;
            newR = R;


            for i = 1:N

                if I(i) == 1

                    % Find neighbours
                    neighbors_i = neighbors(G,i);


                    % Infection process
                    for nb = neighbors_i'

                        if S(nb) == 1 && rand < beta

                            newI(nb) = 1;
                            S(nb) = 0;

                        end

                    end


                    % Recovery process
                    if rand < gamma

                        newI(i) = 0;
                        newR(i) = 1;

                    end

                end

            end


            % Update states
            I = newI;
            R = newR;


            % Current infected nodes
            currentI = sum(I);


            % Track peak infection
            if currentI > peakI

                peakI = currentI;
                peak_time = t;

            end

        end


        % Store results
        peak_values(mc) = peakI;

        time_to_peak_values(mc) = peak_time;

        final_values(mc) = sum(R);

    end


    %% -----------------------------------------------------
    % 9C-4: CALCULATE STATISTICS
    % -----------------------------------------------------

    % Average Peak Infection
    avg_peak_size(s) = mean(peak_values);

    % Standard deviation
    std_peak_size(s) = std(peak_values);

    % 95% confidence interval
    margin = 1.96 * ...
        (std_peak_size(s) / sqrt(numMC));

    CI_low_peak_size(s) = ...
        avg_peak_size(s) - margin;

    CI_high_peak_size(s) = ...
        avg_peak_size(s) + margin;


    % Average Time to Peak
    avg_time_size(s) = ...
        mean(time_to_peak_values);

    std_time_size(s) = ...
        std(time_to_peak_values);


    % Average Final Epidemic Size
    avg_final_size(s) = ...
        mean(final_values);

    std_final_size(s) = ...
        std(final_values);


    %% -----------------------------------------------------
    % 9C-5: DISPLAY SIR RESULTS
    % -----------------------------------------------------

    fprintf('\nSIR RESULTS:\n');

    fprintf('Average Peak Infection  = %.2f\n', ...
        avg_peak_size(s));

    fprintf('95%% CI                  = [%.2f , %.2f]\n', ...
        CI_low_peak_size(s), ...
        CI_high_peak_size(s));

    fprintf('Average Time to Peak    = %.2f\n', ...
        avg_time_size(s));

    fprintf('Average Final Size      = %.2f\n', ...
        avg_final_size(s));

end


%% =========================================================
% STEP 9D: CALCULATE RELATIVE RESULTS
% =========================================================

% Peak infection as percentage of total network
peak_percent_size = ...
    (avg_peak_size ./ N_values(:)) * 100;


% Final epidemic size as percentage of total network
final_percent_size = ...
    (avg_final_size ./ N_values(:)) * 100;


%% =========================================================
% STEP 9E: CREATE FINAL RESULTS TABLE
% =========================================================

Network_Size_Table = table( ...
    N_values(:), ...
    avg_degree_size, ...
    clustering_size, ...
    avg_path_size, ...
    avg_peak_size, ...
    peak_percent_size, ...
    std_peak_size, ...
    CI_low_peak_size, ...
    CI_high_peak_size, ...
    avg_time_size, ...
    std_time_size, ...
    avg_final_size, ...
    final_percent_size, ...
    std_final_size);


Network_Size_Table.Properties.VariableNames = { ...
    'N', ...
    'Avg_Degree', ...
    'Clustering', ...
    'Avg_Path_Length', ...
    'Avg_Peak', ...
    'Peak_Percent', ...
    'Std_Peak', ...
    'CI_Peak_Low', ...
    'CI_Peak_High', ...
    'Avg_Time_to_Peak', ...
    'Std_Time_to_Peak', ...
    'Avg_Final_Size', ...
    'Final_Percent', ...
    'Std_Final_Size'};


%% Display table

fprintf('\n\n');
fprintf('=========================================================\n');
fprintf('          NETWORK SIZE ANALYSIS RESULTS\n');
fprintf('=========================================================\n');

disp(Network_Size_Table);


%% =========================================================
% STEP 9F: ABSOLUTE PEAK INFECTION
% =========================================================

figure('Color','w','Position',[100 100 1000 650]);

errorbar( ...
    N_values, ...
    avg_peak_size, ...
    avg_peak_size - CI_low_peak_size, ...
    CI_high_peak_size - avg_peak_size, ...
    'ko-', ...
    'LineWidth',1.8, ...
    'MarkerSize',8, ...
    'MarkerFaceColor','k');


xlabel('Network Size (N)', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'Color','k');

ylabel('Average Peak Infection', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'Color','k');

title('Effect of Network Size on Peak Infection', ...
    'FontWeight','bold', ...
    'FontSize',15, ...
    'Color','k');


ax = gca;

set(ax, ...
    'Color','w', ...
    'XColor','k', ...
    'YColor','k', ...
    'FontSize',12, ...
    'FontWeight','bold', ...
    'LineWidth',1.2);

grid on;

ax.GridColor = [0.85 0.85 0.85];
ax.GridAlpha = 0.6;

box on;


%% =========================================================
% STEP 9G: RELATIVE PEAK INFECTION
% =========================================================

figure('Color','w','Position',[100 100 1000 650]);

plot( ...
    N_values, ...
    peak_percent_size, ...
    'ko-', ...
    'LineWidth',1.8, ...
    'MarkerSize',8, ...
    'MarkerFaceColor','k');


xlabel('Network Size (N)', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'Color','k');

ylabel('Peak Infection (%)', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'Color','k');

title('Relative Peak Infection vs Network Size', ...
    'FontWeight','bold', ...
    'FontSize',15, ...
    'Color','k');


ax = gca;

set(ax, ...
    'Color','w', ...
    'XColor','k', ...
    'YColor','k', ...
    'FontSize',12, ...
    'FontWeight','bold', ...
    'LineWidth',1.2);

grid on;

ax.GridColor = [0.85 0.85 0.85];
ax.GridAlpha = 0.6;

box on;


%% =========================================================
% STEP 9H: TIME TO PEAK
% =========================================================

figure('Color','w','Position',[100 100 1000 650]);

plot( ...
    N_values, ...
    avg_time_size, ...
    'ko-', ...
    'LineWidth',1.8, ...
    'MarkerSize',8, ...
    'MarkerFaceColor','k');


xlabel('Network Size (N)', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'Color','k');

ylabel('Average Time to Peak', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'Color','k');

title('Effect of Network Size on Time to Peak', ...
    'FontWeight','bold', ...
    'FontSize',15, ...
    'Color','k');


ax = gca;

set(ax, ...
    'Color','w', ...
    'XColor','k', ...
    'YColor','k', ...
    'FontSize',12, ...
    'FontWeight','bold', ...
    'LineWidth',1.2);

grid on;

ax.GridColor = [0.85 0.85 0.85];
ax.GridAlpha = 0.6;

box on;


%% =========================================================
% STEP 9I: ABSOLUTE FINAL EPIDEMIC SIZE
% =========================================================

figure('Color','w','Position',[100 100 1000 650]);

plot( ...
    N_values, ...
    avg_final_size, ...
    'ko-', ...
    'LineWidth',1.8, ...
    'MarkerSize',8, ...
    'MarkerFaceColor','k');


xlabel('Network Size (N)', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'Color','k');

ylabel('Average Final Epidemic Size', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'Color','k');

title('Effect of Network Size on Final Epidemic Size', ...
    'FontWeight','bold', ...
    'FontSize',15, ...
    'Color','k');


ax = gca;

set(ax, ...
    'Color','w', ...
    'XColor','k', ...
    'YColor','k', ...
    'FontSize',12, ...
    'FontWeight','bold', ...
    'LineWidth',1.2);

grid on;

ax.GridColor = [0.85 0.85 0.85];
ax.GridAlpha = 0.6;

box on;


%% =========================================================
% STEP 9J: RELATIVE FINAL EPIDEMIC SIZE
% =========================================================

figure('Color','w','Position',[100 100 1000 650]);

plot( ...
    N_values, ...
    final_percent_size, ...
    'ko-', ...
    'LineWidth',1.8, ...
    'MarkerSize',8, ...
    'MarkerFaceColor','k');


xlabel('Network Size (N)', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'Color','k');

ylabel('Final Epidemic Size (%)', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'Color','k');

title('Relative Final Epidemic Size vs Network Size', ...
    'FontWeight','bold', ...
    'FontSize',15, ...
    'Color','k');


ax = gca;

set(ax, ...
    'Color','w', ...
    'XColor','k', ...
    'YColor','k', ...
    'FontSize',12, ...
    'FontWeight','bold', ...
    'LineWidth',1.2);

grid on;

ax.GridColor = [0.85 0.85 0.85];
ax.GridAlpha = 0.6;

box on;


%% =========================================================
% STEP 9K: CLUSTERING COEFFICIENT
% =========================================================

figure('Color','w','Position',[100 100 1000 650]);

plot( ...
    N_values, ...
    clustering_size, ...
    'ko-', ...
    'LineWidth',1.8, ...
    'MarkerSize',8, ...
    'MarkerFaceColor','k');


xlabel('Network Size (N)', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'Color','k');

ylabel('Clustering Coefficient', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'Color','k');

title('Clustering Coefficient vs Network Size', ...
    'FontWeight','bold', ...
    'FontSize',15, ...
    'Color','k');


ax = gca;

set(ax, ...
    'Color','w', ...
    'XColor','k', ...
    'YColor','k', ...
    'FontSize',12, ...
    'FontWeight','bold', ...
    'LineWidth',1.2);

grid on;

ax.GridColor = [0.85 0.85 0.85];
ax.GridAlpha = 0.6;

box on;


%% =========================================================
% STEP 9L: AVERAGE PATH LENGTH
% =========================================================

figure('Color','w','Position',[100 100 1000 650]);

plot( ...
    N_values, ...
    avg_path_size, ...
    'ko-', ...
    'LineWidth',1.8, ...
    'MarkerSize',8, ...
    'MarkerFaceColor','k');


xlabel('Network Size (N)', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'Color','k');

ylabel('Average Path Length', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'Color','k');

title('Average Path Length vs Network Size', ...
    'FontWeight','bold', ...
    'FontSize',15, ...
    'Color','k');


ax = gca;

set(ax, ...
    'Color','w', ...
    'XColor','k', ...
    'YColor','k', ...
    'FontSize',12, ...
    'FontWeight','bold', ...
    'LineWidth',1.2);

grid on;

ax.GridColor = [0.85 0.85 0.85];
ax.GridAlpha = 0.6;

box on;


%% =========================================================
% STEP 9M: AVERAGE DEGREE
% =========================================================

figure('Color','w','Position',[100 100 1000 650]);

plot( ...
    N_values, ...
    avg_degree_size, ...
    'ko-', ...
    'LineWidth',1.8, ...
    'MarkerSize',8, ...
    'MarkerFaceColor','k');


xlabel('Network Size (N)', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'Color','k');

ylabel('Average Degree', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'Color','k');

title('Average Degree vs Network Size', ...
    'FontWeight','bold', ...
    'FontSize',15, ...
    'Color','k');


ax = gca;

set(ax, ...
    'Color','w', ...
    'XColor','k', ...
    'YColor','k', ...
    'FontSize',12, ...
    'FontWeight','bold', ...
    'LineWidth',1.2);

grid on;

ax.GridColor = [0.85 0.85 0.85];
ax.GridAlpha = 0.6;

box on;


%% =========================================================
% STEP 9N: SAVE RESULTS
% =========================================================

writetable( ...
    Network_Size_Table, ...
    'Network_Size_Results.csv');


fprintf('\n');
fprintf('=========================================================\n');
fprintf('Network size results saved successfully.\n');
fprintf('File: Network_Size_Results.csv\n');
fprintf('=========================================================\n');
