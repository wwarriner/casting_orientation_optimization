classdef (Sealed) OrientationBaseCase < handle
    
    methods ( Access = public )
        
        function obj = OrientationBaseCase( ...
                component_path, ...
                feeders_path, ...
                option_path, ...
                objective_variables_path ...
                )
            
            obj.component = Component.load_obj( component_path );
            obj.feeders = Feeders.load_obj( feeders_path );
            obj.options = Options( option_path );
            obj.objective_variables = ...
                ObjectiveVariables( objective_variables_path );
            
        end
        
        
        function results = determine_results_as_table( obj, angles )
            
            results = array2table( obj.determine_results( angles ) );
            results.Properties.VariableNames = obj.compose_titles();
            
        end
        
        
        function objectives = determine_objectives( obj, angles )
            
            obj.options.set( 'manager.user_needs', obj.objective_variables.get_processes() );
            rotated_case = obj.generate_rotated_case( angles );
            
            try
                pm = ProcessManager( obj.options, rotated_case );
                pm.run();
            catch e
                fprintf( 1, '%s\n', getReport( e ) );
            end
            
            parting_dimension = obj.options.get( 'manager.parting_dimensions' );
            gravity_direction = obj.options.get( 'manager.gravity_directions' );
            objective_count = obj.objective_variables.get_objective_count();
            objectives = nan( 1, objective_count );
            for i = 1 : objective_count
                
                objectives( i ) = obj.objective_variables.evaluate( ...
                    i, ...
                    @rotated_case.get, ...
                    parting_dimension, ...
                    gravity_direction ...
                    );
                
            end
            
        end
        
        
        function name = get_name( obj )
            
            name = obj.component.name;
            
        end
        
    end
    
    
    methods ( Access = public, Static )
        
        
        function titles = get_decision_variable_titles()
            
            titles = { 'phi'; 'theta' };
            
        end
        
        
        function count = get_decision_variable_count()
            
            count = numel( OrientationBaseCase.get_decision_variable_titles() );
            
        end
        
        
        function lb = get_decision_variable_lower_bounds()
            
            [ phi, theta ] = unit_sphere_ranges();
            lb = [ phi( 1 ); theta( 1 ) ];
            
        end
        
        
        function ub = get_decision_variable_upper_bounds()
            
            [ phi, theta ] = unit_sphere_ranges();
            ub = [ phi( 2 ); theta( 2 ) ];
            
        end
        
    end
    
    
    properties ( Access = private )
        
        component
        feeders
        options
        objective_variables
        
    end
    
    
    methods ( Access = private )
        
        function rotated_case = generate_rotated_case( obj, angles )
            
            r = Rotator( angles, obj.component.centroid() );
            rotated_case = Results( obj.options );
            
            component_pk = ProcessKey( Component.NAME );
            rotated_case.add( component_pk, obj.component.rotate( r ) );
            
            mr = Mesh( rotated_case, obj.options );
            mr.run();
            mesh_pk = ProcessKey( Mesh.NAME );
            rotated_case.add( mesh_pk, mr );
            
            feeders_pk = ProcessKey( Feeders.NAME );
            rotated_case.add( feeders_pk, obj.feeders.rotate( r, mr ) );
            
        end
        
        
        function results = determine_results( obj, angles )
            
            angles = angles( : ).';
            objectives = obj.determine_objectives( angles );
            results = [ angles objectives ];
            
        end
        
        
        function titles = compose_titles( obj )
            
            titles = [ ...
                obj.get_decision_variable_titles(); ...
                obj.get_objective_variable_titles() ...
                ];
            
        end
        
        
        function titles = get_objective_variable_titles( obj )
            
            titles = obj.objective_variables.get_tags();
            
        end
        
    end
    
end

