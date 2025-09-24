%
% qc_quantum_circuit.m
%
script = 1;

% export quantum_circuit
global quantum_circuit
quantum_circuit = @(nr_wire) make_quantum_circuit(nr_wire);

% import qc_defs
qc_defs;

% make_quantum_circuit(nr_wire)
%   - construct a quantum circuit of nr_wire wires (qubits)
%       it returns a dictionary of its member functions
%
%   - bit ordering of the quantum circuit
%       MSB of ket is at the first wire and LSB of ket is at the last wire
%       e.g., |abc>: a at the 1st wire, b at the 2nd wire, c at the 3rd wire
%
%   - let wi_x be a wire-index of the quantum circuit, then
%       wi_x is 0-based and wi_x is in [0, nr_wire-1]
%       wi_x = 0         : the first wire (top of qc)   
%       wi_x = nr_wire-1 : the last wire (bottom of qc)
%
function ret = make_quantum_circuit(nr_wire)
    % member variables
    qc_opr = eye(2^nr_wire);    % initial quantum circuit (identity)

    % accessors 
    %
    function ret = get_opr()    % get the mat. repr. of the quantum circuit
        ret = qc_opr;
    end
    function ret = get_reg()    % get the col. vec. repr. of the quantum state
        ret = qc_opr * ket__(0);
    end

    % ket__(nr)
    %   - returns |nr>
    %
    function ret = ket__(nr)
        ret = ket_with_size__(nr, nr_wire);
    end
    function ret = ket_with_size__(nr, nr_qubit)
        ret = zeros(2^nr_qubit, 1);
        ret(nr+1) = 1;
    end

    % swap__(wi_i, wi_j)
    %   - returns an operator that swaps the quantum states of
    %     the wires at wi_i and wi_j
    % 
    function ret = swap__(wi_i, wi_j)
        global I SWAP

        % bubble(wi_swap_indexes)
        %   bubble-up or bubble-down a qubit state along wi_swap_indexes
        %   wi_swap_indexes: swap indexes, i.e., the position of
        %       the swap operator in I @..@ I @ SWAP @ I @..@ I
        %
        function ret = bubble(wi_swap_indexes)
            opr = eye(2^nr_wire);
            for s = wi_swap_indexes   % s: index of SWAP 
                % TODO: build swp operator such that 
                %   - swp is of the form I @..@ I @ SWAP @ I @..@ I and
                %   - SWAP is wired at wire s and s+1. 
                swp = 1;
                for i = 0:(s-1)
                    swp = __________
                end
                swp = __________
                for i = (s+2):(nr_wire-1)
                    swp = __________
                end
                % apply swp to opr
                opr = __________
            end
            ret = opr;
        end

        % an index vector of the increasing order
        %   - swap(wi_i, wi_j) is equivalent to swap(wi_j, wi_i)
        if wi_j < wi_i
            t = wi_i; wi_i = wi_j; wi_j = t;
        end

        % bubble-up operation. 
        % e.g. to swap a and d in |abcd>
        %   |abcd> -> |bacd> -> |bcad> -> |bcda>
        wi_swap_indexes = __________
        swp_opr = bubble(wi_swap_indexes);

        % bubble-down operation
        % e.g. continued
        %   |bcda> -> |bdca> -> |dbca>
        wi_swap_indexes = __________
        swp_opr = __________

        ret = swp_opr;
    end

    % tack_pin__(opr, wi_tgt)
    %   makes an operator such that the pins of opr are repositioned (tacked)
    %   to wires at wi_tgt, i.e., [0..nr_pin-1] pins of opr are ready to
    %   be wired to the wires at wi_tgt
    %   - implementation steps
    %       - swap the states of the wires at wi_tgt
    %         and the wires at [0..nr_pin-1]
    %       - apply opr to the wires at [0..nr_pin-1]
    %       - swap the states of the wires at wi_tgt and
    %         the wires at [0..nr_pin-1]
    %   - e.g., steps to apply CX to [1,3] of |abcd>, i.e.,
    %     b is ctrl, d is target.
    %       - swap a and b of |abcd>   -> |bacd>
    %       - swap a and d of |bacd>   -> |bdca>
    %       - apply CX@I@I to |bdca>   -> |bd'ca>
    %       - swap a and d' of |bd'ca> -> |bacd'>
    %       - swap a and b of |bacd'>  -> |abcd'>
    %    
    function ret = tack_pin__(opr, wi_tgt)
        nr_pin = length(wi_tgt);

        % we want to move the i-th qubit in qi_src to the i-th wire
        qi_src = wi_tgt;

        % qi2wi: map from qubit index to wire index location after swaps
        %   qi2wi(qi): at which wire qi-th quibt is
        % initial qi2wi for |abc> is [0, 1, 2]
        % swapping a, b: |abc> -> |bac> changes qi2wi: [0, 1, 2] -> [1, 0, 2]
        % - qi2wi(0+1)=1: qubit 0 is at 1; qi2wi(1+1)=0: qubit 1 is at 0, ..
        qi2wi = 0:(nr_wire-1);     

        % TODO: swap the qubits of the wires at wi_indexes and 
        % those at the wires at [0..nr_pin-1]
        tacked_opr = eye(2^nr_wire);
        for i = 1:nr_pin
            % qi_src(i): the source qi that needs to be moved to i-1
            % qi2wi(qi_src(i)+1): the wire the source qubit is now
            if i-1 ~= qi2wi(qi_src(i)+1)  
                % move the i-th qubit to wire i-1     
                tacked_opr = __________

                % update qi2wi map
                qi = find(qi2wi==(i-1)) - 1;        % occupant of wire i-1
                qi2wi(qi+1) = qi2wi(qi_src(i)+1);   % qi is moved to where i-th qubit was
                qi2wi(qi_src(i)+1) = i-1;           % qi_src(i) is moved to i-1
            end
        end

        % TODO: apply opr to qubits at [0..nr_pin-1]
        %   i.e., qc_opr =  (opr @ I @..@ I) * qc_opr
        tacked_opr = __________

        % TODO: mvoe the relocated qubits to their original wires
        for i = 1:nr_wire
            if i-1 ~= qi2wi(i)          % if qubit i is not at wire i-1
                % move the qubit i to wire i-1
                tacked_opr = __________

                % update qi2wi map
                qi = find(qi2wi==(i-1)) - 1;    % occupant of wire i-1
                qi2wi(qi+1) = qi2wi(i);         % qi is moved to where i-th qubit was
                qi2wi(i) = i-1;                 % i-th qubit is moved to wire i-1
            end
        end
        ret = tacked_opr;        
    end 

    % wire(opr, wi_indexes)
    %   - wires opr to the quantum circuit such that
    %   - [0..nr_pin-1] pins of opr are wired to the wires at wi_indexes
    % 
   function ret = wire(opr, wi_indexes)
        opr = __________    % tack pins of opr to wi_indexes
        qc_opr = __________ % wire opr to qc (update qc_opr)
        ret = qc_opr;
    end

    % measure(wi_indexes)
    %   - measure qubits at wi_indexes
    %   - return the measured number (MSB: wi_indexes(1), LSB: wi_indexes(end))
    %   - collapse the quantum state
    %
    function ret = measure(wi_indexes)
        global bra
        nr_pin = length(wi_indexes);
        reg  = __________               % current quantum state
        prnd = rand();                  % sample if psum >= prnd
        psum = 0;                       % check when psum >= prnd
        for ket_nr = 0:(2^nr_pin - 1)
            ket = ket_with_size__(ket_nr, nr_pin);
            prj = __________            % prj = |ket_nr><ket_nr|
            prj = __________            % tack pins of prj to wi_indexes
            p = __________              % p = P[ measure ket_nr ]               
            psum = psum + p;            % accumulate p to psum
            if psum >= prnd             % sample
                ret = __________        % measured value
                qc_opr = __________     % collapse state
                return;
            end
        end
    end

    % dispatcher for make_quantum_circuit
    %
    function ret = dispatch(str_opr)
        switch str_opr
            case "get_opr",     ret = @get_opr;
            case "get_reg",     ret = @get_reg;
            case "wire",        ret = @wire;
            case "measure",     ret = @measure;
            case "ket__",       ret = @ket__;
            case "swap__",      ret = @swap__;
            case "tack_pin__",  ret = @tack_pin__;
            otherwise,      assert(false);
        end
    end
    ret = @dispatch;
end  % end of make_quantum_circuit
