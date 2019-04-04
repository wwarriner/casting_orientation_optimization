classdef ThresholdingOption < handle
    
    properties ( GetAccess = public, SetAccess = private )
        
        id
        
    end
    
    
    methods ( Access = public )
        
        function obj = ThresholdingOption( ...
                button_group_handle, ...
                id, ...
                value_picker_fn, ...
                x_padding, ...
                y_pos, ...
                font_size, ...
                label ...
                )
            
            obj.button_group_handle = button_group_handle;
            obj.id = id;
            obj.value_picker_fn = value_picker_fn;
            obj.radio_button_handle = obj.prepare_radio_button( ...
                button_group_handle, ...
                x_padding, ...
                y_pos, ...
                font_size, ...
                label ...
                );
            
        end
        
        
        function set_background_color( obj, color )
            
            obj.radio_button_handle.BackgroundColor = color;
            
        end
        
        
        function select( obj )
            
            obj.radio_button_handle.Value = 1;
            
        end
        
        
        function selected = is_selected( obj )
            
            selected = obj.radio_button_handle.Value == 1;
            
        end
        
        
        function values = pick_values( obj )
            
            threshold = obj.get_threshold_value();
            values = obj.value_picker_fn( threshold );
            
        end
        
        
        % override me
        function value = get_threshold_value( ~ )
            
            value = 0.5;
            
        end
        
    end
    
    
    methods ( Access = public, Static )
        
        function width = get_width()
            
            width = ThresholdingOption.RADIO_BUTTON_WIDTH + ...
                ThresholdingOption.EDIT_TEXT_WIDTH + ...
                ThresholdingOption.SLIDER_WIDTH;
            
        end
        
    end
    
    
    properties ( Access = protected, Constant )
        
        RADIO_BUTTON_WIDTH = 200;
        EDIT_TEXT_WIDTH = 120;
        SLIDER_WIDTH = 300;
        
    end
    
    
    methods ( Access = protected, Static )
        
        function x = get_edit_text_x_pos()
            
            x = ThresholdingOption.RADIO_BUTTON_X_POS + ...
                ThresholdingOption.RADIO_BUTTON_WIDTH;
            
        end
        
        
        function x = get_slider_x_pos()
            
            x = ThresholdingOption.get_edit_text_x_pos() + ...
                ThresholdingOption.EDIT_TEXT_WIDTH;
            
        end
        
    end
    
    
    properties ( Access = private )
        
        button_group_handle
        value_picker_fn
        
        radio_button_handle
        
    end
    
    
    % construction
    methods ( Access = private )
        
        function h = prepare_radio_button( ...
                obj, ...
                button_group_handle, ...
                x_padding, ...
                y_pos, ...
                font_size, ...
                label ...
                )
            
            h = uicontrol();
            h.Style = 'radiobutton';
            h.String = label;
            h.FontSize = font_size;
            h.Position = [ ...
                x_padding ...
                y_pos ...
                obj.RADIO_BUTTON_WIDTH ...
                get_height( font_size ) ...
                ];
            h.Parent = button_group_handle;
            
        end
        
    end
    
end

