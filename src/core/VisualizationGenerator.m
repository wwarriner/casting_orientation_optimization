classdef VisualizationGenerator < handle
    
    methods
        function obj = VisualizationGenerator( base_case )
            obj.base_case = base_case;
        end
        
        function draw( obj, axh, angles )
            assert( isa( axh, "matlab.graphics.axis.Axes" ) );
            
            assert( isa( angles, "double" ) );
            assert( isreal( angles ) );
            assert( all( isfinite( angles ) ) );
            assert( numel( angles ) == 2 );
            
            casting_body = obj.base_case.rotate_casting_body( angles );
            obj.draw_casting( axh, casting_body );
            
            feeder_bodies = obj.base_case.rotate_feeder_bodies( angles );
            obj.draw_feeders( axh, feeder_bodies );
            
            envelope = obj.unify_envelope( casting_body, feeder_bodies );
            obj.draw_mold( axh, envelope, casting_body.centroid );
            obj.draw_reference_axes( axh, envelope, casting_body.centroid );
        end
    end
    
    properties ( Access = private )
        base_case OrientationBaseCase
    end
    
    methods ( Access = private, Static )
        function handle = draw_casting( axh, casting_body )
            handle = patch( axh, casting_body.fv );
            handle.SpecularStrength = 0;
            handle.FaceColor = [ 0.9 0.9 0.9 ];
            handle.FaceAlpha = 0.5;
            handle.EdgeColor = 'none';
        end
        
        function handle = draw_feeders( axh, feeder_bodies )
            count = numel( feeder_bodies );
            handle = gobjects( count, 1 );
            for i = 1 : count
                handle( i ) = patch( axh, feeder_bodies( i ).fv );
                handle( i ).SpecularStrength = 0;
                handle( i ).FaceColor = [ 0.75 0.0 0.0 ];
                handle( i ).FaceAlpha = 1.0;
                handle( i ).EdgeColor = 'none';
            end
        end
        
        function envelope = unify_envelope( casting_body, feeder_bodies )
            envelope = casting_body.envelope;
            for i = 1 : numel( feeder_bodies )
                envelope = envelope.union( feeder_bodies( i ).envelope );
            end
        end
        
        function mh = draw_mold( axh, envelope, origin )
            bm = BasicMold( ...
                envelope.min_point, ...
                envelope.max_point, ...
                origin ...
                );
            mh = bm.draw( axh );
        end
        
        function draw_reference_axes( axh, envelope, origin )
            pa = PrettyAxes3D( ...
                envelope.min_point, ...
                envelope.max_point, ...
                origin ...
                );
            pa.draw( axh );
        end
    end
    
end

