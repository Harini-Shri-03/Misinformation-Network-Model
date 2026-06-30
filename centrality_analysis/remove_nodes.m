function A_new = remove_nodes(A, nodes_to_remove)
    A(nodes_to_remove, :) = 0;
    A(:, nodes_to_remove) = 0;
    A_new = A;
end
