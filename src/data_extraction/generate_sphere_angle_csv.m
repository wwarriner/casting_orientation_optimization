function sphere_angles = generate_sphere_angle_csv( folder )

if nargin < 1
    folder = '.';
end

MEAN_SEPARATION_DEGREES = 5;
sphere_angles = generate_unit_sphere_angles( MEAN_SEPARATION_DEGREES, 'octahedral' );
csvwrite( fullfile( folder, 'sphere_angles.csv' ), sphere_angles );

end

