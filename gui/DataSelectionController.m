classdef DataSelectionController < handle
    
    methods ( Access = public )
        function obj = DataSelectionController( ...
                button_group, ...
                objective_drop_down, ...
                threshold_check_box, ...
                orientation_data_model ...
                )
            obj.button_group = button_group;
            obj.objective_drop_down = objective_drop_down;
            obj.threshold_check_box = threshold_check_box;
            obj.model = orientation_data_model;
        end
        
        function set_drop_down_items( obj )
            obj.objective_drop_down.Items = obj.model.get_tags();
        end
        
        function update_all( obj )
            obj.update_view_selection();
            obj.update_objective_selection();
            obj.update_threshold_check_box();
        end
        
        function update_view_selection( obj )
            view = obj.get_view_tag();
            obj.model.set_view( view );
            if strcmpi( view, obj.model.single_view )
                obj.enable_single_widgets();
            else
                obj.disable_single_widgets();
            end
        end
        
        function update_objective_selection( obj )
            objective = obj.get_selected_objective();
            obj.model.set_selected_objective( objective );
        end
        
        function update_threshold_check_box( obj )
            do_apply = obj.is_threshold_check_box_selected();
            obj.model.apply_threshold_to_single_view( do_apply );
        end
    end
    
    properties ( Access = private )
        button_group
        objective_drop_down
        threshold_check_box
        model
    end
    
    methods ( Access = private )
        function disable_single_widgets( obj )
            obj.objective_drop_down.Enable = false;
            obj.threshold_check_box.Enable = false;
        end
        
        function enable_single_widgets( obj )
            obj.objective_drop_down.Enable = true;
            obj.threshold_check_box.Enable = true;
        end
        
        function tag = get_view_tag( obj )
            tag = obj.button_group.SelectedObject.Tag;
        end
        
        function objective = get_selected_objective( obj )
            objective = obj.objective_drop_down.Value;
        end
        
        function selected = is_threshold_check_box_selected( obj )
            selected = obj.threshold_check_box.Value;
        end
    end
    
end

