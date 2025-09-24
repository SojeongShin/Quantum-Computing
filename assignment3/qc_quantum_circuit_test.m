%
% qc_quantum_circuit_test.m
%   unit test cases for quantum_circuit
%
script = 1;

% import quantum_circuit
qc_quantum_circuit;

function ret = equ(a, b)
    ret = max(max(abs(a-b))) < 1e-10;
end

function [] = test_swap()
    global quantum_circuit
    qc   = quantum_circuit(3);
    ket  = qc("ket__");
    swap = qc("swap__");

    reg = ket(bin2dec("001"));      % |001>
    assert(equ(reg, ket(1)));
    swap(1, 2);
    reg = swap(1, 2) * reg;         % |010>
    assert(equ(reg, ket(bin2dec("010"))));
    reg = swap(0, 1) * reg;         % |100>
    assert(equ(reg, ket(bin2dec("100"))));

    reg = swap(1, 0) * reg;         % |010>
    assert(equ(reg, ket(bin2dec("010"))));
    reg = swap(2, 1) * reg;         % |001>
    assert(equ(reg, ket(bin2dec("001"))));

    reg = swap(2, 0) * reg;         % |100>
    assert(equ(reg, ket(bin2dec("100"))));
    reg = swap(0, 2) * reg;         % |001>
    assert(equ(reg, ket(bin2dec("001"))));
end
test_swap();


function [] = test_tack_pin()
    global I X CX SWAP
    global quantum_circuit
    qc      = quantum_circuit(2);
    tack_pin = qc("tack_pin__");

    opr = tack_pin(X, [1]);     % tack to the second wire
    assert(equ(opr, kron(I, X)));

    opr = tack_pin(CX, [1, 0]); % reverse ctrl and target
    assert(equ(opr, SWAP*CX*SWAP));
end
test_tack_pin();

function [] = test_init()
    global I
    global quantum_circuit
    qc      = quantum_circuit(1);
    get_opr = qc("get_opr");
    get_reg = qc("get_reg");
    ket     = qc("ket__");

    opr = get_opr();    % I
    assert(equ(opr, I));

    reg = get_reg();    % |0>
    assert(equ(reg, ket(0)));
end
test_init();

function [] = test_H()
    global H
    global quantum_circuit
    qc      = quantum_circuit(1);
    get_opr = qc("get_opr");
    get_reg = qc("get_reg");
    wire    = qc("wire");
    ket     = qc("ket__");

    wire(H, [0]);       % H
    opr = get_opr();
    assert(equ(opr, H));

    reg = get_reg();    % (|0>+|1>)/sqrt(2)
    assert(equ(reg, (ket(0)+ket(1))/sqrt(2)));    
end
test_H();

function [] = test_CX()
    global X CX
    global quantum_circuit
    qc      = quantum_circuit(2);
    get_opr = qc("get_opr");
    get_reg = qc("get_reg");
    wire    = qc("wire");
    ket     = qc("ket__");

    wire(X,  [1]);      % |01>
    wire(CX, [1, 0]);   % |11>, reverse order

    reg = get_reg();    % |11>
    assert(equ(reg, ket(3)));    
end
test_CX();

function [] = test_Bell()
    global I H CX
    global quantum_circuit
    qc      = quantum_circuit(2);
    get_opr = qc("get_opr");
    get_reg = qc("get_reg");
    wire    = qc("wire");
    ket     = qc("ket__");

    wire(H,  [0]);      % H@I
    wire(CX, [0, 1]);   % CX
    opr = get_opr();
    assert(equ(opr, CX * kron(H, I)));

    reg = get_reg();    % (|00>+|11>)/sqrt(2)
    assert(equ(reg, (ket(0)+ket(3))/sqrt(2)));
end
test_Bell();

function [] = test_Bell2()
    global I H CX SWAP
    global quantum_circuit
    qc      = quantum_circuit(3);
    get_opr = qc("get_opr");
    get_reg = qc("get_reg");
    wire    = qc("wire");
    ket     = qc("ket__");

    wire(H,    [0]);        % (|000> + |100>)/sqrt(2)
    wire(CX,   [0, 2]);     % (|000> + |101>)/sqrt(2)
    wire(SWAP, [1, 2]);     % (|000> + |110>)/sqrt(2)

    opr = get_opr();
    assert(equ(opr, kron(CX,I)*kron(I,SWAP)*kron(H,kron(I, I))));

    reg = get_reg();    % (|000> + |110>)/sqrt(2)
    assert(equ(reg, (ket(bin2dec("000"))+ket(bin2dec("110")))/sqrt(2)));
end
test_Bell2();


function [] = test_gate()
    global I H CX SWAP
    global quantum_circuit
    gate    = quantum_circuit(2);
    get_opr = gate("get_opr");
    wire    = gate("wire");
    wire(H,  [0]);          % H@I
    wire(CX, [0, 1]);       % CX
    gt_bell = get_opr();
    
    qc      = quantum_circuit(4);
    get_reg = qc("get_reg");
    wire    = qc("wire");
    ket     = qc("ket__");
    wire(gt_bell, [0, 3]);  % wire a gate to qc
    wire(SWAP,    [1, 3]);

    reg = get_reg();    % (|0000> + |1100>)/sqrt(2)
    assert(equ(reg, (ket(bin2dec("0000"))+ket(bin2dec("1100")))/sqrt(2)));
end
test_gate();


function test_measure()
    global I X H CX k00 k10 k11
    global quantum_circuit
    qc      = quantum_circuit(2);
    get_opr = qc("get_opr");
    get_reg = qc("get_reg");
    wire    = qc("wire");
    measure = qc("measure");
    ket     = qc("ket__");
    
    % |00> state
    %
    mea = measure([0, 1]);
    assert(mea == 0);
    reg = get_reg();
    assert(equ(reg, k00));

    % |10> state
    %
    wire(X, [0]);
    
    mea = measure([0, 1]);
    assert(mea == 2);
    reg = get_reg();
    assert(equ(reg, k10));

    mea = measure([0]);
    assert(mea == 1);
    reg = get_reg();
    assert(equ(reg, k10));

    mea = measure([1]);
    assert(mea == 0);
    reg = get_reg();
    assert(equ(reg, k10));

    % |00>-|11> state
    %
    wire(H,  [0]);
    wire(CX, [0, 1]);

    mea = measure([0]);
    reg = get_reg();
    if mea == 0
        assert(equ(reg, k00))
    else
        assert(equ(reg, -k11))
    end
end
test_measure()

fprintf('Success!\n');
