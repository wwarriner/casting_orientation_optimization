classdef ThresholdValueSelectorWidget < handle
    
    methods ( Access = public )
        
        function obj = ThresholdValueSelectorWidget( ...
                figure_handle, ...
                corner_pos, ...
                x_padding, ...
                y_padding, ...
                font_size, ...
                data_filter, ...
                value_change_callback, ...
                check_box_callback ...
                )
            
            h = uipanel();
            h.Title = 'Thresholds';
            h.FontSize = font_size;
            h.BorderType = 'etchedin';
            h.BorderWidth = 1;
            h.Units = 'pixels';
            height = data_filter.get_count() * ( obj.get_height_each( font_size ) + y_padding ) + ...
                2 * y_padding + ...
                font_size;
            h.Position = [ ...
                corner_pos ...
                obj.WIDTH ...
                height ...
                ];
            h.Parent = figure_handle;
            
            tvws = containers.Map( ...
                'keytype', 'char', ...
                'valuetype', 'any' ...
                );
            tags = data_filter.get_tags();
            labels = data_filter.get_titles();
            assert( numel( tags ) == labels.Count() );
            for i = 1 : data_filter.get_count()
            
                tag = tags{ i };
                label = labels( tag );
                c = data_filter.get_count() - i + 1;
                y_pos = ( c - 1 ) * obj.get_height_each( font_size ) + ...
                    c * y_padding;
                tvw = ThresholdValueWidget( ...
                    h, ...
                    x_padding, ...
                    y_pos, ...
                    font_size, ...
                    tag, ...
                    label, ...
                    data_filter.get_threshold( tag ), ...
                    data_filter.get_usage_state( tag ), ...
                    value_change_callback, ...
                    check_box_callback ...
                    );
                tvws( tag ) = tvw;
                
            end
            
            obj.panel_handle = h;
            obj.threshold_value_widgets = tvws;
            obj.data_filter = data_filter;
            
        end
        
        
        function update( obj  )
            
            tags = obj.get_tags();
            for i = 1 : obj.get_count()
                
                tag = tags{ i };
                tvw = obj.threshold_value_widgets( tag );
                v = obj.data_filter.get_threshold( tag );
                tvw.change_constrained_value( v );
                
            end
            
        end
        
        
        function set_background_color( obj, color )
            
            obj.panel_handle.BackgroundColor = color;
            ts = obj.get_tags();
            for i = 1 : obj.get_count()
                
                tvw = obj.threshold_value_widgets( ts{ i } );
                tvw.set_background_color( color );
                
            end
            
        end
        
        
        function pos = get_position( obj )
            
            pos = obj.panel_handle.Position;
            
        end
        
        
        function height = get_height( obj )
            
            pos = obj.get_position();
            height = pos( 4 );
            
        end
        
        
        function set_position( obj, pos )
            
            obj.panel_handle.Position = pos;
            
        end
        
    end
    
    
    properties ( Access = private )
        
        panel_handle
        threshold_value_widgets
        data_filter
        
    end
    
    
    properties ( Access = private, Constant )
        
        WIDTH = 150
        
    end
    
    
    methods ( Access = private )
        
        function count = get_count( obj )
            
            count = obj.data_filter.get_count();
            
        end
        
        
        function tags = get_tags( obj )
            
            tags = obj.data_filter.get_tags();
            
        end
        
    end
    
    
    methods ( Access = private, Static )
        
        function height = get_height_each( font_size )
            
            height = get_height( font_size );
            
        end
        
    end
    
end

