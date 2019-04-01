classdef ThresholdSelectorWidget < handle
    
    properties ( Access = public, Constant )
        
        VALUE_MODE = 1;
        QUANTILE_MODE = 2;
        
    end
    
    
    methods ( Access = public )
        
        % TODO factor out commonality with ValueOption??
        function obj = ThresholdSelectorWidget( ...
                figure_handle, ...
                corner_pos, ...
                font_size, ...
                value_update_callback, ...
                check_box_update_callback, ...
                tag, ...
                title, ...
                value, ...
                value_range, ...
                value_usage_state, ...
                quantile ...
                )
            
            obj.tag = tag;
            obj.value = ConstrainedNumericValue( ...
                value_range.min, ...
                value_range.max, ...
                value ...
                );
            obj.value_range = value_range;
            obj.quantile = ConstrainedNumericValue( 0, 1, quantile );
            obj.mode = obj.VALUE_MODE;
            
            check_box_update_cb = @(h,e)check_box_update_callback(h,e,obj);
            check_box_position = [ ...
                corner_pos( 1 ) + obj.HORIZONTAL_PAD ...
                corner_pos( 2 ) ...
                obj.CHECK_BOX_WIDTH + obj.HORIZONTAL_PAD ...
                obj.get_height( font_size ) ...
                ];
            obj.check_box_handle = obj.create_check_box( ...
                figure_handle, ...
                check_box_position, ...
                value_usage_state, ...
                check_box_update_cb ...
                );
            
            title_position = [ ...
                check_box_position( 1 ) + check_box_position( 3 ) ...
                corner_pos( 2 ) ...
                obj.TITLE_WIDTH ...
                obj.get_height( font_size ) ...
                ];
            obj.static_text_handle = obj.create_title( ...
                figure_handle, ...
                title_position, ...
                font_size, ...
                title, ...
                @(h,e)obj.title_clicked_callback(h,e,check_box_update_cb) ...
                );
            
            value_update_cb = @(h,e)value_update_callback(h,e,obj);
            value_editor_position = [ ...
                title_position( 1 ) + title_position( 3 ) ...
                corner_pos( 2 ) ...
                obj.VALUE_EDITOR_WIDTH ...
                obj.get_height( font_size ) ...
                ];
            obj.edit_text_handle = obj.create_value_editor( ...
                figure_handle, ...
                value_editor_position, ...
                font_size, ...
                value, ...
                value_update_cb ...
                );
            
            slider_position = [ ...
                value_editor_position( 1 ) + value_editor_position( 3 ) ...
                corner_pos( 2 ) ...
                obj.SLIDER_WIDTH ...
                obj.get_height( font_size ) ...
                ];
            obj.slider_handle = obj.create_slider( ...
                figure_handle, ...
                slider_position, ...
                value, ...
                value_range, ...
                value_update_cb ...
                );
            
        end
        
        
        function changed = update_value( obj, style )
            
            new_value = obj.get_new_value( style );
            changed = obj.update_internal_value( new_value );
            obj.update_handle_values( new_value );
            
        end
        
        
        function switch_mode( obj, mode )
            
            obj.mode = mode;
            mode_value = obj.select_mode_value( obj.mode );
            obj.update_handle_values( mode_value.get_value() );
            obj.update_handle_ranges();
            
        end
        
        
        function using = is_using_quantiles( obj )
            
            using = obj.mode == obj.QUANTILE_MODE;
            
        end
        
        
        function value = get_value( obj )
            
            mode_value = obj.select_mode_value( obj.mode );
            value = mode_value.get_value();
            
        end
        
        
        function state = get_usage_state( obj )
            
            state = obj.check_box_handle.Value;
            
        end
        
        
        function tag = get_tag( obj )
            
            tag = obj.tag;
            
        end
        
        
        function set_background_color( obj, color )
            
            obj.check_box_handle.BackgroundColor = color;
            obj.static_text_handle.BackgroundColor = color;
            
        end
        
    end
    
    
    methods ( Access = public, Static )
        
        function width = get_width()
            
            width = ThresholdSelectorWidget.CHECK_BOX_WIDTH + ...
                2 * ThresholdSelectorWidget.HORIZONTAL_PAD + ...
                ThresholdSelectorWidget.TITLE_WIDTH + ...
                ThresholdSelectorWidget.VALUE_EDITOR_WIDTH + ...
                ThresholdSelectorWidget.SLIDER_WIDTH;
            
        end
        
        
        function height = get_height( font_size )
            
            height = get_height( font_size );
            
        end
        
    end
    
    
    properties ( Access = private )
        
        check_box_handle
        static_text_handle
        edit_text_handle
        slider_handle
        
        tag
        value
        value_range
        quantile
        mode
        
    end
    
    
    properties ( Access = private, Constant )
        
        CHECK_BOX_WIDTH = 30;
        TITLE_WIDTH = 250;
        VALUE_EDITOR_WIDTH = 100;
        SLIDER_WIDTH = 200;
        
        HORIZONTAL_PAD = 6;
        
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
        
        
        function changed = update_internal_value( obj, new_value )
            
            mode_value = obj.select_mode_value( obj.mode );
            changed = mode_value.update( new_value );
            
        end
        
        
        function update_handle_values( obj, new_value )
            
            obj.slider_handle.Value = new_value;
            obj.edit_text_handle.String = num2str( new_value );
            
        end
        
        
        function update_handle_ranges( obj )
            
            mode_value = obj.select_mode_value( obj.mode );
            obj.slider_handle.Min = mode_value.get_min();
            obj.slider_handle.Max = mode_value.get_max();
            
        end
        
        
        function value = select_mode_value( obj, mode )
            switch mode
                case obj.VALUE_MODE
                    value = obj.value;
                case obj.QUANTILE_MODE
                    value = obj.quantile;
                otherwise
                    assert( false );
            end
            
        end
        
        
        function title_clicked_callback( obj, h, e, check_box_update_callback )
            
            obj.check_box_handle.Value = ~obj.check_box_handle.Value;
            check_box_update_callback( h, e );
            
        end
        
    end
    
    
    methods ( Access = private, Static )
        
        function h = create_check_box( ...
                parent, ...
                position, ...
                state, ...
                callback ...
                )
            
            h = uicontrol();
            h.Style = 'checkbox';
            h.Value = state;
            h.Position = position;
            h.Callback = callback;
            h.Parent = parent;
            
        end
        
        
        function h = create_title( ...
                parent, ...
                position, ...
                font_size, ...
                text, ...
                callback ...
                )
            
            h = uicontrol();
            h.Style = 'text';
            h.String = text;
            h.FontSize = font_size;
            h.HorizontalAlignment = 'left';
            h.Enable = 'inactive'; % to make clicking work
            h.Position = position;
            h.ButtonDownFcn = callback;
            h.Parent = parent;
            
        end
        
        
        function h = create_value_editor( ...
                parent, ...
                position, ...
                font_size, ...
                value, ...
                callback ...
                )
            
            h = uicontrol();
            h.Style = 'edit';
            h.String = num2str( value );
            h.FontSize = font_size;
            h.Position = position;
            h.Callback = callback;
            h.Parent = parent;
            
        end
        
        
        function h = create_slider( ...
                parent, ...
                position, ...
                value, ...
                value_range, ...
                callback ...
                )
            
            h = uicontrol();
            h.Style = 'slider';
            h.Min = value_range.min;
            h.Max = value_range.max;
            h.Value = value;
            h.Position = position;
            h.Callback = callback;
            h.Parent = parent;
            
        end
        
    end
    
    
end

