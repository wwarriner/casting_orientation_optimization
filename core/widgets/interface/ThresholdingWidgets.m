classdef ThresholdingWidgets < handle
    
    properties ( Access = public, Constant )
        
        NO_THRESHOLD = 1;
        VALUE_THRESHOLD = 2;
        NO_GO_THRESHOLD = 3;
        COUNT = 3;
        
    end
    
    
    methods

        function obj = ThresholdingWidgets( ...
                figure_handle, ...
                corner_pos, ...
                x_padding, ...
                y_padding, ...
                font_size, ...
                default_id, ...
                value_picker_fns, ...
                labels, ...
                selection_changed_function ...
                )
            
            obj.selected_id = default_id;
            
            h = uibuttongroup();
            h.Title = 'Threshold Type';
            h.FontSize = font_size;
            h.BorderType = 'etchedin';
            h.BorderWidth = 1;
            h.Units = 'pixels';
            height = obj.COUNT * ( obj.get_height_each( font_size ) + y_padding ) + ...
                2 * y_padding + ...
                font_size;
            h.Position = [ ...
                corner_pos ...
                obj.get_width() ...
                height ...
                ];
            h.SelectionChangedFcn = selection_changed_function;
            h.Parent = figure_handle;
            
            obj.widget_handles = containers.Map( ...
                'keytype', 'double', ...
                'valuetype', 'any' ...
                );
            ids = obj.get_ids();
            for i = 1 : obj.COUNT
            
                id = ids{ i };
                y_pos = ( i - 1 ) * obj.get_height_each( font_size ) + ...
                    i * y_padding;
                value_picker_fn = value_picker_fns( id );
                obj.widget_handles( id ) = SimpleOption( ...
                    h, ...
                    id, ...
                    value_picker_fn, ...
                    x_padding, ...
                    y_pos, ...
                    font_size, ...
                    labels( id ) ...
                    );
                
            end
            obj.button_group_handle = h;
            %obj.panel_handle = panel_h;
            
        end
        
        
        function set_background_color( obj, color )
            
            obj.button_group_handle.BackgroundColor = color;
            ids = obj.widget_handles.keys();
            for i = 1 : obj.widget_handles.Count()
                
                id = ids{ i };
                h = obj.widget_handles( id );
                h.set_background_color( color );
                
            end
            
        end
        
        
        function select( obj, id )
            
            h = obj.widget_handles( obj.selected_id );
            h.select();
            obj.selected_id = id;
            
        end
        
        
        function values = pick_selected_values( obj )
            
            ids = obj.widget_handles.keys();
            for i = 1 : obj.widget_handles.Count()
                
                id = ids{ i };
                h = obj.widget_handles( id );
                if h.is_selected()
                    values = h.pick_values();
                end
                
            end
            
        end
        
        
        function set_position( obj, pos )
            
            %obj.panel_handle.Position = pos;
            obj.button_group_handle.Position = pos;
            
        end
        
        
        function pos = get_position( obj )
            
            pos = obj.button_group_handle.Position;
            
        end
        
        
        function height = get_height( obj )
            
            pos = obj.get_position();
            height = pos( 4 );
            
        end

    end
    
    
    methods ( Access = public, Static )
        
        function ids = get_ids()
            
            ids = { ...
                ThresholdingWidgets.NO_THRESHOLD, ...
                ThresholdingWidgets.VALUE_THRESHOLD, ...
                ThresholdingWidgets.NO_GO_THRESHOLD ...
                };
            assert( numel( ids ) == ThresholdingWidgets.COUNT );
            
        end
        
        
        function height = get_height_each( font_size )
            
            height = get_height( font_size );
            
        end
        
        
        function height = get_height_internal( count, padding, height_each )
            
            height = ( padding + height_each ) * ( count + 2 );
            
        end
        
        
        function width = get_width()
            
            width = ThresholdingOption.get_width();
            
        end
        
    end


    properties ( Access = private )

        panel_handle
        button_group_handle
        widget_handles
        
        selected_id

    end
    
    
    methods ( Access = private, Static )
        
        function y = get_y_pos( id, padding, height_each )
            
            y = ThresholdingWidgets.get_height_internal( id - 1, padding, height_each );
            
        end
        
    end

end

