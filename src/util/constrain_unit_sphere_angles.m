function angles = constrain_unit_sphere_angles( angles )

TOL = 1e-3;
[ phi_range, theta_range ] = unit_sphere_ranges();
phi_max = max( phi_range ) - TOL;
phi_min = min( phi_range ) + TOL;
theta_max = max( theta_range ) - TOL;
theta_min = min( theta_range ) + TOL;
[ PHI_INDEX, THETA_INDEX ] = unit_sphere_plot_indices();
angles( :, PHI_INDEX ) = min( phi_max, max( phi_min, angles( :, PHI_INDEX ) ) );
angles( :, THETA_INDEX ) = min( theta_max, max( theta_min, angles( :, THETA_INDEX ) ) );

end

