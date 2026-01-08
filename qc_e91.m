function ret = e91_inq()
    global X Z H CX CH RY multi_controlled
    global print_qr quantum_circuit
    qc = quantum_circuit(4);
    wire =  qc("wire");
    get_reg = qc("get_wire");

    wire(H, [2]);
    wire(CX, [2, 3]);
    wire(Z, [2]);
    wire(X, [3]);

    wire(H, [0]);
    wire(H, [1]);

    wire(multi_controlled(RY(pi/4), "0"), [0, 2]);
    wire(multi_controlled(RY(3*pi/4), "1"), [0, 2]);

    wire(multi_controlled(RY(-pi/2), "1"), [1, 3]);

    ret = get_ret();
end

function ret = e91_ineq_sum(reg)
    psum zeros(4);
    prob = zeros(4);

    for k=0:15
        pr_k = abs(reg(k + 1)^2);
        bin_k = dec2bin(k, 4) - '0';
        
end