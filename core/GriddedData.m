classdef GriddedData < handle
    
    properties ( SetAccess = private )
        phi_resolution(1,1) double {mustBeReal,mustBeFinite,mustBePositive} = 1
        theta_resolution(1,1) double {mustBeReal,mustBeFinite,mustBePositive} = 1
        phi_grid(:,:) double {mustBeReal,mustBeFinite}
        theta_grid(:,:) double {mustBeReal,mustBeFinite}
    end
    
    properties ( SetAccess = private, Dependent )
        grid_size(1,:) double {mustBeReal,mustBeFinite,mustBePositive}
    end
    
    methods
        function obj = GriddedData( orientation_data, resolution )
            [ phi_grid, theta_grid ] = ...
                unit_sphere_mesh_grid( resolution );
            value_grids = obj.construct_value_grids( ...
                phi_grid, ...
                theta_grid, ...
                orientation_data.objective_tags, ...
                orientation_data.decisions, ...
                orientation_data.objectives, ...
                orientation_data.interp_methods ...
                );
            value_ranges = containers.Map( ...
                "keytype", "char", ...
                "valuetype", "any" ...
                );
            for i = 1 : orientation_data.objective_count
                tag = orientation_data.objective_tags( i );
                value_ranges( tag ) = [ ...
                    min( orientation_data.get_by_tag( tag ) ) ...
                    max( orientation_data.get_by_tag( tag ) ) ...
                    ];
            end
            quantile_interps = obj.construct_quantile_inverse_interpolants( ...
                theta_grid, ...
                value_grids, ...
                value_ranges, ...
                orientation_data.objective_tags ...
                );
            quantile_grids = obj.convert_to_quantiles( ...
                value_grids, ...
                quantile_interps ...
                );
            
            obj.phi_grid = phi_grid;
            obj.theta_grid = theta_grid;
            obj.values = value_grids;
            obj.quantiles = quantile_grids;
            obj.quantile_interps = quantile_interps;
        end
        
        function value = get_values( obj, tag )
            value = obj.values( tag );
        end
        
        function value = get_thresholded( obj, threshold, tag )
            value = obj.get_values( tag );
            value = threshold < value;
        end
        
        function value = get_no_go( obj, thresholds, active_states )
            tags = thresholds.keys();
            value = true( size( obj.phi_grid ) );
            for i = 1 : thresholds.Count()
                tag = tags{ i };
                if ~active_states( tag )
                    continue;
                end
                threshold = thresholds( tag );
                above = obj.get_thresholded( threshold, tag );
                value = value & ~above;
            end
            value = ~value;
        end
        
        function value = get_quantile_values( obj, tag )
            value = obj.quantiles( tag );
        end
        
        function value = get_quantile_thresholded( obj, threshold, tag )
            value = obj.get_quantiles( tag );
            value = threshold < value;
        end
        
        function value = get_quantile_no_go( obj, thresholds, active_states )
            tags = thresholds.keys();
            value = true( size( obj.phi_grid ) );
            for i = 1 : thresholds.Count()
                tag = tags{ i };
                if ~active_states( tag )
                    continue;
                end
                threshold = thresholds( tag );
                above = obj.get_quantile_thresholded( threshold, tag );
                value = value & ~above;
            end
            value = ~value;
        end
        
        function quantiles = to_quantile( obj, values, tag )
            interp = obj.quantile_interps( tag );
            quantiles = interp( values );
        end
        
        function value = get.grid_size( obj )
            value = size( obj.phi_grid );
        end
    end
    
    properties ( Access = private )
        values containers.Map
        quantiles containers.Map
        quantile_interps containers.Map
    end
    
    methods ( Access = private, Static )
        function value = construct_value_grids( ...
                phi_grid, ...
                theta_grid, ...
                tags, ...
                decisions, ...
                objectives, ...
                interp_methods ...
                )
            value = containers.Map( ...
                "keytype", "char", ...
                "valuetype", "any" ...
                );
            for i = 1 : numel( tags )
                interpolator = generate_unit_sphere_scattered_interpolant( ...
                    decisions, ...
                    objectives( :, i ), ...
                    interp_methods( i ) ...
                    );
                value( tags( i ) ) = interpolator( phi_grid, theta_grid );
            end
        end
        
        function interpolators = construct_quantile_inverse_interpolants( ...
                theta_grid, ...
                values, ...
                value_ranges, ...
                tags ...
                )
            interpolators = containers.Map( ...
                "keytype", "char", ...
                "valuetype", "any" ...
                );
            for i = 1 : numel( tags )
                tag = tags( i );
                v = values( tag );
                vr = value_ranges( tag );
                v = [ v( : ); vr( : ) ];
                tg = [ theta_grid( : ); zeros( size( vr( : ) ) ) ];
                interpolators( tag ) = generate_unit_sphere_quantile_inverse_interpolant( ...
                    tg( : ), ...
                    v( : ), ...
                    "linear" ...
                    );
            end
        end
        
        function quantiles = convert_to_quantiles( values, interps )
            tags = string( values.keys() );
            quantiles = containers.Map( ...
                "keytype", "char", ...
                "valuetype", "any" ...
                );
            for i = 1 : values.Count()
                tag = tags( i );
                interp = interps( tag );
                quantiles( tag ) = interp( values( tag ) );
            end
        end
    end
end

