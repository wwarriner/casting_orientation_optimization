classdef ObjectivePickerWidget < handle
    
    methods ( Access = public )
        
        function obj = ObjectivePickerWidget( ...
                figure_handle, ...
                corner_pos, ...
                font_size, ...
                titles, ...
                initial_index, ...
                list_box_callback ...
                )
            
            count = titles.Count();
            tags = titles.keys();
            index_to_tag = containers.Map( ...
                'keytype', 'double', ...
                'valuetype', 'char' ...
                );
            for i = 1 : count
                
                index_to_tag( i ) = tags{ i };
                
            end
            
            popup_content = cell( count, 1 );
            for i = 1 : count
                
                popup_content{ i } = titles( index_to_tag( i ) );
                
            end
            
            h = uicontrol();
            h.Style = 'popupmenu';
            h.String = popup_content;
            h.Value = initial_index;
            h.FontSize = font_size;
            h.Position = [ ...
                corner_pos, ...
                obj.get_width() ...
                obj.get_height( font_size ) ...
                ];
            h.Callback = @(h,e)list_box_callback(h,e,obj);
            h.Parent = figure_handle;
            
            obj.index_to_tag = index_to_tag;
            obj.list_box_handle = h;
            obj.selected_index = initial_index;
            
        end
        
        
        function changed = update_selection( obj )
            
            new_value = obj.list_box_handle.Value;
            changed = obj.update_selected_index( new_value );
            
        end
        
        
        function tag = get_selected_tag( obj )
            
            tag = obj.index_to_tag( obj.selected_index );
            
        end
        
        
        function pos = get_position( obj )
            
            pos = obj.list_box_handle.Position;
            
        end
        
    end
    
    
    methods ( Access = public, Static )
        
        function height = get_height( font_size )
            
            height = get_height( font_size );
            
        end
        
        
        function width = get_width()
            
            width = ObjectivePickerWidget.WIDTH;
            
        end
        
    end
    
    
    properties ( Access = public )
        
        index_to_tag
        list_box_handle
        selected_index
        
    end
    
    
    properties ( Access = private, Constant )
        
        WIDTH = 300;
        
    end
    
    
    methods ( Access = private )
        
        function changed = update_selected_index( obj, new_value )
            
            changed = obj.has_selected_index_changed( new_value );
            obj.update_handle_selected_index( new_value );
            
        end
        
        
        function changed = has_selected_index_changed( obj, new_value )
            
            changed = obj.selected_index ~= new_value;
            
        end
        
        
        function update_handle_selected_index( obj, new_value )
            
            obj.list_box_handle.Value = new_value;
            obj.selected_index = new_value;
            
        end
        
    end
    
end

