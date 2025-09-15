%
% linear_algebra_matrix.m
%
script = 1;

%
% global constants
%
a = [1, 1; 1, -1] / sqrt(2);
b = diag([exp(i*2*pi/20), exp(i*2*pi/30)]);
m = a * b * a';
clear a b
I = [1,  0; 0,  1] / sqrt(2);
X = [0,  1; 1,  0] / sqrt(2);
Y = [0, -i; i,  0] / sqrt(2);
Z = [1,  0; 0, -1] / sqrt(2);

%
% P1. [3pt] Implement mat_pow function using diagonalization
%   i.e., use the power of each eigenvalue
%
% mat_pow(m, exponent)
%    m: a complex matrix
%    exponent: a complex number
%    returns the matrix power m^exponent
%
function ret = mat_pow(m, exponent)
    [q, p] = eig(m);
    p_pow = diag(diag(p).^exponent);
    ret = q * p_pow * inv(q);

end

%
% test
%
exponent = 100;
m^exponent;
mp = mat_pow(m, exponent);
assert(max(max(abs(mp - m^exponent))) < 1e-10)
fprintf('1 Success!\n');


%
% P2. [3pt] Implement mat_exp function using diagonalization
%   i.e., use the exponentiation of each eigenvalue
%
% mat_exp(m)
%    m: a complex matrix
%    returns the matrix exponentiaion e^m
%
function ret = mat_exp(m)
    [q, p] = eig(m);
    p_exp = diag(exp(1).^(diag(p)));
    ret = q * p_exp * inv(q);

end

%
% test
%
e^m;
me = mat_exp(m);
assert(max(max(abs(me - e^m))) < 1e-10)
fprintf('2 Success!\n');


%
% P3. [2pt] Implement decompose function using the
%   Frobenius inner product
%
% decompose(v, basis)
%    v: a complex matrix
%    basis: an array of orthonormal basis
%    returns the vector of linear combination coefficients
%      such that v = coef(1)*basis{1} + ... + coef(n)*basis{n}
%
function ret = decompose(v, basis)
    n = length(basis);
    ret = zeros(1, n);
    for i = 1:n
        ret(i) = trace(v * basis{i}');
    end
end

%
% test
%
h = [1, 2i; 3, 4i];
coefs = decompose(h, {I, X, Y, Z});
v = coefs(1)*I + coefs(2)*X + coefs(3)*Y + coefs(4)*Z;
assert(max(max(abs(h - v))) < 1e-10);
fprintf('3 Success!\n');


%
% P4. [2pt] Implement compose function
%
% compose(coefs, basis)
%    coefs: a complex vector of linear combination coefficients
%    basis: an array of orthonormal basis
%    returns the vector 
%      coef(1)*basis{1} + ... + coef(n)*basis{n}
%
function ret = compose(coefs, basis)
    n = length(basis);
    ret = 0;
    for i = 1:n
        ret = ret + coefs(i) * basis{i};
    end
end

%
% test
%
h = [1, 2i; 3, 4i];
coefs = decompose(h, {I, X, Y, Z});
v = compose(coefs, {I, X, Y, Z});
assert(max(max(abs(h - v))) < 1e-10);
fprintf('4 Success!\n');
