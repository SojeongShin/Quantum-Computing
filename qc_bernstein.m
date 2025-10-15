% Bernstein-Vazirani [qc_bernstein_vazirani.m]
%
global bv_oracle bernstein_vazirani
bernstein_vazirani_oracle = @bernstein_vazirani_oracle__;
bernstein_vazirani = @bernstein_vazirani__;

function ret = bernstein_vazirani_oracle__(sstr)

    global CX quantum_circuit
    sstr = char(sstr); % to char array
    nr = length(sstr);
    qc = quantum_circuit(nr+1);
    wire = qc("wire");
    get_opr = qc("get_opr");

    for i = 1:nr 
        if sstr(i) == '1'
            wire(CX, [i-1, nr]);
        % phase kickback
        end
    end

    ret = get_opr();
end

function bernstein_vazirani__(Fs, nr_in)
    global X H quantum_circuit print_qr

    qc = quantum_circuit(nr_in+1);
    wire = qc("wire");
    get_reg = qc("get_reg");
    wire(X, [nr_in]); wire(H, [nr_in]);
    
    for i = 1:nr_in 
        wire(H, [i-1]);
    end
    
    wire(Fs, 0:nr_in); 
    for i = 1:nr_in 
        wire(H, [i-1]);
    end
    % |-> for phase kickback
    % superposition
    % oracle (phase kickback)
    % interference
    print_qr(get_reg(), nr_in+1);
end