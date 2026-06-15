A = small_world_generator(100,4,0.1);

beta = 0.3;
gamma = 0.1;

[S,I,R] = sir_model(A, beta, gamma, 1, 50);

plot(I);
title('Baseline Infection Curve');
xlabel('Time');
ylabel('Infected Nodes');
