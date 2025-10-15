run('qc_defs.m')
global k0 k1 b0 b1 X H multi_controlled

qc      = quantum_circuit(4);
wire    = qc("wire");
get_reg = qc("get_reg");

% H를 0,1,2번 와이어에
wire(H, [0]);
wire(H, [1]);
wire(H, [2]);

% 3-제어 X (컨트롤: 0,1,2 / 타깃: 3)
wire(multi_controlled(X, '000'), [0,1,2,3]);
wire(multi_controlled(X, '011'), [0,1,2,3]);
wire(multi_controlled(X, '100'), [0,1,2,3]);
wire(multi_controlled(X, '110'), [0,1,2,3]);

print_qr(get_reg(), 4);
