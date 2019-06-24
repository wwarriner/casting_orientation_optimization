%% SETUP
name = 'steering_column_mount';
ood_file = fullfile( 'D:\wwarr', name, [ name '.ood' ] );
resolution = 300;
output_root_folder = 'C:\Users\wwarr\Desktop\images';

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
axh.Colormap = interp1( [ 0; 1 ], repmat( [ 0.3; 0.9 ], [ 1 3 ] ), linspace( 0, 1, 256 ) );
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
