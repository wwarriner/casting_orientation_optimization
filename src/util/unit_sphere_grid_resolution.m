function [ phi, theta ] = unit_sphere_grid_resolution( resolution )

% the following code ensures odd by odd resolution, for (0,0)
if mod( resolution, 2 ) == 0
    theta = resolution + 1;
end
phi = 2 * theta + 1;

end

