function merge_hpc_data( results_dir )
%% get file names
contents = get_contents( results_dir );
EXTENSION = ".mat";
contents = get_files_with_extension( contents, EXTENSION );
paths = string( get_full_paths( contents ) );

%% merge
lhs = OrientationData.load_obj( paths( 1 ) );
rhs = OrientationData.empty( height( contents ) - 1, 0 );
for i = 1 : height( contents ) - 1
    rhs( i ) = OrientationData.load_obj( paths( i + 1 ) );
end
all = lhs.merge( rhs );

%% get stl name
prefix = "results";
postfix = filesep + EXTENSION;
pattern = sprintf( "%s_(.*?)_[0-9]+_[0-9]+%s", prefix, postfix );
values = string( regexpi( contents.name, pattern, "tokens" ) );
stl_name = values( 1 );

%% save
DATA_EXT = ".ood";
out_name = sprintf( "%s%s", stl_name, DATA_EXT );
out_file = fullfile( results_dir, out_name );
all.save_obj( out_file );

end

