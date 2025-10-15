% Deutsch-Jozsa's algorithm [qc_deutsch_jozsa.m]
%
global deutsch_jozsa;
deutsch_jozsa = @deutsch_jozsa__;

    function [] = deutsch_jozsa__(F, nr_in)
    global X H quantum_circuit print_qr
    
    qc = quantum_circuit(nr_in+1);
    wire = qc("wire");
    get_reg = qc("get_reg");
    wire(X, [nr_in]); wire(H, [nr_in]);

    % |-> for phase kickback
    for i = 1:nr_in 
        wire(H, [i-1]);
    % superposition
    end
    wire(F, 0:nr_in); % phase kickback (oracle)
    for i = 1:nr_in 
        wire(H, [i-1]);
    % interference
    end
    MATLAB
    print_qr(get_reg(), nr_in+1);
end