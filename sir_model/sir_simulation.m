function peakI = sir_simulation(G,beta,gamma)

N = numnodes(G);

S = ones(N,1);
I = zeros(N,1);
R = zeros(N,1);

initial = randi(N);
S(initial)=0; I(initial)=1;

peakI = 0;

while any(I)
    newI = I; newR = R;

    for i=1:N
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

    I=newI; R=newR;
    peakI = max(peakI,sum(I));
end

end
