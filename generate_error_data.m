function error_data = generate_error_data(ture_data, P, sigma)
    %UNTITLED8 Summary of this function goes here
    %   Detailed explanation goes here
    sigma = sigma;
    [link_number, time_interval_number] = size(ture_data);
    wrong_link_number = round(P*time_interval_number);
    ap = wrong_link_number/time_interval_number;
    mape_ap = abs((ap-P)./P);
    error_data = ture_data;
    for i = 1:link_number
        wrong_link_number_i = round(wrong_link_number(i));
        wrong_link_times = randperm(time_interval_number, wrong_link_number_i);
        for j = 1:length(wrong_link_times)
            error_time = wrong_link_times(j);
            error_link = i;
            rand_dis = rand();
            if rand_dis < 0.25 % Guaaisan
                error_data(error_link, error_time) = ture_data(error_link, error_time) + round(randn()*sigma);
            elseif rand_dis < 0.5 % uniform
                error_data(error_link, error_time) = ture_data(error_link, error_time) + round((2*rand()-1)*sigma);
            elseif rand_dis < 0.75 % exp
                error_data(error_link, error_time) = ture_data(error_link, error_time) + round(exprnd(sigma));
            else
                error_data(error_link, error_time) = ture_data(error_link, error_time) + round(gamrnd(sqrt(sigma), sqrt(sigma))); %
            end
%             error_data(error_link, error_time) = ture_data(error_link, error_time) + temp_sign*sigma;
            %% incase
            while error_data(error_link, error_time) < 0 || error_data(error_link, error_time) == ture_data(error_link, error_time)
                error_data(error_link, error_time) = ture_data(error_link, error_time)/2 + round(randn()*sigma); 
            end
        end
    end
end

