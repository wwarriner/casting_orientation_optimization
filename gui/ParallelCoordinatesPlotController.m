classdef ParallelCoordinatesPlotController < handle
    
    methods ( Access = public )
        
        function obj = ParallelCoordinatesPlotController( ...
                parallel_coordinates_ui_axes, ...
                orientation_data_model ...
                )
            
            obj.setup_axes( parallel_coordinates_ui_axes );
            obj.axes = parallel_coordinates_ui_axes;
            obj.model = orientation_data_model;
            
        end
        
        
        function update_values( obj )
            
            % color from http://jfly.iam.u-tokyo.ac.jp/color/#redundant2
            if ~isempty( obj.parallel_coordinates_plot_above_handle )
                delete( obj.parallel_coordinates_plot_above_handle );
            end
            pch = parallelcoords( ...
                obj.axes, ...
                obj.model.get_all_pareto_front_values_above_threshold(), ...
                'color', [ 0.9 0.9 0.9 ] ...
                ); % TODO Replace with parallelplot in R2019a
            obj.parallel_coordinates_plot_above_handle = pch;
            
            if ~isempty( obj.parallel_coordinates_plot_below_handle )
                delete( obj.parallel_coordinates_plot_below_handle );
            end
            pch = parallelcoords( ...
                obj.axes, ...
                obj.model.get_all_pareto_front_values_below_threshold(), ...
                'color', [ 0.9 0.6 0.0 ] ...
                ); % TODO Replace with parallelplot in R2019a
            obj.parallel_coordinates_plot_below_handle = pch;
            
            obj.axes.XTick = 1 : obj.model.get_objective_count();
            obj.axes.XLim = [ 0.5 obj.model.get_objective_count() + 0.5 ];
            
        end
        
        
        function update_clicked( obj )
            
            point = obj.get_axes_point();
            objective_index = obj.determine_objective_index( point );
            threshold = obj.determine_threshold( point );
            obj.model.set_threshold_by_index( objective_index, threshold );
            
        end
        
    end
    
    
    properties ( Access = private )
        
        axes
        parallel_coordinates_plot_above_handle
        parallel_coordinates_plot_below_handle
        model
        
    end
    
    
    methods ( Access = private )
        
        function index = determine_objective_index( obj, point )
            
            count = obj.model.get_objective_count();
            limits = obj.axes.XLim;
            lower_bounds = linspace( limits( 1 ), limits( 2 ), count + 1 );
            index = find( lower_bounds <= point( 1 ), 1, 'first' );
            assert( index > 0 );
            
        end
        
        
        function value = determine_threshold( obj, point )
            
            limits = obj.axes.YLim;
            value = interp1( limits, [ 0 1 ], point( 2 ) );
            
        end
        
        
        function point = get_axes_point( obj )
            
%             raw = obj.axes.CurrentPoint; % TODO R2019a
%             point.x = raw( 1 );
%             point.y = raw( 2 );
            point = [ 0 0 ];
            
        end
        
    end
    
    
    methods ( Access = private, Static )
        
        function setup_axes( axes )
            
            %axes.Toolbar.Visible = 'off'; % TODO: R2019a
            %axes.Interactions = [];
            axes.HitTest = 'off';
            
%             axes.XLim = ImagePlotController.XLIM;
%             axes.XMinorTick = 'on';
%             axes.XAxis.MinorTickValues = axes.XLim( 1 ) : ...
%                 ImagePlotController.MINOR_SPACING : ...
%                 axes.XLim( 2 );
%             axes.XAxisLocation = 'origin';
%             axes.XGrid = 'on';
%             axes.XMinorGrid = 'on';
            
%             axes.YLim = ImagePlotController.YLIM;
%             axes.YTick = axes.YLim( 1 ) : ...
%                 ImagePlotController.MAJOR_SPACING : ...
%                 axes.YLim( 2 );
%             axes.YMinorTick = 'on';
%             axes.YAxis.MinorTickValues = axes.YLim( 1 ) : ...
%                 ImagePlotController.MINOR_SPACING : ...
%                 axes.YLim( 2 );
%             axes.YAxisLocation = 'origin';
%             axes.YGrid = 'on';
%             axes.YMinorGrid = 'on';
            
            axes.Layer = 'top';
%             axes.GridLineStyle = '-';
%             axes.MinorGridLineStyle = ':';
%             axes.GridColor = 'k';
            
            hold( axes, 'on' );
            
        end
        
    end
    
end

