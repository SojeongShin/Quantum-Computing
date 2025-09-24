%
%
a = [1 + i, 1; 0, 1]
b = [0, 1; i, 2]
c = [1, i; i, 1]
d = [1 + i, 0; i, 2]
% Gram-Schmidt (with Frobenius inner-product)
% check the NON-orthonormality
iprod = @(u, v) trace(u * v')
iprod(a, a)
iprod(b, b)
iprod(c, c)
iprod(d, d)
iprod(a, b)
iprod(a, c)
iprod(a, d)
iprod(b, c)
iprod(b, d)
iprod(c, d)


% Gram-Schmidt
w = a
w = w / sqrt(iprod(w, w))

x = b - iprod(b, w) * w
x = x / sqrt(iprod(x, x))

y = c - iprod(c, w) * w - iprod(c, x) * x
y = y / sqrt(iprod(y, y))

z = d - iprod(d, w) * w - iprod(d, x) * x - iprod(d, y) * y
z = z / sqrt(iprod(z, z))

% check the orthonormality
iprod(w, w)
iprod(x, x)
iprod(y, y)
iprod(z, z)
iprod(w, x)
iprod(w, y)
iprod(w, z)
iprod(x, y)
iprod(x, z)
iprod(y, z)
% decompose a matrix
a = [1, 2; 3+i, 4+i]
iprod(a, w)*w + iprod(a, x)*x + iprod(a, y)*y + iprod(a, z)*z % == a