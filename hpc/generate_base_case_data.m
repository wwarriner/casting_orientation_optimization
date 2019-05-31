function [ c_path, f_path ] = generate_base_case_data( ...
    option_path, ...
    stl_file, ...
    output_folder ...
    )

options = Options( option_path );
options.set( 'manager.stl_file', stl_file );
options.set( 'manager.output_folder', output_folder );
try
    pm = ProcessManager( options );
    pm.run();
catch e
    fprintf( 1, '%s\n', getReport( e ) );
    fprintf( 1, '%s\n', options.get( 'manager.stl_file' ) );
    assert( false );
end

if ~isfolder( options.get( 'manager.output_folder' ) )
    mkdir( options.get( 'manager.output_folder' ) )
end

component_pk = ProcessKey( Component.NAME );
c = pm.results.get( component_pk );
c_path = fullfile( options.get( 'manager.output_folder' ), [ c.name '_' Component.NAME '.mat' ] );
c.save_obj( c_path );

feeders_pk = ProcessKey( Feeders.NAME );
f = pm.results.get( feeders_pk );
f_path = fullfile( options.get( 'manager.output_folder' ), [ c.name '_' Feeders.NAME '.mat' ] );
f.save_obj( f_path );

end

