##
## simon.py
##
from qiskit import QuantumCircuit, QuantumRegister, ClassicalRegister
from qiskit_aer import Aer
from qiskit_ibm_runtime import QiskitRuntimeService, SamplerV2 as Sampler
from qiskit.transpiler import generate_preset_pass_manager
from qiskit.visualization import plot_histogram
import matplotlib.pyplot as plt

from bool_fun import *
import random

# return fs builder for a secret string s
def make_fs(s):
    # add fs to qc
    def add_fs(qc, nr_in):
        # fs(i) = fs(i ^ s) = fs[i]
        # randomly pick 2^nr_in numbers without duplication for output
        fs = random.sample(range(0, 2**nr_in), 2**nr_in)
        for i in range(2**nr_in):
            fs[i ^ s] = fs[i]

        # build dnf_list
        dnf_list = []
        nr_out = nr_in              
        for o in range(nr_out):
            # build dnf for each output bit
            dnf = []                
            for i in range(2**nr_in):
                # TODO: add i to dnf if o-th bit of fs[i] is not 0



            dnf = list(set(dnf))    # dedupe
            dnf_list.append(dnf)    # add dnf to dnf_list

        # TODO: implement dnf_list on qc using qc_bool_fun_list


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
def qc_simon(fs, nr_in):
    qr = QuantumRegister(nr_in*2, 'q')
    cr = ClassicalRegister(nr_in, 'meas')
    qc = QuantumCircuit(qr, cr)

    # TODO: uniform superposition


    # TODO: add oracle



    # TODO: make the interference



    # TODO: measure


    return qc

# run qc on a simulator
def main_sim():
    # fs = make_fs(0)
    fs = make_fs(5)
    # qc = qc_simon(fs, 3)
    qc = qc_simon(gt_from_qc(fs), 3)
    # qc = qc_simon(gt_from_qc(fs, name='   Fs   '), 2)

    # display the quantum circuit
    qc.draw(output='mpl')
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
    counts = {k[::-1]:v for k, v in counts.items()} # reverse key

    # plot the histogram of the qpu result
    plot_histogram(counts)
    plt.show()
    return

if __name__ == '__main__':
    main_sim()
