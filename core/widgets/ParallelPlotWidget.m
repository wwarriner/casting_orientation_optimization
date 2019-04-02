classdef ParallelPlotWidget < handle
    
    methods ( Access = public )
        
        function obj = ParallelPlotWidget( ...
                titles, ...
                pareto_front_table ...
                )
            
            obj.titles = titles;
            obj.data = pareto_front_table;
            
        end
        
        
        function fh = draw( obj )
            
            fh = figure();
            fh.Name = sprintf( 'Parallel Plot' );
            fh.NumberTitle = 'off';
            fh.Position = [ 25 25 1000 500 ];
            fh.MenuBar = 'none';
            fh.ToolBar = 'none';
            fh.DockControls = 'off';
            fh.Resize = 'off';
            fh.CloseRequestFcn = @obj.on_close;
            movegui( fh, 'center' );
            
            % replace with parallelplot in R2019a
            v = obj.data{ :, : };
            v = normalize( v, 1, 'range' );
            
            axh = axes( fh );
            
            % replace with parallelplot in R2019a
            lh = parallelcoords( axh, v );
            axh.XLim = [ 1 size( v, 2 ) ];
            
            obj.figure_handle = fh;
            obj.axes_handle = axh;
            obj.line_handles = lh;
            
        end
        
        
        function set_background_color( obj, color )
            
            if ~isempty( obj.figure_handle )
                obj.figure_handle.Color = color;
            end
            
        end
        
        
        function update_thresholds( obj, thresholds, usage_states )
            
            if ~isempty( obj.figure_handle )
                nthresh = containers.Map( thresholds.keys(), thresholds.values() );
                count = thresholds.Count();
                tags = thresholds.keys();
                below = true( size( obj.data{ :, 1 }, 1 ), 1 );
                for i = 1 : count
                    
                    tag = tags{ i };
                    if ~usage_states( tag )
                        continue;
                    end
                    
                    v = obj.data{ :, tag };
                    threshold = ...
                        ( thresholds( tag ) - min( v( : ) ) ) ./ ...
                        ( max( v( : ) ) - min( v( : ) ) );
                    v = ( v - min( v( : ) ) ) ./ ...
                        ( max( v( : ) ) - min( v( : ) ) );
                    above = threshold < v;
                    below = below & ~above;
                    nthresh( tag ) = threshold;
                    
                end
                
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
                
                obj.update_threshold_markers( nthresh, usage_states );
                
                obj.axes_handle.YLim = [ 0 1 ];
                
            end
            
        end
        
    end
    
    
    properties ( Access = private )
        
        titles
        data
        
        figure_handle
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
            
            obj.figure_handle = [];
            obj.axes_handle = [];
            obj.line_handles = [];
            obj.threshold_handles = [];
            closereq();
            
        end
        
        
        function update_threshold_markers( obj, thresholds, usage_states )
            
            if isempty( obj.threshold_handles )
                obj.create_threshold_markers( thresholds );
            end
            
            tags = obj.titles.keys();
            for i = 1 : obj.titles.Count()

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
            tags = obj.titles.keys();
            for i = 1 : obj.titles.Count()
                
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

