# quantum_counting_visual.py

from qiskit import QuantumCircuit, QuantumRegister, ClassicalRegister, transpile
from qiskit_aer import AerSimulator
from qiskit.visualization import plot_histogram
import matplotlib.pyplot as plt
import numpy as np

# =========================================================
# 1) Boolean formula: f(x,y,z) = (x AND y) OR z
# =========================================================

def formula():
    sols = []
    for x in [0, 1]:
        for y in [0, 1]:
            for z in [0, 1]:
                f = (x & y) | z  # f(x,y,z) = (x AND y) OR z
                if f == 1:
                    sols.append(f"{x}{y}{z}")  # MSB->LSB: xyz
    return sols

marked_states = formula()
print("f(x,y,z)=1 states:", marked_states)  # 5 : '001', '011', '101', '110', '111'

# =========================================================
# 2) Oracle: marked_states states flip (-1)
# =========================================================

def make_oracle_gate(n_data, marked_bitstrings):
    qr = QuantumRegister(n_data, "data_sub")
    qc = QuantumCircuit(qr, name="Oracle_f")

    for bitstring in marked_bitstrings:
        # to make bitstring |111...>,  add X 0 state position
        for i, bit in enumerate(bitstring[::-1]):  # Qiskit little-endian
            if bit == '0':
                qc.x(qr[i])

        # multicontrolled Z (H-Z-H)
        qc.h(qr[n_data - 1])
        qc.mcx(qr[0:n_data - 1], qr[n_data - 1])
        qc.h(qr[n_data - 1])

        # X retrurn to original
        for i, bit in enumerate(bitstring[::-1]):
            if bit == '0':
                qc.x(qr[i])

    return qc.to_gate(label="Oracle_f")

# =========================================================
# 3) Diffuser (Grover diffuser)
# =========================================================

def make_diffuser_gate(n_data):
    qr = QuantumRegister(n_data, "data_sub")
    qc = QuantumCircuit(qr, name="Diffuser")

    qc.h(qr)
    qc.x(qr)

    qc.h(qr[n_data - 1])
    qc.mcx(qr[0:n_data - 1], qr[n_data - 1])
    qc.h(qr[n_data - 1])

    qc.x(qr)
    qc.h(qr)

    return qc.to_gate(label="Diffuser")

# =========================================================
# 4) Grover operator G = D * O 
# =========================================================

def make_grover_gate(n_data, marked_bitstrings):
    qr = QuantumRegister(n_data, "data_sub")
    qc = QuantumCircuit(qr, name="G")

    oracle_gate = make_oracle_gate(n_data, marked_bitstrings)
    diffuser_gate = make_diffuser_gate(n_data)

    qc.append(oracle_gate, qr[:])
    qc.append(diffuser_gate, qr[:])

    return qc.to_gate(label="G")

# =========================================================
# 5) Inverse QFT (in-place)
# =========================================================

def inverse_qft(qc, qubits):
    n = len(qubits)
    # swap(reverse)
    for j in range(n // 2):
        qc.swap(qubits[j], qubits[n - 1 - j])
    # controlled-phase + H
    for j in range(n):
        k = n - 1 - j
        qc.h(qubits[k])
        for m in range(k):
            qc.cp(-np.pi / (2 ** (k - m)), qubits[m], qubits[k])

# =========================================================
# 6) Quantum Counting 회로 구성
# =========================================================

n_data = 3   # x,y,z
n_count = 4  # counting precision

qr_count = QuantumRegister(n_count, "count")
qr_data  = QuantumRegister(n_data, "data")
cr_count = ClassicalRegister(n_count, "c_count")

qc = QuantumCircuit(qr_count, qr_data, cr_count)

# Step 1: 균일 중첩
qc.h(qr_count)
qc.h(qr_data)

# Grover Gate
G_gate = make_grover_gate(n_data, marked_states)

# Step 2: controlled-G^(2^j)
for j in range(n_count):
    power = 2 ** j
    controlled_G = G_gate.control(1)
    for _ in range(power):
        qc.append(controlled_G, [qr_count[j]] + list(qr_data))

# Step 3: counting 레지스터에 Inverse QFT
inverse_qft(qc, list(range(n_count)))

# Step 4: counting 레지스터 측정
qc.measure(qr_count, cr_count)

# =========================================================
# 7) 회로 그림 그리기
# =========================================================

# matplotlib 백엔드에 따라 필요하면 주석 해제
# import matplotlib
# matplotlib.use("TkAgg")  # Mac에서 GUI로 띄우고 싶을 때

print(qc.draw())  # 텍스트 버전 출력

# MPL 그림으로
qc.draw(output="mpl")
plt.title("Quantum Counting Circuit (Boolean formula)")
plt.tight_layout()
plt.show()

# =========================================================
# 8) 시뮬레이션 + 히스토그램 그리기
# =========================================================

sim = AerSimulator()
tqc = transpile(qc, sim)
job = sim.run(tqc, shots=4096)
result = job.result()
counts = result.get_counts()

print("Counting 레지스터 측정 결과:", counts)

# 히스토그램 플롯
plt.figure()
plot_histogram(counts)
plt.title("Quantum Counting: Counting Register Measurement")
plt.tight_layout()
plt.show()

# =========================================================
# 9) 결과 해석 (M 추정)
# =========================================================

most_prob_state = max(counts, key=counts.get)
m = int(most_prob_state, 2)

t = n_count
phi = m / (2 ** t)             # φ ≈ θ / (2π)
theta = 2 * np.pi * phi
N = 2 ** n_data
M_est = N * (np.sin(theta / 2) ** 2)

print("\n[결과 해석]")
print(f"가장 많이 나온 m = {m} (binary {most_prob_state})")
print(f"추정된 θ ≈ {theta:.4f} rad")
print(f"추정된 해의 개수 M ≈ {M_est:.2f}")
print(f"실제 해 개수 (truth table) = {len(marked_states)}")
