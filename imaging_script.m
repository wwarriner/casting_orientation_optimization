%% SETUP
oo_data_folder = "C:\Users\wwarr\Desktop\oo_data";
contents = get_contents( oo_data_folder );
contents = get_files_with_extension( contents, ".mat" );
files = string( get_full_paths( contents ) );

oo_results_folder = "C:\Users\wwarr\Desktop\oo_results";
contents = get_contents( oo_results_folder );
folders = get_full_paths( contents );
subfolders = contents.name;

RESOLUTION = 300;
OUTPUT_FOLDER = "C:\Users\wwarr\Desktop\images";

%% LOAD
for i = 1 : numel( files )

file = files( i );
[ folder, name, ext ] = fileparts( file );
name = replace( name, "_base_case", "" );
j = find( startsWith( subfolders, name ) );
folder = folders( j );
ood_file = fullfile( folder, name + ".ood" );
ood = OrientationData.load_obj( ood_file );
gd = GriddedData( ood, RESOLUTION );

output_folder = 

end

%% LOAD RESPONSE DATA
dl = DataLoader();
dl.load( ood_file, resolution );
rd = dl.get_response_data();

%% CREATE OUTPUT FOLDER
name = rd.get_name();
output_folder = fullfile( output_root_folder, name );
if ~isfolder( output_folder )
    mkdir( output_folder )
else
    clear_directory_contents( output_folder )
end

%% GENERATE IMAGES
fh = figure();
%fh.Visible = 'off';
fh.Color = 'white';
axh = axes( fh );
axh.XAxisLocation = 'origin';
axh.YAxisLocation = 'origin';
axh.XGrid = 'on';
axh.YGrid = 'on';
axh.Layer = 'top';
xlim = [ -180 180 ];
ylim = [ -90 90 ];
axh.XLim = xlim;
axh.YLim = ylim;
major_spacing = 45;
axh.XAxis.TickValues = xlim( 1 ) : major_spacing : xlim( 2 );
axh.YAxis.TickValues = ylim( 1 ) : major_spacing : ylim( 2 );
spacing = 15;
axh.XAxis.MinorTickValues = xlim( 1 ) : spacing : xlim( 2 );
axh.YAxis.MinorTickValues = ylim( 1 ) : spacing : ylim( 2 );
axh.XMinorTick = 'on';
axh.YMinorTick = 'on';
axh.DataAspectRatio = [ range( xlim ) range( xlim ) 1 ];
axh.Colormap = flipud( interp1( [ 0; 1 ], repmat( [ 0.3; 0.9 ], [ 1 3 ] ), linspace( 0, 1, 256 ) ) );
cbh = colorbar( axh );
cbh.Location = 'eastoutside';
hold( axh, 'on' );
ih = imagesc( axh, xlim, ylim, 0 );
tags = rd.get_tags();
titles = rd.get_titles();
for i = 1 : rd.get_count()
    
    tag = tags{ i };
    values = rd.get_objective_values( tag );
    ih.CData = values;
    value_range = [ ...
        min( values, [], 'all' )
        max( values, [], 'all' )
        ];
    caxis( axh, value_range );
    obj.colorbar_handle.Ticks = linspace( ...
        value_range( 1 ), ...
        value_range( 2 ), ...
        11 ...
        );
    file_name = sprintf( '%s_%02i_%s.png', name, i, tag );
    output_path = fullfile( output_folder, file_name );
    %imwrite( scaled_values, output_path );
    %CROP_VAL = [ inf 460 225 inf ];
    %CROP_STRING = [ '-c[' sprintf( '%i,%i,%i,%i', CROP_VAL ) ']' ];
    export_fig( fh, output_path );
    
end
