classdef DataExtractor < handle
    
    methods ( Access = public )
        
        function obj = DataExtractor( data_table, metadata, resolution )
            
            name = metadata.Name;
            
            ov = ObjectiveVariables( metadata.ObjectiveVariablesPath );
            titles = ov.get_titles();
            tags = ov.get_tags();
            interp_methods = ov.get_interpolation_methods();
            
            start = metadata.ObjectiveStartColumn;
            finish = size( data_table, 2 );
            count = finish - start + 1;
            
            assert( ov.get_objective_count() == count );
            assert( numel( titles ) == count );
            assert( numel( tags ) == count );
            
            obj.name = name;
            obj.titles = titles;
            obj.tags = tags;
            obj.interp_methods = interp_methods;
            obj.data = data_table;
            
            [ obj.phi_resolution, obj.theta_resolution ] = ...
                unit_sphere_grid_resolution( resolution );
            
            [ obj.phi_grid, obj.theta_grid ] = ...
                unit_sphere_mesh_grid( resolution );
            
            obj.objective_count = count;
            obj.objective_indices = start : finish;
            
            obj.decision_count = size( data_table, 1 );
            obj.decision_indices = 1 : metadata.DecisionEndColumn;
            
        end
        
        
        function name = get_name( obj )
            
            name = obj.name;
            
        end
        
        
        function count = get_objective_count( obj )
            
            count = obj.objective_count;
            
        end
        
        
        function count = get_decision_count( obj )
            
            count = obj.decision_count;
            
        end
        
        
        function titles = get_titles( obj )
            
            titles = containers.Map( ...
                'keytype', 'char', ...
                'valuetype', 'any' ...
                );
            for i = 1 : obj.objective_count
                
                tag = obj.get_tag( i );
                titles( tag ) = obj.titles{ i };
                
            end
            
        end
        
        
        function grid = get_phi_grid( obj )
            
            grid = obj.phi_grid;
            
        end
        
        
        function grid = get_theta_grid( obj )
            
            grid = obj.theta_grid;
            
        end
        
        
        function values = get_objective_values( obj )
            
            values = containers.Map( ...
                'keytype', 'char', ...
                'valuetype', 'any' ...
                );
            for i = 1 : obj.objective_count
                
                tag = obj.get_tag( i );
                interpolator = generate_unit_sphere_scattered_interpolant( ...
                    obj.data{ :, obj.decision_indices }, ...
                    obj.data{ :, tag }, ...
                    obj.interp_methods{ i } ...
                    );
                values( tag ) = interpolator( obj.phi_grid, obj.theta_grid );
                
            end
            
        end
        
        
        function points = get_minima_points( obj )
            
            points_uncorrected = nan( obj.objective_count, 2 );
            for i = 1 : obj.objective_count
                
                values = obj.data{ :, obj.objective_indices( i ) };
                [ ~, index ] = min( values( : ) );
                points_uncorrected( i, : ) = obj.data{ index, obj.decision_indices };
                
            end
            assert( ~any( isnan( points_uncorrected( : ) ) ) );
            
            points_corrected = points_uncorrected;
            TOL = 1e-3;
            points_corrected( :, 1 ) = min( pi - TOL, max( -pi + TOL, points_uncorrected( :, 1 ) ) );
            points_corrected( :, 2 ) = min( pi / 2 - TOL, max( -pi / 2 + TOL, points_uncorrected( :, 2 ) ) );
            
            points = containers.Map( ...
                'keytype', 'char', ...
                'valuetype', 'any' ...
                );
            for i = 1 : obj.objective_count
                
                points( obj.get_tag( i ) ) = points_corrected( i, : );
                
            end
            
        end
        
        
        function points = get_pareto_front_points( obj )
            
            points = [ ...
                obj.data.phi( obj.data.is_pareto_dominant ) ...
                obj.data.theta( obj.data.is_pareto_dominant ) ...
                ];
            
        end
        
        
        function values = get_pareto_front_values( obj )
            
            values = containers.Map( ...
                'keytype', 'char', ...
                'valuetype', 'any' ...
                );
            for i = 1 : obj.objective_count
                
                tag = obj.get_tag( i );
                values( tag ) = obj.data{ obj.data.is_pareto_dominant, tag };
                
            end
            
        end
        
        
        function interpolators = get_quantile_interpolants( obj, objective_values )
            
            interpolators = containers.Map( ...
                'keytype', 'char', ...
                'valuetype', 'any' ...
                );
            for i = 1 : obj.objective_count
                
                tag = obj.get_tag( i );
                interpolators( tag ) = generate_unit_sphere_quantile_interpolant( ...
                    obj.theta_grid, ...
                    objective_values( tag ), ...
                    'linear' ...
                    );
                
            end
            
        end
        
        
        function interpolators = get_quantile_inverse_interpolants( obj, objective_values )
            
            interpolators = containers.Map( ...
                'keytype', 'char', ...
                'valuetype', 'any' ...
                );
            for i = 1 : obj.objective_count
                
                tag = obj.get_tag( i );
                interpolators( tag ) = generate_unit_sphere_quantile_inverse_interpolant( ...
                    obj.theta_grid, ...
                    objective_values( tag ), ...
                    'linear' ...
                    );
                
            end
            
        end
        
    end
    
    
    properties ( Access = private )
        
        name
        titles
        tags
        interp_methods
        data
        
        phi_resolution
        theta_resolution
        
        phi_grid
        theta_grid
        
        start
        objective_count
        objective_indices
        
        decision_count
        decision_indices
        
    end
    
    
    methods ( Access = private )
        
        function tag = get_tag( obj, objective )
            
            tag = obj.tags{ objective };
            
        end
        
    end
    
end

