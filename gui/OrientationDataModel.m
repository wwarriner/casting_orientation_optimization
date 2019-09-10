classdef OrientationDataModel < handle
    
    properties
        resolution_factor(1,1) double {mustBeReal,mustBeFinite,mustBePositive} = 300;
        mode(1,1) string = OrientationDataModel.VALUES_MODE
        view(1,1) string = OrientationDataModel.SINGLE_VIEW
        show_pareto_front(1,1) logical
        show_global_minimum(1,1) logical
        show_threshold(1,1) logical
        selected_angles(1,2) double {mustBeReal,mustBeFinite}
        selected_tag(1,1) string
    end
    
    properties ( Constant )
        VALUES_MODE = "values";
        QUANTILES_MODE = "quantiles";
        SINGLE_VIEW = "single";
        FEASIBILITY_VIEW = "feasibility";
    end
    
    properties ( SetAccess = private )
        name(1,1) string
    end
    
    properties ( SetAccess = private, Dependent )
        ready(1,1) logical
        modes(:,1) string
        views(:,1) string
        tags(:,1) string
        single_view_selected(1,1) logical
        single_view_threshold_relevant(1,1) logical
        global_minimum_relevant(1,1) logical
        global_minimum(1,2) double
        pareto_objectives(:,:) double
        pareto_below(:,1) logical
        pareto_decisions_above_tag_threshold(:,2) double
        pareto_decisions_below_tag_threshold(:,2) double
        objectives(:,:) double
    end
    
    methods
        function obj = OrientationDataModel()
            obj.resolution_factor = 300;
            obj.selected_angles = [ 0 0 ];
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
                old_tags = sort( obj.tags );
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
        
        function set.mode( obj, value )
            assert( ismember( value, obj.modes ) ); %#ok<MCSUP>
            obj.mode = value;
        end
        
        function set.view( obj, value )
            assert( ismember( value, obj.views ) ); %#ok<MCSUP>
            obj.view = value;
        end
        
        function set.selected_tag( obj, tag )
            assert( ismember( tag, obj.tags ) || tag == "" ); %#ok<MCSUP>
            if tag == ""
                obj.valid_selected_tag = false; %#ok<MCSUP>
            else
                obj.valid_selected_tag = true; %#ok<MCSUP>
            end
            obj.selected_tag = tag;
        end
        
        function value = get.show_global_minimum( obj )
            if obj.global_minimum_relevant
                value = obj.show_global_minimum;
            else
                value = false;
            end
        end
        
        function set_threshold( obj, tag, value )
            switch obj.mode
                case obj.VALUES_MODE
                    threshold = obj.value_thresholds( tag );
                case obj.QUANTILES_MODE
                    threshold = obj.quantile_thresholds( tag );
                otherwise
                    assert( false )
            end
            threshold.update( value );
        end
        
        function set_active_state( obj, tag, is_active )
            obj.active_tags( tag ) = is_active;
        end
        
        function value = get.ready( obj )
            value = ~isempty( obj.response_data );
        end
        
        function value = get.modes( obj )
            value = [ obj.VALUES_MODE obj.QUANTILES_MODE ];
        end
        
        function value = get.views( obj )
            value = [ obj.SINGLE_VIEW obj.FEASIBILITY_VIEW ];
        end
        
        function value = get.single_view_selected( obj )
            value = obj.view == obj.SINGLE_VIEW;
        end
        
        function value = get.show_threshold( obj )
            if obj.view == obj.SINGLE_VIEW
                value = obj.show_threshold;
            else
                value = false;
            end
        end
        
        function value = get.tags( obj )
            if obj.ready
                value = obj.response_data.tags;
            else
                value = "";
            end
        end
        
        function value = get.global_minimum( obj )
            if ~obj.valid_selected_tag
                value = [ 0 0 ];
            else
                value = obj.response_data.get_minimum( obj.selected_tag );
            end
        end
        
        function value = get.pareto_objectives( obj )
            value = nan( ...
                obj.response_data.pareto_front_count, ...
                obj.get_objective_count() ...
                );
            for i = 1 : obj.get_objective_count()
                value( :, i ) = obj.select_pareto_objectives( ...
                    obj.get_objective_from_index( i ) ...
                    );
            end
        end
        
        function value = get.pareto_below( obj )
            value = obj.is_pareto_front_below();
        end
        
        function points = get.pareto_decisions_above_tag_threshold( obj )
            points = obj.select_pareto_decisions();
            points( obj.is_pareto_front_below(), : ) = [];
        end
        
        function points = get.pareto_decisions_below_tag_threshold( obj )
            points = obj.select_pareto_decisions();
            points( ~obj.is_pareto_front_below(), : ) = [];
        end
        
        function value = get.global_minimum_relevant( obj )
            switch obj.view
                case obj.SINGLE_VIEW
                    value = true;
                case obj.FEASIBILITY_VIEW
                    value = false;
                otherwise
                    assert( false )
            end
        end
        
        function limits = get_data_limits( obj, tag )
            limits = obj.select_threshold( tag ).range;
        end
        
        function limits = get_all_data_limits( obj )
            limits = nan( obj.get_objective_count(), 2 );
            for i = 1 : obj.get_objective_count()
                limits( i, : ) = obj.get_data_limits( obj.get_objective_from_index( i ) );
            end
            assert( ~any( isnan( limits ), 'all' ) );
        end
        
        function enabled = is_enabled( obj, tag )
            switch obj.view
                case obj.SINGLE_VIEW
                    enabled = obj.selected_objective == tag;
                case obj.FEASIBILITY_VIEW
                    enabled = true;
                otherwise
                    assert( false );
            end
        end
        
        function active = is_active( obj, tag )
            switch obj.view
                case obj.SINGLE_VIEW
                    active = obj.selected_objective == tag;
                case obj.FEASIBILITY_VIEW
                    active = obj.active_tags( tag );
                otherwise
                    assert( false );
            end
        end
        
        function value = get.objectives( obj )
            switch obj.view
                case obj.SINGLE_VIEW
                    value = obj.select_single_values( obj.selected_tag );
                case obj.FEASIBILITY_VIEW
                    value = obj.select_feasibility_values();
                otherwise
                    assert( false )
            end
            value = double( value );
        end
        
        function range = get_color_axis_range( obj )
            if obj.view == obj.SINGLE_VIEW ...
                    && obj.mode == obj.VALUES_MODE
                values = obj.objectives;
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
        
        function threshold = get_threshold( obj, tag )
            threshold = obj.select_threshold( tag );
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
            values = double( obj.select_single_thresholded_values( obj.selected_tag ) );
        end
        
        function count = get_objective_count( obj )
            if ~obj.ready
                count = 0;
            else
                count = double( obj.response_data.count );
            end
        end
        
        function angles = get_selected_point_angles_in_degrees( obj )
            angles = obj.selected_angles();
        end
        
        function angles = get_selected_point_angles_in_radians( obj )
            angles = deg2rad( obj.selected_angles() );
        end
        
        function value = get_value( obj )
            % snap to grid
            offset = [ pi pi/2 ];
            total_length = [ 2*pi pi ];
            indices = ( deg2rad( obj.selected_angles ) + offset ) .* ...
                obj.get_image_size() ...
                ./ total_length;
            indices = min( indices, obj.get_image_size() );
            indices = max( indices, 1 );
            indices = round( indices );
            value = obj.objectives( indices( 1 ), indices( 2 ) );
        end
        
        function objective = get_objective_from_index( obj, index )
            objective = obj.response_data.tags{ index };
        end
    end
    
    properties ( Access = private )
        response_data
        visualization_generator
        active_tags
        value_thresholds
        quantile_thresholds
        
        valid_selected_tag(1,1) logical
    end
    
    methods ( Access = private )
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
            assert( obj.valid_selected_tag );
            switch obj.mode
                case obj.VALUES_MODE
                    values = obj.response_data.get_objective_values( tag );
                case obj.QUANTILES_MODE
                    values = obj.response_data.get_quantile_values( tag );
                otherwise
                    assert( false )
            end
        end
        
        function values = select_single_thresholded_values( obj, tag )
            assert( obj.valid_selected_tag );
            values = obj.select_single_values( tag );
            values = obj.threshold_values( tag, values );
        end
        
        function threshold = select_threshold( obj, tag )
            switch obj.mode
                case obj.VALUES_MODE
                    threshold = obj.value_thresholds( tag );
                case obj.QUANTILES_MODE
                    threshold = obj.quantile_thresholds( tag );
                otherwise
                    assert( false )
            end
        end
        
        function points = select_pareto_decisions( obj )
            points = rad2deg( obj.response_data.pareto_front );
        end
        
        function values = select_pareto_objectives( obj, tag )
            switch obj.mode
                case obj.VALUES_MODE
                    values = obj.response_data.get_pareto_front_values( tag );
                case obj.QUANTILES_MODE
                    values = obj.response_data.get_pareto_front_quantiles( tag );
                otherwise
                    assert( false );
            end
        end
        
        function values = threshold_values( obj, objective, values )
            threshold = obj.get_threshold( objective );
            values = values <= threshold;
        end
        
        function below = is_pareto_front_below( obj )
            switch obj.view
                case obj.SINGLE_VIEW
                    values = obj.select_pareto_objectives( obj.selected_tag );
                    below = obj.threshold_values( tag, values );
                case obj.FEASIBILITY_VIEW
                    t = obj.quantile_thresholds.values();
                    thresholds = zeros( size( t ) );
                    for i = 1 : numel( t )
                        thresholds( i ) = t{ i }.value();
                    end
                    values = obj.response_data.pareto_quantiles;
                    below = all( values <= thresholds, 2 );
                otherwise
                    assert( false )
            end
        end
        
        function sz = get_image_size( obj )
            sz = obj.response_data.grid_size;
        end
    end
    
end

