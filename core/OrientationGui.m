classdef (Sealed) OrientationGui < handle
    
    methods ( Access = public )
        
        function obj = OrientationGui( ...
                response_data, ...
                visualization_generator, ...
                figure_resolution_px ...
                )
            
            filter = DataFilter( response_data );
            
            obj.create_figure( ...
                figure_resolution_px, ...
                response_data.get_name(), ...
                response_data.get_titles(), ...
                rad2deg( response_data.get_phi_grid() ), ...
                rad2deg( response_data.get_theta_grid() ), ...
                visualization_generator, ...
                filter ...
                );
            
            obj.data = response_data;
            obj.data_filter = filter;
            
            obj.axes_widget.activate( obj.figure_handle );
            obj.update_surface_plots();
            
            obj.picked_point = [ 0 0 ];
            obj.update_picked_point();
            
            drawnow();
            
        end
        
        
        function set_color_map( obj, color_map )
            
            obj.axes_widget.set_color_map( flipud( color_map ) );
            
        end
        
        
        function set_grid_color( obj, grid_color )
            
            obj.axes_widget.set_grid_color( grid_color );
            
        end
        
        
        function set_background_color( obj, bg_color )
            
            obj.figure_handle.Color = bg_color;
            obj.point_reporter_widget.set_background_color( bg_color );
            
            obj.point_plotter.set_background_color( bg_color );
            obj.thresholder.set_background_color( bg_color );
            obj.mode_selector.set_background_color( bg_color );
            obj.threshold_value_selector.set_background_color( bg_color );
            
            obj.background_color = bg_color;
            
        end
        
    end
    
    
    properties ( Access = private )
        
        data
        data_filter
        picked_point
        
        background_color
        
        figure_handle
        
        % TOP PANE
        point_reporter_widget
        objective_picker
        
        % LEFT PANE
        point_plotter
        thresholder
        mode_selector
        visualizer
        threshold_value_selector
        
        % RIGHT PANE
        axes_widget
        surface_plotter
        parallel_plotter
        
    end
    
    
    properties ( Access = private, Constant )
        
        UPDATE_COLOR_BAR = true;
        
    end
    
    
    methods ( Access = private )
        
        function update_points( obj )
            
            obj.update_pareto_front();
            obj.update_minimum();
            obj.update_picked_point();
            
        end
        
        
        function update_pareto_front( obj )
            
            % color pareto front points differently based on parallel plot etc
            points = rad2deg( obj.data.get_pareto_front() );
            obj.point_plotter.update_pareto_front( ...
                points, ...
                obj.data_filter.is_pareto_front_below_thresholds() ...
                );
            
        end
        
        
        function update_minimum( obj )
            
            point = rad2deg( obj.data.get_minimum( obj.get_selected_objective() ) );
            obj.point_plotter.update_minimum( point );
            
        end
        
        
        function update_picked_point( obj )
            
            value = obj.data_filter.get_value( ...
                deg2rad( obj.picked_point ), ...
                obj.get_selected_objective() ...
                );
            obj.point_reporter_widget.update_picked_point( ...
                obj.picked_point, ...
                value ...
                );
            
        end
        
        
        function update_surface_plots( obj )
            
            values = obj.thresholder.pick_selected_values();
            values = double( values );
            %scaled_values = rescale( values, value_range.min, value_range.max );
            obj.surface_plotter.update_surface_plot( values );
            %if do_update_color_bar
                range.min = min( values( : ) );
                range.max = max( values( : ) );
                obj.axes_widget.update_color_bar( range );
            %end
            
        end
        
        
        function value = get_selected_objective( obj )
            
            value = obj.objective_picker.get_selected_tag();
            
        end
        
        
        function create_figure( obj, ...
                figure_resolution_px, ...
                figure_title, ...
                objective_titles, ...
                phi_grid, ...
                theta_grid, ...
                visualization_generator, ...
                data_filter ...
                )
            
            % HACK order matters, determines tab order
            wf = WidgetFactory( figure_resolution_px );
            h = wf.create_figure( figure_title );
            
            obj.point_reporter_widget = wf.add_point_reporter_widget();
            
            DEFAULT_OBJECTIVE_INDEX = 1;
            obj.objective_picker = wf.add_objective_picker_widget( ...
                objective_titles, ...
                DEFAULT_OBJECTIVE_INDEX, ...
                @obj.ui_objective_selection_list_box_Callback ...
                );
            
            obj.visualizer = wf.add_visualization_widget( ...
                visualization_generator, ...
                @obj.ui_visualize_button_Callback ...
                );
            
            obj.mode_selector = wf.add_mode_selector_widget( ...
                @obj.ui_mode_changed_Callback ...
                );
            
            obj.point_plotter = wf.add_point_plot_widgets( ...
                @obj.ui_point_check_box_Callback ...
                );
            
            DEFAULT_THRESHOLD_SELECTION_ID = ThresholdingWidgets.NO_THRESHOLD;
            ids = ThresholdingWidgets.get_ids();
            picker_fns = containers.Map( ids, { ...
                @obj.value_picker_objective_values, ...
                @obj.value_picker_thresholded_values, ...
                @obj.value_picker_no_go_values ...
                } );
            labels = containers.Map( ids, { ...
                'Threshold Off', ...
                'Threshold On', ...
                'Go/No-Go' ...
                } );
            obj.thresholder = wf.add_thresholding_widget( ...
                DEFAULT_THRESHOLD_SELECTION_ID, ...
                picker_fns, ...
                labels, ...
                @obj.ui_threshold_selection_changed_Callback ...
                );
            
            obj.threshold_value_selector = wf.add_threshold_value_selector_widget( ...
                data_filter, ...
                @obj.ui_threshold_value_widget_value_Callback, ...
                @obj.ui_threshold_value_widget_check_box_Callback ...
                );
            
            obj.axes_widget = wf.add_axes_widget( ...
                @obj.ui_axes_button_down_Callback ...
                );
            
            obj.surface_plotter = wf.add_surface_plotter_widget( ...
                phi_grid, ...
                theta_grid ...
                );
            
            obj.parallel_plotter = wf.add_parallel_plotter_widget( ...
                data_filter ...
                );
            
            obj.figure_handle = h;
            
        end
        
    end
    
    
    % callbacks
    methods ( Access = private )
        
        function ui_objective_selection_list_box_Callback( obj, ~, ~, widget )
            
            obj.axes_widget.activate( obj.figure_handle );
            if widget.update_selection()
                obj.update_surface_plots();
                obj.update_points();
            end
            drawnow();
            
        end
        
        
        function ui_threshold_selection_changed_Callback( obj, ~, ~ )
            
            obj.axes_widget.activate( obj.figure_handle );
            obj.update_surface_plots();
            obj.update_points();
            drawnow();
            
        end
        
        
        function ui_point_check_box_Callback( obj, ~, ~ )
            
            obj.axes_widget.activate( obj.figure_handle );
            obj.update_points();
            drawnow();
            
        end
        
        
        function ui_visualize_button_Callback( obj, ~, ~ )
            
            obj.visualizer.generate_visualization( deg2rad( obj.picked_point ) );
            
        end
        
        
        function ui_axes_button_down_Callback( obj, ~, ~ )
            
            % pick point
            point_deg = obj.axes_widget.get_picked_point();
            obj.picked_point = rad2deg( obj.data.snap_to_grid( deg2rad( point_deg ) ) );
            
            % update
            obj.axes_widget.activate( obj.figure_handle );
            obj.update_points();
            drawnow();
            
        end
        
        
        function ui_mode_changed_Callback( obj, ~, e )
            
            obj.data_filter.set_mode( e.NewValue.Tag );
            obj.parallel_plotter.update_lines();
            obj.threshold_value_selector.update();
            
            obj.axes_widget.activate( obj.figure_handle );
            obj.update_surface_plots();
            obj.update_points();
            drawnow();
            
        end
        
        
        function ui_threshold_value_widget_value_Callback( obj, h, ~, widget )
            
            if widget.update_value( h.Style )
                obj.data_filter.set_threshold( ...
                    widget.get_tag(), ...
                    widget.get_value() ...
                    );
            end
            obj.parallel_plotter.update_thresholds();
            
            obj.axes_widget.activate( obj.figure_handle );
            obj.update_surface_plots();
            obj.update_points();
            drawnow();
            
        end
        
        
        function ui_threshold_value_widget_check_box_Callback( obj, ~, ~, widget )
            
            obj.data_filter.set_usage_state( ...
                widget.get_tag(), ...
                widget.get_usage_state() ...
                );
            obj.parallel_plotter.update_thresholds();
            
            obj.axes_widget.activate( obj.figure_handle );
            obj.update_surface_plots();
            obj.update_points();
            drawnow();
            
        end
        
        
        function values = value_picker_objective_values( obj, ~ )
            
            values = obj.data_filter.get_values( ...
                obj.get_selected_objective() ...
                );
            
        end
        
        
        function values = value_picker_thresholded_values( obj, ~ )
            
            values = obj.data_filter.get_thresholded_values( ...
                obj.get_selected_objective() ...
                );
            
        end
        
        
        function values = value_picker_no_go_values( obj, ~ )
            
            values = obj.data_filter.get_composited_values();
            
        end
        
    end
    
end

