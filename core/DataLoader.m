classdef DataLoader < handle
    
    methods ( Access = public )
        
        function obj = DataLoader()
            
            obj.response_data = [];
            obj.visualization_generator = [];
            
        end
        
        
        function load( obj, ood_file_path, resolution_px )
            
            data = load( ood_file_path, '-mat' );
            results = data.results;
            objective_variables = data.objective_variables;
            data_extractor = DataExtractor( ...
                results, ...
                objective_variables, ...
                resolution_px ...
                );
            rd = ResponseData( data_extractor );
            
            [ path, name, ~ ] = fileparts( ood_file_path );
            component_file_name = [ name '_' Component.NAME '.ooc' ];
            component_file_path = fullfile( path, component_file_name );
            c = Component.load_obj( component_file_path );
            feeders_file_name = [ name '_' Feeders.NAME '.oof' ];
            feeders_file_path = fullfile( path, feeders_file_name );
            f = Feeders.load_obj( feeders_file_path );
            vg = VisualizationGenerator( c, f );
            
            obj.response_data = rd;
            obj.visualization_generator = vg;
            
        end
        
        
        function data = get_response_data( obj )
            
            assert( ~isempty( obj.response_data ) );
            
            data = obj.response_data;
            
        end
        
        
        function generator = get_visualization_generator( obj )
            
            assert( ~isempty( obj.visualization_generator ) );
            
            generator = obj.visualization_generator;
            
        end
        
    end
    
    
    properties ( Access = private )
        
        response_data
        visualization_generator
        
    end
    
end

