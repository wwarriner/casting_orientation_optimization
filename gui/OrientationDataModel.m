classdef OrientationDataModel < handle
    
    % setters
    methods ( Access = public )
        
        function use_value_mode( obj )
        end
        
        
        function use_quantile_mode( obj )
        end
        
        
        function use_single_view( obj )
        end
        
        
        function set_selected_objective( obj, objective )
        end
        
        
        function apply_threshold_to_single_view( obj, do_apply )
        end
        
        
        function use_feasibility_view( obj )
        end
        
        
        function set_threshold( obj, objective, value )
        end
        
        
        function set_threshold_by_index( obj, objective_index, value )
        end
        
        
        function show_pareto_front( obj, do_show )
        end
        
        
        function show_global_minimum( obj, do_show )
        end
        
        
        function set_selected_angles( obj, angles )
        end
        
    end
    
    
    % getters
    methods ( Access = public )
        
        function is = is_pareto_front_shown( obj )
        end
        
        
        function is = is_global_minimum_shown( obj )
        end
        
        
        function point = get_current_global_minimum_point( obj )
        end
        
        
        function is = is_threshold_visible( obj )
        end
        
        
        function values = get_current_values( obj )
        end
        
        
        function values = get_single_threshold_values( obj )
        end
        
        
        function count = get_objective_count( obj )
        end
        
        
        function angles = get_selected_point_angles_in_degrees( obj )
        end
        
        
        function value = get_selected_point_value( obj )
        end
        
    end
    
    
    properties ( Access = private )
        
        
        
    end
    
end

