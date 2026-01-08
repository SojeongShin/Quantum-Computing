%
% algebra_hilbert_space.m
% 
script = 1;

% export hilbert space functions
global hilbert_space_function;
hilbert_space_function = dictionary(...
    ["make_hilbert_space", "test_hilbert_space"],...
    {@make_hilbert_space,  @test_hilbert_space});
    
% import vector_space functions
algebra_vector_space;

% import inner_product functions
algebra_inner_product;

function ret = make_hilbert_space(member, add, add_id, add_inv,...
                                  s_mul, inner_prod)
    % Note: we are restricting the Field to R or C
    ret = dictionary(...
        ["member", "add",       "add_id", "add_inv",...
         "s_mul", "inner_prod", "norm"],...
        { member,   add,         add_id,   add_inv,...
          s_mul,   inner_prod,...
          @(x) sqrt(inner_prod(x, x))... % TODO: induced norm
        }); 
end

function [] = test_hilbert_space(hilbert_space, x, y, z, s, t, equ)
    % Note: completeness is not tested
    
    % vector_space
    member     = hilbert_space{"member"};
    add        = hilbert_space{"add"};
    add_id     = hilbert_space{"add_id"};
    add_inv    = hilbert_space{"add_inv"};
    s_mul      = hilbert_space{"s_mul"};
    
    % hilbert_space
    inner_prod = hilbert_space{"inner_prod"};
    norm       = hilbert_space{"norm"};

    global vector_space_function;
    make_vector_space = vector_space_function{"make_vector_space"};
    test_vector_space = vector_space_function{"test_vector_space"};

    global inner_product_function;
    test_norm          = inner_product_function{"test_norm"};
    test_inner_product = inner_product_function{"test_inner_product"};

    % vector space
    vs = make_vector_space(member, add, add_id, add_inv, s_mul);
    test_vector_space(vs, x, y, z, s, t, equ);

    % inner product
    test_inner_product(vs, inner_prod, x, y, z, s)

    % induced norm
    test_norm(vs, norm, x, y, z, s)
end

% vector 2d
%    
hs_vec2 = make_hilbert_space(...
    @(x)    isequal(size(x), [2,1]),... % member
    @(x, y) x + y,...              % add
    [0;0],...                      % add_id
    @(x)    -x,...              % add_inv
    @(s, x) s .* x,...              % s_mul
    @(x, y) trace(x * y'));                % inner_prod
test_hilbert_space(...
    hs_vec2,...                         % hilbert_space
    [1; 1i], [1; 2i], [i; 3i],...       % x, y, z
    2+i, 3+i,...                        % s, t
    @(x, y) max(abs(x - y)) < 1e-10);   % equ

% 2x2 matrix
%
hs_mat2x2 = make_hilbert_space(...
    @(x)    isequal(size(x), [2,2]),... % member
    @(x, y) x + y,...              % add
    [0,0 ; 0,0],...                      % add_id
    @(x)    -x,...              % add_inv
    @(s, x) s .* x,...              % s_mul
    @(x, y) trace(x * y'));                % inner_prod    

test_hilbert_space(...
    hs_mat2x2,...                                  % hilbert_space
    [0, 1; 1, 0], [0, -i; i, 0], [1, 0; 0, -1],... % x, y, z
    2, 3,...                                       % s, t
    @(x, y) max(max(abs(x - y))) < 1e-10);         % equ
% function
%
hs_fun = make_hilbert_space(...
    @(f)    isa(f, 'function_handle'),... % member
    @(f, g) @(x) f(x) + g(x),...          % add
    @(x)    x - x,...                     % add_id: (x-x) to match vector size 
    @(f)    add_inv(f),...                % add_inv
    @(s, f) s_mul(s, f),...                % s_mul
    @(f, g) integral(f(x) .* conj(g(x)), -inf, inf), ...                 % inner_prod
    ... % hint: integrate f(x) .* conj(g(x))) from -Inf to Inf
    ... % (use integral)
    );
test_hilbert_space(...
    hs_fun,...                            % hilbert_space
    @(x) exp(-x.^2) * i .* sin(x),...     % x
    @(x) exp(-x.^2) .* cos(x),...         % y
    @(x) exp(-x.^2) .* x.^2,...           % z
    2+i, 3+i,...                          % s, t
    @(f, g) max(abs(f(-1:0.1:1) - g(-1:0.1:1))) < 1e-10); % equ
