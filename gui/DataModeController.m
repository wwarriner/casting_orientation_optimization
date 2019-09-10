classdef DataModeController < handle
    
    methods ( Access = public )
        function obj = DataModeController( ...
                button_group, ...
                orientation_data_model ...
                )
            obj.button_group = button_group;
            obj.model = orientation_data_model;
        end
        
        function update( obj )
            obj.model.mode = obj.get_selected_tag();
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

