function error_node_flow = generate_ND_error_node_flow(ture_data, p_node, sigma, A)
%% the number of error data observed by nodes must strictly satisfy the flow balance law, 
%% However, the coupling of error links will mislead the error probabiliteis of the node, to address this, we must generate error data from nodes 
    [node_number, ~] = size(A);
    [~, time_interval_number] = size(ture_data);
    error_data = ture_data;
    % expected correct flow
    error_node_flow = A*error_data;
    sigma = sigma;

    wrong_number = round(p_node*time_interval_number);
    for i = 1:node_number
        wrong_number_i = wrong_number(i);
        wrong_time_index = randperm(time_interval_number, wrong_number_i);
            for j = 1:length(wrong_time_index)
                error_time = wrong_time_index(j); % error times
                %% irregular noise with four differnt distributions on nodes
                rand_dis = rand();
                if rand_dis < 0.25 % Guaaisan
                    error_node_flow(i, error_time) = error_node_flow(i, error_time) + round(randn()*sigma);
                elseif rand_dis < 0.5 % uniform
                    error_node_flow(i, error_time) = error_node_flow(i, error_time) + round((2*rand()-1)*sigma);
                elseif rand_dis < 0.75 % exp
                    error_node_flow(i, error_time) = error_node_flow(i, error_time) + round(exprnd(sigma));
                else
                    error_node_flow(i, error_time) = error_node_flow(i, error_time) + round(gamrnd(sqrt(sigma), sqrt(sigma)));
                end
            end
    end
end