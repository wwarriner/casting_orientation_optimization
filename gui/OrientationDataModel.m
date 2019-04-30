classdef OrientationDataModel < handle
    
    % mode
    properties ( Access = public )
        
        values_mode = 'values';
        quantiles_mode = 'quantiles';
        
    end
    
    
    methods ( Access = public )
        
        function set_mode( obj, mode )
            
            obj.mode = mode;
            
        end
        
    end
    
    
    % view
    properties ( Access = public )
        
        single_view = 'single';
        feasibility_view = 'feasibility';
        
    end
    
    
    methods ( Access = public )
        
        function obj = OrientationDataModel( full_path )
            
            % todo automate/extract this
            results = load( full_path );
            [ path, name, ~ ] = fileparts( full_path );
            data = results.(name);
            
            data.Properties.UserData.Name = name;
            data.Properties.UserData.ObjectiveVariablesPath = ...
                which( data.Properties.UserData.ObjectiveVariablesPath );
            
            figure_resolution_px = 600;
            data_extractor = DataExtractor( ...
                data, ...
                data.Properties.UserData, ...
                ceil( figure_resolution_px / 2 ) ...
                );
            obj.response_data = ResponseData( data_extractor );
            objectives = obj.response_data.get_tags();
            obj.active_objectives = containers.Map( ...
                objectives, ...
                true( obj.response_data.get_count(), 1 ) ...
                );
            initial_values = cell( obj.response_data.get_count(), 1 );
            for i = 1 : obj.response_data.get_count()
                
                objective = objectives{ i };
                range = obj.response_data.get_objective_value_range( objective );
                initial_values{ i } = ConstrainedNumericValue( ...
                    range.min, ...
                    range.max, ...
                    mean( [ range.min range.max ] ) ...
                    );
                
            end
            obj.value_thresholds = containers.Map( ...
                obj.response_data.get_tags(), ...
                initial_values ...
                );
            initial_values = cell( obj.response_data.get_count(), 1 );
            for i = 1 : obj.response_data.get_count()
                
                initial_values{ i } = ConstrainedNumericValue( 0, 1, 0.5 );
                
            end
            obj.quantile_thresholds = containers.Map( ...
                obj.response_data.get_tags(), ...
                initial_values ...
                );
            
        end
        
        
        function set_view( obj, view )
            
            obj.view = view;
            
        end
        
        
        function set_selected_objective( obj, objective )
            
            obj.selected_objective = objective;
            
        end
        
        
        function apply_threshold_to_single_view( obj, do_apply )
            
            obj.show_single_threshold = do_apply;
            
        end
        
    end
    
    
    % point display
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
    
    
    % feasibility
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
            
            obj.active_objectives( objective ) = is_active;
            
        end
        
    end
    
    
    % getters
    methods ( Access = public )
        
        function objectives = get_objectives( obj )
            
            objectives = obj.response_data.get_tags();
            
        end
        
        
        function is = is_pareto_front_shown( obj )
            
            is = obj.show_pareto;
            
        end
        
        
        function points = get_pareto_front( obj )
            
            points = rad2deg( obj.response_data.get_pareto_front() );
            
        end
        
        
        function values = get_all_pareto_front_values_above_threshold( obj )
            
            values = obj.select_all_pareto_front_values();
            values( obj.select_pareto_front_below(), : ) = [];
            
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
            
            if strcmpi( obj.view, obj.single_view )
                is = obj.show_minimum;
            else
                is = false;
            end
            
        end
        
        
        function point = get_current_global_minimum_point( obj )
            
            point = obj.response_data.get_minimum( obj.selected_objective );
            
        end
        
        
        function is = is_single_threshold_shown( obj )
            
            if strcmpi( obj.view, obj.single_view )
                is = obj.show_single_threshold;
            else
                is = false;
            end
            
        end
        
        
        function enabled = is_enabled( obj, objective )
            
            switch obj.view
                case obj.single_view
                    enabled = strcmpi( obj.selected_objective, objective );
                case obj.feasibility_view
                    enabled = true;
                otherwise
                    assert( false );
            end
            
        end
        
        
        function active = is_active( obj, objective )
            
            switch obj.view
                case obj.single_view
                    active = strcmpi( obj.selected_objective, objective );
                case obj.feasibility_view
                    active = obj.active_objectives( objective );
                otherwise
                    assert( false );
            end
            
        end
        
        
        function values = get_current_values( obj )
            
            values = double( obj.select_values() );
            
        end
        
        
        function threshold = get_threshold( obj, objective )
            
            threshold = obj.select_threshold( objective );
            threshold = threshold.get_value();
            
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
            
            count = double( obj.response_data.get_count() );
            
        end
        
        
        function angles = get_selected_point_angles_in_degrees( obj )
            
            angles = obj.selected_angles();
            
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
            
            objectives = obj.response_data.get_tags();
            objective = objectives{ index };
            
        end
        
    end
    
    
    properties ( Access = private )
        
        response_data
        
        mode
        view
        selected_objective
        
        show_pareto
        show_minimum
        show_single_threshold
        selected_angles
        
        active_objectives
        value_thresholds
        quantile_thresholds
        
    end
    
    
    methods ( Access = public )
        
        function values = select_values( obj )
            
            switch obj.view
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
        
        
        function values = select_single_values( obj, objective )
            
            switch obj.mode
                case obj.values_mode
                    values = obj.response_data.get_objective_values( objective );
                case obj.quantiles_mode
                    values = obj.response_data.get_quantile_values( objective );
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
            
            values = nan( obj.get_pareto_front_count(), obj.get_objective_count() );
            for i = 1 : obj.get_objective_count()
                
                values( :, i ) = obj.get_pareto_front_values( obj.get_objective_from_index( i ) );
                
            end
            
        end
        
        
        function below = select_pareto_front_below( obj )
            
            switch obj.view
                case obj.single_view
                    below = obj.is_pareto_front_below_single_threshold( obj.selected_objective );
                case obj.feasibility_view
                    below = obj.is_pareto_front_feasible();
                otherwise
                    assert( false )
            end
            
        end
        
        
        function below = is_pareto_front_feasible( obj )
            
            below = true( obj.response_data.get_pareto_front_count(), 1 );
            for i = 1 : obj.get_objective_count()
                
                v = obj.get_objective_from_index( i );
                if ~obj.is_active( v )
                    continue;
                end
                below = below & ...
                    obj.is_pareto_front_below_single_threshold( v );
                
            end
            
        end
        
        
        function below = is_pareto_front_below_single_threshold( obj, objective )
            
            values = obj.get_pareto_front_values( objective );
            below = obj.threshold_values( objective, values );
            
        end
        
        
        function count = get_pareto_front_count( obj )
            
            count = obj.response_data.get_pareto_front_count();
            
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
            
            sz = obj.response_data.get_grid_size();
            
        end
        
    end
    
end

