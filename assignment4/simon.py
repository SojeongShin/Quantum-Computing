##
## simon.py
##
from qiskit import QuantumCircuit, QuantumRegister, ClassicalRegister
from qiskit_aer import Aer
from qiskit_ibm_runtime import QiskitRuntimeService, SamplerV2 as Sampler
from qiskit.transpiler import generate_preset_pass_manager
from qiskit.visualization import plot_histogram
import matplotlib.pyplot as plt

from bool_fun import qc_bool_fun_list 
import random

# return fs builder for a secret string s
def make_fs(s):
    # add fs to qc
    def add_fs(qc, nr_in):
        # fs(i) = fs(i ^ s)
        nr_qubits = qc.num_qubits 
        nr_out = nr_qubits - nr_in 
        fs = random.sample(range(0, 2**nr_out), 2**nr_in)
        # Ensure fs(i) = fs(i ^ s)
        for i in range(2**nr_in):
            fs[i ^ s] = fs[i]

        # build dnf_list
        dnf_list = []
        for o in range(nr_out):
            # build dnf for each output bit
            dnf = []
            for i in range(2**nr_in):
                # Add input 'i' to the DNF if the o-th bit of fs[i] is not 0
                if (fs[i] >> o) & 1:
                    dnf.append(i)
            
            dnf = list(set(dnf))    # dedupe
            dnf_list.append(dnf)    # add dnf to dnf_list

        # implement dnf_list on qc using qc_bool_fun_list
        qc_bool_fun_list(qc, dnf_list, nr_in)

        return qc
    return add_fs

# add fs as an oracle gate
def gt_from_qc(fs, name=' Oracle '):
    def append(qc, nr_in):
        qc_f = QuantumCircuit(nr_in * 2, 0)
        fs(qc_f, nr_in)
        gt = qc_f.to_gate()
        gt.name = name
        qc.append(gt, list(range(nr_in * 2))) 
        return qc
    return append

# Simons' algorithm
def qc_simon(fs_gate_builder, nr_in):
    qr = QuantumRegister(nr_in*2, 'q') 
    cr = ClassicalRegister(nr_in, 'meas') 
    qc = QuantumCircuit(qr, cr)

    # 1. Uniform superposition
    qc.h(range(nr_in))

    # 2. Add oracle
    fs_gate_builder(qc, nr_in)

    # 3. Make the interference
    qc.h(range(nr_in))

    # 4. Measure
    qc.measure(range(nr_in), cr)

    return qc

# run qc on a simulator
def main_sim():
    # Example: secret string s = 101 (s=5)
    fs = make_fs(5) 
    nr_in = 3
    qc = qc_simon(gt_from_qc(fs), nr_in)

    qc.draw(output='mpl', fold=100)
    plt.show()

    # a simulator backed
    backend = Aer.get_backend('aer_simulator')

    # transpile to the backend
    pm = generate_preset_pass_manager(backend = backend)
    isa_qc = pm.run(qc)

    sampler = Sampler(backend)
    job = sampler.run([isa_qc], shots=1024)
    counts = job.result()[0].data.meas.get_counts()
    
    # Reverse key to MSB-first bitstring
    counts = {k[::-1]:v for k, v in counts.items()} 

    plot_histogram(counts)
    plt.show()
    return

if __name__ == '__main__':
    main_sim()