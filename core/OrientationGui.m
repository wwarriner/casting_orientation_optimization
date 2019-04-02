classdef (Sealed) OrientationGui < handle
    
    methods ( Access = public )
        
        function obj = OrientationGui( ...
                response_data, ...
                visualization_generator, ...
                figure_resolution_px ...
                )
            
            obj.create_figure( ...
                figure_resolution_px, ...
                response_data.get_name(), ...
                response_data.get_titles(), ...
                rad2deg( response_data.get_phi_grid() ), ...
                rad2deg( response_data.get_theta_grid() ), ...
                visualization_generator ...
                );
            obj.create_threshold_selector( ...
                response_data.get_titles(), ...
                response_data.get_objective_value_ranges() ...
                );
            
            obj.data = response_data;
            
            obj.update_value_range();
            obj.update_surface_plots( obj.UPDATE_COLOR_BAR );
            
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
            obj.picked_point_reporter.set_background_color( bg_color );
            obj.thresholder.set_background_color( bg_color );
            obj.point_plotter.set_background_color( bg_color );
            obj.threshold_selector.set_background_color( bg_color );
            
            obj.background_color = bg_color;
            
        end
        
    end
    
    
    properties ( Access = private )
        
        data
        picked_point
        
        background_color
        
        figure_handle
        threshold_selector
        
        picked_point_reporter
        objective_picker
        axes_widget
        surface_plotter
        thresholder
        point_plotter
        visualizer
        
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
            
            points = rad2deg( obj.data.get_pareto_front() );
            obj.point_plotter.update_pareto_front( points );
            
        end
        
        
        function update_minimum( obj )
            
            point = rad2deg( obj.data.get_minimum( obj.get_selected_objective() ) );
            obj.point_plotter.update_minimum( point );
            
        end
        
        
        function update_picked_point( obj )
            
            value = obj.data.get_objective_value( ...
                deg2rad( obj.picked_point ), ...
                obj.get_selected_objective() ...
                );
            obj.picked_point_reporter.update_picked_point( ...
                obj.picked_point, ...
                value ...
                );
            
        end
        
        
        function update_value_range( obj )
            
            value_range = obj.get_value_range();
            obj.thresholder.update_value_range( value_range );
            
        end
        
        
        function update_surface_plots( obj, do_update_color_bar )
            
            if nargin < 2
                do_update_color_bar = false;
            end
            value_range = obj.get_value_range();
            values = obj.thresholder.pick_selected_values();
            scaled_values = rescale( values, value_range.min, value_range.max );
            obj.surface_plotter.update_surface_plot( scaled_values );
            if do_update_color_bar
                obj.axes_widget.update_color_bar( value_range );
            end
            
        end
        
        
        function values = get_value_range( obj )
            
            values = obj.data.get_objective_value_range( obj.get_selected_objective() );
            
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
                visualization_generator ...
                )
            
            % HACK order matters, determines tab order
            wf = WidgetFactory( figure_resolution_px );
            h = wf.create_figure( figure_title );
            
            obj.picked_point_reporter = wf.add_picked_point_reporter_widget( ...
                h ...
                );
            
            DEFAULT_OBJECTIVE_INDEX = 1;
            obj.objective_picker = wf.add_objective_picker_widget( ...
                h, ...
                objective_titles, ...
                DEFAULT_OBJECTIVE_INDEX, ...
                @obj.ui_objective_selection_list_box_Callback ...
                );
            
            obj.axes_widget = wf.add_axes_widget( ...
                h, ...
                @obj.ui_axes_button_down_Callback ...
                );
            
            obj.surface_plotter = wf.add_surface_plotter_widget( ...
                phi_grid, ...
                theta_grid ...
                );
            
            obj.point_plotter = wf.add_point_plot_widgets( ...
                h, ...
                @obj.ui_point_check_box_Callback ...
                );
            
            DEFAULT_THRESHOLD_SELECTION_ID = ThresholdingWidgets.NO_THRESHOLD;
            ids = ThresholdingWidgets.get_ids();
            types = containers.Map( ids, { ...
                SimpleOption.get_type(), ...
                ValueOption.get_type(), ...
                QuantileOption.get_type(), ...
                ButtonOption.get_type() ...
                } );
            picker_fns = containers.Map( ids, { ...
                @obj.value_picker_objective_values, ...
                @obj.value_picker_thresholded_values, ...
                @obj.value_picker_quantile_values, ...
                @obj.value_picker_no_go_values ...
                } );
            labels = containers.Map( ids, { ...
                'Threshold Off', ...
                'Value Threshold', ...
                'Quantile Threshold', ...
                'Go/No-Go' ...
                } );
            no_go_button_label = 'Select thresholds...';
            obj.thresholder = wf.add_thresholding_widget( ...
                h, ...
                DEFAULT_THRESHOLD_SELECTION_ID, ...
                types, ...
                picker_fns, ...
                labels, ...
                @obj.ui_threshold_selection_changed_Callback, ...
                @obj.ui_threshold_value_option_Callback, ...
                no_go_button_label, ...
                @obj.ui_no_go_button_Callback ...
                );
            
            obj.thresholder.select( ThresholdingWidgets.NO_THRESHOLD );
            
            obj.visualizer = wf.add_visualization_widget( ...
                h, ...
                @obj.ui_visualize_button_Callback, ...
                visualization_generator ...
                );
            
            obj.figure_handle = h;
            
        end
        
        
        function create_threshold_selector( ...
                obj, ...
                titles, ...
                value_ranges ...
                )
            
            obj.threshold_selector = ThresholdSelector( ...
                @obj.ui_threshold_selector_update_Callback, ...
                titles, ...
                value_ranges ...
                );
            
        end
        
    end
    
    
    % callbacks
    methods ( Access = private )
        
        function ui_objective_selection_list_box_Callback( obj, ~, ~, widget )
            
            obj.axes_widget.activate( obj.figure_handle );
            if widget.update_selection()
                obj.update_value_range();
                obj.update_surface_plots( obj.UPDATE_COLOR_BAR );
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
        
        
        function ui_threshold_value_option_Callback( obj, h, ~, widget )
            
            obj.axes_widget.activate( obj.figure_handle );
            if widget.update_threshold_value( h.Style )
                widget.select();
                obj.update_surface_plots();
            end
            obj.update_points();
            drawnow();
            
        end
        
        
        function ui_no_go_button_Callback( obj, ~, ~, widget )
            
            obj.axes_widget.activate( obj.figure_handle );
            widget.select();
            obj.update_surface_plots();
            obj.update_points();
            drawnow();
            
            obj.threshold_selector.draw();
            obj.threshold_selector.set_background_color( obj.background_color );
            
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
        
        
        function ui_threshold_selector_update_Callback( obj, ~, ~ )
            
            obj.axes_widget.activate( obj.figure_handle );
            obj.update_surface_plots();
            obj.update_points();
            drawnow();
            
        end
        
        
        function values = value_picker_objective_values( obj, ~ )
            
            values = obj.data.get_objective_values( ...
                obj.get_selected_objective() ...
                );
            
        end
        
        
        function values = value_picker_quantile_values( obj, quantile )
            
            values = obj.data.get_quantile_values( ...
                quantile, ...
                obj.get_selected_objective() ...
                );
            values = double( values );
            
        end
        
        
        function values = value_picker_thresholded_values( obj, threshold )
            
            values = obj.data.get_thresholded_values( ...
                threshold, ...
                obj.get_selected_objective() ...
                );
            values = double( values );
            
        end
        
        
        function values = value_picker_no_go_values( obj, ~ )
            
            values = obj.data.get_no_go_values( ...
                obj.threshold_selector.get_thresholds(), ...
                obj.threshold_selector.get_usage_states() ...
                );
            values = double( values );
            
        end
        
    end
    
end

