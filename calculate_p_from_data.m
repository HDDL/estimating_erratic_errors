function [estimated_p_link, estimated_b, estimated_p_node] = calculate_p_from_data(A, error_data, error_node_flow, X, true_p_node, true_p_link, conservation_result)
% linear regression
[node_number, link_number] = size(A);
[~, time_interval_number] = size(error_data);
flow_diff = error_node_flow ~= conservation_result;
flow_diff = sum(flow_diff, 2);
estimated_p_node = flow_diff/time_interval_number;
%estimated_p_node(estimated_p_node==1) = 0.99; % avoid inf values
mape_p_node = mean(abs(estimated_p_node-true_p_node)./true_p_node) % check the correcness of p_node 
noise_std = 0.001; % simulate noise
true_p_node = true_p_node + noise_std* randn(size(true_p_node));
true_p_node(true_p_node>=1) = 1-0.00001; %  avoid zero denominator
disp(true_p_node)
node_y = -log(1-true_p_node);
node_X = abs(A)*X;
mdl = fitglm(node_X,node_y,'intercept', false);
regress(node_y, node_X)
%% calculate mape
b = mdl.Coefficients;
b  = table2array(b(:,1));
estimated_p_link = 1 - exp(-X*b);
% avoid zero denominator
estimated_p_link(estimated_p_link <= 0) = 0.01;
estimated_p_link(estimated_p_link >= 1) = 0.99;
mape_p_link = mean(abs(estimated_p_link-true_p_link)./true_p_link);
disp('mape_p_link_from_data')
disp(mape_p_link)
estimated_b = b;
end

