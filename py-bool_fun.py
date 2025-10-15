##
## bool_fun.py
##
from qiskit import QuantumCircuit
from qiskit_aer import Aer
from qiskit_ibm_runtime import QiskitRuntimeService, SamplerV2 as Sampler
from qiskit.transpiler import generate_preset_pass_manager
from qiskit.visualization import plot_histogram
import matplotlib.pyplot as plt

# qc_bool_fun(qc, dnf, nr_in)
#   make a boolean function from DNF on qc
#   dnf: list of conjunctive terms of a DNF
#   nr_in: number of input variables
#
def qc_bool_fun(qc, dnf, nr_in):
    terms = dnf.copy()
    terms.sort()

    controls = list(range(nr_in))
    target = nr_in

    for term in terms:
        # MSB->LSB bitstring of length nr_in
        ctrl_str = format(term, f'0{nr_in}b')
        # Qiskit ctrl_state is interpreted little-endian w.r.t. controls order
        qc.mcx(controls, target, ctrl_state=ctrl_str[::-1])

    return qc

# gt_bool_fun(dnf, nr_in, name)
#   make a boolean function from DNF as a gate
#   dnf: list of conjunctive terms of a DNF
#   nr_in: number of input variables
#   name: name of the gate
#
def gt_bool_fun(dnf, nr_in, name=' Bool Fun '):
    qc = QuantumCircuit(nr_in + 1, 0)
    qc_bool_fun(qc, dnf, nr_in)
    gt = qc.to_gate()
    gt.name = name
    return gt


# qc_bool_fun_list(qc, dnf_list, nr_in)
#   make a multi-output boolean function from DNF on qc
#   dnf_list: list of list of conjunctive terms of a DNF for each output bit
#   nr_in: number of input variables
#
def qc_bool_fun_list(qc, dnf_list, nr_in):
    nr_out = len(dnf_list)
    controls = list(range(nr_in))

    # dedupe: unique dnfs in dnf_list
    terms = list(set(x for y in dnf_list for x in y))
    terms.sort()

    for term in terms:
        # MSB->LSB bitstring (shared by all outputs that contain this term)
        ctrl_str = format(term, f'0{nr_in}b')
        for o in range(nr_out):
            if term not in dnf_list[o]:
                continue
            target = nr_in + o
            qc.mcx(controls, target, ctrl_state=ctrl_str[::-1])

    return qc

# gt_bool_fun_list(dnf_list, nr_in, name)
#   make a multi-output boolean function from DNF as a gate
#   dnf_list: list of list of conjunctive terms of a DNF for each output bit
#   nr_in: number of input variables
#   name: name of the gate
#
def gt_bool_fun_list(dnf_list, nr_in, name=' Bool Fun '):
    nr_out = len(dnf_list)
    qc = QuantumCircuit(nr_in + nr_out, 0)
    qc_bool_fun_list(qc, dnf_list, nr_in)
    gt = qc.to_gate()
    gt.name = name
    return gt

def qc_bool_fun_test():
    qc = QuantumCircuit(4)
    # superposition of all input
    qc.h(0)
    qc.h(1)
    qc.h(2)
    qc.barrier()

    qc_bool_fun(qc, [3, 5], 3)  # implement directly on qc

    # make the measurement
    qc.measure_all()
    return qc

def gt_bool_fun_test():
    qc = QuantumCircuit(4)
    # superposition of all input
    qc.h(0)
    qc.h(1)
    qc.h(2)
    qc.barrier()

    # make the boolean function as a gate
    gt = gt_bool_fun([3, 5], 3)
    qc.append(gt, [0, 1, 2, 3])  # append the gate to qc

    # make the measurement
    qc.measure_all()
    return qc

def qc_lst_bool_fun_test():
    qc = QuantumCircuit(5)
    # superposition of all input
    qc.h(0)
    qc.h(1)
    qc.h(2)
    qc.barrier()

    qc_bool_fun_list(qc, [[3, 5], [4, 5]], 3)  # implement directly on qc

    # make the measurement
    qc.measure_all()
    return qc

def gt_lst_bool_fun_test():
    qc = QuantumCircuit(5)
    # superposition of all input
    qc.h(0)
    qc.h(1)
    qc.h(2)
    qc.barrier()

    # make the boolean function as a gate
    gt = gt_bool_fun_list([[3, 5], [4, 5]], 3)
    qc.append(gt, [0, 1, 2, 3, 4])  # append the gate to qc

    # make the measurement
    qc.measure_all()
    return qc

def main():
    # qc = qc_bool_fun_test()
    qc = gt_bool_fun_test()
    # qc = qc_lst_bool_fun_test()
    # qc = gt_lst_bool_fun_test()

    # display the quantum circuit
    qc.draw(output='mpl', fold=100)
    plt.show()

    # a simulator backed
    backend = Aer.get_backend('aer_simulator')

    # transpile to the backend
    pm = generate_preset_pass_manager(backend=backend)
    isa_qc = pm.run(qc)

    # sample
    sampler = Sampler(backend)
    job = sampler.run([isa_qc], shots=1024)
    counts = job.result()[0].data.meas.get_counts()
    counts = {k[::-1]: v for k, v in counts.items()}  # reverse key

    # plot the histogram of the qpu result
    plot_histogram(counts)
    plt.show()
    return

if __name__ == '__main__':
    main()
