classdef OrientationData < handle & Saveable
    
    properties ( SetAccess = private )
        decision_tags(1,:) string
        decision_titles(1,:) string
        objective_tags(1,:) string
        objective_titles(1,:) string
        interp_methods(1,:) string
        stl_file(1,1) string
    end
    
    properties ( SetAccess = private, Dependent )
        decision_count(1,1) double
        decisions(:,:) double
        pareto_decisions(:,:) double
        objective_count(1,1) double
        objectives(:,:) double
        pareto_objectives(:,:) double
    end
    
    methods
        function obj = OrientationData( data )
            assert( istable( data ) );
            assert( all( varfun( @isnumeric, data, 'outputformat', 'uniform' ) ) );
            
            props = data.Properties.CustomProperties;
            pnames = properties( props );
            assert( ismember( "decision_tags", pnames ) ); % isprop returns incorrect result
            assert( ismember( "decision_titles", pnames ) );
            assert( ismember( "objective_tags", pnames ) );
            assert( ismember( "objective_titles", pnames ) );
            assert( ismember( "stl_file", pnames ) );
            
            var_names = data.Properties.VariableNames;
            
            decision_tags = props.decision_tags;
            if ischar( decision_tags ) || iscellstr( decision_tags ) %#ok<ISCLSTR>
                decision_tags = string( decision_tags );
            end
            assert( isstring( decision_tags ) );
            assert( isvector( decision_tags ) );
            assert( numel( unique( decision_tags ) ) == numel( decision_tags ) );
            assert( all( ismember( decision_tags, var_names ) ) );
            props.decision_tags = decision_tags;
            
            decision_titles = props.decision_titles;
            if ischar( decision_titles ) || iscellstr( decision_titles ) %#ok<ISCLSTR>
                decision_titles = string( decision_titles );
            end
            assert( isstring( decision_titles ) );
            assert( isvector( decision_titles ) );
            assert( numel( unique( decision_titles ) ) == numel( decision_titles ) );
            assert( numel( decision_titles ) == numel( decision_tags ) );
            props.decision_titles = decision_titles;
            
            objective_tags = props.objective_tags;
            if ischar( objective_tags ) || iscellstr( objective_tags ) %#ok<ISCLSTR>
                objective_tags = string( objective_tags );
            end
            assert( isstring( objective_tags ) );
            assert( isvector( objective_tags ) );
            assert( numel( unique( objective_tags ) ) == numel( objective_tags ) );
            assert( all( ismember( objective_tags, var_names ) ) );
            assert( isempty( intersect( decision_tags, objective_tags ) ) );
            props.objective_tags = objective_tags;
            
            objective_titles = props.objective_titles;
            if ischar( objective_titles ) || iscellstr( objective_titles ) %#ok<ISCLSTR>
                objective_titles = string( objective_titles );
            end
            assert( isstring( objective_titles ) );
            assert( isvector( objective_titles ) );
            assert( numel( unique( objective_titles ) ) == numel( objective_titles ) );
            assert( numel( objective_titles ) == numel( objective_tags ) );
            props.objective_titles = objective_titles;
            
            stl_file = props.stl_file;
            if ischar( stl_file ) || iscellstr( stl_file ) %#ok<ISCLSTR>
                stl_file = string( stl_file );
            end
            assert( isstring( stl_file ) );
            assert( isscalar( stl_file ) );
            [ ~, name, ext ] = fileparts( stl_file );
            stl_file = name + ext;
            props.stl_file = stl_file;
            
            if ismember( "pareto_tag", pnames )
                pareto_tag = props.pareto_tag;
                if ischar( pareto_tag ) || iscellstr( pareto_tag ) %#ok<ISCLSTR>
                    pareto_tag = string( pareto_tag );
                end
                assert( isstring( pareto_tag ) );
                assert( isscalar( pareto_tag ) );
                assert( ismember( pareto_tag, var_names ) );
                assert( isempty( intersect( pareto_tag, objective_tags ) ) );
                assert( isempty( intersect( pareto_tag, decision_tags ) ) );
                props.pareto_tag = pareto_tag;
            else
                data = addprop( data, obj.DEFAULT_PARETO_TAG, "table" );
                pareto_tag = obj.DEFAULT_PARETO_TAG;
            end
            
            if ismember( "interp_methods", pnames )
                interp_methods = props.interp_methods;
                if iscell( interp_methods ) && ~iscellstr( interp_methods )
                    interp_methods = [ interp_methods{ : } ];
                end
                if ischar( interp_methods ) || iscellstr( interp_methods ) %#ok<ISCLSTR>
                    interp_methods = string( interp_methods );
                end
                assert( isstring( interp_methods ) );
                assert( isvector( interp_methods ) );
                assert( numel( interp_methods ) == numel( objective_tags ) );
                props.interp_methods = interp_methods;
            else
                props.interp_methods = repmat( size( objective_tags ), "linear" );
            end
            
            obj.data = data;
            obj.data.Properties.CustomProperties = props;
            obj.decision_tags = decision_tags;
            obj.decision_titles = decision_titles;
            obj.objective_tags = objective_tags;
            obj.objective_titles = objective_titles;
            obj.interp_methods = interp_methods;
            obj.pareto_tag = pareto_tag;
            obj.stl_file = stl_file;
        end
        
        function clone = merge( obj, others )
            assert( isa( others, mfilename( "class" ) ) );
            assert( isvector( others ) );
            
            t = obj.data;
            c = nan( numel( others ), width( t ) );
            c = array2table( c );
            c.Properties.VariableNames = t.Properties.VariableNames;
            t = [ t; c ];
            tcp = t.Properties.CustomProperties;
            for i = 1 : numel( others )
                d = others( i ).data;
                dcp = d.Properties.CustomProperties;
                assert( all( sort( tcp.decision_tags ) == sort( dcp.decision_tags ) ) );
                assert( all( sort( tcp.decision_titles ) == sort( dcp.decision_titles ) ) );
                assert( all( sort( tcp.objective_tags ) == sort( dcp.objective_tags ) ) );
                assert( all( sort( tcp.objective_titles ) == sort( dcp.objective_titles ) ) );
                assert( all( tcp.interp_methods == dcp.interp_methods ) );
                assert( tcp.stl_file == dcp.stl_file );
                if ismember( "pareto_tag", properties( tcp ) )
                    assert( ismember( "pareto_tag", properties( dcp ) ) );
                    assert( tcp.pareto_tag == dcp.pareto_tag );
                end
                t{ i + 1, : } = d{ :, : };
            end
            clone = OrientationData( t );
            clone.compute_pareto_front();
        end
        
        function value = get_by_tag( obj, tag )
            value = obj.data{ :, tag };
        end
        
        function value = get_pareto_by_tag( obj, tag )
            value = obj.data{ obj.get_pareto_front(), tag };
        end
        
        function value = get_range( obj, tag )
            value.min = min( obj.get_by_tag( tag ), [], "all" );
            value.max = max( obj.get_by_tag( tag ), [], "all" );
        end
        
        function value = get.decision_count( obj )
            value = numel( obj.decision_tags );
        end
        
        function value = get.decisions( obj )
            value = obj.data{ :, obj.decision_tags };
        end
        
        function value = get.pareto_decisions( obj )
            value = obj.decisions( obj.get_pareto_front(), : );
        end
        
        function value = get.objective_count( obj )
            value = numel( obj.objective_tags );
        end
        
        function value = get.objectives( obj )
            value = obj.data{ :, obj.objective_tags };
        end
        
        function value = get.pareto_objectives( obj )
            value = obj.objectives( obj.get_pareto_front(), : );
        end
    end
    
    properties
        data table
        pareto_tag(1,1) string
    end
    
    methods ( Access = private )
        function compute_pareto_front( obj )
            pareto_front = find_pareto_indices( obj.objectives );
            obj.data{ :, obj.DEFAULT_PARETO_TAG } = false( height( obj.data ), 1 );
            obj.data{ pareto_front, obj.DEFAULT_PARETO_TAG } = true;
            obj.pareto_tag = obj.DEFAULT_PARETO_TAG;
        end
        
        function value = get_pareto_front( obj )
            if obj.has_pareto_front()
                value = obj.data{ :, obj.pareto_tag };
            else
                value = ones( height( obj.data ), 1 );
            end
        end
        
        function value = has_pareto_front( obj )
            value = obj.pareto_tag ~= "";
        end
        
        function set_pareto_tag( obj, value )
            obj.pareto_tag = value;
            obj.data.Properties.CustomProperties.pareto_tag = value;
        end
    end
    
    properties ( Access = private, Constant )
        DEFAULT_PARETO_TAG = "pareto_front";
    end
    
end

