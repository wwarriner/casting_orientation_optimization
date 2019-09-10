%% SETUP
oo_data_folder = "C:\Users\wwarr\Desktop\data";
contents = get_contents( oo_data_folder );
contents = get_files_with_extension( contents, ".mat" );
files = string( get_full_paths( contents ) );

oo_results_folder = "C:\Users\wwarr\Desktop\results";
contents = get_contents( oo_results_folder );
folders = get_full_paths( contents );
subfolders = contents.name;

RESOLUTION = 300;
OUTPUT_FOLDER = "C:\Users\wwarr\Desktop\images";
prepare_folder( OUTPUT_FOLDER );

%% LOAD
for i = 1 : numel( files )
    
    file = files( i );
    [ ~, name, ext ] = fileparts( file );
    name = replace( name, "_base_case", "" );
    folder_index = find( startsWith( subfolders, name ) );
    folder = folders( folder_index );
    assert( numel( folder ) <= 1 );
    if numel( folder ) == 0
        continue;
    end
    ood_file = fullfile( folder, name + ".ood" );
    ood = OrientationData.load_obj( ood_file );
    gd = GriddedData( ood, RESOLUTION );
    
    output_folder = fullfile( OUTPUT_FOLDER, name );
    prepare_folder( output_folder );
    
    for j = 1 : ood.objective_count
        tag = ood.objective_tags( j );
        im = gd.get_values( tag );
        min( im, [], "all" )
        max( im, [], "all" )
        im = 1 - rescale( im, 0, 1 );
        imwrite( im, fullfile( output_folder, tag + ".png" ) );
    end
    
end
