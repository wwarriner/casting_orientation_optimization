function usrp = plot_sample_data( sample_file_name )

if nargin < 1
    sample_file_name = 'bearing_block_data.mat';
end

full_path = which( sample_file_name );
results = load( full_path );
[ path, name, ~ ] = fileparts( full_path );
data = results.(name);

data.Properties.UserData.Name = name;
data.Properties.UserData.ObjectiveVariablesPath = ...
    which( data.Properties.UserData.ObjectiveVariablesPath );
data.Properties.UserData.StlPath = ...
    which( data.Properties.UserData.StlPath );
data.Properties.UserData.OptionsPath = ...
    which( data.Properties.UserData.OptionsPath );

%% construct response data
figure_resolution_px = 600;
data_extractor = DataExtractor( ...
    data, ...
    data.Properties.UserData, ...
    ceil( figure_resolution_px / 2 ) ...
    );
response_data = ResponseData( data_extractor );

%% create visualization generator
c = Component.load_obj( fullfile( path, [ name '_' Component.NAME '.mat' ] ) );
f = Feeders.load_obj( fullfile( path, [ name '_' Feeders.NAME '.mat' ] ) );
visualization_generator = VisualizationGenerator( c, f );

%% start tool
usrp = UnitSphereResponsePlot( ...
    response_data, ...
    visualization_generator, ...
    figure_resolution_px ...
    );
grayscale_color_map = interp1( ...
    [ 0; 1 ], ...
    repmat( [ 0.3; 0.9 ], [ 1 3 ] ), ...
    linspace( 0, 1, 256 ) ...
    );
usrp.set_color_map( grayscale_color_map );
grid_color = [ 0 0 0 ];
usrp.set_grid_color( grid_color );
bg_color = [ 1 1 1 ];
usrp.set_background_color( bg_color );

end

