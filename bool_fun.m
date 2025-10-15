function main_bool_fun()
% bool_fun.m
%   Qiskit 버전의 DNF Boolean 함수 회로를
%   MATLAB(사용자 정의 quantum_circuit/wire)로 포팅

% 전제: qc_defs.m에서 아래 전역/함수들이 준비되어 있어야 함
%   global X H multi_controlled
%   quantum_circuit(n), wire = qc("wire"), get_reg = qc("get_reg")
%   (wire는 0-based 와이어 인덱스를 받는 구현)

run('qc_defs.m');
global k0 k1 b0 b1 X H multi_controlled


% ====== 테스트 하나 골라 실행 ======
% qc = qc_bool_fun_test();
qc = gt_bool_fun_test();
% qc = qc_lst_bool_fun_test();
% qc = gt_lst_bool_fun_test();

% 상태 출력 (원하면 히스토그램으로 바꿔도 됨)
get_reg = qc("get_reg");
psi = get_reg();                 % 상태 벡터 (길이 = 2^n)
n = round(log2(length(psi)));    % 큐비트 수
print_qr(psi, n);
end


% ------------------------------- 유틸 -------------------------------

function s = bitstr_msb(term, nr_in)
% MSB->LSB bitstring (ex: nr_in=3, term=5 -> '101')
    s = dec2bin(term, nr_in);
end

function qc = qc_bool_fun(qc, dnf, nr_in)
% qc_bool_fun(qc, dnf, nr_in)
%   dnf: 정수(term)들의 리스트. 각 term은 조건을 만족하는 입력 비트패턴
%   nr_in: 입력 비트 수
%
% 파이썬 판의 ctrl_state와 동일 효과: multi_controlled(X, ctrl_str)
%   여기서는 ctrl_str을 MSB->LSB로 넘긴다. 만약 엔디안이 반대라면 fliplr로 바꿔줘.
    % 정렬/중복제거
    terms = unique(sort(dnf(:).'));
    wire = qc("wire");

    % controls=[0..nr_in-1], target=nr_in  (0-based wire 인덱스 가정)
    for term = terms
        ctrl_str = bitstr_msb(term, nr_in);  % '0101' 등 (MSB->LSB)
        % 필요 시 아래 한 줄로 LSB<->MSB 반전
        % ctrl_str = fliplr(ctrl_str);

        op = multi_controlled(X, ctrl_str);
        wire(op, 0:nr_in);   % [controls..., target]
    end
end

function gt = gt_bool_fun(dnf, nr_in, name)
% gt_bool_fun(dnf, nr_in, name)
%   반환값은 (nr_in+1)-qubit 유니터리 게이트(행렬)
    if nargin < 3, name = ' Bool Fun '; end
    global X multi_controlled

    nq = nr_in + 1;
    U  = eye(2^nq);

    terms = unique(sort(dnf(:).'));
    for term = terms
        ctrl_str = bitstr_msb(term, nr_in);
        % ctrl_str = fliplr(ctrl_str); % 필요 시
        U = multi_controlled(X, ctrl_str) * U;
    end

    gt = U;  % wire(gt, [0..nr_in]) 형태로 붙여 사용
    % name은 주석용
end

function qc = qc_bool_fun_list(qc, dnf_list, nr_in)
% qc_bool_fun_list(qc, dnf_list, nr_in)
%   dnf_list: {dnf_out0, dnf_out1, ...} 혹은 행벡터 셀 아님이면 cell로 처리
%   출력 비트 수 = length(dnf_list)
    if ~iscell(dnf_list), dnf_list = num2cell(dnf_list, 2); end
    wire = qc("wire");

    nr_out = numel(dnf_list);
    % 모든 term 집합
    all_terms = unique(sort([dnf_list{:}]));
    for term = all_terms
        ctrl_str = bitstr_msb(term, nr_in);
        % ctrl_str = fliplr(ctrl_str); % 필요 시

        for o = 0:(nr_out-1)
            if ~ismember(term, dnf_list{o+1}), continue; end
            op = multi_controlled(X, ctrl_str);
            % controls=[0..nr_in-1], target = nr_in + o
            wire(op, [0:(nr_in-1), (nr_in+o)]);
        end
    end
end

function gt = gt_bool_fun_list(dnf_list, nr_in, name)
% gt_bool_fun_list(dnf_list, nr_in, name)
%   multi-output 유니터리( (nr_in+nr_out)-qubit )를 반환
    if nargin < 3, name = ' Bool Fun '; end
    global X multi_controlled
    if ~iscell(dnf_list), dnf_list = num2cell(dnf_list, 2); end

    nr_out = numel(dnf_list);
    nq     = nr_in + nr_out;
    U      = eye(2^nq);

    all_terms = unique(sort([dnf_list{:}]));
    for term = all_terms
        ctrl_str = bitstr_msb(term, nr_in);
        % ctrl_str = fliplr(ctrl_str); % 필요 시

        for o = 0:(nr_out-1)
            if ~ismember(term, dnf_list{o+1}), continue; end
            % 한 출력 타깃 o에 대한 연산자 구성:
            % controls는 앞 nr_in qubits, target은 nr_in+o 번째 qubit
            % multi_controlled는 (controls ⊗ target)만의 연산자이므로,
            % 전체 nq에 맞게 적절히 임베딩해서 누적 곱해준다.
            Uo = embed_ctrl_on_target(X, ctrl_str, nr_in, o, nq);
            U  = Uo * U;
        end
    end
    gt = U; %#ok<NASGU>  % name은 주석용
end

function Uo = embed_ctrl_on_target(Xgate, ctrl_str, nr_in, out_idx, nq)
% controls: 0..nr_in-1, target: nr_in + out_idx  (0-based)
% multi_controlled(X, ctrl_str)는 (nr_in+1)-qubit 연산자이므로
% 전체 nq로 임베딩하려면 타깃 위치를 맞춰 tensor로 확장/자리바꿈 필요.
    global multi_controlled
    op_small = multi_controlled(Xgate, ctrl_str); % (nr_in+1)-qubit

    % 작은 연산자의 퀴빗 순서는 [controls(0..nr_in-1) , target]
    % 전체 nq에서 타깃은 (nr_in+out_idx). 나머지 출력들(o'≠out_idx)은 항등.
    % 따라서 전체 순서를 [controls, target, others]로 재배열할 Permutation을 만든 뒤
    % (op_small ⊗ I_others)를 해당 순서에 맞춰 inverse-permute 한다.

    nr_out   = nq - nr_in;
    others   = setdiff(nr_in:(nq-1), nr_in+out_idx, 'stable'); % 나머지 출력 와이어
    order    = [0:(nr_in-1), nr_in+out_idx, others];           % 원하는 앞쪽 순서
    % 크기 체크
    dim_small  = 2^(nr_in+1);
    dim_others = 2^(nr_out-1);

    big = kron(op_small, eye(dim_others));  % [controls,target,others] 순서 기준
    Uo  = permute_qubits(big, order, nq);   % 해당 순서를 원래 [0..nq-1]로 되돌림
end

function U2 = permute_qubits(U, order, nq)
% U: 2^n × 2^n 유니터리, 현재 큐빗 순서가 'order'라고 가정.
% 이를 표준 순서 [0..nq-1]로 되돌리는 permutation 연산.
% 구현은 인덱스 기반 스왑으로 단순화.
    U2 = U;
    % order를 [0..nq-1]로 만들기 위한 스왑 시퀀스
    tgt = 0:(nq-1);
    for k = 1:nq
        if order(k) == tgt(k), continue; end
        j = find(order == tgt(k), 1, 'first');
        U2 = swap_qubits(U2, k-1, j-1, nq);      % 0-based 스왑
        % order 갱신
        tmp = order(k); order(k) = order(j); order(j) = tmp;
    end
end

function U3 = swap_qubits(U, q1, q2, nq)
% 두 큐빗(q1,q2)을 스왑하는 유니터리와 곱한다.
    if q1 == q2, U3 = U; return; end
    % 2-qubit SWAP을 전체 nq로 내삽
    % SWAP = |00><00| + |01><10| + |10><01| + |11><11|
    % 여기서는 표준 기저 순서에서 q1<->q2 비트만 바꾸는 퍼뮤테이션 행렬을 만든다.
    dim = 2^nq;
    Uperm = sparse(dim, dim);
    for i = 0:(dim-1)
        j = bitset(i, q1+1, bitget(i, q2+1));    % q1 <- old q2
        j = bitset(j, q2+1, bitget(i, q1+1));    % q2 <- old q1
        Uperm(j+1, i+1) = 1;
    end
    U3 = Uperm * U;
end


% ----------------------------- 테스트 ------------------------------

function qc = qc_bool_fun_test()
% 입력 3, 출력 1 (총 4 qubits). dnf=[3,5] 를 회로에 직접 구현
    run('qc_defs.m'); global H
    qc   = quantum_circuit(4);
    wire = qc("wire");

    % superposition on inputs (0,1,2)
    wire(H, [0]); wire(H, [1]); wire(H, [2]);
    wire(1, []);

    qc = qc_bool_fun(qc, [3,5], 3);
end

function qc = gt_bool_fun_test()
    global quantum_circuit
% 입력 3, 출력 1 (총 4 qubits). dnf=[3,5] 를 게이트로 만들어 append
    run('qc_defs.m'); global H
    qc   = quantum_circuit(4);
    wire = qc("wire");

    wire(H, [0]); wire(H, [1]); wire(H, [2]);
    wire(1, []);
    gt = gt_bool_fun([3,5], 3);       % 16x16 행렬
    wire(gt, [0,1,2,3]);
end

function qc = qc_lst_bool_fun_test()
% 2-출력 예: dnf_list = {[3,5], [4,5]}
    run('qc_defs.m'); global H
    qc   = quantum_circuit(5);
    wire = qc("wire");

    wire(H, [0]); wire(H, [1]); wire(H, [2]);
    wire(1, []);

    qc = qc_bool_fun_list(qc, {[3,5], [4,5]}, 3);
end

function qc = gt_lst_bool_fun_test()
% 2-출력 게이트 생성 후 append
    run('qc_defs.m'); global H
    qc   = quantum_circuit(5);
    wire = qc("wire");

    wire(H, [0]); wire(H, [1]); wire(H, [2]);
    wire(1, []);

    gt = gt_bool_fun_list({[3,5], [4,5]}, 3);   % 32x32 행렬
    wire(gt, [0,1,2,3,4]);
end


% ---- 선택: barrier 대용 (없으면 생략 가능) ----
function out = barrier(~)
% wire(@barrier, []) 형태로 호출 가능하게 더미 정의
    out = 1; %#ok<NASGU>
end
