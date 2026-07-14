function G = small_world_generator(N,K,p)

A = zeros(N);

% Ring lattice
for i = 1:N
    for j = 1:K
        right = mod(i-1 + j, N) + 1;
        left  = mod(i-1 - j, N) + 1;

        A(i,right)=1; A(right,i)=1;
        A(i,left)=1;  A(left,i)=1;
    end
end

% Rewiring
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

G = graph(A);

end
