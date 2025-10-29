qc_defs;
global k0 k1
global RX RY RZ

u = @(theta) cos(theta)*k0 - sin(theta)*k1;
v = @(theta) sin(theta)*k0 - cos(theta)*k1;

equ = @(a,b) max(max(abs(a-b))) < 1e-10;
equ(u(-pi/16), RY(pi/8) * k0)
equ(v(-pi/16), RY(pi/8) * k1)

CB = @(theta) RY(theta*2); 