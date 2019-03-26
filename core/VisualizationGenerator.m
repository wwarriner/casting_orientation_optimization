classdef VisualizationGenerator < handle
    
    methods ( Access = public )
        
        function obj = VisualizationGenerator( ...
                component, ...
                feeders ...
                )
            
            obj.component = component;
            obj.feeders = feeders;
            
        end
        
        
        function draw( obj, axes_handle, angles )
            
            obj.draw_component( axes_handle, angles );
            obj.draw_feeders( axes_handle, angles );
            bounds = obj.get_bounds( angles );
            obj.draw_mold( axes_handle, bounds );
            obj.draw_reference_axes( axes_handle, bounds );
            
        end
                
        
    end
    
    
    properties ( Access = private )
        
        component
        feeders
        
    end
    
    
    methods ( Access = private )
        
        function rch = draw_component( obj, axes_handle, angles )
            
            rotated_component_fv = obj.rotate_component( angles );
            rch = patch( axes_handle, rotated_component_fv );
            rch.SpecularStrength = 0;
            rch.FaceColor = [ 0.9 0.9 0.9 ];
            rch.EdgeColor = 'none';
            
        end
        
        
        function rfh = draw_feeders( obj, axes_handle, angles )
            
            rotated_feeder_fvs = obj.rotate_feeders( angles );
            count = numel( rotated_feeder_fvs );
            rfh = gobjects( count, 1 );
            for i = 1 : count
                
                rfh( i ) = patch( axes_handle, rotated_feeder_fvs{ i } );
                rfh( i ).SpecularStrength = 0;
                rfh( i ).FaceColor = [ 0.75 0.0 0.0 ];
                rfh( i ).FaceAlpha = 0.5;
                rfh( i ).EdgeColor = 'none';
                
            end
            
        end
        
        
        function bounds = get_bounds( obj, angles )
            
            all_fvs = [ ...
                obj.rotate_feeders( angles ); ...
                obj.rotate_component( angles ) ...
                ];
            min_point = [ inf inf inf ];
            max_point = [ -inf -inf -inf ];
            for i = 1 : numel( all_fvs )
                
                curr_min_point = min( all_fvs{ i }.vertices );
                min_point = min( [ curr_min_point; min_point ] );
                
                curr_max_point = max( all_fvs{ i }.vertices );
                max_point = max( [ curr_max_point; max_point ] );
                
            end
            bounds.min = min_point;
            bounds.max = max_point;
            
        end
        
        
        function mh = draw_mold( obj, axes_handle, bounds )
            
            bm = BasicMold( bounds.min, bounds.max, obj.component.centroid );
            mh = bm.draw( axes_handle );
            
        end
        
        
        function draw_reference_axes( obj, axes_handle, bounds )
            
            pa = PrettyAxes3D( bounds.min, bounds.max, obj.component.centroid );
            pa.draw( axes_handle );
            
        end
        
        
        function fv = rotate_component( obj, angles )
            
            rc = obj.component.rotate( obj.create_rotator( angles ) );
            fv = rc.fv;
            
        end
        
        
        function fvs = rotate_feeders( obj, angles )
            
            fvs = obj.feeders.rotate_fvs_only( obj.create_rotator( angles ) );
            
        end
        
        
        function rotator = create_rotator( obj, angles )
            
            rotator = Rotator( angles, obj.component.centroid );
            
        end
        
    end
    
end

