function bc = betweenness_centrality(A)
    G = graph(A);
    bc = centrality(G,'betweenness');
end
