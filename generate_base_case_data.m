function [ c_path, f_path ] = generate_base_case_data( path )

base_case = Results();
objects = { ...
    Component( base_case, options ), ...
    Mesh( base_case, options ), ...
    EdtProfile( base_case, options ), ...
    Segmentation( base_case, options ), ...
    Feeders( base_case, options ) ...
    };
for i = 1 : numel( objects )
    
    current = objects{ i };
    current.run();
    base_case.add( current.NAME, current );
    
end

c = base_case( Component.NAME );
c_path = fullfile( path, [ c.name '_' Component.NAME '.mat' ] );
c.save_obj( c_path );

f = base_case( Feeders.NAME );
f_path = fullfile( path, [ c.name '_' Feeders.NAME '.mat' ] );
f.save_obj( f_path );

end

