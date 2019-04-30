classdef FeasibilityThresholdSelectionController < handle
    
    methods ( Access = public )
        
        function obj = FeasibilityThresholdSelectionController( ...
                feasibility_threshold_selection_panel, ...
                check_box_base, ...
                slider_base, ...
                spinner_base, ...
                orientation_data_model ...
                )
            
            % disable base
            check_box_base.Enable = 'off';
            check_box_base.Visible = 'off';
            slider_base.Enable = 'off';
            slider_base.Visible = 'off';
            spinner_base.Enable = 'off';
            spinner_base.Visible = 'off';
            
            % construct clones
            HEIGHT_OFFSET = 30;
            count = orientation_data_model.get_objective_count();
            check_boxes = cell( count, 1 );
            sliders = cell( count, 1 );
            spinners = cell( count, 1 );
            for i = 1 : count
                
                parent = feasibility_threshold_selection_panel;
                offset = ( i - 1 ) * HEIGHT_OFFSET;
                objective = orientation_data_model.get_objective_from_index( i );
                check_boxes{ i } = obj.clone_check_box( ...
                    check_box_base, ...
                    parent, ...
                    offset, ...
                    objective ...
                    );
                sliders{ i } = obj.clone_slider( ...
                    slider_base, ...
                    parent, ...
                    offset, ...
                    objective ...
                    );
                spinners{ i } = obj.clone_spinner( ...
                    spinner_base, ...
                    parent, ...
                    offset, ...
                    objective ...
                    );
                
            end
            
            % set up object
            objectives = orientation_data_model.get_objectives();
            obj.check_boxes = containers.Map( objectives, check_boxes );
            obj.sliders = containers.Map( objectives, sliders );
            obj.spinners = containers.Map( objectives, spinners );
            obj.model = orientation_data_model;
            
        end
        
        
        function update_from_external( obj )
            
            for i = 1 : obj.model.get_objective_count()
                
                objective = obj.model.get_objective_from_index( i );
                limits = obj.model.get_data_limits( objective );
                value = obj.model.get_threshold( objective );
                obj.update_slider_value( objective, limits, value );
                obj.update_spinner_value( objective, limits, value );
                
            end
            obj.update_interactivity_all();
            
        end
        
        
        function update_from_checkbox( obj, objective )
            
            cb = obj.check_boxes( objective );
            obj.model.set_active_state( objective, cb.Value );
            obj.update_interactivity( objective );
            
        end
        
        
        function update_from_slider( obj, objective )
            
            value = obj.get_slider_value( objective );
            limits = obj.model.get_data_limits( objective );
            obj.update_spinner_value( objective, limits, value );
            obj.model.set_threshold( objective, value );
            
        end
        
        
        function update_from_spinner( obj, objective )
            
            value = obj.get_spinner_value( objective );
            limits = obj.model.get_data_limits( objective );
            obj.update_slider_value( objective, limits, value );
            obj.model.set_threshold( objective, value );
            
        end
        
    end
    
    
    properties ( Access = private )
        
        check_boxes
        sliders
        spinners
        model
        
    end
    
    
    methods ( Access = private )
        
        function value = get_slider_value( obj, objective )
            
            slider = obj.sliders( objective );
            value = slider.Value;
            
        end
        
        
        function value = get_spinner_value( obj, objective )
            
            spinner = obj.spinners( objective );
            value = spinner.Value;
            
        end
        
        
        function update_interactivity_all( obj )
            
            for i = 1 : obj.model.get_objective_count()
                
                objective = obj.model.get_objective_from_index( i );
                obj.update_interactivity( objective );
                
            end
            
        end
        
        
        function update_interactivity( obj, objective )
            
            cb = obj.check_boxes( objective );
            sl = obj.sliders( objective );
            sp = obj.spinners( objective );
            a = obj.model.is_active( objective );
            e = obj.model.is_enabled( objective );
            obj.update_widget_interactivity( a, e, cb, sl, sp );
            drawnow();
            
        end
        
        
        function update_slider_value( obj, objective, limits, value )
            
            sl = obj.sliders( objective );
            sl.Limits = limits;
            sl.Value = value;
                
        end
        
        
        function update_spinner_value( obj, objective, limits, value )
            
            sp = obj.spinners( objective );
            sp.Limits = limits;
            sp.Step = diff( limits ) ./ 100;
            sp.Value = value; 
            
        end
        
    end
    
    
    methods ( Access = private, Static )
        
        function update_widget_interactivity( ...
                active, ...
                enabled, ...
                check_box, ...
                slider, ...
                spinner ...
                )
            
            if active && enabled
                check_box.Enable = 'on';
                slider.Enable = 'on';
                spinner.Enable = 'on';
            elseif enabled
                check_box.Enable = 'on';
                slider.Enable = 'off';
                spinner.Enable = 'of';
            else
                check_box.Enable = 'off';
                slider.Enable = 'off';
                spinner.Enable = 'off';
            end 
            
        end
        
        
        function check_box = clone_check_box( ...
                check_box_base, ...
                parent, ...
                height_offset, ...
                objective ...
                )

            check_box = uicheckbox( parent );
            FeasibilityThresholdSelectionController.setup_clone( ...
                check_box_base, ...
                height_offset, ...
                objective, ...
                check_box ...
                );
            check_box.Value = 1;
            check_box.Text = objective;
            
        end
        
        
        function slider = clone_slider( ...
                slider_base, ...
                parent, ...
                height_offset, ...
                objective ...
                )
            
            slider = uislider( parent );
            FeasibilityThresholdSelectionController.setup_clone( ...
                slider_base, ...
                height_offset, ...
                objective, ...
                slider ...
                );
            slider.FontColor = parent.BackgroundColor;
            
        end
        
        
        function spinner = clone_spinner( ...
                spinner_base, ...
                parent, ...
                height_offset, ...
                objective ...
                )
            
            spinner = uispinner( parent );
            FeasibilityThresholdSelectionController.setup_clone( ...
                spinner_base, ...
                height_offset, ...
                objective, ...
                spinner ...
                );
            spinner.ValueDisplayFormat = spinner_base.ValueDisplayFormat;
            
        end
        
        
        function setup_clone( base, height_offset, objective, clone )
            
            clone.Position( 1 ) = base.Position( 1 );
            clone.Position( 2 ) = base.Position( 2 ) - height_offset;
            clone.Position( 3 ) = base.Position( 3 );
            clone.Tag = objective;
            clone.ValueChangedFcn = base.ValueChangedFcn;
            
        end
        
    end
    
end

