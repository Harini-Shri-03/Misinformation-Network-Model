clc; clear; close all;

load('snap_graph.mat');   % contains G_snap
G = G_snap;

beta = 0.4;
gamma = 0.2;
numMC = 30;

N = numnodes(G);

peaks = zeros(numMC,1);

for mc = 1:numMC

    S = ones(N,1);
    I = zeros(N,1);
    R = zeros(N,1);

    initial = randi(N);
    S(initial)=0;
    I(initial)=1;

    peakI = 0;

    while any(I)

        newI = I;
        newR = R;

        for i = 1:N
            if I(i)==1
                neighbors_i = neighbors(G,i);

                for nb = neighbors_i'
                    if S(nb)==1 && rand < beta
                        newI(nb)=1;
                        S(nb)=0;
                    end
                end

                if rand < gamma
                    newI(i)=0;
                    newR(i)=1;
                end
            end
        end

        I=newI;
        R=newR;

        peakI = max(peakI,sum(I));
    end

    peaks(mc)=peakI;
end

fprintf('\n=== SNAP MONTE CARLO RESULTS ===\n');
fprintf('Average Peak = %.2f\n', mean(peaks));
fprintf('Std = %.2f\n', std(peaks));
