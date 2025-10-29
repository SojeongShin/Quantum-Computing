##
## grover.py
##
from qiskit import QuantumCircuit, QuantumRegister, ClassicalRegister
from qiskit_aer import Aer
from qiskit_ibm_runtime import QiskitRuntimeService, SamplerV2 as Sampler
from qiskit.transpiler import generate_preset_pass_manager
from qiskit.visualization import plot_histogram
import matplotlib.pyplot as plt

import math
from bool_fun import *

#######################################
# oracle reflection
#
def f(sol):
    def qc_f(qc, nr_in):
       # TODO: implement the Boolean function f such that
       #    f(|x>|0>) = |x>|1> if x == sol
       #    f(|x>|0>) = |x>|0> if x != sol
       # hint: use qc_bool_fun


    return qc_f

# add f as a gate    
def gt_from_qc(f, name=' Oracle '):
    def append(qc, nr_in):
        qc_f = QuantumCircuit(nr_in+1, 0)
        f(qc_f, nr_in)
        gt = qc_f.to_gate()
        gt.name = name
        qc.append(gt, list(range(0, nr_in+1)))
        return qc
    return append


#######################################
# Grover's diffusion operation
#   : a.k.a. uniform reflection operation
#
# TODO: implement the uniform reflection operation
def qc_diffuser(qc, nr_in):
    # TODO: change of basis such that |+..+> -> |0..0>


    # TODO: phase kickback if the state is |0..0>


    # TODO: change of basis such that |0..0> -> |+..+>


    return qc

#######################################
# Grover's algorithm
#
# TODO: implement Grover's algorithm
def qc_grover(qc_oracle, nr_in):
    qr = QuantumRegister(nr_in+1, 'q')
    cr = ClassicalRegister(nr_in, 'meas')
    qc = QuantumCircuit(qr, cr)

    # TODO: prepare the |+..+> state


    # TODO: prepare the |-> state


    # TODO: compute the number of iterations
    nr_iter = 
    
    # TODO: run Grover's steps nr_iter times


    # TODO: measure the result


    return qc

# run qc on a simulator
def main_sim():
    qc = qc_grover(f(sol=3), nr_in=3)

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
