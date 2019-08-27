classdef (Abstract) OrientationRecipeInterface < handle
    
    methods ( Abstract )
        % @evaluate uses the input @decisions to transform an
        % OrientationBaseCase object into an OrientationData object.
        % Inputs:
        % - @base_case, an OrientationBaseCase object.
        % - @angles, a real, finite, double vector of angles representing
        % the decision variables
        % Outputs:
        % - @data, an OrientationData object.
        data = evaluate( obj, base_case, angles )
    end
    
end

