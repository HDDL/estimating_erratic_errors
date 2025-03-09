function network_matrix = get_network_adjacent_matrix(network_folder)
% network in the form of adjacent matrix
network = importdata([network_folder, 'network.dat']); 
network = network.data;
[edge_number, ~] = size(network);
link_id = 1:edge_number;
network = [link_id', network(:, 1:2)];
[link_number, ~] = size(network);
start_node = network(:, 2);
end_node = network(:, 3);
unique_start = unique(start_node);
unique_end = unique(end_node);
unique_node = unique([unique_start; unique_end]);
node_number = length(unique_node);
network_matrix = zeros(node_number,link_number);
for i = 1:link_number
    link_id = network(i, 1);
    start_node_id = network(i, 2);
    end_node_id = network(i, 3);
    network_matrix(start_node_id, link_id) = -1;
    network_matrix(end_node_id, link_id) = 1;
end

end

