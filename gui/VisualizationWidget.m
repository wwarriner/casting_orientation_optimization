classdef VisualizationWidget < handle
    
    methods ( Access = public )
        
        function obj = VisualizationWidget( ...
                figure_handle, ...
                corner_pos, ...
                font_size, ...
                button_callback, ...
                visualization_generator ...
                )
            
            h = uicontrol();
            h.Style = 'pushbutton';
            h.String = 'Visualize Picked Point...';
            h.FontSize = font_size;
            h.Position = [ ...
                corner_pos ...
                obj.get_width() ...
                obj.get_height( font_size ) ...
                ];
            h.Callback = button_callback;
            h.Parent = figure_handle;
            
            obj.button_handle = h;
            obj.visualization_generator = visualization_generator;
            
        end
        
        
        function figure_handle = generate_visualization( obj, angles )
            
            figure_handle = figure();
            [ PHI_INDEX, THETA_INDEX ] = unit_sphere_plot_indices();
            figure_handle.Name = sprintf( ...
                'Visualization with @X: %.2f and @Y: %.2f', ...
                rad2deg( angles( PHI_INDEX ) ), ...
                rad2deg( angles( THETA_INDEX ) ) ...
                );
            figure_handle.NumberTitle = 'off';
            figure_handle.MenuBar = 'none';
            figure_handle.ToolBar = 'none';
            figure_handle.DockControls = 'off';
            figure_handle.Resize = 'off';
            cameratoolbar( figure_handle, 'show' );
            
            axh = axes( figure_handle );
            axh.Color = 'none';
            hold( axh, 'on' );
            
            obj.visualization_generator.draw( axh, angles );
            
            view( 3 );
            light( axh, 'Position', [ 0 0 -1 ] );
            light( axh, 'Position', [ 0 0 1 ] );
            
            axis( axh, 'equal', 'vis3d', 'off' );
            
        end
        
        
        function pos = get_position( obj )
            
            pos = obj.button_handle.Position;
            
        end
        
    end
    
    
    methods ( Access = public, Static )
        
        function height = get_height( font_size )
            
            height = get_height( font_size );
            
        end
        
        
        function width = get_width()
            
            width = VisualizationWidget.WIDTH;
            
        end
        
    end
    
    
    properties ( Access = private )
        
        button_handle
        visualization_generator
        
    end
    
    
    properties ( Access = private, Constant )
        
        WIDTH = 200;
        
    end
    
end

