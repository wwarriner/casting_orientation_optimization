classdef ParallelCoordinatesPlotController < handle
    
    methods ( Access = public )
        
        function obj = ParallelCoordinatesPlotController( ...
                parallel_coordinates_ui_axes, ...
                orientation_data_model ...
                )
            
            obj.axes = parallel_coordinates_ui_axes;
            obj.model = orientation_data_model;
            
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
        model
        
    end
    
    
    methods ( Access = private )
        
        function index = determine_objective_index( obj, point )
            
            count = obj.model.get_objective_count();
            limits = obj.axes.XLim;
            lower_bounds = linspace( limits( 1 ), limits( 2 ), count + 1 );
            index = find( lower_bounds <= point.x, 'first', 1 );
            assert( index > 0 );
            
        end
        
        
        function value = determine_threshold( obj, point )
            
            limits = obj.axes.YLim;
            value = interp1( limits, [ 0 1 ], point.y );
            
        end
        
        
        function point = get_axes_point( obj )
            
            raw = obj.axes.CurrentPoint;
            point.x = raw( 1 );
            point.y = raw( 2 );
            
        end
        
    end
    
end

