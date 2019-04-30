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
            
            % DRAW COORDS
            % color from http://jfly.iam.u-tokyo.ac.jp/color/#redundant2
            if ~isempty( obj.parallel_coordinates_plot_above_handle )
                delete( obj.parallel_coordinates_plot_above_handle );
            end
            limits = obj.model.get_all_data_limits();
            v = obj.model.get_all_pareto_front_values_above_threshold();
            for i = 1 : obj.model.get_objective_count()
                v( :, i ) = ( v( :, i ) - limits( i, 1 ) ) ./ ( limits( i, 2 ) - limits( i, 1 ) );
            end
            pch = parallelcoords( ...
                obj.axes, ...
                v, ...
                'color', [ 0.9 0.9 0.9 ] ...
                ); % TODO Replace with parallelplot in R2019a
            obj.parallel_coordinates_plot_above_handle = pch;
            
            if ~isempty( obj.parallel_coordinates_plot_below_handle )
                delete( obj.parallel_coordinates_plot_below_handle );
            end
            v = obj.model.get_all_pareto_front_values_below_threshold();
            for i = 1 : obj.model.get_objective_count()
                v( :, i ) = ( v( :, i ) - limits( i, 1 ) ) ./ ( limits( i, 2 ) - limits( i, 1 ) );
            end
            pch = parallelcoords( ...
                obj.axes, ...
                v, ...
                'color', [ 0.9 0.6 0.0 ] ...
                ); % TODO Replace with parallelplot in R2019a
            obj.parallel_coordinates_plot_below_handle = pch;
            
            % UPDATE MARKERS
            if isempty( obj.marker_handles )
                mhs = cell( obj.model.get_objective_count(), 1 );
                for i = 1 : obj.model.get_objective_count()
                    
                    mh = plot( ...
                        obj.axes, ...
                        i, ...
                        1 ...
                        );
                    mh.Marker = '+';
                    mh.MarkerSize = 16;
                    mh.LineStyle = 'none';
                    mh.LineWidth = 2;
                    mh.Color = 'k';
                    mhs{ i } = mh;
                    
                end
                obj.marker_handles = containers.Map( ...
                    obj.model.get_objectives(), ...
                    mhs ...
                    );
            end
            limits = obj.model.get_all_data_limits();
            v = obj.model.get_all_thresholds();
            for i = 1 : obj.model.get_objective_count()
                v( i ) = ( v( i ) - limits( i, 1 ) ) ./ ( limits( i, 2 ) - limits( i, 1 ) );
            end
            active = obj.model.get_active_objectives();
            for i = 1 : obj.model.get_objective_count()
                
                objective = obj.model.get_objective_from_index( i );
                mh = obj.marker_handles( objective );
                if active( objective )
                    mh.Visible = 'on';
                    mh.YData = v( i );
                else
                    mh.Visible = 'off';
                end
                
            end
            
            % UPDATE SHADING
            % color from http://jfly.iam.u-tokyo.ac.jp/color/#redundant2
            if isempty( obj.shaded_box_handles )
                sbhs = cell( obj.model.get_objective_count(), 1 );
                for i = 1 : obj.model.get_objective_count()
                    
                    x_pos = ( i - 1 ) + 0.5;
                    sbh = patch( ...
                        obj.axes, ...
                        [ 0 1 1 0 ] + x_pos, ...
                        [ 0 0 1 1 ], ...
                        [ 0.8 0.4 0.0 ] ...
                        );
                    sbh.FaceAlpha = 0.1;
                    sbh.EdgeColor = 'none';
                    sbhs{ i } = sbh;
                    
                end
                obj.shaded_box_handles = containers.Map( ...
                    obj.model.get_objectives(), ...
                    sbhs ...
                    );
            end
            for i = 1 : obj.model.get_objective_count()
                
                objective = obj.model.get_objective_from_index( i );
                sbh = obj.shaded_box_handles( objective );
                if active( objective )
                    sbh.Visible = 'on';
                else
                    sbh.Visible = 'off';
                end
                
            end
            
            % RESET AXES
            obj.axes.XTick = 1 : obj.model.get_objective_count();
            obj.axes.XLim = [ 0.5 obj.model.get_objective_count() + 0.5 ];
            
            obj.axes.YLim = [ 0 1 ];
            obj.axes.YTick = obj.axes.YLim( 1 ) : ...
                0.1 : ...
                obj.axes.YLim( 2 );
            
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
        marker_handles
        shaded_box_handles
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
            
            hold( axes, 'on' );
            
        end
        
    end
    
end

