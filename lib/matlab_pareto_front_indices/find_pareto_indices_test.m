%% SETUP
count = 1000;
x = rand( count, 1 );
y = rand( count, 1 );
z = rand( count, 1 );
rng( 314159 );

%% 2D
p = [ x y ];
c = [ 0 0 ];
% remove inside circle centered on origin
remove = sqrt( sum( ( p - c ) .^ 2, 2 ) ) < 0.75;
c = [ 1/sqrt(2) 1/sqrt(2) ];
% create region of no data
remove = remove | sqrt( sum( ( p - c ) .^ 2, 2 ) ) < 0.25;
p( remove, : ) = [];
pfi = find_pareto_indices( p );

figure();
axes();
plot( p(:,1), p(:,2), 'k.', p(pfi,1), p(pfi,2), 'r*' );
axis( 'equal', 'square' );


%% 3D
p = [ x y z ];
c = [ 0 0 0 ];
% remove inside circle centered on origin
remove = sqrt( sum( ( p - c ) .^ 2, 2 ) ) < 1.0;
c = [ 1/sqrt(3) 1/sqrt(3) 1/sqrt(3) ];
% create region of no data
remove = remove | sqrt( sum( ( p - c ) .^ 2, 2 ) ) < 0.25;
p( remove, : ) = [];
pfi = find_pareto_indices( p );

figure();
axes();
plot3( ...
    p(:,1), p(:,2), p(:,3), 'k.', ...
    p(pfi,1), p(pfi,2), p(pfi,3), 'r*' ...
    );
axis( 'equal', 'vis3d' );
view( 3 );
