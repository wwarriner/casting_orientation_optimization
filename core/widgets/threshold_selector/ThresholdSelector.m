classdef ThresholdSelector < handle
    
    methods ( Access = public )
        
        function obj = ThresholdSelector( ...
                mode_change_callback, ...
                value_callback, ...
                titles, ...
                value_ranges, ...
                data_filter ...
                )
            
            count = titles.Count();
            tags = titles.keys();
            
            values = containers.Map( ...
                'keytype', 'char', ...
                'valuetype', 'any' ...
                );
            quantiles = containers.Map( ...
                'keytype', 'char', ...
                'valuetype', 'any' ...
                );
            for i = 1 : count
                
                tag = tags{ i };
                range = value_ranges( tag );
                values( tag ) = ConstrainedNumericValue( ...
                    range.min, ...
                    range.max, ...
                    mean( [ range.min range.max ] )...
                    );
                quantiles( tag ) = ConstrainedNumericValue( 0, 1, 0.5 );
                
            end
            
            obj.titles = titles;
            obj.mode_change_callback;
            obj.value_callback = value_callback;
            obj.data_filter = data_filter;
            
        end
        
        
        function h = draw( obj )
            
            count = obj.titles.Count();
            
            % create figure
            h = figure();
            h.Name = sprintf( 'Go/No-Go Threshold Selections' );
            h.NumberTitle = 'off';
            height_each = ...
                ThresholdSelectorWidget.get_height( obj.FONT_SIZE ) + ...
                obj.VERTICAL_PAD;
            height = ...
                height_each + ...
                obj.VERTICAL_PAD + ...
                count * height_each + ...
                obj.VERTICAL_PAD;
            h.Position = [ ...
                25 ...
                25 ...
                ThresholdSelectorWidget.get_width() + obj.HORIZONTAL_PAD ...
                height ...
                ];
            h.MenuBar = 'none';
            h.ToolBar = 'none';
            h.DockControls = 'off';
            h.Resize = 'off';
            h.CloseRequestFcn = @obj.on_close;
            movegui( h, 'center' );
            
            % populate panel with subwidgets
            tags = obj.titles.keys();
            wh = containers.Map( ...
                'keytype', 'char', ...
                'valuetype', 'any' ...
                );
            for i = 1 : count
                
                tag = tags{ i };
                title = obj.titles( tag );
                value = obj.data_filter.get_threshold( tag );
                value_usage_state = obj.data_filter.get_usage_state( tag );
                y_pos = h.Position( 4 ) - ...
                    ( ThresholdSelectorWidget.get_height( obj.FONT_SIZE ) + ...
                    obj.VERTICAL_PAD ) * ( i + 1 );
                corner_pos = [ 0 y_pos ];
                wh( tag ) = ThresholdSelectorWidget( ...
                    h, ...
                    corner_pos, ...
                    obj.FONT_SIZE, ...
                    @obj.widget_value_callback, ...
                    @obj.widget_check_box_callback, ...
                    tag, ...
                    title, ...
                    value, ...
                    value_usage_state ...
                    );
                
            end
            
            % mode selector
            mode_selector_position = [ ...
                0 ...
                h.Position( 2 ) - height_each ...
                h.Position( 3 ) ...
                height_each ...
                ];
            obj.mode_selector = obj.create_mode_selector( ...
                h, ...
                mode_selector_position, ...
                obj.FONT_SIZE, ...
                @obj.mode_selection_callback ...
                );
            
            obj.figure_handle = h;
            obj.subwidgets = wh;
            
        end
        
        
        function set_background_color( obj, color )
            
            if ~isempty( obj.figure_handle )
                obj.figure_handle.Color = color;
                count = obj.titles.Count();
                tags = obj.titles.keys();
                for i = 1 : count
                    
                    tag = tags{ i };
                    wh = obj.subwidgets( tag );
                    wh.set_background_color( color );
                    
                end
                obj.mode_selector.BackgroundColor = color;
                
            end
            
        end
        
        
        function close( obj )
            
            close( obj.figure_handle, 'force' );
            
        end
        
    end
    
    
    properties ( Access = private )
        
        value_callback
        titles
        data_filter
        
        figure_handle
        mode_selector
        subwidgets
        
    end
    
    
    properties ( Access = private, Constant )
        
        VALUE_TAG = 'value';
        QUANTILE_TAG = 'quantile';
        
        % TODO factor these out
        VERTICAL_PAD = 6;
        HORIZONTAL_PAD = 6;
        HEIGHT = 23;
        
        FONT_SIZE = 10;
        
    end
    
    
    methods ( Access = private )
        
        function on_close( obj, ~, ~ )
            
%             obj.figure_handle = [];
%             obj.subwidgets = [];
%             closereq();
            
        end
        
        
        function widget_check_box_callback( obj, h, e, widget )
            
            obj.data_filter.set_usage_state( ...
                widget.get_tag(), ...
                widget.get_usage_state() ...
                );
            obj.value_callback( h, e );
            
        end
        
        
        function widget_value_callback( obj, h, e, widget )
            
            if widget.update_value( h.Style )
                obj.data_filter.set_threshold( ...
                    widget.get_tag(), ...
                    widget.get_value() ...
                    );
                obj.value_callback( h, e );
            end
            
        end
        
        
        function mode_selection_callback( obj, h, e )
            
            obj.data_filter.set_mode( e.NewValue.Tag );
            
            count = obj.titles.Count();
            tags = obj.titles.keys();
            for i = 1 : count
                
                tag = tags{ i };
                wh = obj.subwidgets( tag );
                v = obj.data_filter.get_threshold( tag );
                wh.change_constrained_value( v );
                
            end
            obj.mode_changed_callback( h, e );
            
        end
        
    end
    
    
    % construction
    methods ( Access = private, Static )
        
        function group_h = create_mode_selector( ...
                parent, ...
                position, ...
                font_size, ...
                selection_changed_function ...
                )
            
            group_h = uibuttongroup();
            group_h.Units = 'pixels';
            group_h.Position = position;
            group_h.BorderType = 'none';
            group_h.SelectionChangedFcn = selection_changed_function;
            group_h.Parent = parent;
            
            WIDTH = 120;
            center = group_h.Position( 1 ) + ...
                floor( group_h.Position( 3 ) / 2 );
            
            values_h = uicontrol();
            values_h.Style = 'radiobutton';
            values_h.Position = [ ...
                center - WIDTH ...
                -ThresholdSelector.VERTICAL_PAD ...
                WIDTH ...
                group_h.Position( 4 ) ...
                ];
            values_h.String = 'Values';
            values_h.FontSize = font_size;
            values_h.Tag = DataFilter.VALUE_MODE;
            values_h.Parent = group_h;
            values_h.Value = true;
            
            quantiles_h = uicontrol();
            quantiles_h.Style = 'radiobutton';
            quantiles_h.Position = [ ...
                center ...
                -ThresholdSelector.VERTICAL_PAD ...
                WIDTH ...
                group_h.Position( 4 ) ...
                ];
            quantiles_h.String = 'Quantiles';
            quantiles_h.FontSize = font_size;
            quantiles_h.Tag = DataFilter.QUANTILE_MODE;
            quantiles_h.Parent = group_h;
            
        end
        
    end
    
end

