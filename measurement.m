qc_defs

Y
Y'

[p, q] = eig(Y);

P1 = q(:, 1) * q(:, 1)';
P2 = q(:, 2) * q(:, 2)';
p(1, 1) * P1 + p(2, 2) * P2

x = (3/5)*k0 + 1i*(4/5)*k1;
pr1 = bra(x) * P1 * x;
pr2 = bra(x) * P2 * x;

P1 * x / sqrt(pr1)
P2 * x / sqrt(pr2)

-1 * pr1 + 1 * pr2
