%
% algebra_field.m
%
script = 1;

% export field functions
global field_function;
field_function = dictionary(...
    ["make_field", "test_field"],...
    {@make_field,  @test_field});

% import group functions
algebra_group;

function ret = make_field(member, add, mul, add_id, mul_id, add_inv, mul_inv)
    ret = dictionary(...
        ["member", "add", "mul", "add_id", "mul_id", "add_inv", "mul_inv"],...
        { member,   add,   mul,   add_id,   mul_id,   add_inv,   mul_inv}); 
end

function [] = test_field(field, x, y, z, equ)
    member  = field{"member"};
    add     = field{"add"};
    mul     = field{"mul"};
    add_id  = field{"add_id"};
    mul_id  = field{"mul_id"};
    add_inv = field{"add_inv"};
    mul_inv = field{"mul_inv"};

    global group_function;
    make_group         = group_function{"make_group"};
    test_abelian_group = group_function{"test_abelian_group"};
    
    %
    % TODO: fill the blanks
    %
    
    % test abelian group properties of add
    % hint: make_group(member, opr, identity, inverse)
    grp_add = make_group(memeber, add, add_id, add_inv);
    test_abelian_group(grp_add, x, y, z, equ);

    % test abelian group properties of mul
    grp_mul = make_group(member, mul, mul_id, mul_inv);
    test_abelian_group(grp_mul, x, y, z, equ);

    % distributivity: x*(y+z) = x*y + x*z, (y+z)*x = y*x + z*x
    a = mul(x, add(y, z));
    b = add(mul(x, y), mul(x, z));
    assert(equ(a, b));

    a = mul(add(y, z), x);
    b = add(mul(y, x), mul(z, x));
    assert(equ(a, b));
end

% complex number
%   
fld_complex = make_field(...
    @(x) isequal(size(x), [1,1]),... % member
    @(x, y) x + y,...               % add
    @(x, y) x * y,...               % mul
    0,...                           % add_id
    1,...                           % mul_id
    @(x) -x,...                     % add_inv
    @(x) 1/x);                      % mul_inv

test_field(...
    fld_complex,...                 % field
    1+i, 2, 3i,...                  % x, y, z
    @(x, y) abs(x - y) < 1e-10);    % equ

%
% TODO: fill the blanks
%
    
% integer modulo 7
%   
fld_intmod = make_field(...
    @(x) isequal(size(x), [1,1]),... % member
    @(x, y) mod(x+y, 7),...                   % add
    @(x, y) mod(x*y, 7),...                   % mul
    0,...                   % add_id
    1,...                   % mul_id
    @(x) (7-x),...                   % add_inv
    @(x) intmod_mul_inv(7, x);                     % mul_inv

test_field(...
    fld_intmod,...                   % field
    2, 3, 4,...                      % x, y, z
    @(x, y) mod(x, 7) == mod(y, 7)); % equ   

function ret = intmod_mul_inv(n, x)
    ret = 0;
    for i = 0:(n-1)
        if mod(i * x, n) == 1
            ret = i;
            return
        end
    end
end
