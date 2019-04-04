classdef PointPlotWidgets < handle
    
    methods ( Access = public )
        
        function obj = PointPlotWidgets( ...
                figure_handle, ...
                corner_pos, ...
                x_padding, ...
                y_padding, ...
                font_size, ...
                check_box_callback ...
                )
            
            h = uipanel();
            h.Title = 'Point Display';
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
            h.Parent = figure_handle;
            
            min_h = uicontrol();
            min_h.Style = 'checkbox';
            min_h.String = 'Show Minimum';
            min_h.FontSize = font_size;
            min_h.Position = [ ...
                x_padding ...
                y_padding ...
                obj.WIDTH ...
                obj.get_height_each( font_size ) ...
                ];
            min_h.Callback = check_box_callback;
            min_h.Parent = h;
            
            par_h = uicontrol();
            par_h.Style = 'checkbox';
            par_h.String = 'Show Pareto Front';
            par_h.FontSize = font_size;
            par_h.Position = [ ...
                x_padding ...
                obj.get_height_each( font_size ) + 2 * y_padding ...
                obj.WIDTH ...
                obj.get_height_each( font_size ) ...
                ];
            par_h.Callback = check_box_callback;
            par_h.Parent = h;
            
            obj.panel_handle = h;
            obj.minimum_check_box_handle = min_h;
            obj.pareto_front_check_box_handle = par_h;
            
            obj.minimum_plot_handle = ...
                AxesPlotHandle( @obj.create_minimum_plot );
            obj.above_pareto_front_plot_handle = ...
                AxesPlotHandle( @obj.create_above_pareto_front_plot );
            obj.below_pareto_front_plot_handle = ...
                AxesPlotHandle( @obj.create_below_pareto_front_plot );
            
        end
        
        
        function set_background_color( obj, color )
            
            obj.panel_handle.BackgroundColor = color;
            obj.minimum_check_box_handle.BackgroundColor = color;
            obj.pareto_front_check_box_handle.BackgroundColor = color;
            
        end
        
        
        function update_minimum( obj, point )
            
            switch obj.minimum_check_box_handle.Value
                case false
                    obj.minimum_plot_handle.remove();
                case true
                    obj.minimum_plot_handle.remove();
                    obj.minimum_plot_handle.update( point );
                otherwise
                    assert( false );
            end
            
        end
        
        
        function update_pareto_front( obj, points, highlight_indices )
            
            switch obj.pareto_front_check_box_handle.Value
                case false
                    obj.below_pareto_front_plot_handle.remove();
                    obj.above_pareto_front_plot_handle.remove();
                case true
                    obj.below_pareto_front_plot_handle.remove();
                    obj.above_pareto_front_plot_handle.remove();
                    below = points( highlight_indices, : );
                    if ~isempty( below )
                        obj.below_pareto_front_plot_handle.update( below );
                    end
                    above = points( ~highlight_indices, : );
                    if ~isempty( above )
                        obj.above_pareto_front_plot_handle.update( above );
                    end
                otherwise
                    assert( false );
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
    
    
    methods ( Access = public, Static )
        
        function height = get_height_each( font_size )
            
            height = get_height( font_size );
            
        end
        
        
        function width = get_width()
            
            width = PointPlotWidgets.MIN_WIDTH + ...
                PointPlotWidgets.PAR_WIDTH;
            
        end
        
    end
    
    
    properties ( Access = private )
        
        panel_handle
        minimum_check_box_handle
        pareto_front_check_box_handle
        
        minimum_plot_handle
        above_pareto_front_plot_handle
        below_pareto_front_plot_handle
        
    end
    
    
    properties ( Access = private, Constant )
        
        WIDTH = 140;
        
    end
    
    
    methods ( Access = private, Static )
        
        % color from http://jfly.iam.u-tokyo.ac.jp/color/#redundant2
        function plot_handle = create_minimum_plot( points )
            
            plot_handle = add_point_plot( points );
            plot_handle.LineStyle = 'none';
            plot_handle.Marker = 's';
            plot_handle.MarkerSize = 8;
            plot_handle.MarkerEdgeColor = 'k';
            plot_handle.MarkerFaceColor = [ 0.95 0.9 0.25 ];
            plot_handle.HitTest = 'off';
            
        end
        
        
        % color from http://jfly.iam.u-tokyo.ac.jp/color/#redundant2
        function plot_handle = create_above_pareto_front_plot( points )
            
            plot_handle = add_point_plot( points );
            plot_handle.LineStyle = 'none';
            plot_handle.Marker = 'o';
            plot_handle.MarkerSize = 3;
            plot_handle.MarkerEdgeColor = 'none';
            plot_handle.MarkerFaceColor = [ 0 0.6 0.5 ];
            plot_handle.HitTest = 'off';
            
        end
        
        
        % color from http://jfly.iam.u-tokyo.ac.jp/color/#redundant2
        function plot_handle = create_below_pareto_front_plot( points )
            
            plot_handle = add_point_plot( points );
            plot_handle.LineStyle = 'none';
            plot_handle.Marker = 'o';
            plot_handle.MarkerSize = 5;
            plot_handle.MarkerEdgeColor = 'k';
            plot_handle.MarkerFaceColor = [ 0.9 0.6 0 ];
            plot_handle.HitTest = 'off';
            
        end
        
    end
    
end

