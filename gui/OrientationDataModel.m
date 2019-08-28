classdef OrientationDataModel < handle
    
    properties
        resolution_factor(1,1) double {mustBeReal,mustBeFinite,mustBePositive} = 300;
    end
    
    properties ( SetAccess = private )
        name(1,1) string
    end
    
    methods
        function obj = OrientationDataModel()
            obj.resolution_factor = 300;
            obj.selected_angles = [ 0 0 ];
        end
    end
    
    
    % file operations
    methods ( Access = public )
        function ready = is_ready( obj )
            ready = ~isempty( obj.response_data );
        end
        
        function canceled = load( obj, root_path )
            
            % dialog
            start_path = fullfile( root_path, 'sample' );
            EXT = '.ood';
            filter = fullfile( start_path, [ '*' EXT ] );
            [ file, path ] = uigetfile( filter );
            canceled = false;
            if file == 0
                canceled = true;
                return;
            end
            data_file = fullfile( path, file );
            
            % load response data
            new_data = OrientationData.load_obj( data_file );
            new_data = ResponseData( new_data, obj.resolution_factor );
            
            % retain current settings if possible
            % active_states
            new_tags = sort( new_data.tags );
            new_active_tags = containers.Map( ...
                new_tags, ...
                true( new_data.count, 1 ) ...
                );
            new_count = numel( new_tags );
            
            % value_thresholds
            v = ConstrainedNumericValue.empty( new_count, 0 );
            for i = 1 : new_count
                range = new_data.get_objective_value_range( new_tags( i ) );
                c = ConstrainedNumericValue();
                c.range = [ range.min range.max ];
                c.ratio = 0.5;
                v( i ) = c;
            end
            new_value_thresholds = containers.Map( ...
                new_data.tags, ...
                num2cell( v ) ...
                );
            
            % quantile_thresholds
            v = ConstrainedNumericValue.empty( new_count, 0 );
            for i = 1 : new_count
                c = ConstrainedNumericValue();
                c.range = [ 0 1 ];
                c.ratio = 0.5;
                v( i ) = c;
            end
            new_quantile_thresholds = containers.Map( ...
                new_data.tags, ...
                num2cell( v )...
                );
            
            if ~isempty( obj.response_data )
                old_tags = sort( obj.get_tags() );
                for i = 1 : new_count
                    new_tag = new_tags( i );
                    if ismember( new_tag, old_tags )
                        new_active_tags( new_tag ) = obj.active_tags( new_tag );
                        new_value_thresholds( new_tag ) = obj.value_thresholds( new_tag );
                        new_quantile_thresholds( new_tag ) = obj.quantile_thresholds( new_tag );
                    end
                end
            end
            
            % setup
            obj.active_tags = new_active_tags;
            obj.value_thresholds = new_value_thresholds;
            obj.quantile_thresholds = new_quantile_thresholds;
            obj.response_data = new_data;
            % TODO vis generator
        end
    end
    
    properties ( Access = public )
        values_mode = 'values';
        quantiles_mode = 'quantiles';
    end
    
    methods ( Access = public )
        function set_mode( obj, mode )
            obj.mode = mode;
        end
    end
    
    properties ( Access = public )
        single_view = 'single';
        feasibility_view = 'feasibility';
    end
    
    methods ( Access = public )
        function set_view( obj, view )
            obj.view_setting = view;
        end
        
        function set_selected_objective( obj, objective )
            obj.selected_objective = objective;
        end
        
        function apply_threshold_to_single_view( obj, do_apply )
            obj.show_single_threshold = do_apply;
        end
    end
    
    methods ( Access = public )
        function show_pareto_front( obj, do_show )
            obj.show_pareto = do_show;
        end
        
        function show_global_minimum( obj, do_show )
            obj.show_minimum = do_show;
        end
        
        function set_selected_angles( obj, angles )
            obj.selected_angles = angles;
        end
    end
    
    methods ( Access = public )
        function set_threshold( obj, objective, value )
            switch obj.mode
                case obj.values_mode
                    threshold = obj.value_thresholds( objective );
                case obj.quantiles_mode
                    threshold = obj.quantile_thresholds( objective );
                otherwise
                    assert( false )
            end
            threshold.update( value );
        end
        
        function set_threshold_by_index( obj, objective_index, value )
            v = obj.get_objective_from_index( objective_index );
            obj.set_threshold( v, value );
        end
        
        function set_active_state( obj, objective, is_active )
            obj.active_tags( objective ) = is_active;
        end
    end
    
    methods ( Access = public )
        function visualize( obj )
            % TODO update this to use uifigure/uiaxes when rotation tools avail
            fh = figure();
            fh.MenuBar = 'none';
            fh.ToolBar = 'none';
            fh.DockControls = 'off';
            fh.Color = 'w';
            fh.Resize = 'off';
            deg_angles = obj.get_selected_point_angles_in_degrees();
            fh.Name = sprintf( ...
                'Visualization of %s with @X: %.2f and @Y: %.2f', ...
                obj.response_data.name, ...
                deg_angles( 1 ), ...
                deg_angles( 2 ) ...
                );
            fh.NumberTitle = 'off';
            cameratoolbar( fh, 'show' );
            axh = axes( fh );
            axh.Color = 'none';
            hold( axh, 'on' );
            view( axh, 3 );
            light( axh, 'Position', [ 0 0 -1 ] );
            light( axh, 'Position', [ 0 0 1 ] );
            axis( axh, 'equal', 'vis3d', 'off' );
            obj.visualization_generator.draw( axh, obj.get_selected_point_angles_in_radians() );
        end
        
        function objectives = get_tags( obj )
            objectives = obj.response_data.tags;
        end
        
        function relevant = is_global_minimum_relevant( obj )
            switch obj.view_setting
                case obj.single_view
                    relevant = true;
                case obj.feasibility_view
                    relevant = false;
                otherwise
                    assert( false )
            end
        end
        
        function is = is_pareto_front_shown( obj )
            is = obj.show_pareto;
        end
        
        function points = get_pareto_front( obj )
            points = rad2deg( obj.response_data.pareto_front );
        end
        
        function values = get_all_pareto_front_values( obj )
            values = obj.select_all_pareto_front_values();
        end
        
        function value = get_pareto_indices_above( obj )
            value = find( ~obj.select_pareto_front_below() );
        end
        
        function value = get_pareto_indices_below( obj )
            value = find( obj.select_pareto_front_below() );
        end
        
        function values = get_all_pareto_front_values_above_threshold( obj )
        end
        
        function values = get_all_pareto_front_values_below_threshold( obj )
            values = obj.select_all_pareto_front_values();
            values( ~obj.select_pareto_front_below(), : ) = [];
        end
        
        function points = get_pareto_front_above_threshold( obj )
            points = obj.get_pareto_front();
            points( obj.select_pareto_front_below(), : ) = [];
        end
        
        function points = get_pareto_front_below_threshold( obj )
            points = obj.get_pareto_front();
            points( ~obj.select_pareto_front_below(), : ) = [];
        end
        
        function limits = get_data_limits( obj, objective )
            switch obj.mode
                case obj.values_mode
                    range = obj.response_data.get_objective_value_range( objective );
                    limits = [ range.min range.max ];
                case obj.quantiles_mode
                    limits = [ 0 1 ];
                otherwise
                    assert( false )
            end
        end
        
        function limits = get_all_data_limits( obj )
            limits = nan( obj.get_objective_count(), 2 );
            for i = 1 : obj.get_objective_count()
                limits( i, : ) = obj.get_data_limits( obj.get_objective_from_index( i ) );
            end
            assert( ~any( isnan( limits ), 'all' ) );
        end
        
        function is = is_global_minimum_shown( obj )
            if strcmpi( obj.view_setting, obj.single_view )
                is = obj.show_minimum;
            else
                is = false;
            end
        end
        
        function point = get_current_global_minimum_point( obj )
            point = obj.response_data.get_minimum( obj.selected_objective );
        end
        
        function is = is_single_threshold_shown( obj )
            if strcmpi( obj.view_setting, obj.single_view )
                is = obj.show_single_threshold;
            else
                is = false;
            end
        end
        
        function enabled = is_enabled( obj, objective )
            switch obj.view_setting
                case obj.single_view
                    enabled = strcmpi( obj.selected_objective, objective );
                case obj.feasibility_view
                    enabled = true;
                otherwise
                    assert( false );
            end
        end
        
        function active = is_active( obj, objective )
            switch obj.view_setting
                case obj.single_view
                    active = strcmpi( obj.selected_objective, objective );
                case obj.feasibility_view
                    active = obj.active_tags( objective );
                otherwise
                    assert( false );
            end
        end
        
        function values = get_current_values( obj )
            values = double( obj.select_values() );
        end
        
        function range = get_color_axis_range( obj )
            if strcmpi( obj.view_setting, obj.single_view ) && ...
                    strcmpi( obj.mode, obj.values_mode )
                values = obj.get_current_values();
                range = [ ...
                    min( values, [], 'all' )
                    max( values, [], 'all' )
                    ];
                if diff( range ) < eps
                    range = [ range( 1 ) - 0.5, range( 2 ) + 0.5 ];
                end
            else
                range = [ 0 1 ];
            end
        end
        
        function threshold = get_threshold( obj, objective )
            threshold = obj.select_threshold( objective );
            threshold = threshold.value;
        end
        
        function thresholds = get_all_thresholds( obj )
            thresholds = nan( obj.get_objective_count(), 1 );
            for i = 1 : obj.get_objective_count()
                thresholds( i ) = obj.get_threshold( obj.get_objective_from_index( i ) );
            end
            assert( ~any( isnan( thresholds ), 'all' ) );
        end
        
        function values = get_single_threshold_values( obj )
            values = double( obj.select_single_thresholded_values( obj.selected_objective ) );
        end
        
        function count = get_objective_count( obj )
            if ~obj.is_ready()
                count = 0;
                return;
            end
            count = double( obj.response_data.count );
        end
        
        function angles = get_selected_point_angles_in_degrees( obj )
            angles = obj.selected_angles();
        end
        
        function angles = get_selected_point_angles_in_radians( obj )
            angles = deg2rad( obj.selected_angles() );
        end
        
        function value = get_value( obj )
            % snap
            offset = [ pi pi/2 ];
            total_length = [ 2*pi pi ];
            indices = ( deg2rad( obj.selected_angles ) + offset ) .* ...
                obj.get_image_size() ...
                ./ total_length;
            indices = min( indices, obj.get_image_size() );
            indices = max( indices, 1 );
            indices = round( indices );
            values = obj.select_values();
            value = values( indices( 1 ), indices( 2 ) );
        end
        
        function objective = get_objective_from_index( obj, index )
            objectives = obj.response_data.tags;
            objective = objectives{ index };
        end
    end
    
    properties ( Access = private )
        response_data
        visualization_generator
        mode
        view_setting
        selected_objective
        show_pareto
        show_minimum
        show_single_threshold
        selected_angles
        active_tags
        value_thresholds
        quantile_thresholds
    end
    
    methods ( Access = public )
        function values = select_values( obj )
            switch obj.view_setting
                case obj.single_view
                    values = obj.select_single_values( obj.selected_objective );
                case obj.feasibility_view
                    values = obj.select_feasibility_values();
                otherwise
                    assert( false )
            end
        end
        
        function values = select_feasibility_values( obj )
            values = true( obj.get_image_size() );
            for i = 1 : obj.get_objective_count()
                v = obj.get_objective_from_index( i );
                if ~obj.is_active( v )
                    continue;
                end
                values = values & ...
                    obj.select_single_thresholded_values( v );
            end
        end
        
        function values = select_single_values( obj, tag )
            switch obj.mode
                case obj.values_mode
                    values = obj.response_data.get_objective_values( tag );
                case obj.quantiles_mode
                    values = obj.response_data.get_quantile_values( tag );
                otherwise
                    assert( false )
            end
        end
        
        function values = select_single_thresholded_values( obj, objective )
            values = obj.select_single_values( objective );
            values = obj.threshold_values( objective, values );
        end
        
        function values = threshold_values( obj, objective, values )
            threshold = obj.get_threshold( objective );
            values = values <= threshold;
        end
        
        function threshold = select_threshold( obj, objective )
            switch obj.mode
                case obj.values_mode
                    threshold = obj.value_thresholds( objective );
                case obj.quantiles_mode
                    threshold = obj.quantile_thresholds( objective );
                otherwise
                    assert( false )
            end
        end
        
        function values = select_all_pareto_front_values( obj )
            values = nan( obj.response_data.pareto_front_count, obj.get_objective_count() );
            for i = 1 : obj.get_objective_count()
                values( :, i ) = obj.get_pareto_front_values( obj.get_objective_from_index( i ) );
            end
        end
        
        function below = select_pareto_front_below( obj )
            switch obj.view_setting
                case obj.single_view
                    below = obj.is_pareto_front_below_single_threshold( obj.selected_objective );
                case obj.feasibility_view
                    below = obj.is_pareto_front_feasible();
                otherwise
                    assert( false )
            end
        end
        
        function below = is_pareto_front_feasible( obj )
            below = true( obj.response_data.pareto_front_count, 1 );
            for i = 1 : obj.get_objective_count()
                v = obj.get_objective_from_index( i );
                if ~obj.is_active( v )
                    continue;
                end
                below = below & ...
                    obj.is_pareto_front_below_single_threshold( v );
            end
        end
        
        function below = is_pareto_front_below_single_threshold( obj, tag )
            values = obj.get_pareto_front_values( tag );
            below = obj.threshold_values( tag, values );
        end
        
        function count = get_pareto_front_count( obj )
            count = obj.response_data.pareto_front_count;
        end
        
        function values = get_pareto_front_values( obj, objective )
            switch obj.mode
                case obj.values_mode
                    values = obj.response_data.get_pareto_front_values( objective );
                case obj.quantiles_mode
                    values = obj.response_data.get_pareto_front_quantiles( objective );
                otherwise
                    assert( false );
            end
        end
        
        function sz = get_image_size( obj )
            sz = obj.response_data.grid_size;
        end
    end
    
end

