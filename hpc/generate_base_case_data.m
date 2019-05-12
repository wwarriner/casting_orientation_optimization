function [ c_path, f_path ] = generate_base_case_data( ...
    option_path, ...
    stl_path, ...
    output_folder, ...
    var_add_paths ...
    )

if nargin >= 4
    original_path = [];
    for i = 1 : numel( var_add_paths )
        oldpath = addpath( genpath( var_add_paths{ i } ) );
        if i == 1
            original_path = oldpath;
        end
    end
    cleanup = onCleanup( @()path(original_path) );
end

options = Options( '', option_path, stl_path, output_folder );
try
    pm = ProcessManager( options );
    pm.run();
catch e
    fprintf( 1, '%s\n', getReport( e ) );
    fprintf( 1, '%s\n', options.input_stl_path );
    assert( false );
end

if ~isfolder( options.output_path )
    mkdir( options.output_path )
end

component_pk = ProcessKey( Component.NAME );
c = pm.results.get( component_pk );
c_path = fullfile( options.output_path, [ c.name '_' Component.NAME '.mat' ] );
c.save_obj( c_path );

feeders_pk = ProcessKey( Feeders.NAME );
f = pm.results.get( feeders_pk );
f_path = fullfile( options.output_path, [ c.name '_' Feeders.NAME '.mat' ] );
f.save_obj( f_path );

end

