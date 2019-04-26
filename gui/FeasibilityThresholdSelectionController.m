classdef FeasibilityThresholdSelectionController < handle
    
    methods ( Access = public )
        
        function obj = FeasibilityThresholdSelectionController( ...
                check_boxes, ...
                sliders, ...
                spinners, ...
                orientation_data_model ...
                )
            
            obj.check_boxes = check_boxes;
            obj.sliders = sliders;
            obj.spinners = spinners;
            obj.model = orientation_data_model;
            
        end
        
        
        function update_from_external( obj )
            
            % get threshold data from model
            % update all sliders
            % update all spinners
            
        end
        
        
        function update_from_checkbox( obj )
            
            % update model feasibility state
            
        end
        
        
        function update_from_slider( obj )
            
            % get objective
            % get threshold value from slider
            % update spinner
            % update model
            
        end
        
        
        function update_from_spinner( obj )
            
            % get objective
            % get threshold value from spinner
            % update slider
            % update model
            
        end
        
    end
    
    
    properties ( Access = private )
        
        model
        
    end
    
    
    methods ( Access = private )
        
        function objective = get_objective( obj )
            
            
            
        end
        
    end
    
end

