# Final Analysis

## 1. WS-4000 and SNAP-4039 Comparison

The final analysis compares the synthetic WS-4000 network with the real SNAP-4039 network.

The WS-4000 network has an average degree of 4.00, a clustering coefficient of 0.1764, and an average path length of 7.5644.

The SNAP-4039 network has substantially higher connectivity and a shorter average path length. These structural differences provide an explanation for the faster misinformation spreading observed in the SNAP network.

The average peak infection was 1770.40 nodes for WS-4000 and 2538.72 nodes for SNAP-4039. The average time to peak was 16.78 time steps for WS-4000 compared with 6.32 time steps for SNAP-4039.

## 2. Effect of Network Size

The network-size experiment used synthetic networks containing 100, 250, 500, 1000, 2000, and 4000 nodes.

As the network size increased, the absolute number of infected nodes increased. However, the percentage of nodes infected at the peak remained broadly stable, ranging from approximately 43% to 47%.

This indicates that the spreading behaviour observed in the synthetic network was not primarily caused by network size alone.

## 3. Effect of Network Topology

The topology experiment compared regular, small-world, and random network structures using rewiring probabilities of p = 0, 0.3, and 1.

The average peak infection increased from 12.32 nodes for p = 0 to 1692.72 nodes for p = 0.3 and 1994.24 nodes for p = 1.

The results demonstrate that introducing shortcuts and increasing network randomness can substantially increase misinformation spreading.

## 4. Intervention Analysis

Three node-removal strategies were compared with the baseline case:

- Random removal
- Degree-based removal
- Betweenness-based removal

For WS-4000, the reduction in peak infection was 8.90% for random removal, 22.85% for degree-based removal, and 26.69% for betweenness-based removal.

For SNAP-4039, the corresponding peak reductions were 7.18%, 24.73%, and 82.88%.

Betweenness-based removal therefore produced the largest reduction in peak infection in both networks, with a particularly strong effect in the SNAP network.

## 5. Overall Interpretation

The final results indicate that network structure plays an important role in misinformation spreading.

The network-size analysis shows that increasing the number of nodes mainly increases the absolute outbreak size, while the relative peak remains broadly stable. In contrast, differences in network structure, connectivity, and path length are associated with substantial differences in spreading speed and peak infection.

The intervention results further indicate that structurally important nodes can have a greater influence on misinformation spreading than randomly selected nodes. In particular, the strong effect of betweenness-based removal in the SNAP network suggests that bridge-like nodes can play an important role in connecting different parts of the network.

## 6. Final Project Contribution

The project combines:

1. Watts–Strogatz small-world modelling.
2. SIR-based misinformation spreading.
3. Network-size analysis.
4. Real-world SNAP network validation.
5. Degree and betweenness centrality analysis.
6. Comparison of random and targeted node-removal strategies.

The final analysis provides a network-level perspective for understanding and controlling misinformation spread alongside conventional content-based moderation.
