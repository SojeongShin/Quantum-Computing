%
% algebra_group.m
%
script = 1;

% export group functions
global group_function;
group_function = dictionary(... 
    ["make_group", "test_group", "test_abelian_group"],...
    {@make_group,  @test_group,  @test_abelian_group});

function ret = make_group(member, opr, identity, inverse)
    ret = dictionary(...
        ["member", "opr", "identity", "inverse"],...
        {member,    opr,   identity,   inverse}); 
end

function [] = test_group(group, x, y, z, equ)
    member   = group{"member"};
    opr      = group{"opr"};
    identity = group{"identity"};
    inverse  = group{"inverse"};

    % closure
    assert(member(identity));
    assert(member(x));
    assert(member(y));
    assert(member(z));
    assert(member(opr(x, y)));
    assert(member(opr(y, x)));
    assert(member(opr(x, z)));
    assert(member(opr(z, x)));
    assert(member(opr(y, z)));
    assert(member(opr(z, y)));
    assert(member(inverse(x)));
    assert(member(inverse(y)));
    assert(member(inverse(z)));

    %
    % TODO: add conditions for asserts
    %

    % associativity: (x*y)*z = x*(y*z)
    a = opr(opr(x, y), z);
    b = opr(x, opr(y, z));
    assert(equ(a, b));

    % identity: x*id = id*x = x
    a = opr(x, identity);
    assert(equ(a, x));
    a = opr(identity, x);
    assert(equ(a, x));

    % inverse: x * x_inv = x_inv * x = id
    a = inverse(x);
    b = opr(x, a);
    assert(equ(b, identity));
    b = opr(a, x);
    assert(equ(b, identity));
end

function [] = test_abelian_group(group, x, y, z, equ)
    opr = group{"opr"};
    
    % test group properties
    test_group(group, x, y, z, equ);

    %
    % TODO: add conditions for asserts
    %
        
    % commutativity x*y = y*x
    a = opr(x, y);
    b = opr(y, x);
    assert(equ(a, b));

    a = opr(x, z);
    b = opr(z, x);
    assert(equ(a, b));

    a = opr(y, z);
    b = opr(z, y);
    assert(equ(a, b));
end

% complex number (add)
%
grp_int = make_group(...
    @(x) isequal(size(x), [1,1]),...    % member
    @(x, y) x + y,...                   % opr
    0,...                               % identity
    @(x) -x);                           % inverse
test_abelian_group(...
    grp_int,...                         % group
    1+i, 2, 3i,...                      % x, y, z
    @(x, y) x == y);                    % equ

% vector (add)
%    
grp_vec2 = make_group(...
    @(x) isequal(size(x), [2,1]),...    %member
    @(x, y) x + y,...                   % opr
    [0; 0],...                          % identity
    @(x) -x);                           % inverse
test_abelian_group(...
    grp_vec2,...                        % group
    [1; 1], [2; 2], [3; 3],...          % x, y, z  
    @(x, y) max(abs(x - y)) < 1e-10);   % equ


%
% TODO: implement the test cases
%
    
% 2x2 matrix (add)
%    
grp_mat2x2_add = make_group(...
    @(x) isequal(size(x), [2,2]),... % member
    @(x, y) x + y,...                   % opr (add)
    [0 0; 0 0],...                   % identity
    @(x) -x;                     % inverse
test_abelian_group(...
    grp_mat2x2_add,...                           % group
    [1, 2; 3, 4], [2, 3; 4, 5], [3, 4; 5, 6],... % x, y, z
    @(x, y) max(max(abs(x - y))) < 1e-10);       % equ


% invertible 2x2 matrix (mul is not commutative)
%    
grp_mat2x2_mul = make_group(...
    @(x) rank(x)==2 && isequal(size(x), [2,2]),... % member
    @(x, y) x * y,...                      % opr (mul)
    [1 0; 0 1],...                      % identity
    @(x) inv(x));                        % inverse
test_group(...
    grp_mat2x2_mul,...                           % group
    [1, 2; 3, 4], [2, 3; 4, 5], [3, 4; 5, 6],... % x, y, z
    @(x, y) max(max(abs(x - y))) < 1e-10);       % equ


% function (add, i.e. add(f, g)(x) = f(x) + g(x)) 
% 
grp_fun = make_group(...
    @(f) isa(f, 'function_handle'),...  % member
    @(f, g) @(x) f(x) + g(x),...                      % opr
    @(x) 0,...                      % identity
    @(f) @(x) -f(x));                        % inverse
test_abelian_group(...
    grp_fun,...                         % group
    @sin, @cos, @(x) x.^2,...           % x, y, z
    @(f, g) max(abs(f(-1:0.1:1) - g(-1:0.1:1))) < 1e-10); % equ
