function flag = fes_solution_exist(A, error_link_index_origin, node_conservation_flag)
    flag = 1;
    [link_number, time_interval_number] = size(error_link_index_origin);
    for link_index=1:link_number
        for t = 1:time_interval_number
            if error_link_index_origin(link_index, t) == 1 % link error
                connected_node = find(A(:, link_index)~=0);
                if sum(node_conservation_flag(connected_node, t)) > 0
                    flag = 0;
                    return
                end
            end
        end
    end
end