function organize_csv_data( results_dir )
%% get file names
extension = '.csv';
pattern = sprintf( '*%s', extension );
file_names = strip( string( ls( fullfile( results_dir, pattern ) ) ) );

%% get stl name
prefix = 'results';
postfix = [ '\' extension ];
pattern = sprintf( '%s_(.*?)_[0-9]+_[0-9]+%s', prefix, postfix );
values = regexpi( file_names, pattern, 'tokens' );
stl_name = values{ 1 }{ 1 };

%% sort file names by number
c = contains( file_names, stl_name );
file_names( ~c ) = [];

pattern = sprintf( '%s_.*?_([0-9]+)_([0-9]+)%s', prefix, postfix );
numbers = regexpi( file_names, pattern, 'tokens' );
numbers = cellfun( @( x ) str2double( x{ : } ), numbers, 'uniformoutput', false );
numbers = cell2mat( numbers );
job_id = numbers( 1 );
task_ids = numbers( :, 2 );
[ ~, indices ] = sortrows( task_ids, 'ascend' );
file_names = file_names( indices );

%% construct full paths
count = size( file_names, 1 );
file_names = join( [ repmat( results_dir, [ count 1 ] ) file_names ], filesep, 2 );

%% get headers
fid = fopen( file_names( 1 ) );
fc = create_file_closer( fid );
headers = fgetl( fid );
delete( fc );
headers = strsplit( headers, ',' );

%% read data from files
var_count = numel( headers );
results = nan( count, var_count );
for i = 1 : count
    
    fid = fopen( file_names( i ) );
    fc = create_file_closer( fid );
    fgetl( fid );
    values = fgetl( fid );
    delete( fc );
    results( i, : ) = str2double( strsplit( values, ',' ) );
    
end

%% convert to table
results = array2table( results );
results.Properties.VariableNames = headers;

%% append useful data
results.Properties.UserData.Name = stl_name;
results.Properties.UserData.DecisionEndColumn = OrientationBaseCase.get_decision_variable_count();
results.Properties.UserData.ObjectiveStartColumn = results.Properties.UserData.DecisionEndColumn + 1;

%% append objective_variables.json path
objective_variables_name = sprintf( 'objective_variables_%i.json', job_id );
objectives_path = fullfile( results_dir, objective_variables_name );
objective_variables = ObjectiveVariables( objectives_path );

%% mark pareto frontier
pareto_indices = find_pareto_indices( results{ :, results.Properties.UserData.ObjectiveStartColumn : end } );
is_pareto_dominant = false( count, 1 );
is_pareto_dominant( pareto_indices ) = true;
results.is_pareto_dominant = is_pareto_dominant;
results = movevars( results, 'is_pareto_dominant', 'before', results.Properties.UserData.ObjectiveStartColumn );
results.Properties.UserData.ParetoIndicesColumn = results.Properties.UserData.ObjectiveStartColumn;
results.Properties.UserData.ObjectiveStartColumn = results.Properties.UserData.ObjectiveStartColumn + 1;

%% save
DATA_EXT = '.ood';
out_name = sprintf( '%s%s', stl_name, DATA_EXT );
out_path = fullfile( results_dir, out_name );
save( out_path, 'results', 'objective_variables' );

COMPONENT_EXT = '.ooc';
component_base_name = sprintf( '%s_%s', stl_name, Component.NAME );
copyfile( ...
    fullfile( results_dir, sprintf( '%s_%i%s', component_base_name, job_id, '.mat' ) ), ...
    fullfile( results_dir, sprintf( '%s%s', component_base_name, COMPONENT_EXT ) ) ...
    );

FEEDER_EXT = '.oof';
feeders_base_name = sprintf( '%s_%s', stl_name, Feeders.NAME );
copyfile( ...
    fullfile( results_dir, sprintf( '%s_%i%s', feeders_base_name, job_id, '.mat' ) ), ...
    fullfile( results_dir, sprintf( '%s%s', feeders_base_name, FEEDER_EXT ) )...
    );

end

