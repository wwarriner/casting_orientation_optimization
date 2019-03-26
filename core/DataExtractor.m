classdef DataExtractor < handle
    
    methods ( Access = public )
        
        function obj = DataExtractor( data_table, metadata, resolution )
            
            name = metadata.Name;
            
            ov = ObjectiveVariables( metadata.ObjectiveVariablesPath );
            titles = ov.get_display_titles();
            tags = ov.get_titles();
            interp_methods = ov.get_interpolation_methods();
            
            start = metadata.ObjectiveStartColumn;
            finish = size( data_table, 2 );
            count = finish - start + 1;
            
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
            
            titles = obj.titles;
            
        end
        
        
        function grid = get_phi_grid( obj )
            
            grid = obj.phi_grid;
            
        end
        
        
        function grid = get_theta_grid( obj )
            
            grid = obj.theta_grid;
            
        end
        
        
        function values = get_objective_values( obj )
            
            values = nan( ...
                obj.theta_resolution, ...
                obj.phi_resolution, ...
                obj.objective_count ...
                );            
            for i = 1 : obj.objective_count
                
                interpolator = generate_unit_sphere_scattered_interpolant( ...
                    obj.data{ :, obj.decision_indices }, ...
                    obj.data{ :, obj.get_tag( i ) }, ...
                    obj.interp_methods{ i } ...
                    );
                values( :, :, i ) = interpolator( obj.phi_grid, obj.theta_grid );
                
            end
            assert( ~any( isnan( values( : ) ) ) );
            
        end
        
        
        function points = get_minima_points( obj )
            
            points = nan( obj.objective_count, 2 );
            for i = 1 : obj.objective_count
                
                values = obj.data{ :, obj.objective_indices( i ) };
                [ ~, index ] = min( values( : ) );
                points( i, : ) = obj.data{ index, obj.decision_indices };
                
            end
            assert( ~any( isnan( points( : ) ) ) );
            
            TOL = 1e-3;
            points( :, 1 ) = min( pi - TOL, max( -pi + TOL, points( :, 1 ) ) );
            points( :, 2 ) = min( pi / 2 - TOL, max( -pi / 2 + TOL, points( :, 2 ) ) );
            
        end
        
        
        function points = get_pareto_front_points( obj )
            
            points = [ ...
                obj.data.phi( obj.data.is_pareto_dominant ) ...
                obj.data.theta( obj.data.is_pareto_dominant ) ...
                ];
            
        end
        
        
        function interpolators = get_quantile_interpolants( obj, objective_values )
            
            interpolators = cell( obj.objective_count );
            for i = 1 : obj.objective_count
                
                interpolators{ i } = generate_unit_sphere_quantile_interpolant( ...
                    obj.theta_grid, ...
                    objective_values( :, :, i ), ...
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
    
%         function [ objective_values, titles, display_titles, interp_methods ] = ...
%                 append_scaled_maximum_objective( objective_values, titles, display_titles, interp_methods )
%             
%             temp = objective_values;
%             removes = [];
%             for i = 1 : size( objective_values, 3 )
% %                 if strcmpi( titles{ i }, 'draft_metric' ) || strcmpi( titles{ i }, 'fd_inaccessibility_max' )
% %                     removes = [ removes i ];
% %                     continue;
% %                 end % debug only
%                 temp( :, :, i ) = rescale( temp( :, :, i ) );
%             end
%             temp( :, :, removes ) = [];
%             objective_values( :, :, end + 1 ) = max( temp, [], 3 );
%             titles{ end + 1 } = 'scaled_maximum_over_all';
%             display_titles{ end + 1 } = 'Maximum of Normalized Values';
%             interp_methods{ end + 1 } = 'natural';
%             
%         end
    
end
