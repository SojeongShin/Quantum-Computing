%
% linear_algebra.m
%    Copy the content to the end of the submission
%

script = 1;

equ = @(x, y) max(max(abs(x - y))) < 1e-10;

%% =================== TESTS / SCRIPT PART ===================

% ---------- P1 test ----------
i = sqrt(-1);
x = 1 + i;
a = roots(x, 3);        % a: 1-by-3 complex row vector

assert( length(a) == 3 );
assert( ~equ(a(1), a(2)) );
assert( ~equ(a(1), a(3)) );
assert( ~equ(a(2), a(3)) );
assert( equ(a(1)^3, x) );
assert( equ(a(2)^3, x) );
assert( equ(a(3)^3, x) );
fprintf('[P1] Success!\n');

% ---------- P2 test ----------
u = [1+i; 1-i];
v = [2+i; 3+i];
assert( equ(iprod(u, v), 5-3i) )
assert( equ(iprod(u, u), 4) )
assert( equ(iprod(v, v), 15) )
fprintf('[P2] Success!\n');

% ---------- P3 test ----------
bw = gram_schmidt({[1 + i; 0], [1; 1]});
assert( length(bw) == 2 );
assert( length(bw{1}) == 2 );
assert( length(bw{2}) == 2 );
assert( equ(iprod(bw{1}, bw{1}), 1) );
assert( equ(iprod(bw{2}, bw{2}), 1) );
assert( equ(iprod(bw{2}, bw{1}), 0) );
fprintf('[P3] Success!\n');

% ---------- P4 (compute a,b,c and verify) ----------
bw = gram_schmidt({[1 + i; 0; 1], [1; 1; 0], [0; 1; i]});
x  = [2 + 3i; 4 + 5i; 1 + 2i];
a  = iprod(x, bw{1});
b  = iprod(x, bw{2});
c  = iprod(x, bw{3});

y = a*bw{1} + b*bw{2} + c*bw{3};
assert( equ(y, x) );
fprintf('[P4] Success!\n');

disp('=== All tests passed ===');

%% =================== LOCAL FUNCTIONS (MUST BE AT END) ===================

%
% P1. [3 pt] Implement roots function
% roots(x, n)
%   x: a complex number
%   n: an integer
%   returns an array of all nth-roots of x
%
function ret = roots(x, n)
    if x == 0
        ret = zeros(1, n);
        return;
    end
    r   = abs(x);
    th  = angle(x);
    rho = r^(1/n);
    ret = zeros(1, n);
    for k = 0:n-1
        ret(k+1) = rho * exp(1i*(th + 2*pi*k)/n);
    end
end

%
% P2. [2 pt] Implement iprod function
% iprod(u, v)
%    u, v: column vectors
%    returns the inner product <u, v>
%
function ret = iprod(u, v)
    m = size(u, 1);  % vector length
    s = 0;
    for t = 1:m
        s = s + conj(v(t)) * u(t);   % <u,v> = v'*u
    end
    ret = s;
end

%
% P3. [3 pt] Implement gram_schmidt function
% gram_schmidt(bv)
%    bv: an array of basis
%    returns an array of orthonormal basis bw
%       such that span(bv) = span(bw)
%
function bw = gram_schmidt(bv)
    bw = {};   % result cell array
    for i = 1:length(bv)
        v = bv{i};
        for j = 1:length(bw)
            v = v - iprod(v, bw{j}) * bw{j};
        end
        nrm = sqrt(iprod(v, v));
        bw{end+1} = v / nrm;
    end
end
