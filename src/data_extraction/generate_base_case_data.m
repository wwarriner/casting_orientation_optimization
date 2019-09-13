function obc_path = generate_base_case_data( ...
    settings_file, ...
    stl_file, ...
    output_folder ...
    )

settings = Settings( settings_file );
settings.processes.Casting.input_file = stl_file;
settings.manager.output_folder = output_folder;

obc = OrientationBaseCase( settings );

if ~isfolder( settings.manager.output_folder )
    mkdir( settings.manager.output_folder )
end

obc_name = obc.name + ".obc";
obc_path = fullfile( settings.manager.output_folder, obc_name );
obc.save_obj( obc_path );

end

