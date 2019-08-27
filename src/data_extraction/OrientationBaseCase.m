classdef OrientationBaseCase < Saveable
    
    properties ( SetAccess = private )
        settings Settings
    end
    
    properties ( SetAccess = private, Dependent )
        name(1,1) string
        file(1,1) string
    end
    
    methods
        function obj = OrientationBaseCase( settings )
            user_needs = settings.manager.user_needs;
            cleaner = onCleanup( @()obj.restore_user_needs( settings, user_needs ) );
            settings.manager.user_needs = { "Casting" "Feeders" };
            
            pm = ProcessManager( settings );
            pm.run();
            casting = pm.get( ProcessKey( Casting.NAME ) );
            feeders = pm.get( ProcessKey( Feeders.NAME ) );
            
            obj.settings = settings;
            obj.casting = casting;
            obj.feeders = feeders;
        end
        
        function rotated_case = generate_rotated_case( obj, angles )
            assert( isa( angles, 'double' ) );
            assert( isreal( angles ) );
            assert( all( isfinite( angles ) ) );
            assert( isvector( angles ) );
            assert( numel( angles ) == 2 );
            
            r = Rotation();
            r.angles = [ angles 0 ];
            r.origin = obj.casting.centroid;
            c = obj.casting.rotate( r );
            f = obj.feeders.rotate( r );
            
            rotated_case = Results( obj.settings );
            rotated_case.add( ProcessKey( c.NAME ), c );
            rotated_case.add( ProcessKey( f.NAME ), f );
        end
        
        function name = get.name( obj )
            name = obj.casting.name;
        end
        
        function file = get.file( obj )
            file = obj.casting.input_file;
            file = string( file );
            assert( file ~= "" );
        end
    end
    
    properties ( Access = private )
        casting Casting
        mesh Mesh
        feeders Feeders
    end
    
    methods ( Access = private, Static )
        function restore_user_needs( settings, user_needs )
            settings.manager.user_needs = user_needs;
        end
    end
    
end

