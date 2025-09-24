global k0 k1
k0 =  [1;0];  % |0>
k1 =  [0;1];  % |1>

ku =  (k0 + k1) / sqrt(2);  % |u> = (|0> + |1>) / sqrt(2)

global bra b0 b1
bra = @(u) u';  % <u|
b0 = bra(k0);  % <0|
b1 = bra(k1);  % <1|

ku = (k0 + i*k1) / sqrt(2);
bu = bra(ku);

global iprod
iprod = @(u, v) bra(v) * u;

% iprod(k1, k0+i*k1/sqrt(2))

global len
len = @(u) sqrt(iprod(u, u));

% len((k0+i*k1)/sqrt(2))

global dist
dist = @(u, v) len(u-v);

% dist(k1, (k0+i*k1)/sqrt(2))

global k00 k01 k10 k11

% kron function is a tensor product (kronical product)
k00 = kron(k0, k0);
k01 = kron(k0, k1);
k10 = kron(k1, k0);
k11 = kron(k1, k1);

global b00 b01 b10 b11

b00 = bra(k00);
b01 = bra(k01);
b10 = bra(k10);
b11 = bra(k11);

global I X Y Z
I = k0*b0 + k1*b1;
X = k1*b0 + k0*b1;
Y = i*k1*b0 - i*k0*b1;
Z = k0*b0 - k1*b1;

global H
H = (k0+k1)/sqrt(2)*b0 + (k0-k1)/sqrt(2)*b1;

global SWAP
SWAP = k00*b00 + k10*b01 + k01*b10 + k11*b11;

global controlled
controlled = @(a) kron(k0*b0, eye(length(a))) + kron(k1*b1, a);

global CX CY CZ CH
CX = controlled(X);
CY = controlled(Y);
CZ = controlled(Z);
CH = controlled(H);

global k000 k001 k010 k011
global k100 k101 k110 k111
k000 = kron(k0, k00); % |000>
k001 = kron(k0, k01); % |001>
k010 = kron(k0, k10); % |010>
k011 = kron(k0, k11); % |011>
k100 = kron(k1, k00); % |100>
k101 = kron(k1, k01); % |101>
k110 = kron(k1, k10); % |110>
k111 = kron(k1, k11); % |111>

global b000 b001 b010 b011
global b100 b101 b110 b111
b000 = bra(k000); % <000|
b001 = bra(k001); % <001|
b010 = bra(k010); % <010|
b011 = bra(k011); % <011|
b100 = bra(k100); % <100|
b101 = bra(k101); % <101|
b110 = bra(k110); % <110|
b111 = bra(k111); % <111|

global CCX
CCX = controlled(CX);

global multi_controlled
multi_controlled = @multi_controlled__;
function ret = multi_controlled__(opr, str_ctrl)
    str_ctrl = char(str_ctrl);
    function ret = recur(i_ctrl)
        if i_ctrl > length(str_ctrl)
            ret = opr;
        else
            op = recur(i_ctrl+1);
            if str_ctrl(i_ctrl) == '1'
                ret = kron(k0*b0, eye(length(op))) + kron(k1*b1, op);
            elseif str_ctrl(i_ctrl) == '0'
                ret = kron(k0*b0, op) + kron(k1*b1, eye(length(op)));
            else
                assert(false)
            end
        end
    end
    ret = recur(1);
end