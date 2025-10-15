##
## simon.py
##
from qiskit import QuantumCircuit, QuantumRegister, ClassicalRegister
from qiskit_aer import Aer
from qiskit_ibm_runtime import QiskitRuntimeService, SamplerV2 as Sampler
from qiskit.transpiler import generate_preset_pass_manager
from qiskit.visualization import plot_histogram
import matplotlib.pyplot as plt

from bool_fun import qc_bool_fun_list # Import the necessary function
import random

# return fs builder for a secret string s
def make_fs(s):
    # add fs to qc
    def add_fs(qc, nr_in):
        # fs(i) = fs(i ^ s)
        # nr_in is the number of input qubits (n)

        # randomly pick 2^nr_in numbers without duplication for output
        # This implementation ensures the function is two-to-one (if s != 0) or one-to-one (if s = 0)
        # by mapping i and i^s to the same random output value.
        fs = random.sample(range(0, 2**nr_in), 2**nr_in)
        for i in range(2**nr_in):
            fs[i ^ s] = fs[i] # Ensure fs(i) = fs(i ^ s)

        # build dnf_list for the multi-output boolean function
        dnf_list = []
        # In Simon's algorithm, the number of output bits (nr_out) is often set to nr_in (n)
        nr_out = nr_in

        for o in range(nr_out):
            # build dnf for each output bit 'o'
            dnf = []
            for i in range(2**nr_in):
                # Check if the o-th bit (LSB is bit 0) of fs[i] is 1
                # The expression (fs[i] >> o) & 1 checks the o-th bit of fs[i]
                if (fs[i] >> o) & 1:
                    dnf.append(i) # Add input 'i' to the DNF for the o-th output bit

            dnf = list(set(dnf))    # dedupe
            dnf_list.append(dnf)    # add dnf to dnf_list

        # implement dnf_list on qc using qc_bool_fun_list
        qc_bool_fun_list(qc, dnf_list, nr_in)

        return qc
    return add_fs

# add fs as an oracle gate
def gt_from_qc(fs, name=' Oracle '):
    def append(qc, nr_in):
        # Total qubits = nr_in (input register) + nr_in (output register)
        qc_f = QuantumCircuit(nr_in * 2, 0)
        # fs operates on the first nr_in qubits, and cnot-like gates flip the second nr_in qubits
        # The qc_f circuit passed to fs will have 2*nr_in qubits.
        # The qc_bool_fun_list in fs expects the input register (controls) to be indices 0 to nr_in-1
        # and the output register (targets) to be indices nr_in to 2*nr_in-1.
        # However, qc_bool_fun_list internally uses indices 0 to nr_in-1 for controls and
        # nr_in + o for targets, so it assumes a circuit size of nr_in + nr_out, where nr_out=nr_in.
        fs(qc_f, nr_in)
        gt = qc_f.to_gate()
        gt.name = name
        qc.append(gt, list(range(nr_in * 2)))
        return qc
    return append

# Simons' algorithm
def qc_simon(fs_gate_builder, nr_in):
    # Total qubits: 2*nr_in (n for input, n for output)
    qr = QuantumRegister(nr_in*2, 'q')
    # Classical bits for measurement: nr_in
    cr = ClassicalRegister(nr_in, 'meas')
    qc = QuantumCircuit(qr, cr)

    # 1. Uniform superposition on the input register (q[0] to q[nr_in-1])
    qc.h(range(nr_in))

    # Initialize output register |0>
    # The output register starts in |0>, which is the default for a QuantumCircuit.
    # To get the required state for the oracle Uf|x>|0> -> |x>|f(x)>, we need |x>|0> in the input.
    # The oracle implementation 'qc_bool_fun_list' acts as Uf|x>|y> -> |x>|y XOR f(x)>, which is correct.

    # 2. Add oracle
    fs_gate_builder(qc, nr_in)

    # 3. Make the interference: Apply Hadamard gates to the input register (q[0] to q[nr_in-1])
    qc.h(range(nr_in))

    # 4. Measure the input register (q[0] to q[nr_in-1])
    # The result 'y' is measured on the first nr_in qubits.
    qc.measure(range(nr_in), cr)

    return qc

# run qc on a simulator
def main_sim():
    # Example for secret string s = 000 (s=0) or s = 101 (s=5)
    # fs = make_fs(0) # s = 000
    fs = make_fs(5) # s = 101
    nr_in = 3 # n = 3
    qc = qc_simon(gt_from_qc(fs), nr_in)

    # display the quantum circuit
    qc.draw(output='mpl', filename='simon_circuit.png')
    plt.show()

    # a simulator backed
    backend = Aer.get_backend('aer_simulator')

    # transpile to the backend
    pm = generate_preset_pass_manager(backend = backend)
    isa_qc = pm.run(qc)

    # sample
    sampler = Sampler(backend)
    job = sampler.run([isa_qc], shots=1024)
    counts = job.result()[0].data.meas.get_counts()
    # counts = {k[::-1]:v for k, v in counts.items()} # reverse key (Qiskit's bit order is LSB-first in counts by default)
    # The `measure` call in qc_simon measures (q[0], q[1], ..., q[nr_in-1]) into (cr[0], cr[1], ..., cr[nr_in-1]).
    # The key format is a string where the *last* bit is cr[0], which corresponds to q[0] (the first measured qubit).
    # If we want the bitstring 'y' such that q[0] is the MSB, we need to reverse the key:
    counts = {k[::-1]:v for k, v in counts.items()} # reverse key to MSB-first

    # plot the histogram of the qpu result
    plot_histogram(counts)
    plt.show()
    return

if __name__ == '__main__':
    main_sim()