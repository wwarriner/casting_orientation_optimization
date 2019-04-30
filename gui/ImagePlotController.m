classdef ImagePlotController < handle
    
    methods ( Access = public )
        
        function obj = ImagePlotController( ...
                image_ui_axes, ...
                orientation_data_model ...
                )
            
            obj.setup_axes( image_ui_axes );
            obj.axes = image_ui_axes;
            obj.model = orientation_data_model;
            
        end
        
        
        function update_values( obj )
            
            if isempty( obj.image_handle )
                ih = imagesc( ...
                    obj.axes, ...
                    obj.XLIM, ...
                    obj.YLIM, ...
                    0 ...
                    );
                ih.HitTest = 'off';
                obj.image_handle = ih;
                
                obj.axes.Colormap = flipud( obj.axes.Colormap );
                cbh = colorbar( obj.axes );
                cbh.Location = 'eastoutside';
                obj.colorbar_handle = cbh;
            end
            
            values = obj.model.get_current_values();
            obj.image_handle.CData = obj.model.get_current_values();
            obj.colorbar_handle.Ticks = linspace( ...
                min( values, [], 'all' ), ...
                max( values, [], 'all' ), ...
                11 ...
                );
            
        end
        
        
        function update_threshold_values( obj )
            
            if isempty( obj.threshold_handle )
                th = imagesc( ...
                    obj.axes, ...
                    obj.XLIM, ...
                    obj.YLIM, ...
                    0 ...
                    );
                th.HitTest = 'off';
                obj.threshold_handle = th;
            end
            
            if obj.model.is_single_threshold_shown()
                obj.threshold_handle.Visible = 'on';
                values = obj.model.get_single_threshold_values();
                obj.threshold_handle.CData = repmat( ...
                    values, ...
                    [ 1 1 3 ] ...
                    );
                obj.threshold_handle.AlphaData = ...
                    obj.THRESHOLD_ALPHA .* ( 1 - values );
            else
                obj.threshold_handle.Visible = 'off';
            end
            
        end
        
        
        function update_pareto_front( obj )

            % color from http://jfly.iam.u-tokyo.ac.jp/color/#redundant2
            if isempty( obj.pareto_front_above_threshold_handle )
                pfah = plot( ...
                    obj.axes, ...
                    [ 0 0 ] ...
                    );
                pfah.LineStyle = 'none';
                pfah.Marker = 'o';
                pfah.MarkerSize = 3;
                pfah.MarkerEdgeColor = 'k';
                pfah.MarkerFaceColor = [ 0.0 0.6 0.5 ];
                pfah.HitTest = 'off';
                obj.pareto_front_above_threshold_handle = pfah;
            end

            if isempty( obj.pareto_front_below_threshold_handle )
                pfbh = plot( ...
                    obj.axes, ...
                    [ 0 0 ] ...
                    );
                pfbh.LineStyle = 'none';
                pfbh.Marker = 'o';
                pfbh.MarkerSize = 3;
                pfbh.MarkerEdgeColor = 'k';
                pfbh.MarkerFaceColor = [ 0.9 0.6 0.0 ];
                pfbh.HitTest = 'off';
                obj.pareto_front_below_threshold_handle = pfbh;
            end
            
            if obj.model.is_pareto_front_shown()
                obj.pareto_front_above_threshold_handle.Visible = 'on';
                above = obj.model.get_pareto_front_above_threshold();
                obj.pareto_front_above_threshold_handle.XData = above( :, 1 );
                obj.pareto_front_above_threshold_handle.YData = above( :, 2 );
                
                obj.pareto_front_below_threshold_handle.Visible = 'on';
                below = obj.model.get_pareto_front_below_threshold();
                obj.pareto_front_below_threshold_handle.XData = below( :, 1 );
                obj.pareto_front_below_threshold_handle.YData = below( :, 2 );
            else
                obj.pareto_front_above_threshold_handle.Visible = 'off';
                obj.pareto_front_below_threshold_handle.Visible = 'off';
            end
            
        end
        
        
        function update_global_minimum( obj )

            % color from http://jfly.iam.u-tokyo.ac.jp/color/#redundant2
            if isempty( obj.global_minimum_handle )
                gmh = plot( ...
                    obj.axes, ...
                    [ 0 0 ] ...
                    );
                gmh.LineStyle = 'none';
                gmh.Marker = 's';
                gmh.MarkerSize = 8;
                gmh.MarkerEdgeColor = 'k';
                gmh.MarkerFaceColor = [ 0.95 0.9 0.25 ];
                gmh.HitTest = 'off';
                obj.global_minimum_handle = gmh;
            end
            
            if obj.model.is_global_minimum_shown()
                obj.global_minimum_handle.Visible = 'on';
                point = obj.model.get_current_global_minimum_point();
                obj.global_minimum_handle.XData = point( 1 );
                obj.global_minimum_handle.YData = point( 2 );
            else
                obj.global_minimum_handle.Visible = 'off';
            end
            
        end
        
        
        function update_clicked( obj )

            % color from http://jfly.iam.u-tokyo.ac.jp/color/#redundant2
            if isempty( obj.selected_point_handle )
                sph = plot( ...
                    obj.axes, ...
                    [ 0 0 ] ...
                    );
                sph.LineStyle = 'none';
                sph.Marker = 'd';
                sph.MarkerSize = 8;
                sph.MarkerEdgeColor = 'k';
                sph.MarkerFaceColor = [ 0.35 0.7 0.9 ];
                sph.HitTest = 'off';
                obj.selected_point_handle = sph;
            end
            
            point = obj.get_axes_point();
            obj.model.set_selected_angles( point );
            obj.selected_point_handle.XData = point( 1 );
            obj.selected_point_handle.YData = point( 2 );
            
        end
        
    end
    
    
    properties ( Access = private )
        
        axes
        image_handle
        colorbar_handle
        threshold_handle
        pareto_front_above_threshold_handle
        pareto_front_below_threshold_handle
        global_minimum_handle
        selected_point_handle
        model
        
    end
    
    
    properties ( Access = private, Constant )
        
        XLIM = [ -180 180 ];
        YLIM = [ -90 90 ];
        MAJOR_SPACING = 45;
        MINOR_SPACING = 15;
        THRESHOLD_ALPHA = 0.75;
        
    end
    
    
    methods ( Access = private )
        
        function point = get_axes_point( obj )
            
            %raw = obj.axes.CurrentPoint; % TODO R2019a
            %point.x = raw( 1 );
            %point.y = raw( 2 );
            point = [ 0 0 ];
            
        end
        
    end
    
    
    methods ( Access = private, Static )
        
        function setup_axes( axes )
            
            %axes.Toolbar.Visible = 'off'; % TODO: R2019a
            %axes.Interactions = [];
            axes.HitTest = 'off';
            
            axes.XLim = ImagePlotController.XLIM;
            axes.XTick = axes.XLim( 1 ) : ...
                ImagePlotController.MAJOR_SPACING : ...
                axes.XLim( 2 );
            axes.XMinorTick = 'on';
            axes.XAxis.MinorTickValues = axes.XLim( 1 ) : ...
                ImagePlotController.MINOR_SPACING : ...
                axes.XLim( 2 );
            axes.XAxisLocation = 'origin';
            axes.XGrid = 'on';
            axes.XMinorGrid = 'on';
            
            axes.YLim = ImagePlotController.YLIM;
            axes.YTick = axes.YLim( 1 ) : ...
                ImagePlotController.MAJOR_SPACING : ...
                axes.YLim( 2 );
            axes.YMinorTick = 'on';
            axes.YAxis.MinorTickValues = axes.YLim( 1 ) : ...
                ImagePlotController.MINOR_SPACING : ...
                axes.YLim( 2 );
            axes.YAxisLocation = 'origin';
            axes.YGrid = 'on';
            axes.YMinorGrid = 'on';
            
            axes.Layer = 'top';
            axes.GridLineStyle = '-';
            axes.MinorGridLineStyle = ':';
            axes.GridColor = 'k';
            
            hold( axes, 'on' );
            
        end
        
    end
    
end
