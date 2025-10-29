% superdense coding

function [] = superdense_coding(msg)
    global I X Z H CX
    qc_quantum_circuit;
    qc_defs;
    global print_qr quantum_circuit
    qc = quantum_circuit(2);
    wire = qc("wire");
    get_reg = qc("get_reg");
    
    % initialize |ab>
    wire(H, [0]);
    wire(CX, [0, 1]);
    
    if msg =="00"
        wire(I, [0]);
    elseif msg =="01"
        wire(X, [0]);
    elseif msg =="10"
        wire(Z, [0]);
    elseif msg =="11"
        wire(X, [0]);
        wire(Z, [0]);
    else
        assert(false);
    end
    
    % Bob
    wire(CX, [0, 1]);
    wire(H, [0]);
    
    reg = get_reg();
    % print_qr(reg, 2); ----------------------> 여기서 에러남
end