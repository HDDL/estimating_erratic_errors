function link_conservation_flag = get_link_conservation_flag(A, error_data, conservation_result)
    observed_flow_conservation = A*error_data;
    node_conservation_flag = observed_flow_conservation == conservation_result;
    [~, time_interval_number] = size(node_conservation_flag);
    [node_number, link_number] = size(A);
    link_conservation_flag = zeros(link_number, time_interval_number);
    for i = 1:node_number
        for t = 1:time_interval_number
            if node_conservation_flag(i, t) == 1 % 如果该node处守恒,则认为与node相连的link数据都是正确的
                temp_flag = abs(A(i, :));
                %connected_link_index = find(A(i, :)~=0);
                link_conservation_flag(:, t) = temp_flag';
            end
        end
    end
end