# MATLAB Pareto Front Indices
MATLAB utility to determine the indices of the pareto front of a multiple objective data set. No optimization is performed, the user is expected to provide a data set representing the results of an optimization.

#### Usage
The function takes a two-dimensional array of objective values. Columns represent objectives, rows represent points in the decision space. The function outputs a vector of indices of rows which belong to the pareto front of the input set. It is important to note that the set determined is not necessarily the pareto front of the underlying optimization problem, only of the set of input data.
