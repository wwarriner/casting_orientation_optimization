classdef ResponseData < handle
    
    properties ( SetAccess = private, Dependent )
        name(1,1) string
        count(1,1) string
        grid_size(1,:) double {mustBeReal,mustBeFinite}
        tags(1,:) string
        pareto_front_count(1,1) double {mustBeReal,mustBeFinite,mustBePositive}
        pareto_front(:,:) double {mustBeReal,mustBeFinite}
    end
    
    % all expect radians
    methods
        function obj = ResponseData( orientation_data, resolution )
            gridded_data = GriddedData( orientation_data, resolution );
            minima = obj.compute_minima( ...
                orientation_data.decisions, ...
                orientation_data.objectives, ...
                orientation_data.objective_tags ...
                );
            
            obj.orientation_data = orientation_data;
            obj.gridded_data = gridded_data;
            obj.minima = minima;
        end
        
        function value = get.name( obj )
            value = obj.orientation_data.name;
        end
        
        function value = get.count( obj )
            value = obj.orientation_data.objective_count;
        end
        
        function value = get.grid_size( obj )
            value = obj.gridded_data.grid_size;
        end
        
        function value = get.tags( obj )
            value = obj.orientation_data.objective_tags;
        end
        
        function value = get.pareto_front_count( obj )
            value = size( obj.orientation_data.pareto_objectives, 1 );
        end
        
        function value = get.pareto_front( obj )
            value = obj.orientation_data.pareto_decisions;
        end
        
        function values = get_objective_values( obj, tag )
            values = obj.gridded_data.get_values( tag );
        end
        
        function value = get_pareto_front_values( obj, tag )
            value = obj.orientation_data.get_pareto_by_tag( tag );
        end
        
        function value = get_pareto_front_quantiles( obj, tag )
            value = obj.get_pareto_front_values( tag );
            value = obj.gridded_data.to_quantile( value, tag );
        end
        
        function value = get_objective_value_range( obj, tag )
            value = obj.orientation_data.get_range( tag );
        end
        
        function value = get_minimum( obj, tag )
            value = obj.minima( tag );
        end
        
        function value = get_quantile_values( obj, tag )
            value = obj.gridded_data.get_quantile_values( tag );
        end
        
        function value = get_thresholded_values( obj, threshold, tag )
            value = obj.gridded_data.get_thresholded( threshold, tag );
        end
        
        function value = get_no_go_values( obj, thresholds, active_states )
            value = obj.gridded_data.get_no_go( obj, thresholds, active_states );
        end
        
        function value = get_no_go_quantiles( obj, thresholds, active_states )
            value = obj.gridded_data.get_quantile_no_go( obj, thresholds, active_states );
        end
    end
    
    properties ( Access = private )
        orientation_data OrientationData
        gridded_data GriddedData
        minima containers.Map
    end
    
    methods ( Access = private, Static )
        function minima = compute_minima( decisions, objectives, tags )
            minima = containers.Map( ...
                "keytype", "char", ...
                "valuetype", "any" ...
                );
            for i = 1 : size( objectives, 2 )
                v = objectives( :, i );
                [ ~, index ] = min( v( : ) );
                angles = decisions( index, : );
                angles = constrain_unit_sphere_angles( angles );
                minima( tags( i ) ) = angles;
            end
        end
    end
    
end

