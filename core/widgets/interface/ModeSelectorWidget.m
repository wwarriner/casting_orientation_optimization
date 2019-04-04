classdef ModeSelectorWidget < handle
    
    methods ( Access = public )
        
        function obj = ModeSelectorWidget( ...
                figure_handle, ...
                corner_pos, ...
                x_padding, ...
                y_padding, ...
                font_size, ...
                default_mode, ...
                mode_change_callback ...
                )
            
            h = uibuttongroup();
            h.Title = 'Data Mode';
            h.FontSize = font_size;
            h.BorderType = 'etchedin';
            h.BorderWidth = 1;
            h.Units = 'pixels';
            height = 2 * ( obj.get_height_each( font_size ) + y_padding ) + ...
                2 * y_padding + ...
                font_size;
            h.Position = [ ...
                corner_pos ...
                obj.WIDTH ...
                height ...
                ];
            h.SelectionChangedFcn = mode_change_callback;
            h.Parent = figure_handle;
            
            rbhs = containers.Map( ...
                'keytype', 'char', ...
                'valuetype', 'any' ...
                );
            tags = obj.get_tags();
            labels = obj.get_labels();
            assert( numel( tags ) == numel( labels ) );
            for i = 1 : obj.get_count()
                
                tag = tags{ i };
                label = labels( i );
                c = obj.get_count() - i + 1;
                y_pos = ( c - 1 ) * obj.get_height_each( font_size ) + ...
                    c * y_padding;
                rbh = uicontrol();
                rbh.Style = 'radiobutton';
                rbh.String = label;
                rbh.FontSize = font_size;
                rbh.Position = [ ...
                    x_padding ...
                    y_pos ...
                    obj.WIDTH ...
                    obj.get_height_each( font_size ) ...
                    ];
                rbh.Tag = tag;
                rbh.Parent = h;
                rbhs( tag ) = rbh;
                
            end
            
            for i = 1 : obj.get_count()
                
                rbh = rbhs( tags{ i } );
                if strcmpi( default_mode, tags{ i } )
                    rbh.Value = true;
                end
                
            end
            
            obj.button_group_handle = h;
            obj.radio_button_handles = rbhs;
            
        end
        
        
        function set_background_color( obj, color )
            
            obj.button_group_handle.BackgroundColor = color;
            ts = obj.get_tags();
            for i = 1 : obj.get_count()
                
                rbh = obj.radio_button_handles( ts{ i } );
                rbh.BackgroundColor = color;
                
            end
            
        end
        
        
        function pos = get_position( obj )
            
            pos = obj.button_group_handle.Position;
            
        end
        
        
        function height = get_height( obj )
            
            pos = obj.get_position();
            height = pos( 4 );
            
        end
        
        
        function set_position( obj, pos )
            
            obj.button_group_handle.Position = pos;
            
        end
        
    end
    
    
    properties ( Access = private )
        
        button_group_handle
        radio_button_handles
        data_filter
        
    end
    
    
    properties ( Access = private, Constant )
        
        WIDTH = 150
        
    end
    
    
    methods ( Access = private, Static )
        
        function height = get_height_each( font_size )
            
            height = get_height( font_size );
            
        end
        
        
        function count = get_count()
            
            count = numel( DataFilter.get_modes() );
            
        end
        
        
        function tags = get_tags()
            
            tags = DataFilter.get_modes();
            
        end
        
        
        function labels = get_labels()
            
            labels = { ...
                'Values' ...
                'Quantiles' ...
                };
            
        end
        
    end
    
end

