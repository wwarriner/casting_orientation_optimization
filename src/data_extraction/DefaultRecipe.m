classdef DefaultRecipe < OrientationRecipeInterface
    
    methods
        % @evaluate uses the input @decisions to transform an
        % OrientationBaseCase object into an OrientationData object.
        % Inputs:
        % - @base_case, an OrientationBaseCase object.
        % - @angles, a real, finite, double vector of angles representing
        % the decision variables
        % Outputs:
        % - @data, an OrientationData object.
        function data = evaluate( obj, base_case, angles )
            assert( isa( base_case, "OrientationBaseCase" ) );
            assert( isscalar( base_case ) );
            
            assert( isa( angles, "double" ) );
            assert( isvector( angles ) );
            angles = angles( 1 : 2 );
            
            rotated_case = base_case.generate_rotated_case( angles );
            rotated_case.get( ProcessKey( Parting.NAME ) );
            rotated_case.get( ProcessKey( Undercuts.NAME ) );
            
            [ t, interp ] = obj.get_objective_table( rotated_case );
            objective_tags = t.Properties.VariableNames;
            objective_titles = make_title( objective_tags );
            interp_methods = interp;
            
            decision_tags = [ "phi" "theta" ];
            decision_titles = make_title( decision_tags );
            t = [ table( angles( 1 ), angles( 2 ), 'variablenames', decision_tags ) t ];
            
            stl_file = base_case.file;
            
            props = { ...
                decision_tags ...
                decision_titles ...
                objective_tags ...
                objective_titles ...
                interp_methods ...
                stl_file ...
                };
            prop_names = [ ...
                "decision_tags" ...
                "decision_titles" ...
                "objective_tags" ...
                "objective_titles" ...
                "interp_methods" ...
                "stl_file" ...
                ];
            t = addprop( t, prop_names, repmat( "table", size( prop_names ) ) );
            
            assert( numel( props ) == numel( prop_names ) );
            for i = 1 : numel( props )
                t.Properties.CustomProperties.( prop_names( i ) ) = props{ i };
            end
            
            data = OrientationData( t );
        end
    end
    
    methods ( Access = private, Static )
        function [ t, interp ] = get_objective_table( rotated_case )
            s = rotated_case.compose_summary();
            m = table2map( s );
            
            p = containers.Map( "keytype", "char", "valuetype", "any" );
            i = containers.Map( "keytype", "char", "valuetype", "any" );
            
            k = "feeder_median_inaccessibility";
            p( k ) = 1 - m( "Feeders_median_accessibility" );
            i( k ) = "linear";
            
            k = "feeder_max_inaccessibility";
            p( k ) = 1 - m( "Feeders_min_accessibility" );
            i( k ) = "linear";
            
            k = "feeder_interface_area";
            area = m( "Casting_surface_area" ) + m( "Feeders_sum_surface_area" );
            p( k ) = m( "Feeders_sum_interface_area" ) ./ area;
            i( k ) = "linear";
            
            k = "parting_reciprocal_projected_area";
            p( k ) = m( "Casting_surface_area" ) ./ m( "Parting_area" );
            i( k ) = "linear";
            
            k = "parting_flatness";
            p( k ) = 1 - ( 1 ./ m( "Parting_flatness" ) );
            i( k ) = "linear";
            
            k = "parting_draw";
            p( k ) = m( "Parting_draw" ) ./ ( 2 * m( "Casting_bounding_sphere_diameter" ) );
            i( k ) = "linear";
            
            k = "undercut_count";
            p( k ) = m( "Undercuts_count" );
            i( k ) = "nearest";
            
            k = "undercut_volume";
            p( "undercut_volume" ) = m( "Undercuts_volume" ) ./ m( "Casting_convex_volume" );
            i( k ) = "linear";
            
            t = map2table( p );
            interp = i.values();
            interp = [ interp{ : } ];
        end
    end
    
end

