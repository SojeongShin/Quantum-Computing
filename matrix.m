%
%
% matrix power
a = [1, sqrt(2); i, 0] / sqrt(2)
b = diag([2*exp(i/8), exp(i/5)])
c = a * b * inv(a)
clear a b
[q, p] = eig(c) % diagonalization
r = abs(p) % magnitude (abs) of eigenvalues
a = diag(angle(p)) % phase (angle) of eigenvalues
r .* diag(exp(i*a)) % == p?
q * (r .* diag(exp(i*a))) * inv(q) % == c?
[q, p] = eig(c^2) 
abs(p) - r.^2 
angle(p) - diag(a * 2) 
r.^2 .* diag(exp(i*a*2)) 
c^2
% diagonalization of c^2
% magnitude (abs) of eigenvalues
% phase (angle) of eigenvalues
q * (r.^2 .* diag(exp(i*a*2))) * inv(q) % == c^2? 
[q, p] = eig(c^3) abs(p) - r.^3 angle(p) - diag(a * 3) r.^3 .* diag(exp(i*a*3)) 
c^3
% diagonalization of c^3
% magnitude (abs) of eigenvalues
% phase (angle) of eigenvalues
q * (r.^3 .* diag(exp(i*a*3))) * inv(q) 