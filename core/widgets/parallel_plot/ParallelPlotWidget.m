classdef ParallelPlotWidget < handle
    
    methods ( Access = public )
        
        function obj = ParallelPlotWidget( ...
                figure_handle, ...
                corner_pos, ...
                desired_size, ...
                font_size, ...
                data_filter ...
                )
            
            % TODO make me interactive!
            
            h = axes( figure_handle );
            
            % adjust size
            h.Units = 'pixels';
            x_ratio = 1.18;
            x_shift = ( 0.75 ) * ( ( x_ratio - 1 ) * desired_size( 1 ) );
            y_shift = ( 0.7 ) * ( ( x_ratio - 1 ) * desired_size( 2 ) );
            
            % axis box
            axis( h, 'tight', 'manual' );
            h.Box = 'on';
            
            h.OuterPosition = [ ...
                corner_pos( 1 ) - x_shift ...
                corner_pos( 2 ) - x_ratio * desired_size( 2 ) - y_shift ...
                x_ratio * desired_size ...
                ];
            
            % appearance font
            h.Color = 'none';
            h.FontSize = font_size;
            h.LabelFontSizeMultiplier = 1.0;
            h.TitleFontSizeMultiplier = 1.0;
            
            % hit test consistency
            ch = h.Children;
            for i = 1 : numel( ch )
                
                ch( i ).HitTest = 'off';
                
            end
            
            obj.data_filter = data_filter;
            obj.axes_handle = h;
            
            obj.update_lines();
            
        end
        
        
        function set_background_color( obj, color )
            
            if ~isempty( obj.figure_handle )
                obj.figure_handle.Color = color;
            end
            
        end
        
        
        function indices = get_acceptable_indices( obj )
            
            indices = obj.previous_below;
            
        end
        
        
        function update_lines( obj )
            
            obj.threshold_handles = [];
            obj.previous_below = [];
            
            % replace with parallelplot in R2019a
            tags = obj.data_filter.get_tags();
            v = nan( ...
                obj.data_filter.get_pareto_front_count(), ...
                obj.data_filter.get_count() ...
                );
            pf = obj.data_filter.get_pareto_front_values();
            for i = 1 : obj.data_filter.get_count()
                
                v( :, i ) = pf( tags{ i } );
                
            end
            v = normalize( v, 1, 'range' );
            obj.line_handles = parallelcoords( obj.axes_handle, v );
            obj.axes_handle.XLim = [ 1 size( v, 2 ) ];
            obj.update_thresholds();
            
        end
        
        
        function update_thresholds( obj )
            
            below = obj.data_filter.is_pareto_front_below_thresholds();
            if ~isempty( obj.previous_below )
                changed = xor( obj.previous_below, below );
                go_update = changed & below;
                no_go_update = changed & ~below;
            else
                go_update = below;
                no_go_update = ~below;
            end
            obj.format_go_lines( obj.line_handles( go_update ) );
            obj.format_no_go_lines( obj.line_handles( no_go_update ) );
            obj.previous_below = below;

            % remove with parallelplot in R2019a
            tags = obj.data_filter.get_tags();
            thresholds = obj.data_filter.get_thresholds();
            nthresh = containers.Map( tags, thresholds.values() );
            pareto_front = obj.data_filter.get_pareto_front_values();
            for i = 1 : obj.data_filter.get_count()

                tag = tags{ i };

                v = pareto_front( tag );
                raw_threshold_value = obj.data_filter.get_threshold( tag ).get_value();
                scaled_threshold = ...
                    ( raw_threshold_value - min( v( : ) ) ) ./ ...
                    ( max( v( : ) ) - min( v( : ) ) );
                nthresh( tag ) = scaled_threshold;

            end
            obj.update_threshold_markers( nthresh, obj.data_filter.get_usage_states() );

            obj.axes_handle.YLim = [ 0 1 ];
            
        end
        
        
        function pos = get_position( obj )
            
            pos = obj.axes_handle.OuterPosition;
            
        end
        
    end
    
    
    properties ( Access = private )
        
        data_filter
        axes_handle
        line_handles
        threshold_handles
        
        previous_below
        
    end
    
    
    properties ( Access = private, Constant )
        
        GO_COLOR = [ 1.0 0.5 0.0 1.0 ];
        NO_GO_COLOR = [ 0.5 0.5 0.5 0.1 ];
        
        GO_THICKNESS = 2.5;
        NO_GO_THICKNESS = 1.0;
        
    end
    
    
    methods ( Access = private )
        
        function on_close( obj, ~, ~ )
            
%             obj.figure_handle = [];
%             obj.axes_handle = [];
%             obj.line_handles = [];
%             obj.threshold_handles = [];
%             closereq();
            
        end
        
        
        function update_threshold_markers( obj, thresholds, usage_states )
            
            if isempty( obj.threshold_handles )
                obj.create_threshold_markers( thresholds );
            end
            
            tags = obj.data_filter.get_tags();
            for i = 1 : obj.data_filter.get_count()

                tag = tags{ i };
                th = obj.threshold_handles( tag );
                th.YData = thresholds( tag );
                if usage_states( tag )
                    th.Visible = 'on';
                else
                    th.Visible = 'off';
                end
            
            end
            
        end
        
        
        function create_threshold_markers( obj, thresholds )
            
            th = containers.Map( ...
                'keytype', 'char', ...
                'valuetype', 'any' ...
                );
            tags = obj.data_filter.get_tags();
            for i = 1 : obj.data_filter.get_count()
                
                tag = tags{ i };
                th( tag ) = line( ...
                    obj.axes_handle, ...
                    i, ...
                    thresholds( tag ), ...
                    'marker', '+', ...
                    'color', 'k', ...
                    'markersize', 12, ...
                    'linewidth', 2 ...
                    );
                
            end
            obj.threshold_handles = th;
            
        end
        
    end
    
    
    methods ( Access = private, Static )
        
        function format_go_lines( line_handles )
            
            if isempty( line_handles ); return; end
            [ line_handles.Color ] = deal( [ 0.9 0.6 0.0 1.0 ] );
            [ line_handles.LineWidth ] = deal( 2.5 );
            
        end
        
        
        function format_no_go_lines( line_handles )
            
            if isempty( line_handles ); return; end
            [ line_handles.Color ] = deal( [ 0.5 0.5 0.5 0.1 ] );
            [ line_handles.LineWidth ] = deal( 0.5 );
            
        end
        
    end
    
end

