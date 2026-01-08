%
% algebra_inner_product.m
% 
script = 1;

% export inner product functions
global inner_product_function;
inner_product_function = dictionary(...
    ["test_metric", "test_norm", "test_inner_product"],...
    {@test_metric,  @test_norm,  @test_inner_product});


% import vector_space
algebra_vector_space;

function [] = test_metric(distance, x, y, z)

    %
    % TODO: fill the blanks
    %

    % positivity: d(x, y) > 0 if x != y
    a = distance(x, y);
    b = distance(y, z);
    c = distance(z, x);
    assert(a > 0 && b > 0 && c > 0);
    
    % definiteness: d(x, x) = 0
    a = distance(x, x);
    b = distance(y, y);
    c = distance(z, z);
    assert(abs(a) < 1e-10 && abs(b) < 1e-10 && abs(c) < 1e-10);

    % symmetry: d(x, y) = d(y, x)
    a = distance(x, y) - distance(y, x);
    b = distance(y, z) - distance(z, y);
    c = distance(z, x) - distance(x, z);
    assert(abs(a) < 1e-10 && abs(b) < 1e-10 && abs(c) < 1e-10);

    % triangle inequality: d(x, y) + d(y, z) >= d(x, z)
    a = distance(x, z);
    b = distance(x, y) + distance(y, z);
    assert(a <= b);
end    

function [] = test_norm(vector_space, norm, x, y, z, s)
    add    = vector_space{"add"};
    add_id = vector_space{"add_id"};    
    s_mul  = vector_space{"s_mul"};

    %
    % TODO: fill the blanks
    %

    % non-negativity: |x| > 0 if x != id
    a = norm(x);
    b = norm(y);
    c = norm(z);
    assert(a > 0 && b > 0 && c > 0);
    
    % |id| = 0
    a = norm(add_id);
    assert(abs(a) < 1e-10);
    
    % triangle inequality: |x + y| <= |x| + |y|
    a = norm(add(x, y));
    b = norm(x) + norm(y);
    assert(a <= b);

    % scaling: |s*x| = |s|*|x|
    a = norm(s_mul(s, x));
    b = abs(s) .* norm(x);
    assert(abs(a - b) < 1e-10);
end  

function [] = test_inner_product(vector_space, inner_prod, x, y, z, s)
    add        = vector_space{"add"};
    add_id     = vector_space{"add_id"};
    s_mul      = vector_space{"s_mul"};

    %
    % Fill the blanks
    %

    % conjugate symmetry: <x, y> = conj(<y, x>)
    a = inner_prod(x, y);
    b = inner_prod(y, x);
    assert(abs(a - conj(b))< 1e-10);

    % linearity:<s*x, y> = s*<x, y>
    a = inner_prod(s_mul(s, x), y);
    b = s .* inner_prod(x, y);
    assert(abs(a - b)< 1e-10);

    % <x + y, z> = <x, z> + <y, z>        
    a = inner_prod(add(x, y), z);
    b = add(inner-prod(x, z), inner_prod(y, z));
    assert(abs(a - b)< 1e-10);

    % anti-linearity: <x, s*y> = conj(s)*<x, y>
    a = inner_prod(x, s_mul(s, y));
    b = conj(s) .* inner_prod(x, y);
    assert(abs(a - b)< 1e-10);

    % <x, y + z> = <x, y> + <x, z>        
    a = inner_prod(x, add(y, z));
    b = inner_prod(x, y) + inner_prod(x, z);
    assert(abs(a - b)< 1e-10);

    % positive definiteness <x, x> > 0 if x != id
    a = inner_prod(x, x);
    b = inner_prod(y, y);
    c = inner_prod(z, z);
    assert(a > 0 && b > 0 && c > 0);

    % <id, id> = 0
    a = inner_prod(add_id, add_id);
    assert(abs(a) < 1e-10);
end


% metric
%
% binary vector: Hamming distance
test_metric(...
    @(x, y) sum(xor(x, y)),...  
    [1, 0, 1, 0], [1, 1, 0, 0], [1, 1, 1, 1]);

% binary vector: abs of binary numbers    
test_metric(...
    @(x, y) abs([8, 4, 2, 1]*(x - y)'),... 
    [1, 0, 1, 0], [1, 1, 0, 0], [1, 1, 1, 1]);

% binary vector: L-2 norm of vectors    
test_metric(...
    @(x, y) sqrt((x - y) * (x - y)'),... 
    [1, 0, 1, 0], [1, 1, 0, 0], [1, 1, 1, 1]);

% 2D vector: induced metric by inner product
test_metric(...
    @(x, y) sqrt(trace((x - y) * (x - y)')),...
    [1; 1], [2; i], [3; 3]);

% 2x2 matrix: induced metric by Frobenius inner product
test_metric(...
    @(x, y) sqrt(trace((x - y) * (x - y)')),...
    [0, 1; 1, 0], [0, -i; i, 0], [1, 0; 0, -1]);

% function: induced metric by inner product
test_metric(...
    @(f, g) sqrt(integral(@(x) (f(x)-g(x)).*conj(f(x)-g(x)), -pi, pi)),...
    @sin, @cos, @(x) x.^2);

global vector_space_function;
make_vector_space = vector_space_function{"make_vector_space"};

% vector 2d
%
vs_vec2 = make_vector_space(...
    @(x) isequal(size(x), [2,1]),... % member
    @(x, y) x + y,...                % add
    [0; 0],...                       % add_id
    @(x) -x,...                      % add_inv
    @(s, x) s .* x);                 % s_mul
p = 3;    
test_norm(...
    vs_vec2,...                % vector_space   
    @(x) __________,...        % L-p norm
    [1; 1], [2; i], [3; 3],... % x, y, z 
    2);                        % s 
test_inner_product(...
    vs_vec2,...                % vector_space
    @(x, y) trace(x * y'),...     % inner_prod
    [1; 1], [2; i], [3; 3],... % x, y, z
    2);                        % s

% 2x2 matrix
%
vs_mat2x2 = make_vector_space(...
    @(x) isequal(size(x), [2,2]),... % member
    @(x, y) x + y,...                % add
    [0, 0; 0, 0],...                 % add_id
    @(x) -x,...                      % add_inv
    @(s, x) s .* x);                 % s_mul
test_norm(...
    vs_mat2x2,...                                  % vector_space 
    @(x) __________,...                            % Frobenius norm
    [0, 1; 1, 0], [0, -i; i, 0], [1, 0; 0, -1],... % x, y, z
    2);                                            % s
test_inner_product(...
    vs_mat2x2,...                                  % vector_space
    @(x, y) trace(x * y'),...                         % Frobenius inner_prod
    [0, 1; 1, 0], [0, -i; i, 0], [1, 0; 0, -1],... % x, y, z
    2);                                            % s

% function
%
vs_fun = make_vector_space(...
    @(f) isa(f, 'function_handle'),...  % member
    @(f, g) @(x) f(x) + g(x),...        % add
    @(x) 0 + x - x,...                  % add_id
    @(f) @(x) -f(x),...                 % add_inv
    @(s, f) @(x) s .* f(x));            % s_mul
test_norm(...
    vs_fun,...                % vector_space
    @(f) sqrt(integral(@(x) f(x).*conj(f(x)), -pi, pi)),...       % norm: sqrt of integral f(x)*conj(f(x)) 
    ...  % from -pi to pi (hint: use integral)
    @sin, @cos, @(x) x.^2,... % x, y, z 
    2);                       % s    
test_inner_product(...
    vs_fun,...                % vector_space
    @(f, g) integral(@(x) f(x).*conj(f(x)), -pi, pi),...    % inner_prod: integrate f(x)*conj(g(x)) 
    ... % from -pi to pi (hint: use integral)
    @sin, @cos, @(x) x.^2,... % x, y, z
    2);                       % s   

%
% Fourier transform example
%
fprintf('To test Fourier transform, set test_fourier=1\n')
global test_fourier;
if test_fourier
    step = @(x) (-pi/2 <= x) & (x <= pi/2);
    draw_fourier_tf(step);
end

function [] = draw_fourier_tf(f)
    xtick = -pi:0.05:pi;
    k = 1;
    for j = 1:3:10
        % g: estimate of f using j+1 Fourier basis
        g = fourier(f, j);  
        y = [f(xtick); g(xtick)];

        subplot(4, 1, k); k = k + 1;
        plot(xtick, y);
        title(sprintf('N = %d', j));
    end
end

function ret = fourier(f, n)
    % get Fourier basis
    function ret = build_basis()
        basis = { @(x) (x-x)+1/sqrt(2*pi) }; % constant. x-x: to match dimension
        for j = 1:n
            basis{end+1} = @(x) cos(j*x)/sqrt(pi);
        end 
        ret = basis;
    end

    % Fourier transform
    function ret = decompose(f, basis)
        iprod = @(f, g) integral(@(x) f(x).*conj(g(x)), -pi, pi);
        coefs = [];
        for j = 1:length(basis)
            % TODO: compute c, the component of f in basis{j} direction
            c = __________; 
            coefs = [coefs, c];
        end
        ret = coefs;
    end

    % inverse Fourier transform
    function ret = compose(coefs, basis)
        g = @(x) 0;
        for j = 1:length(basis)
            % TODO: reconstruct f by adding the component of f
            %       in basis{j} direction
            g = @(x) __________;
        end
        ret = g;
    end

    basis = build_basis();
    coefs = decompose(f, basis);
    ret   = compose(coefs, basis);
end
