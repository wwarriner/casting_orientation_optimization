%% SETUP
oo_data_folder = "C:\Users\wwarr\Desktop\data";
contents = get_contents( oo_data_folder );
contents = get_files_with_extension( contents, ".ood" );
ood_files = string( get_full_paths( contents ) );

RESOLUTION = 300;
OUTPUT_FOLDER = "C:\Users\wwarr\Desktop\images";
prepare_folder( OUTPUT_FOLDER );

%% LOAD
extremes = nan( ood.objective_count, 2 * numel( ood_files ) );
for i = 1 : numel( ood_files )
    
    ood_file = ood_files( i );
    ood = OrientationData.load_obj( ood_file );
    gd = GriddedData( ood, RESOLUTION );
    
    [ ~, name ] = fileparts( ood_file );
    output_folder = fullfile( OUTPUT_FOLDER, name );
    prepare_folder( output_folder );
    
    for j = 1 : ood.objective_count
        tag = ood.objective_tags( j );
        im = gd.get_values( tag );
        extremes( j, 2 * i - 1 : 2 * i ) = [ min( im, [], "all" ) max( im, [], "all" ) ];
        im = 1 - rescale( im, 0.2, 0.8 );
        imwrite( im, fullfile( output_folder, tag + ".png" ) );
    end
    
end

assert( ~any( isnan( extremes ), "all" ) );
csvwrite( fullfile( OUTPUT_FOLDER, "extremes.csv" ), extremes );
