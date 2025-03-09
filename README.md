# estimating_erratic_errors
Implemented by Zhenjie Zheng, advised by Wei Ma, Civil and environmental engineering, The Hong Kong Polytechnic University.

Requirements
Matlab 2024a
Yalmip tools
Solver: Mosek
At least 32GB RAM

# Introductions
We develop a mixed-integer nonlinear programming model to simultaneously estimate sensor error probabilities and recover traffic flow based on the Poisson process. To solve the complex model, we propose a tractable algorithm under the assumptions of linear correlations and a low-rank matrix structure. We validate the proposed model and algorithm using the classical Nguyen-Dupuis network.

# Instructions
The core code, including network structure, input data, error generation, error probability estimation, and the tractable algorithm, is provided in this directory. You can directly run the main.m to estimate the sensor error probabilities and recover traffic flow. The origin MAPE and optimized MAPE will be reported. 

# Note
(1) The uploaded algorithm serves as a benchmark for comparison with other algorithms in future reseach.
(2) Running all data may take a long time. You can also use partial data to validate the model while achieving comparable performance.

# Data
We employ the same method as in existing studies (Yang, Yang, and Fan 2019) to generate the samples of road traffic by randomizing flows using the traffic assignment algorithm (see flow_matrix.txt for details).

# Contact
Uploading all codes for various testing scenarios is extremely time-consuming and labor-intensive. If you need specific codes or have any other questions, please contact zhengzj17@gmail.com or zzj17.zheng@polyu.edu.hk.
