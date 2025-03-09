function [c_gamma, c_error] = our_admm(Q)
    % Q: observed flow matrix

    [M, N] = size(Q);
    % avoid nan values
    unobserved = isnan(Q);
    Q(unobserved) = 0;
    % cvx relaxtions
    normQ = norm(Q, 'fro');
    % std parameters
    rank_reg = 1 / sqrt(max(M,N));
    mu = 10*rank_reg;
    error_tol = 1e-6;
    N_steps = 1000;
    
    % initial solution
    c_gamma = zeros(M, N);
    c_error = zeros(M, N);
    Y = zeros(M, N);
    
    for step = (1:N_steps)
        % ADMM step: update c_gamma and c_error
        c_gamma = Do(1/mu, Q - c_error + (1/mu)*Y);
        c_error = So(rank_reg/mu, Q - c_gamma + (1/mu)*Y);
        % and augmented lagrangian multiplier
        Z = Q - c_gamma - c_error;
        Z(unobserved) = 0; % skip missing values
        Y = Y + mu*Z;
        
        err = norm(Z, 'fro') / normQ;
        if (step == 1) || (mod(step, 10) == 0) || (err < error_tol)
            fprintf(1, 'step: %04d\terr: %f\trank(c_gamma): %d\tcard(c_error): %d\n', ...
                    step, err, rank(c_gamma), nnz(c_error(~unobserved)));
        end
        if (err < error_tol) break; end
    end
end

% std so and do operators
function r = So(tau, Q)
    r = sign(Q) .* max(abs(Q) - tau, 0);
end

function r = Do(tau, Q)
    [U, c_error, V] = svd(Q, 'econ');
    r = U*So(tau, c_error)*V';
end
