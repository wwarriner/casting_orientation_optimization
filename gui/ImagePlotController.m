classdef ImagePlotController < handle
    
    methods ( Access = public )
        
        function obj = ImagePlotController( ...
                image_ui_axes, ...
                orientation_data_model ...
                )
            
            obj.axes = image_ui_axes;
            obj.model = orientation_data_model;
            
        end
        
        
        function update_values( obj )
            
            obj.image.CData = obj.model.get_current_values();
            
        end
        
        
        function update_threshold_values( obj )
            
            obj.update_threshold_visibility();
            if obj.model.is_threshold_visible()
                values = obj.model.get_single_threshold_values();
                obj.threshold.CData = values;
                obj.threshold.AlphaData = obj.THRESHOLD_ALPHA .* values;
            end
            
        end
        
        
        function update_threshold_visibility( obj )
            
            if obj.model.is_threshold_visible()
                obj.threshold.Visible = 'on';
            else
                obj.threshold.Visible = 'off';
            end
            
        end
        
        
        function update_pareto_front( obj )
            
            if obj.model.is_pareto_front_visible()
                obj.pareto_front.Visible = 'on';
            else
                obj.pareto_front.Visible = 'off';
            end
            
        end
        
        
        function update_global_minimum( obj )
            
            if obj.model.is_global_minimum_visible()
                obj.global_minimum.Visible = 'on';
                point = obj.model.get_current_global_minimum_point();
                obj.global_minimum.XData = point.x;
                obj.global_minimum.YData = point.y;
            else
                obj.global_minimum.Visible = 'off';
            end
            
        end
        
        
        function update_clicked( obj )
            
            point = obj.get_axes_point();
            angles = [ point.x point.y ];
            obj.model.set_selected_point( angles );
            obj.selected_point.XData = point.x;
            obj.selected_point.YData = point.y;
            
        end
        
    end
    
    
    properties ( Access = private )
        
        axes
        image
        threshold
        pareto_front
        global_minimum
        selected_point
        model
        
    end
    
    
    properties ( Access = private )
        
        THRESHOLD_ALPHA = 0.25;
        
    end
    
    
    methods ( Access = private )
        
        function point = get_axes_point( obj )
            
            raw = obj.axes.CurrentPoint;
            point.x = raw( 1 );
            point.y = raw( 2 );
            
        end
        
    end
    
end

