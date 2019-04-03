classdef DataFilter < handle
    
    properties ( Access = public, Constant )
        
        VALUE_MODE = 'value'
        QUANTILE_MODE = 'quantile'
        
    end
    
    
    methods ( Access = public )
        
        function obj = DataFilter( response_data )
            
            obj.response_data = response_data;
            obj.mode = obj.VALUE_MODE;
            obj.value_raw_thresholds = ...
                obj.compute_initial_values( response_data.get_objective_value_ranges() );
            obj.quantile_raw_thresholds = ...
                obj.compute_initial_quantiles( response_data.get_objective_value_ranges() );
            obj.value_usage_states = ...
                obj.create_initial_usage_states( response_data.get_tags() );
            
        end
        
        
        function set_mode( obj, mode )
            
            obj.mode = mode;
            
        end
        
        
        function value = get_value( obj, point, tag )
            
            switch obj.mode
                case obj.VALUE_MODE
                    value = obj.response_data.get_objective_value( point, tag );
                case obj.QUANTILE_MODE
                    value = obj.response_data.get_quantile_value( point, tag );
                otherwise
                    assert( false );
            end 
            
        end
        
        
        function values = get_values( obj, tag )
            
            switch obj.mode
                case obj.VALUE_MODE
                    values = obj.response_data.get_objective_values( tag );
                case obj.QUANTILE_MODE
                    values = obj.response_data.get_quantile_values( tag );
                otherwise
                    assert( false );
            end
            
        end
        
        
        function values = get_thresholded_values( obj, tag )
            
            threshold = obj.get_threshold( tag );
            values = obj.get_values( tag ) < threshold.get_value();
            
        end
        
        
        function values = get_composited_values( obj )
            
            tags = obj.get_tags();
            values = true( obj.get_grid_size() );
            for i = 1 : obj.get_count()
                
                tag = tags{ i };
                if ~obj.value_usage_states( tag )
                    continue;
                end
                below = obj.get_thresholded_values( tag );
                values = values & below;
                
            end
            values = ~values;
            
        end
        
        
        function below = is_pareto_front_below_thresholds( obj )
            
            tags = obj.get_tags();
            below = true( obj.get_pareto_front_count(), 1 );
            pf = obj.get_pareto_front_values();
            for i = 1 : obj.get_count()
                
                tag = tags{ i };
                if ~obj.value_usage_states( tag )
                    continue;
                end
                current_below = pf( tag ) < obj.get_raw_threshold_value( tag );
                below = below & current_below;
                
            end
            
        end
        
        
        function set_threshold( obj, tag, value )
            
            switch obj.mode
                case obj.VALUE_MODE
                    obj.value_raw_thresholds( tag ) = value;
                case obj.QUANTILE_MODE
                    obj.quantile_raw_thresholds( tag ) = value;
                otherwise
                    assert( false );
            end
            
        end
        
        
        function threshold = get_threshold( obj, tag )
            
            threshold = obj.create_threshold( tag );
            
        end
        
        
        function thresholds = get_thresholds( obj )
            
            tags = obj.get_tags();
            constrained_values = cell( obj.get_count(), 1 );
            for i = 1 : obj.get_count()
                
                constrained_values{ i } = obj.create_threshold( tags{ i } );
                
            end
            thresholds = containers.Map( ...
                tags, ...
                constrained_values ...
                );
            
        end
        
        
        function state = set_usage_state( obj, tag, state )
            
            obj.value_usage_states( tag ) = state;
            
        end
        
        
        function state = get_usage_state( obj, tag )
            
            state = obj.value_usage_states( tag );
            
        end
        
        
        function count = get_pareto_front_count( obj )
            
            v = obj.get_pareto_front_values().values();
            count = size( v{ 1 }, 1 );
            
        end
        
        
        function values = get_pareto_front_values( obj )
            
            switch obj.mode
                case obj.VALUE_MODE
                    values = obj.response_data.get_pareto_front_values();
                case obj.QUANTILE_MODE
                    values = obj.response_data.get_pareto_front_quantiles();
                otherwise
                    assert( false );
            end
            
        end
        
        
        function states = get_usage_states( obj )
            
            states = obj.value_usage_states;
            
        end
        
        
        function count = get_count( obj )
            
            count = obj.response_data.get_count();
            
        end
        
        
        function tags = get_tags( obj )
            
            tags = obj.response_data.get_tags();
            
        end
        
    end
    
    
    properties ( Access = private )
        
        response_data
        mode
        value_raw_thresholds
        quantile_raw_thresholds
        value_usage_states
        
    end
    
    
    methods ( Access = private )
        
        function threshold = create_threshold( obj, tag )
            
            range = obj.get_range( tag );
            threshold = ConstrainedNumericValue( ...
                range.min, ...
                range.max, ...
                obj.get_raw_threshold_value( tag ) ...
                );
            
        end
        
        
        function range = get_range( obj, tag )
            
            switch obj.mode
                case obj.VALUE_MODE
                    range = obj.response_data.get_objective_value_range( tag );
                case obj.QUANTILE_MODE
                    range.min = 0;
                    range.max = 1;
                otherwise
                    assert( false );
            end
            
        end
        
        
        function value = get_raw_threshold_value( obj, tag )
            
            switch obj.mode
                case obj.VALUE_MODE
                    value = obj.value_raw_thresholds( tag );
                case obj.QUANTILE_MODE
                    value = obj.quantile_raw_thresholds( tag );
                otherwise
                    assert( false );
            end
            
        end
        
        
        function sz = get_grid_size( obj )
            
            sz = obj.response_data.get_grid_size();
            
        end
        
    end
    
    
    % construction
    methods ( Access = private, Static )
        
        function raw = compute_initial_values( value_ranges )
            
            raw = containers.Map( ...
                'keytype', 'char', ...
                'valuetype', 'double' ...
                );
            tags = value_ranges.keys();
            for i = 1 : value_ranges.Count()
                
                tag = tags{ i };
                range = value_ranges( tag );
                raw( tag ) = mean( [ range.min range.max ] );
                
            end
            
        end
        
        
        function raw = compute_initial_quantiles( value_ranges )
            
            raw = containers.Map( ...
                value_ranges.keys(), ...
                0.5 * ones( value_ranges.Count(), 1 ) ...
                );
            
        end
        
        
        function states = create_initial_usage_states( tags )
            
            states = containers.Map( ...
                tags, ...
                true( numel( tags ), 1 ) ...
                );
            
        end
        
    end
    
end

