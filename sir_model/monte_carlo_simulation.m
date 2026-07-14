function [avg_peak, CI_low, CI_high] = monte_carlo(G,beta,gamma,numMC)

peaks = zeros(numMC,1);

for i=1:numMC
    peaks(i) = sir_simulation(G,beta,gamma);
end

avg_peak = mean(peaks);
std_peak = std(peaks);

margin = 1.96*(std_peak/sqrt(numMC));
CI_low = avg_peak - margin;
CI_high = avg_peak + margin;

end
