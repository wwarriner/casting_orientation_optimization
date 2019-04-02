classdef ThresholdSelector < handle
    
    methods ( Access = public )
        
        function obj = ThresholdSelector( ...
                value_callback, ...
                titles, ...
                value_ranges ...
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
            obj.value_callback = value_callback;
            
            obj.values = values;
            obj.quantiles = quantiles;
            obj.usage_states = containers.Map( tags, true( count, 1 ) );
            obj.mode = obj.VALUE_TAG;
            
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
            v = obj.get_values();
            for i = 1 : count
                
                tag = tags{ i };
                title = obj.titles( tag );
                value = v( tag );
                value_usage_state = obj.usage_states( tag );
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
                @obj.mode_selection_callback, ...
                obj.mode ...
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
        
        
        function values = get_thresholds( obj )
            
            v = obj.get_values();
            tags = v.keys();
            values = containers.Map( ...
                'keytype', 'char', ...
                'valuetype', 'double' ...
                );
            for i = 1 : v.Count()
                
                values( tags{ i } ) = v( tags{ i } ).get_value();
                
            end
            
        end
        
        
        function states = get_usage_states( obj )
            
            states = obj.usage_states;
            
        end
        
        
        function using = is_using_quantiles( obj )
            
            using = strcmpi( obj.get_mode(), obj.QUANTILE_TAG );
            
        end
        
        
        function mode = get_mode( obj )
            
            mode = obj.mode;
            
        end
        
    end
    
    
    properties ( Access = private )
        
        value_callback
        titles
        values
        quantiles
        usage_states
        
        figure_handle
        mode_selector
        mode
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
            
            obj.figure_handle = [];
            obj.subwidgets = [];
            closereq();
            
        end
        
        
        function widget_check_box_callback( obj, h, e, widget )
            
            obj.usage_states( widget.get_tag() ) = widget.get_usage_state();
            obj.value_callback( h, e );
            
        end
        
        
        function widget_value_callback( obj, h, e, widget )
            
            if widget.update_value( h.Style )
                v = obj.values( widget.get_tag() );
                v.update( widget.get_value() );
                obj.value_callback( h, e );
            end
            
        end
        
        
        function mode_selection_callback( obj, h, e )
            
            obj.mode = e.NewValue.Tag;
            
            count = obj.titles.Count();
            tags = obj.titles.keys();
            v = obj.get_values();
            for i = 1 : count
                
                tag = tags{ i };
                wh = obj.subwidgets( tag );
                wh.change_constrained_value( v( tag ) );
                
            end
            obj.value_callback( h, e );
            
        end
        
        
        function values = get_values( obj )
            
            switch obj.get_mode()
                case obj.VALUE_TAG
                    values = obj.values;
                case obj.QUANTILE_TAG
                    values = obj.quantiles;
                otherwise
                    assert( false );
            end
            
        end
        
    end
    
    
    % construction
    methods ( Access = private, Static )
        
        function group_h = create_mode_selector( ...
                parent, ...
                position, ...
                font_size, ...
                selection_changed_function, ...
                current_mode ...
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
            values_h.Tag = ThresholdSelector.VALUE_TAG;
            values_h.Parent = group_h;
            
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
            quantiles_h.Tag = ThresholdSelector.QUANTILE_TAG;
            quantiles_h.Parent = group_h;
            
            switch current_mode
                case ThresholdSelector.VALUE_TAG
                    values_h.Value = 1;
                case ThresholdSelector.QUANTILE_TAG
                    quantiles_h.Value = 1;
                otherwise
                    assert( false )
            end
            
        end
        
    end
    
end

