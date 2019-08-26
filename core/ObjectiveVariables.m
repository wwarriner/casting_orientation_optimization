classdef ObjectiveVariables < handle
    
    properties ( SetAccess = private, Dependent )
        count(1,1) double {mustBeReal,mustBeFinite,mustBePositive}
        tags(:,1) string
        titles(:,1) string
        interpolation_methods(:,1) string
        process_names(:,1) string
    end
    
    methods
        function obj = ObjectiveVariables( file, base_case )
            if ischar( file )
                file = string( file );
            end
            assert( isstring( file ) );
            assert( isscalar( file ) );
            assert( isfile( file ) );
            
            variables = obj.read_objective_variables( file );
            
            obj.variables = variables;
            obj.base_case = base_case;
        end
        
        % retrieval function must take a process name and return the desired process object
        function values = evaluate( obj, decision_variables )
            angles = decision_variables.angles;
            rotated_case = obj.base_case.generate_rotated_case( angles );
            pm = ProcessManager( obj.base_case.settings, rotated_case );
            pm.run();
            
            values = nan( obj.count, 1 );
            for i = 1 : obj.count
                name = obj.variables.process{ i };
                key = ProcessKey( name );
                process = pm.get( key );
                property = obj.variables.property{ i };
                
                metric_fn_str = sprintf( ...
                    "@(property)%s;\n", ... % must use identifier "property"
                    obj.variables.metric{ i } ...
                    );
                metric_fn = str2func( metric_fn_str );
                values( i ) = metric_fn( process.(property) );
            end
            values = num2cell( [ angles values.' ] );
            vn = [ decision_variables.tags obj.tags.' ];
            values = table( values{ : }, 'variablenames', vn );
        end
        
        function value = get.count( obj )
            value = size( obj.variables, 1 );
        end
        
        function value = get.tags( obj )
            value = obj.variables.tag;
        end
        
        function value = get.titles( obj )
            value = obj.variables.title;
        end
        
        function value = get.interpolation_methods( obj )
            value = obj.variables.interpolation_method;
        end
        
        function value = get.process_names( obj )
            value = unique( obj.variables.process );
        end
    end
    
    properties ( Access = private )
        variables table
        base_case OrientationBaseCase
    end
    
    properties ( Access = private, Constant )
        type_to_interpolation_method containers.Map = containers.Map( ...
            { 'categorical' 'ordinal' 'continuous' }, ...
            { 'nearest' 'nearest' 'natural' } ...
            );
    end
    
    methods ( Access = private, Static )
        function variables = read_objective_variables( file )
            variables = struct2table( read_json_file( file ) );
            methods = cell( height( variables ), 1 );
            for i = 1 : height( variables )
                methods{ i } = ObjectiveVariables.type_to_interpolation_method( variables.type{ i } );
            end
            variables.interpolation_methods = methods;
        end
    end
    
end

