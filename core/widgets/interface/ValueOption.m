classdef ValueOption < ThresholdingOption
    
    methods ( Access = public )
        
        function obj = ValueOption( ...
                button_group_handle, ...
                id, ...
                value_picker_fn, ...
                y_pos, ...
                font_size, ...
                label, ...
                data_filter, ...
                value_changed_callback ...
                )
            
            obj = obj@ThresholdingOption( ...
                button_group_handle, ...
                id, ...
                value_picker_fn, ...
                y_pos, ...
                font_size, ...
                label ...
                );
            DEFAULT_VALUE = 0.5;
            obj.edit_text_handle = obj.prepare_edit_text( ...
                button_group_handle, ...
                y_pos, ...
                font_size, ...
                DEFAULT_VALUE, ...
                @(h,e)value_changed_callback(h,e,obj) ...
                );
            DEFAULT_MIN = 0;
            DEFAULT_MAX = 1;
            obj.slider_handle = obj.prepare_slider( ...
                button_group_handle, ...
                y_pos, ...
                font_size, ...
                DEFAULT_MIN, ...
                DEFAULT_MAX, ...
                DEFAULT_VALUE, ...
                @(h,e)value_changed_callback(h,e,obj) ...
                );
            obj.data_filter = data_filter;
            
        end
        
        
        function set_background_color( obj, color )
            
            obj.set_background_color@ThresholdingOption( color );
            obj.edit_text_handle.BackgroundColor = color;
            
        end
        
        
        function set_threshold_value( obj, tag )
            
            obj.update_handle_values( obj.get_threshold( tag ) );
            
        end
        
        
        function changed = update_threshold_value( obj, style, tag )
            
            new_value = obj.get_new_value( style );
            changed = new_value ~= obj.get_threshold( tag );
            obj.data_filter.set_threshold( tag, new_value );
            obj.update_handle_values( obj.data_filter.get_threshold( tag ) );
            
        end
        
    end
    
    
    methods ( Access = public, Static )
        
        function type = get_type()
            
            type = 'value';
            
        end
        
    end
    
    
    methods ( Access = protected )
        
        function update_handle_values( obj, value )
            
            obj.slider_handle.Min = value.get_min();
            obj.slider_handle.Max = value.get_max();
            obj.slider_handle.Value = value.get_value();
            obj.edit_text_handle.String = num2str( value.get_value() );
            
        end
        
    end
    
    
    properties ( Access = private )
        
        edit_text_handle
        slider_handle
        data_filter
        
    end
    
    
    methods ( Access = private )
        
        function value = get_new_value( obj, style )
            
            if strcmpi( style, 'edit' )
                value = str2double( obj.edit_text_handle.String );
            elseif strcmpi( style, 'slider' )
                value = obj.slider_handle.Value;
            else
                assert( false )
            end
            
        end
        
        
        function value = get_threshold( obj, tag )
            
            value = obj.data_filter.get_threshold( tag );
            
        end
        
    end
    
    
    % construction
    methods ( Access = private, Static )
        
        function h = prepare_edit_text( ...
                button_group_handle, ...
                y_pos, ...
                font_size, ...
                default_threshold_value, ...
                edit_text_callback ...
                )
            
            h = uicontrol();
            h.Style = 'edit';
            h.String = num2str( default_threshold_value );
            h.FontSize = font_size;
            h.Position = [ ...
                ThresholdingOption.get_edit_text_x_pos() ...
                y_pos ...
                ThresholdingOption.EDIT_TEXT_WIDTH ...
                get_height( font_size ) ...
                ];
            h.Parent = button_group_handle;
            h.Callback = edit_text_callback;
            
        end
        
        
        function h = prepare_slider( ...
                button_group_handle, ...
                y_pos, ...
                font_size, ...
                default_min, ...
                default_max, ...
                default_threshold_value, ...
                slider_callback ...
                )
            
            h = uicontrol();
            h.Style = 'slider';
            h.Min = default_min;
            h.Max = default_max;
            h.Value = default_threshold_value;
            h.Position = [ ...
                ThresholdingOption.get_slider_x_pos() ...
                y_pos ...
                ThresholdingOption.SLIDER_WIDTH ...
                get_height( font_size ) ...
                ];
            h.Parent = button_group_handle;
            h.Callback = slider_callback;
            
        end
        
    end
    
end

