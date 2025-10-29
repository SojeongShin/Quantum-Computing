
qc_defs;

function ret = chsh_game()
    global X Z H CX CH RY multi_controlled
    global print_qr quantum_circuit
    
    qc = quantum_circuit(4);
    wire = qc("wire");
    get_reg = qc("get_reg");
    
    % initial state
    wire(H, [2]);
    wire(CX, [2, 3]);
    wire(Z, [2]);
    
    % 
    wire(H, [0]);
    wire(H, [1]);
    
    wire(multi_controlled(RY(-pi/8), "0"), [0, 2]);
    wire(multi_controlled(RY(3*pi/8), "1"), [0, 2]);
    wire(multi_controlled(RY(-pi/8), "0"), [1, 3]);
    wire(multi_controlled(RY(3*pi/8), "1"), [1, 3]);

    % measure
    ret = get_reg();
end

function ret = chsh_game_winning_prob(reg)
    p_win = 0;
    for k = 0:15
        pr_k = abs(reg(k+1))^2;

        bin_k = dec2bin(k, 4) - '0';
        x = bin_k(1);
        y = bin_k(2);
        a = bin_k(3);
        b = bin_k(4);
        if and(x, y) == xor(a, b)
            p_win = p_win + pr_k;
        end
    end
    ret = p_win;
end

reg = chsh_game();
print_qr(reg, 4);

p_win = chsh_game_winning_prob(reg)
p_win > 0.75