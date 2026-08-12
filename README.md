# MISN-CTRL Project

## Controlling the Spread of Misinformation in Networks using Small-World Modelling and Real-World Validation

This project investigates how misinformation spreads through social networks and how network structure can be used to reduce its spread.

The study combines synthetic Watts–Strogatz small-world networks with a real-world Facebook network from the Stanford Network Analysis Project (SNAP). The SIR epidemic model is used to simulate misinformation spreading, while centrality-based intervention strategies are evaluated to identify structurally important nodes for targeted removal.

## Research Objective

The main objective is to investigate how network structure influences misinformation spreading and to evaluate whether targeting structurally important nodes can reduce the spread more effectively than random intervention.

## Methodology

The project consists of the following main stages:

1. Generation of Watts–Strogatz small-world networks.
2. SIR-based misinformation spreading simulation.
3. Monte Carlo simulation for statistical evaluation.
4. Network centrality analysis using degree and betweenness centrality.
5. Comparison of random, degree-based, and betweenness-based node removal.
6. Network-size analysis using different synthetic network sizes.
7. Validation using the real-world SNAP Facebook network.
8. Comparison of synthetic and real-world network spreading behaviour.

## Main Simulation Parameters

- Infection rate (β) = 0.4
- Recovery rate (γ) = 0.2
- Basic reproduction number (R₀) = 2
- Average network degree (k) = 4
- Main small-world rewiring probability (p) = 0.3
- Monte Carlo simulations = 50
- Intervention removal fraction = 5%

## Synthetic Network Analysis

Synthetic Watts–Strogatz networks were evaluated for different network sizes:

- N = 100
- N = 250
- N = 500
- N = 1000
- N = 2000
- N = 4000

The WS-4000 network was used as the main synthetic network for comparison with the SNAP network because the two networks have similar numbers of nodes.

## Real-World Validation

The real-world validation uses the SNAP Facebook network containing:

- 4039 nodes
- 88234 edges

Structural properties and SIR spreading behaviour were analysed and compared with the WS-4000 synthetic network.

## Intervention Strategies

Three intervention strategies are evaluated:

- Random node removal
- Degree-based node removal
- Betweenness-based node removal

The intervention experiments investigate whether targeting structurally important nodes can reduce misinformation spreading more effectively than random removal.

## Network Topology Analysis

The effect of network topology is investigated by varying the Watts–Strogatz rewiring probability:

- p = 0 — regular network
- p = 0.3 — small-world network
- p = 1 — random network

## Repository Structure

```text
Misinformation-Network-Model/
│
├── synthetic_network/
├── sir_model/
├── centrality_analysis/
├── intervention/
├── real_world_validation/
├── documentation/
│
├── README.md
└── run_experiments.m

  
