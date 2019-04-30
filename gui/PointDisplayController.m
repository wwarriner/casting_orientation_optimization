classdef PointDisplayController < handle
    
    methods ( Access = public )
        
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
        
        
        function update_pareto_front( obj )
            
            do_show = obj.is_pareto_front_selected();
            obj.model.show_pareto_front( do_show );
            
        end
        
        
        function update_global_minimum( obj )
            
            if ~obj.model.is_global_minimum_relevant()
                obj.global_minimum_check_box.Enable = false;
                obj.model.show_global_minimum( false );
            else
                obj.global_minimum_check_box.Enable = true;
                do_show = obj.is_global_minimum_selected();
                obj.model.show_global_minimum( do_show );
            end
            
        end
        
        
        function update_selected_point( obj )
            
            point_data = obj.get_selected_point_data();
            text = obj.format_text( point_data );
            obj.set_selected_point_text( text );
            
        end
        
        
        function visualize_selected_point( obj )
            
            % TODO: visualization code
            
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
            
            data.angles = obj.model.get_selected_point_angles_in_degrees();
            data.value = obj.model.get_value();
            
        end
        
        
        function text = format_text( obj, point_data )
            
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
        
        
        function set_selected_point_text( obj, text )
            
            obj.selected_point_text_area.Value = text;
            
        end
        
    end
    
end

