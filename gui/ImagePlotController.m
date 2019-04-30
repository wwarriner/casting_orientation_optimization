classdef ImagePlotController < handle
    
    methods ( Access = public )
        
        function obj = ImagePlotController( ...
                image_ui_axes, ...
                orientation_data_model, ...
                CALLBACK_HACK ... % TODO R2019a
                )
            
            obj.callback_hack = CALLBACK_HACK;
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
                %ih.HitTest = 'off'; % TODO R2019a
                ih.ButtonDownFcn = obj.callback_hack;
                obj.image_handle = ih;
                
                grayscale_color_map = interp1( ...
                    [ 0; 1 ], ...
                    repmat( [ 0.3; 0.9 ], [ 1 3 ] ), ...
                    linspace( 0, 1, 256 ) ...
                    );
                obj.axes.Colormap = flipud( grayscale_color_map );
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
            
            % HACK FIX R2019a
            if ~isempty( obj.dummy_image_handle )
                delete( obj.dummy_image_handle )
            end
            obj.dummy_image_handle = image( ...
                obj.axes, ...
                obj.XLIM, ...
                obj.YLIM, ...
                0 ...
                );
            obj.dummy_image_handle.AlphaData = 0.0;
            %obj.dummy_image_handle.Visible = 'off';
            obj.dummy_image_handle.ButtonDownFcn = obj.callback_hack;
            drawnow();
            
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
                pfah.MarkerSize = 5;
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
                pfbh.MarkerSize = 5;
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
        
        
        function update_clicked( obj, point )

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
            
            %point = obj.get_axes_point();
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
        
        callback_hack % TODO R2019a
        dummy_image_handle
        
    end
    
    
    properties ( Access = private, Constant )
        
        XLIM = [ -180 180 ];
        YLIM = [ -90 90 ];
        MAJOR_SPACING = 45;
        MINOR_SPACING = 15;
        THRESHOLD_ALPHA = 0.5;
        
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
            
            %axes.XTickFormat = [ '%.0f' degree_symbol() ];
            % TODO when available
            axes.XAxis.MinorTickValues = axes.XLim( 1 ) : ...
                ImagePlotController.MINOR_SPACING : ...
                axes.XLim( 2 );
            
            axes.YAxis.MinorTickValues = axes.YLim( 1 ) : ...
                ImagePlotController.MINOR_SPACING : ...
                axes.YLim( 2 );
                        
            hold( axes, 'on' );
            
        end
        
    end
    
end

