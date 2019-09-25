classdef ConstrainedNumericValue < handle
    
    properties
        range(1,2) double {mustBeReal,mustBeFinite} = [ 0 1 ]
    end
    
    properties ( Dependent )
        ratio(1,1) double {mustBeReal,mustBeFinite}
    end
    
    properties ( SetAccess = private )
        value(1,1) double {mustBeReal,mustBeFinite} = 0.5
    end
    
    methods
        function changed = update( obj, new_value )
            constrained_value = obj.constrain_value( new_value );
            changed = obj.has_changed( constrained_value );
            obj.value = constrained_value;
        end
        
        function set.range( obj, v )
            v = sort( v );
            assert( 0 < diff( v ) );
            
            new_value = obj.ratio * diff( v ) + v( 1 ); %#ok<MCSUP>
            obj.range = v;
            obj.update( new_value );
        end
        
        function set.ratio( obj, v )
            assert( 0.0 <= v );
            assert( v <= 1.0 );
            
            r = obj.range;
            obj.update( v * diff( r ) + r( 1 ) );
        end
        
        function v = get.ratio( obj )
            v = ( obj.value - obj.range( 1 ) ) ./ diff( obj.range );
        end
    end
    
    methods ( Access = private )
        function value = constrain_value( obj, new_value )
            if isnan( new_value )
                value = obj.value;
            elseif new_value < obj.range( 1 )
                value = obj.range( 1 );
            elseif obj.range( 2 ) < new_value
                value = obj.range( 2 );
            else
                value = new_value;
            end
        end
        
        function changed = has_changed( obj, constrained_value )
            changed = constrained_value ~= obj.value;
        end
    end
    
end

