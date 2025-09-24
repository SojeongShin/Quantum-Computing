% --- computational basis kets ---
k0 = [1; 0];
k1 = [0; 1];

% --- single-qubit bras ---
b0 = bra(k0);
b1 = bra(k1);

% --- two-qubit kets (Kronecker products) ---
k00 = kron(k0, k0);
k01 = kron(k0, k1);
k10 = kron(k1, k0);
k11 = kron(k1, k1);

% --- bras (conjugate transpose) ---
b00 = bra(k00);
b01 = bra(k01);
b10 = bra(k10);
b11 = bra(k11);

% --- quick sanity checks ---
disp(b11 * k11)   % -> 1
disp(b00 * k11)   % -> 0


%%
global I X Y Z
I = k0 * b0 + k1 * b1;
X = k0 * b1 + k1 * b0;
Y = i * k1 * b0 - i * k0 * b1;
Z = k0 * b0 - k1 * b1;


global H
H = (k0+k1) / sqrt(2)*b0 + (k0-k1)/sqrt(2)*b1;

global SWAP
SWAP = k00*b00 + k01*b10 + k10*b01 + k11*b11;


global controlled
controlled = @(a) kron(k0*b0, eye(length(a))) + kron(k1*b1, a);

global CX CY CZ CH
CX = controlled(X);
CY = controlled(Y);
CZ = controlled(Z);
CH = controlled(H);

global k000 k001 k010 k011 k100 k101 k110 k111
k000 = kron(k0, k00);
k001 = kron(k0, k01);
k010 = kron(k0, k10);
k011 = kron(k0, k11);
k100 = kron(k1, k00);
k101 = kron(k1, k01);
k110 = kron(k1, k10);
k111 = kron(k1, k11);

global b000 b001 b010 b011 b100 b101 b110 b111
b000 = bra(k000);
b001 = bra(k001);
b010 = bra(k010);
b011 = bra(k011);
b100 = bra(k100);
b101 = bra(k101);
b110 = bra(k110);
b111 = bra(k111);

global CCX
CCX = controlled(CX);


% ===== local function =====
function b = bra(ket)
    % conjugate transpose: ket (column) -> bra (row)
    b = ket';     % (')는 켤레전치, (.' )는 단순 전치
end