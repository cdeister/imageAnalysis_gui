% Make an arbitrary connectivity matrix
a = [0 1 0 1;
     1 0 1 0;
     0 1 0 1;
     1 0 1 0];
 
 % Make an arbitrary set of coordinates
coord = [0 1 0; 1 0 0; 0 -1 0; -1 0 0];

% See if it plots
gplot3(a, coord);