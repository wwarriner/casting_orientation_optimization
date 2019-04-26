classdef DataModeController < handle
    
    properties ( Access = public, Constant )
        
        values = 'values';
        quantiles = 'quantiles';
        
    end
    
    
    methods ( Access = public )
        
        function obj = DataModeController( ...
                button_group, ...
                orientation_data_model ...
                )
            
            obj.button_group = button_group;
            obj.model = orientation_data_model;
            
        end
        
        
        function update( obj )
            
            switch obj.get_selected_tag()
                case obj.values
                    obj.model.switch_to_value_mode();
                case obj.quantiles
                    obj.model.switch_to_quantile_mode();
                otherwise
                    assert( false );
            end
            
        end
        
    end
    
    
    properties ( Access = private )
        
        button_group
        model
        
    end
    
    
    methods ( Access = private )
        
        function tag = get_selected_tag( obj )
            
            tag = obj.button_group.SelectedObject.Tag;
            
        end
        
    end
    
end

