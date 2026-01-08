u0 = k0;
v0 = k1;

a = -pi/8;
u1 = cos(a)*k0 + sin(a)*k1;
v1 = -sin(a)*k0 + cos(a)*k1;

a = -3*pi/8;
u2 = cos(a)*k0 + sin(a)*k1;
v2 = -sin(a)*k0 + cos(a)*k1;

a = pi/4;
u3 = cos(a)*k0 + sin(a)*k1;
v3 = -sin(a)*k0 + cos(a)*k1;

% Observables
A = u0*bra(u0) - v0*bra(v0)
B = u1*bra(u1) - v1*bra(v1)
C = -u2*bra(u2) + v2*bra(v2)
D = -u3*bra(u3) + v3*bra(v3)