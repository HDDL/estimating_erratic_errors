clc,clear;
close all;
rng(10)
%% import true_flow_matrix
file_name = './flow_matrix.txt';
true_flow_matrix = importdata(file_name);
%% import network aj matrix and true data that satisfies the trffic flow conservation
network_folder = './';
A = get_network_adjacent_matrix(network_folder);
A(14:19,:)=[]; % remove od nodes
%% test the flow-conservation
conservation_result = A*true_flow_matrix; % the correct traffic flow conservations results based on the flow balance law
%% generate error_data based on sensor error probabilities
[node_number, link_number] = size(A);
[~, time_interval_number] = size(true_flow_matrix+1); % avoid zero denominator
[P, p_node, X] = obtain_error_probability(A);
sigma = std(true_flow_matrix(:));
% test the algorithm performence when most of the data are corrupted
%P(P<0.5) = 0.55;
error_data = generate_error_data(true_flow_matrix, P, sigma);
error_node_flow = generate_error_node_flow(true_flow_matrix, p_node, sigma, A);
ae_origin = abs(error_data-true_flow_matrix);
mae_origin = mean(ae_origin(:));
ape_origin = ae_origin./(true_flow_matrix+1);
mape_origin = mean(ape_origin(:));
error_link_index_origin = round(double(ae_origin~=0));
%% stage 1: regression: calculate p from data
[estimated_p, estimated_b] = calculate_p_from_data(A, error_data, error_node_flow, X, p_node, P, conservation_result);
link_conservation_flag = get_link_conservation_flag(A, error_data, conservation_result);
observed_conservation_result = A*error_data;
node_conservation_flag = observed_conservation_result == conservation_result;
%% the input must satisfy all theoretical assumptions of flow balance law, however sometimes it is difficuilt to generate them automatically
% you can also skip these codes for worse performence
while fes_solution_exist(A, error_link_index_origin, node_conservation_flag) == 0
    error_data = generate_error_data(true_flow_matrix, P, sigma);
    error_node_flow = generate_error_node_flow(true_flow_matrix, p_node, sigma, A);
    ae_origin = abs(error_data-true_flow_matrix);
    mae_origin = mean(ae_origin(:));
    ape_origin = ae_origin./(true_flow_matrix+1);
    mape_origin = mean(ape_origin(:));
    error_link_index_origin = double(ae_origin~=0);
    %% calculate p from data
    estimated_p = calculate_p_from_data(A, error_data, error_node_flow, X, p_node, P, conservation_result);
    link_conservation_flag = get_link_conservation_flag(A, error_data, conservation_result);
    %%
    observed_conservation_result = A*error_data;
    node_conservation_flag = observed_conservation_result == conservation_result;   
end
%% stage 2: solve the non-linear model with the proposed tractable algorithm
[M, N] = size(A);
ele_number = link_number*time_interval_number;
q_hat_number = ele_number;
z_number = ele_number; 
gamma_number = ele_number; 
var_number = q_hat_number + z_number + gamma_number;
%% Predefined parameters
Delta = 1-node_conservation_flag;
UM = round(1.2*P.*time_interval_number);
LM = round(P.*time_interval_number);
actual_conservation_result = A*true_flow_matrix;
BIG_NUMBER = 200; % maximum flow
%% std_admm
[RQ, S] = our_admm(error_data);
v_Gamma = abs(S)./error_data;
%% A tractable algorithm for feasible solution for continuous $\gamma_{j,t}$ see the appendix for details
zero_list = zeros(link_number, time_interval_number);
fes_Gamma = zeros(link_number, time_interval_number);
% delta(i,t)=0
for i = 1:node_number
    for t = 1:time_interval_number
        if Delta(i, t)==0
            link_index_array = find(A(i,:) ~= 0);
            for j = 1:length(link_index_array)
                link_index = link_index_array(j);
                zero_list(link_index, t) = 1;
            end
        end
    end
end
pre_rank = 3;
[sorted_Gamma, Gamma_Index] = sort(v_Gamma, 2, 'descend');
for j = 1:link_number
    temp_index = Gamma_Index(j, :);
    number_of_e_data = min(LM(j),time_interval_number-pre_rank);
    time_index = temp_index(1:number_of_e_data);
    for t = 1:length(time_index)
        if zero_list(j, time_index(t)) == 0
            fes_Gamma(j, time_index(t)) = 1;
        end
    end
end
% delta(i,t)=1
for i = 1:node_number
    for t = 1:time_interval_number
        if Delta(i, t)==1
            link_index_array = find(A(i,:) ~= 0);
            selected_link_id = link_index_array(randperm(numel(link_index_array), 1));
            while(zero_list(selected_link_id, t) == 1)
                selected_link_id = link_index_array(randperm(numel(link_index_array), 1));
            end
            fes_Gamma(selected_link_id, t) = 1;
        end
    end
end
yalmip('clear')
sub_Q  = sdpvar(link_number, time_interval_number);
sub_Z = sdpvar(link_number, time_interval_number);
C1 = [sub_Q == (1-fes_Gamma).*error_data + sub_Z];
C2 = [sub_Z - fes_Gamma.*BIG_NUMBER <= 0 ];
C3 = [sub_Q >= 0];
C4 = [sub_Z >= 0];
C5 = [A*sub_Q==actual_conservation_result];% penalty term
C=[C1,C2,C3,C4];%C1,C2,C2,C3,C4,
sub_obj = norm(sub_Q, 'nuclear') + 100000*norm(A*sub_Q - actual_conservation_result, 1);
ops = sdpsettings('solver', 'mosek');
sol = optimize(C,sub_obj,ops)

v_Q = value(sub_Q);
v_Z = value(sub_Z);
sub_ae_result = abs(v_Q-true_flow_matrix);
sub_mae_result = mean(sub_ae_result(:));
sub_ape_result = sub_ae_result./(true_flow_matrix+1);
sub_mape_result = mean(sub_ape_result(:));
% disp the results
disp(['origin_mape: ', num2str(mape_origin)]);
disp(['our_mape: ', num2str(sub_mape_result)]);