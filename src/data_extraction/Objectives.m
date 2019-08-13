classdef Objectives < handle
    
    properties ( SetAccess = private, Dependent )
        name(1,1) string
        summary table
        objectives(1,:) double {mustBeReal,mustBeFinite}
    end
    
    methods
        function obj = Features( process_manager )
            obj.process_manager = process_manager;
        end
        
        function write( obj, file )
            writetable( obj.summary, file );
        end
        
        function value = get.name( obj )
            c = obj.get_casting();
            value = c.name;
        end
        
        function value = get.summary( obj )
            value = obj.get_feature_table();
        end
        
        function value = get.objectives( obj )
            value = obj.summary;
            value = value{ :, : };
            
            assert( isa( value, 'double' ) );
        end
    end
    
    properties
        process_manager ProcessManager
    end
    
    methods ( Access = private )
        function c = get_casting( obj )
            c = obj.process_manager.get( ProcessKey( Casting.NAME ) );
        end
        
        function t = get_feature_table( obj )
            s = obj.process_manager.compose_summary();
            m = table2map( s );
            p = containers.Map( 'keytpye', 'char', 'valuetype', 'any' );
            p( 'Feeder_inaccessibility' ) = m( 'Feeders_median_accessibility' );
            p( 'Feeder_interface_area' ) = m( 'Feeders_sum_interface_area' ) ./ m( 'Casting_surface_area' );
            p( 'Projected_area' ) = m( 'Parting_area' ) ./ m( 'Casting_surface_area' );
            p( 'Parting_line_flatness' ) = m( 'Parting_flatness' );
            p( 'Draw' ) = m( 'Parting_draw' ) ./ m( 'Casting_bounding_sphere_diameter' );
            p( 'Undercut_count' ) = m( 'Undercuts_count' );
            p( 'Undercut_volume' ) = m( 'Undercuts_volume' ) ./ m( 'Casting_convex_volume' );
            t = map2table( p );
        end
    end
    
end

