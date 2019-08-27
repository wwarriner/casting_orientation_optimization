classdef OrientationData < handle
    
    properties ( SetAccess = private )
        decision_tags(1,:) string
        decision_titles(1,:) string
        objective_tags(1,:) string
        objective_titles(1,:) string
        stl_file(1,1) string
    end
    
    properties ( SetAccess = private, Dependent )
        decision_count(1,1) double
        decisions(:,:) double
        pareto_decisions(:,:) double
        objective_count(1,1) double
        objectives(:,:) double
        pareto_objectives(:,:) double
    end
    
    methods
        function obj = OrientationData( data )
            assert( istable( data ) );
            assert( all( varfun( @isnumeric, data ) ) );
            
            props = data.Properties.CustomProperties;
            assert( isprop( props, "decision_tags" ) );
            assert( isprop( props, "decision_titles" ) );
            assert( isprop( props, "objective_tags" ) );
            assert( isprop( props, "objective_titles" ) );
            assert( isprop( props, "pareto_tag" ) );
            assert( isprop( props, "stl_file" ) );
            
            var_names = data.Properties.VariableNames;
            
            decision_tags = props.decision_tags;
            if ischar( decision_tags )
                decision_tags = string( decision_tags );
            end
            assert( isstring( decision_tags ) );
            assert( isvector( decision_tags ) );
            assert( numel( unique( decision_tags ) ) == numel( decision_tags ) );
            assert( all( ismember( decision_tags, var_names ) ) );
            
            decision_titles = props.decision_titles;
            if ischar( decision_titles )
                decision_titles = string( decision_titles );
            end
            assert( isstring( decision_titles ) );
            assert( isvector( decision_titles ) );
            assert( numel( unique( decision_titles ) ) == numel( decision_titles ) );
            assert( numel( decision_titles ) == numel( decision_tags ) );
            
            objective_tags = props.objective_tags;
            if ischar( objective_tags )
                objective_tags = string( objective_tags );
            end
            assert( isstring( objective_tags ) );
            assert( isvector( objective_tags ) );
            assert( numel( unique( objective_tags ) ) == numel( objective_tags ) );
            assert( all( ismember( objective_tags, var_names ) ) );
            
            objective_titles = props.objective_titles;
            if ischar( objective_titles )
                objective_titles = string( objective_titles );
            end
            assert( isstring( objective_titles ) );
            assert( isvector( objective_titles ) );
            assert( numel( unique( objective_titles ) ) == numel( objective_titles ) );
            assert( numel( objective_titles ) == numel( objective_titles ) );
            
            pareto_tag = props.pareto_tag;
            if ischar( pareto_tag )
                pareto_tag = string( pareto_tag );
            end
            assert( isstring( pareto_tag ) );
            assert( isscalar( pareto_tag ) );
            assert( ismember( pareto_tag, var_names ) );
            
            assert( isempty( intersect( decision_tags, objective_tags ) ) );
            assert( isempty( intersect( pareto_tag, objective_tags ) ) );
            assert( isempty( intersect( pareto_tag, decision_tags ) ) );
            
            stl_file = props.stl_file;
            if ischar( stl_file )
                stl_file = string( stl_file );
            end
            assert( isstring( stl_file ) );
            assert( isscalar( stl_file ) );
            
            obj.data = data;
            obj.decision_tags = decision_tags;
            obj.decision_titles = decision_titles;
            obj.objective_tags = objective_tags;
            obj.objective_titles = objective_titles;
            obj.pareto_tag = pareto_tag;
            obj.stl_file = stl_file;
        end
        
        function value = get_by_tag( obj, tag )
            value = obj.data{ :, tag };
        end
        
        function value = get_pareto_by_tag( obj, tag )
            value = obj.data{ obj.get_pareto_front(), tag };
        end
        
        function value = get.decision_count( obj )
            value = numel( obj.decision_tags );
        end
        
        function value = get.decisions( obj )
            value = obj.data{ :, obj.decision_tags };
        end
        
        function value = get.pareto_decisions( obj )
            value = obj.decisions( obj.get_pareto_front(), : );
        end
        
        function value = get.objective_count( obj )
            value = numel( obj.objective_tags );
        end
        
        function value = get.objectives( obj )
            value = obj.data{ :, obj.objective_tags };
        end
        
        function value = get.pareto_objectives( obj )
            value = obj.objectives( obj.get_pareto_front(), : );
        end
    end
    
    properties
        data table
        pareto_tag(1,1) string
    end
    
    methods ( Access = private )
        function value = get_pareto_front( obj )
            value = obj.data{ :, obj.pareto_tag };
        end
    end
    
end

