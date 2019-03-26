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
            obj.options = Options( ...
                'option_defaults.json', ...
                option_path, ...
                '', ...
                '' ...
                );
            obj.objective_variables = ...
                ObjectiveVariables( objective_variables_path );
            
        end
        
        
        function results = determine_results_as_table( obj, angles )
            
            results = array2table( obj.determine_results( angles ) );
            results.Properties.VariableNames = obj.compose_titles();
            
        end
        
        
        function objectives = determine_objectives( obj, angles )
            
            rotated_case = obj.get_rotated_case( angles );
            
            DIM = 3;
            GRAVITY_DIRECTION = 'down';
            
            uc = Undercuts();
            uc.legacy_run( rotated_case.get( Mesh.NAME ), DIM );
            rotated_case.add( uc.NAME, uc );
            pp = PartingPerimeter();
            pp.legacy_run( rotated_case.get( Mesh.NAME ), DIM, true );
            rotated_case.add( pp.NAME, pp );
            wf = Waterfall();
            wf.legacy_run( rotated_case.get( Mesh.NAME ), pp, GRAVITY_DIRECTION );
            rotated_case.add( wf.NAME, wf );
            
            objective_count = obj.objective_variables.get_objective_count();
            objectives = nan( 1, objective_count );
            for i = 1 : objective_count
                
                objectives( i ) = obj.objective_variables.evaluate( i, @rotated_case.get, DIM, GRAVITY_DIRECTION );
                
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
        
        function rotated_case = get_rotated_case( obj, angles )
            
            rotated_case = obj.generate_rotated_case( angles );
            
        end
        
        
        function rotated_case = generate_rotated_case( obj, angles )
            
            r = obj.create_rotator( angles );
            rotated_case = Results();
            rotated_case.add( Component.NAME, obj.component.rotate( r ) );
            mr = Mesh( rotated_case, obj.options );
            mr.run();
            rotated_case.add( Mesh.NAME, mr );
            rotated_case.add( Feeders.NAME, obj.feeders.rotate( r, mr ) );
            
        end
        
        
        function rotator = create_rotator( obj, angles )
            
            rotator = Rotator( angles, obj.component.centroid() );
            
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
            
            titles = obj.objective_variables.get_titles();
            
        end
        
    end
    
end

