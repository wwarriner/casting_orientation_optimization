classdef PointDisplayController < handle
    
    methods
        function obj = PointDisplayController( ...
                pareto_front_check_box, ...
                global_minimum_check_box, ...
                selected_point_text_area, ...
                orientation_data_model ...
                )
            obj.pareto_front_check_box = pareto_front_check_box;
            obj.global_minimum_check_box = global_minimum_check_box;
            obj.selected_point_text_area = selected_point_text_area;
            obj.model = orientation_data_model;
        end
        
        function update_all( obj )
            obj.update_pareto_front();
            obj.update_global_minimum();
            obj.update_selected_point();
        end
        
        function update_pareto_front( obj )
            obj.model.show_pareto_front = obj.is_pareto_front_selected();
        end
        
        function update_global_minimum( obj )
            if ~obj.model.global_minimum_relevant
                enable = false;
                show = false;
            else
                enable = true;
                show = obj.is_global_minimum_selected();
            end
            obj.global_minimum_check_box.Enable = enable;
            obj.model.show_global_minimum = show;
        end
        
        function update_selected_point( obj )
            point_data = obj.get_selected_point_data();
            text = obj.format_text( point_data );
            obj.set_selected_point_text( text );
        end
        
        function visualize_selected_point( obj )
            obj.model.visualize();
        end
    end
    
    properties ( Access = private )
        pareto_front_check_box
        global_minimum_check_box
        selected_point_text_area
        model
    end
    
    methods ( Access = private )
        function selected = is_pareto_front_selected( obj )
            selected = obj.pareto_front_check_box.Value;
        end
        
        function selected = is_global_minimum_selected( obj )
            selected = obj.global_minimum_check_box.Value;
        end
        
        function data = get_selected_point_data( obj )
            data.angles = obj.model.selected_angles_deg;
            data.value = obj.model.get_value();
        end
        
        function set_selected_point_text( obj, text )
            obj.selected_point_text_area.Value = text;
        end
    end
    
    methods ( Access = private, Static )
        function text = format_text( point_data )
            NUMERIC_FORMAT = '%.3g';
            format = [ ...
                'Selected point:' newline ...
                '  @x: ' NUMERIC_FORMAT degree_symbol() newline ...
                '  @y: ' NUMERIC_FORMAT degree_symbol() newline ...
                '  value: ' NUMERIC_FORMAT ...
                ];
            text = sprintf( ...
                format, ...
                point_data.angles( 1 ), ...
                point_data.angles( 2 ), ...
                point_data.value ...
                );
        end
    end
    
end

