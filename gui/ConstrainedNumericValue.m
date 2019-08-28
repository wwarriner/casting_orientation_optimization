classdef ConstrainedNumericValue < handle
    
    methods ( Access = public )
        function obj = ConstrainedNumericValue( min, max, initial )
            obj.min = min;
            obj.max = max;
            obj.value = initial;
        end
        
        function changed = update( obj, new_value )
            constrained_value = obj.constrain_value( new_value );
            changed = obj.has_changed( constrained_value );
            obj.set_value( constrained_value );
        end
        
        function value = get_value( obj )
            value = obj.value;
        end
        
        function min = get_min( obj )
            min = obj.min;
        end
        
        function max = get_max( obj )
            max = obj.max;
        end
        
        function range = get_range( obj )
            range.min = obj.get_min();
            range.max = obj.get_max();
        end
        
        function set_range( obj, new_min, new_max )
            assert( new_min < new_max );
            
            ratio = ( obj.value - obj.min ) / ( obj.max - obj.min );
            new_value = ratio * ( new_max - new_min ) + new_min;
            obj.min = new_min;
            obj.max = new_max;
            obj.update( new_value );
        end
    end
    
    properties ( Access = private )
        min
        max
        value
    end
    
    methods ( Access = private )
        function value = constrain_value( obj, new_value )
            if isnan( new_value )
                value = obj.value;
            elseif new_value < obj.min
                value = obj.min;
            elseif obj.max < new_value
                value = obj.max;
            else
                value = new_value;
            end
        end
        
        function changed = has_changed( obj, constrained_value )
            changed = constrained_value ~= obj.value;
        end
        
        function set_value( obj, value )
            obj.value = value;
        end
    end
    
end

