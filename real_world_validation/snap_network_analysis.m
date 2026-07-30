clc; clear; close all;

% Load SNAP graph (must already be converted to MATLAB graph object)
load('snap_graph.mat');   % contains G_snap
G = G_snap;

N = numnodes(G);

deg = degree(G);
avg_degree = mean(deg);

A = adjacency(G);
C = zeros(N,1);

for u = 1:N
    neigh = find(A(u,:));
    k = length(neigh);
    if k >= 2
        sub = A(neigh, neigh);
        actual = sum(sub(:)) / 2;
        possible = k*(k-1)/2;
        C(u) = actual / possible;
    end
end

clustering = mean(C);

D = distances(G);
D(D==Inf)=NaN;
avg_path = mean(D(~isnan(D) & D>0));

fprintf('\n=== SNAP STRUCTURAL METRICS ===\n');
fprintf('Average Degree: %.2f\n', avg_degree);
fprintf('Clustering Coefficient: %.4f\n', clustering);
fprintf('Average Path Length: %.4f\n', avg_path);
