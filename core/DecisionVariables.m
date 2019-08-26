classdef DecisionVariables < handle
    
    properties ( SetAccess = private )
        angles(1,:) double {mustBeReal,mustBeFinite}
    end
    
    properties ( SetAccess = private, Dependent )
        count(1,1) double {mustBeReal,mustBeFinite,mustBePositive}
        tags(1,:) string
        titles(1,:) string
        lower_bounds(1,:) double {mustBeReal,mustBeFinite}
        upper_bounds(1,:) double {mustBeReal,mustBeFinite}
    end
    
    methods
        function obj = DecisionVariables( angles )
            obj.angles = angles;
        end
        
        function value = get.count( obj )
            value = numel( obj.titles );
        end
        
        function value = get.tags( ~ )
            value = [ "phi" "theta" ];
        end
        
        function value = get.titles( ~ )
            value = [ "Phi" "Theta" ];
        end
        
        function value = get.lower_bounds( ~ )
            [ phi, theta ] = unit_sphere_ranges();
            value = [ phi( 1 ) theta( 1 ) ];
        end
        
        function value = get.upper_bounds( ~ )
            [ phi, theta ] = unit_sphere_ranges();
            value = [ phi( 2 ) theta( 2 ) ];
        end
    end
    
end

