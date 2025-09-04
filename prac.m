% Orthonormal basis {a, b}
i = sqrt(-1)
iprod = @(a, b) b' * a; % inner product
a = [i; 1; 0] / sqrt(2)
b = [-i; 1; 2i] / sqrt(6)
c = [1; i; 1] / sqrt(3)
x = [1; 2; 3i] / sqrt(3)
% check the orthonormality of c with respect to a and b
iprod(c, c)
iprod(c, a)
iprod(c, b)
iprod(a, a)
iprod(b, b)
iprod(a, b)
% get the linear combination coefficients of x w.r.t. {a, b}

p = iprod(x, a) % component of a in x
q = iprod(x, b) % component of b in x
r = iprod(x, c)

p*a + q*b + r*c % x: [2; 3i]

