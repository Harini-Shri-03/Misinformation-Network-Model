function [S,I,R] = sir_model(A, beta, gamma, initial_infected, max_steps)

n = size(A,1);

state = zeros(n,1); % 0=S, 1=I, 2=R
state(initial_infected) = 1;

S = zeros(max_steps,1);
I = zeros(max_steps,1);
R = zeros(max_steps,1);

for t = 1:max_steps
    new_state = state;

    for i = 1:n
        if state(i) == 1  % infected
            neighbors = find(A(i,:));
            for j = neighbors
                if state(j) == 0 && rand < beta
                    new_state(j) = 1;
                end
            end
            if rand < gamma
                new_state(i) = 2;
            end
        end
    end

    state = new_state;

    S(t) = sum(state==0);
    I(t) = sum(state==1);
    R(t) = sum(state==2);
end

end
