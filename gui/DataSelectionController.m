classdef DataSelectionController < handle
    
    properties ( Access = public, Constant )
        
        single = 'single';
        feasibility = 'feasibility';
        
    end
    
    
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
        
        
        function update_view_selection( obj )
            
            switch obj.get_mode_tag()
                case obj.single
                    obj.switch_to_single_view();
                case obj.feasibility
                    obj.switch_to_feasibility_view();
                otherwise
                    assert( false );
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
        
        
        function switch_to_single_view( obj )
            
            obj.enable_single_widgets();
            obj.model.switch_to_single_view();
            
        end
        
        
        function switch_to_feasibility_view( obj )
            
            obj.disable_single_widgets();
            obj.model.switch_to_feasibility_view();
            
        end
        
        
        function disable_single_widgets( obj )
            
            obj.objective_drop_down.Enable = false;
            obj.threshold_check_box.Enable = false;
            
        end
        
        
        function enable_single_widgets( obj )
            
            obj.objective_drop_down.Enable = true;
            obj.threshold_check_box.Enable = true;
            
        end
        
        
        function tag = get_mode_tag( obj )
            
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

