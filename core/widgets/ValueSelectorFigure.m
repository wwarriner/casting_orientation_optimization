classdef ValueSelectorFigure < handle
    
    methods ( Access = public )
        
        function obj = ValueSelectorFigure( ...
                config_file_path, ...
                update_callback, ...
                titles, ...
                values, ...
                value_ranges ...
                )
            
            % todo read these from config_file_path
            tags = { ...
                'uc_count' ...
                'pp_projected_area_reciprocal' ...
                'pp_flatness' ...
                'pp_draw' ...
                'wf_worst_drop_max' ...
                'flask_height' ...
                };
            
            % create figure
            h = figure();
            h.Name = sprintf( 'Go/No-Go Threshold Selections' );
            h.NumberTitle = 'off';
            height_each = ...
                ValueSelectorWidget.get_height( obj.FONT_SIZE ) + ...
                obj.VERTICAL_PAD;
            height = ...
                numel( tags ) * height_each + ...
                obj.VERTICAL_PAD;
            h.Position = [ ...
                25 ...
                25 ...
                ValueSelectorWidget.get_width() + obj.X_BUFFER ...
                height ...
                ];
            h.MenuBar = 'none';
            h.ToolBar = 'none';
            h.DockControls = 'off';
            h.Resize = 'off';
            movegui( h, 'center' );
            
            % create scrollable panel
%             ph = uipanel();
%             ph.BorderType = 'none';
%             ph.Scrollable = 'on';
%             ph.Parent = h;
            
            % populate panel with subwidgets
            obj.subwidgets = containers.Map( ...
                'keytype', 'char', ...
                'valuetype', 'any' ...
                );
            for i = 1 : numel( tags )
                
                tag = tags{ i };
                title = titles( tag );
                value = values( tag );
                value_range = value_ranges( tag );
                y_pos = h.Position( 4 ) - ...
                    ( ValueSelectorWidget.get_height( obj.FONT_SIZE ) + ...
                    obj.VERTICAL_PAD ) * i;
                corner_pos = [ 0 y_pos ];
                obj.subwidgets( tag ) = ValueSelectorWidget( ...
                    h, ...
                    corner_pos, ...
                    obj.FONT_SIZE, ...
                    update_callback, ...
                    title, ...
                    value, ...
                    value_range ...
                    );
                
            end
            obj.figure_handle = h;
            
        end
        
        
        function set_background_color( obj, color )
            
            obj.figure_handle.BackgroundColor = color;
            for i = 1 : numel( obj.subwidgets )
                
                obj.subwidgets.set_background_color( color );
                
            end
            
        end
        
    end
    
    
    properties ( Access = private )
        
        figure_handle
        subwidgets
        
    end
    
    
    properties ( Access = private, Constant )
        
        X_BUFFER = 25;
        
        % TODO factor these out
        VERTICAL_PAD = 6;
        HORIZONTAL_PAD = 6;
        HEIGHT = 23;
        
        FONT_SIZE = 10;
        
    end
        
end

