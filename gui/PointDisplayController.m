classdef PointDisplayController < handle
    
    methods
        function obj = PointDisplayController( ...
                pareto_front_check_box, ...
                global_minimum_check_box, ...
                rotation_x_spinner, ...
                rotation_x_slider, ...
                rotation_y_spinner, ...
                rotation_y_slider, ...
                orientation_data_model ...
                )
            obj.pareto_front_check_box = pareto_front_check_box;
            obj.global_minimum_check_box = global_minimum_check_box;
            obj.rotation_x_spinner = rotation_x_spinner;
            obj.rotation_x_slider = rotation_x_slider;
            obj.rotation_y_spinner = rotation_y_spinner;
            obj.rotation_y_slider = rotation_y_slider;
            obj.model = orientation_data_model;
        end
        
        function update_all( obj )
            obj.update_pareto_front();
            obj.update_global_minimum();
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
        
        function update_selected_point_by_click( obj )
            point_data = obj.get_selected_point_data();
            obj.rotation_x_spinner.Value = point_data.angles( 1 );
            obj.rotation_x_slider.Value = point_data.angles( 1 );
            obj.rotation_x_spinner.Value = point_data.angles( 2 );
            obj.rotation_x_slider.Value = point_data.angles( 2 );
        end
        
        function update_selected_point_by_spinner( obj, axis )
            curr = obj.model.selected_angles_deg;
            value = curr( axis );
            switch axis
                case 1
                    value = obj.rotation_x_spinner.Value;
                    obj.rotation_x_slider.Value = value;
                case 2
                    value = obj.rotation_y_spinner.Value;
                    obj.rotation_y_slider.Value = value;
                otherwise
                    assert( false );
            end
            curr( axis ) = value;
            obj.model.selected_angles_deg = curr;
        end
        
        function update_selected_point_by_slider( obj, axis )
            curr = obj.model.selected_angles_deg;
            value = curr( axis );
            switch axis
                case 1
                    value = obj.rotation_x_slider.Value;
                    obj.rotation_x_spinner.Value = value;
                case 2
                    value = obj.rotation_y_slider.Value;
                    obj.rotation_y_spinner.Value = value;
                otherwise
                    assert( false );
            end
            curr( axis ) = value;
            obj.model.selected_angles_deg = curr;
        end
        
        function visualize_selected_point( obj )
            obj.model.visualize();
        end
    end
    
    properties ( Access = private )
        pareto_front_check_box
        global_minimum_check_box
        rotation_x_spinner
        rotation_x_slider
        rotation_y_spinner
        rotation_y_slider
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
    end
end

