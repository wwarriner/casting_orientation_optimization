classdef FeasibilityThresholdSelectionController < handle
    
    methods ( Access = public )
        
        function obj = FeasibilityThresholdSelectionController( ...
                feasibility_threshold_selection_panel, ...
                check_box_base, ...
                slider_base, ...
                spinner_base, ...
                orientation_data_model ...
                )
            
            height_offset = 30;
            check_boxes = cell( orientation_data_model.get_objective_count(), 1);
            for i = 1 : orientation_data_model.get_objective_count()
                
                cb = uicheckbox( feasibility_threshold_selection_panel );
                cb.Value = 1;
                cb.Text = orientation_data_model.get_objective_from_index( i );
                cb.Position( 1 ) = check_box_base.Position( 1 );
                cb.Position( 2 ) = check_box_base.Position( 2 ) - ...
                    ( i - 1 ) * height_offset;
                cb.Position( 3 ) = check_box_base.Position( 3 );
                cb.Tag = orientation_data_model.get_objective_from_index( i );
                cb.ValueChangedFcn = check_box_base.ValueChangedFcn;
                check_boxes{ i } = cb;
                
            end
            obj.check_boxes = containers.Map( ...
                orientation_data_model.get_objectives(), ...
                check_boxes ...
                );
            check_box_base.Enable = 'off';
            check_box_base.Visible = 'off';
            
            sliders = cell( orientation_data_model.get_objective_count(), 1);
            for i = 1 : orientation_data_model.get_objective_count()
                
                sl = uislider( feasibility_threshold_selection_panel );
                sl.FontColor = feasibility_threshold_selection_panel.BackgroundColor;
                sl.Position( 1 ) = slider_base.Position( 1 );
                sl.Position( 2 ) = slider_base.Position( 2 ) - ...
                    ( i - 1 ) * height_offset;
                sl.Position( 3 ) = slider_base.Position( 3 );
                sl.Tag = orientation_data_model.get_objective_from_index( i );
                sl.ValueChangedFcn = slider_base.ValueChangedFcn;
                sliders{ i } = sl;
                
            end
            obj.sliders = containers.Map( ...
                orientation_data_model.get_objectives(), ...
                sliders ...
                );
            slider_base.Enable = 'off';
            slider_base.Visible = 'off';
            
            spinners = cell( orientation_data_model.get_objective_count(), 1);
            for i = 1 : orientation_data_model.get_objective_count()
                
                sp = uispinner( feasibility_threshold_selection_panel );
                sp.Position( 1 ) = spinner_base.Position( 1 );
                sp.Position( 2 ) = spinner_base.Position( 2 ) - ...
                    ( i - 1 ) * height_offset;
                sp.Position( 3 ) = spinner_base.Position( 3 );
                sp.Tag = orientation_data_model.get_objective_from_index( i );
                sp.ValueChangedFcn = spinner_base.ValueChangedFcn;
                spinners{ i } = sp;
                
            end
            obj.spinners = containers.Map( ...
                orientation_data_model.get_objectives(), ...
                spinners ...
                );
            spinner_base.Enable = 'off';
            spinner_base.Visible = 'off';
            
            obj.model = orientation_data_model;
            
        end
        
        
        function update_from_external( obj )
            
            enabled = obj.model.get_enabled_objectives();
            for i = 1 : obj.model.get_objective_count()
                
                objective = obj.model.get_objective_from_index( i );
                threshold = obj.model.get_threshold( objective );
                limits = obj.model.get_data_limits( objective );
                sl = obj.sliders( objective );
                sl.Limits = limits;
                sl.Value = threshold;
                sp = obj.spinners( objective );
                sp.Limits = limits;
                sp.Value = threshold;
                cb = obj.check_boxes( objective );
                
                if enabled( objective )
                    sl.Enable = 'on';
                    sp.Enable = 'on';
                    cb.Enable = 'on';
                else
                    sl.Enable = 'off';
                    sp.Enable = 'off';
                    cb.Enable = 'off';
                end
                
            end
            % get threshold data from model
            % update all sliders
            % update all spinners
            
        end
        
        
        function update_from_checkbox( obj, objective )
            
            cb = obj.check_boxes( objective );
            obj.model.set_active_state( objective, cb.Value );
            
        end
        
        
        function update_from_slider( obj, objective )
            
            sl = obj.sliders( objective );
            v = sl.Value;
            sp = obj.spinners( objective );
            sp.Value = v;
            obj.model.set_threshold( objective, v );
            
        end
        
        
        function update_from_spinner( obj, objective )
            
            sp = obj.spinners( objective );
            v = sp.Value;
            sl = obj.sliders( objective );
            sl.Value = v;
            obj.model.set_threshold( objective, v );
            
        end
        
    end
    
    
    properties ( Access = private )
        
        check_boxes
        sliders
        spinners
        model
        
    end
    
    
    methods ( Access = private )
        
        function objective = get_objective( obj )
            
            
            
        end
        
    end
    
end

