classdef ValueSelectorWidget < handle
    
    methods ( Access = public )
        
        function obj = ValueSelectorWidget( ...
                figure_handle, ...
                corner_pos, ...
                font_size, ...
                value_update_callback, ...
                title, ...
                value, ...
                value_range ...
                )
            
            obj.value = ConstrainedNumericValue( ...
                value_range.min, ...
                value_range.max, ...
                value ...
                );
            obj.value_range = value_range;
            title_position = [ ...
                corner_pos, ...
                obj.TITLE_WIDTH ...
                obj.get_height( font_size ) ...
                ];
            obj.static_text_handle = obj.create_title( ...
                figure_handle, ...
                title_position, ...
                title ...
                );
            
            value_editor_position = [ ...
                corner_pos( 1 ) + obj.TITLE_WIDTH ...
                corner_pos( 2 ) ...
                obj.VALUE_EDITOR_WIDTH ...
                obj.get_height( font_size ) ...
                ];
            obj.edit_text_handle = obj.create_value_editor( ...
                figure_handle, ...
                value_editor_position, ...
                value, ...
                @(h,e)value_update_callback(h,e,obj) ...
                );
            
        end
        
        
        function set_range( obj, range )
            
            obj.threshold_value.set_range( range.min, range.max );
            obj.update_value( obj.threshold_value.get_value() );
            
        end
        
        
        function changed = update_value( obj )
            
            new_value = str2double( obj.edit_text_handle.String );
            changed = obj.value.update( new_value );
            
        end
        
        
        function value = get_value( obj )
            
            value = obj.value;
            
        end
        
        
        function set_background_color( obj, color )
            
            obj.static_text_handle.BackgroundColor = color;
            
        end
        
    end
    
    
    methods ( Access = public, Static )
        
        function width = get_width()
            
            width = ValueSelectorWidget.TITLE_WIDTH + ...
                ValueSelectorWidget.VALUE_EDITOR_WIDTH;
            
        end
        
        
        function height = get_height( font_size )
            
            height = get_height( font_size );
            
        end
        
    end
    
    
    properties ( Access = private )
        
        static_text_handle
        edit_text_handle
        
        value
        value_range
        
    end
    
    
    properties ( Access = private, Constant )
        
        TITLE_WIDTH = 200;
        VALUE_EDITOR_WIDTH = 100;
        
    end
    
    
    methods ( Access = private, Static )
        
        function h = create_title( parent, position, text )
            
            h = uicontrol();
            h.Style = 'text';
            h.String = text;
            h.Position = position;
            h.Parent = parent;
            
        end
        
        
        function h = create_value_editor( parent, position, value, callback )
            
            h = uicontrol();
            h.Style = 'edit';
            h.String = num2str( value );
            h.Position = position;
            h.Callback = callback;
            h.Parent = parent;
            
        end
        
    end
    
    
end

