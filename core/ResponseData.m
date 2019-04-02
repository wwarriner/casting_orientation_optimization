classdef ResponseData < handle
    
    % all expect radians
    methods ( Access = public )
        
        function obj = ResponseData( data_extractor )
            
            obj.name = data_extractor.get_name();
            obj.titles = data_extractor.get_titles();
            obj.values = data_extractor.get_objective_values();
            obj.minima = data_extractor.get_minima_points();
            obj.pareto_front = data_extractor.get_pareto_front_points();
            obj.quantiles = data_extractor.get_quantile_interpolants( obj.values );
            obj.phi_grid = data_extractor.get_phi_grid();
            obj.theta_grid = data_extractor.get_theta_grid();
            
        end
        
        
        function name = get_name( obj )
            
            name = obj.name;
            
        end
        
        
        function count = get_count( obj )
            
            count = obj.titles.Count();
            
        end
        
        
        function titles = get_titles( obj )
            
            titles = obj.titles;
            
        end
        
        
        function grid = get_phi_grid( obj )
            
            grid = obj.phi_grid;
            
        end
        
        
        function grid = get_theta_grid( obj )
            
            grid = obj.theta_grid;
            
        end
        
        
        function value = get_objective_value( obj, point, objective )
            
            indices = obj.snap_to_grid_indices( point );
            [ PHI_INDEX, THETA_INDEX ] = unit_sphere_plot_indices();
            v = obj.get_objective_values( objective );
            value = v( indices( THETA_INDEX ), indices( PHI_INDEX ) );
            
        end
        
        
        function values = get_objective_value_ranges( obj )
            
            values = containers.Map( ...
                'keytype', 'char', ...
                'valuetype', 'any' ...
                );
            tags = obj.titles.keys();
            for i = 1 : obj.get_count()
                
                tag = tags{ i };
                values( tag ) = obj.get_objective_value_range( tag );
                
            end
            
        end
        
        
        function values = get_objective_value_range( obj, objective )
            
            values.min = min( obj.get_objective_values( objective ), [], 'all' );
            values.max = max( obj.get_objective_values( objective ), [], 'all' );
            
        end
        
        
        function values = get_objective_values( obj, objective )
            
            values = obj.values( objective );
            
        end
        
        
        function point = get_minimum( obj, objective )
            
            point = obj.minima( objective );
            
        end
        
        
        function points = get_pareto_front( obj )
            
            points = obj.pareto_front;
            
        end
        
        
        function values = get_quantile_values( obj, quantile, objective )
            
            assert( 0 <= quantile );
            assert( quantile <= 1 );
            
            interpolant = obj.quantiles( objective );
            threshold = interpolant( quantile );
            values = obj.get_thresholded_values( threshold, objective );
            
        end
        
        
        function values = get_thresholded_values( obj, threshold, objective )
            
            values = obj.get_objective_values( objective );
            values = threshold < values;
            
        end
        
        
        function values = get_no_go_values( ...
                obj, ...
                thresholds, ...
                usage_states, ...
                use_quantiles ...
                )
            
            count = thresholds.Count();
            tags = thresholds.keys();
            values = true( size( obj.phi_grid ) );
            for i = 1 : count
                
                tag = tags{ i };
                if ~usage_states( tag )
                    continue;
                end
                
                threshold = thresholds( tag );
                if use_quantiles
                    above = obj.get_quantile_values( threshold, tag );
                else
                    above = obj.get_thresholded_values( threshold, tag );
                end
                values = values & ~above;
                
            end
            values = ~values;
            
        end
        
        
        function point = snap_to_grid( obj, point )
            
            indices = obj.snap_to_grid_indices( point );
            [ PHI_INDEX, THETA_INDEX ] = unit_sphere_plot_indices();
            point = [ ...
                obj.phi_grid( indices( THETA_INDEX ), indices( PHI_INDEX ) ) ...
                obj.theta_grid( indices( THETA_INDEX ), indices( PHI_INDEX ) ) ...
                ];
            
        end
        
    end
    
    
    properties ( Access = private )
        
        name
        titles
        values
        minima
        pareto_front
        quantiles
        phi_grid
        theta_grid
        
    end
    
    
    methods ( Access = private )
        
        function indices = snap_to_grid_indices( obj, point )
            
            [ PHI_INDEX, THETA_INDEX ] = unit_sphere_plot_indices();
            phi_index = round( ...
                ( point( PHI_INDEX ) + pi ) ...
                * size( obj.phi_grid, 2 ) ...
                ./ ( 2 * pi ) ...
                );
            phi_index = min( phi_index, size( obj.phi_grid, 2 ) );
            indices( PHI_INDEX ) = max( phi_index, 1 );
            
            theta_index = round( ...
                ( point( THETA_INDEX ) + pi / 2 ) ...
                * size( obj.theta_grid, 1 ) ...
                ./ pi ...
                );
            theta_index = min( theta_index, size( obj.theta_grid, 1 ) );
            indices( THETA_INDEX ) = max( theta_index, 1 );
            
        end
        
    end
    
end

