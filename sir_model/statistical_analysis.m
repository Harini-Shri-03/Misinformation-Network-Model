mean_peak = mean(peaks);
std_peak = std(peaks);
CI_low = mean_peak - 1.96*(std_peak/sqrt(n));
CI_high = mean_peak + 1.96*(std_peak/sqrt(n));
