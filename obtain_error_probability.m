function [p_link, p_node, X] = obtain_error_probability(A)
    %% this function is used to generate random attributes associted with sensor error probabiliteis
    %% To obtain large sensor error probabilies (>0.5), some attributes are specified manually
    %% first randomly generate sensor features
    [node_number, link_number] = size(A);
    number_of_vars = 7;
    var_coeff = zeros(1, number_of_vars);
    var_coeff(1) = 0.01; % install time
    var_coeff(2) = 0.01; % sensitivity %
    var_coeff(3) = 0.005; % link length km
    var_coeff(4) = 0.0001; % lane number
    var_coeff(5) = -0.001; % speed limit km/h
    var_coeff(6) = -0.004; % traffic index
    var_coeff(7) = 0.1; % foggy or rainy
    link_features = zeros(link_number, number_of_vars);
    link_features(:, 1) = 5 + rand(link_number, 1)*14; % install time %10
    link_features(:, 2) = 5 + rand(link_number, 1)*9; % senstity %1
    link_features(:, 3) = rand(link_number, 1)*4.5 + 1; % link length
    link_features(:, 4) = round(rand(link_number, 1)*2) + 2; % lane number
    link_features(:, 5) = rand(link_number, 1)*30 + 30; % speed_limit
    link_features(:, 6) = rand(link_number, 1)*20; % traffic index
    link_features(:, 7) = rand(link_number, 1); % rainy
    sunny_index = link_features(:, 7) <= 0.9;
    link_features(:, 7) = double(~sunny_index);
    %%  specify large sensor error probabilites
    link_features(15, :) = [25, 20, 5, 4, 30, 1, 1];
    link_features(41, :) = [30, 30, 10, 10, 10, 1, 1];
    link_features([38;26;8;23;45;46], 1) = 20 + rand(6, 1)*5; % install time;
    link_features([38;26;8;23;45;46], 2) = 20 + rand(6, 1)*5; % install time;
    link_features([38;26;8;23;45;46], 3) = 10 + rand(6, 1)*5; % install time;
    lambda_link = (link_features*var_coeff');
    %% avoid negative values
    wrong_index = find(lambda_link <= 0);
    while(~isempty(wrong_index))   
        link_features(wrong_index,1)=link_features(wrong_index,1)+1;
        link_features(wrong_index,2)=link_features(wrong_index,2)+2;
        lambda_link = (link_features*var_coeff' + gaussian_error);
        wrong_index = find(lambda_link <= 0);
    end
    % calcualte p_link and p_node: the true error probabilities of links and nodes
    p_link = 1 - exp(-lambda_link);
    p_node = zeros(node_number, 1);
    for i = 1:node_number
        temp_p_node = 1;
        for j = 1:link_number
            if A(i,j) ~= 0
                temp_p_node = temp_p_node*(1-p_link(j));
            end
        end
        p_node(i) = 1 - temp_p_node;
    end
    node_y = -log(1-p_node);

    node_X = zeros(node_number, number_of_vars);
    for node_index = 1:node_number
        connected_link = find(A(node_index,:)~=0);
        node_X(node_index, :) = sum(link_features(connected_link, :));
    end
    node_X = abs(A)*link_features;
    %[b,~,r,~,stats] = regress(node_y, node_X);
    mdl = fitglm(node_X, node_y, 'intercept', false);
    %% perfect regression results
    b = mdl.Coefficients;
    b  = table2array(b(:,1));
    X = link_features;
    ture_p_link = p_link;
    estimated_p_link = 1 -exp(-link_features*b);
    MAPE = abs(estimated_p_link - ture_p_link)./(ture_p_link+estimated_p_link)/2;
    disp('p_link_mape:')
    disp(mean(MAPE))

end

