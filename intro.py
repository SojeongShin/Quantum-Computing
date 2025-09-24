from qiskit import QuantumCircuit
from qiskit_aer import Aer
from qiskit_ibm_runtime import QiskitRuntimeService, SamplerV2 as Sampler
from qiskit.transpiler import generate_preset_pass_manager
from qiskit.visualization import plot_histogram
import matplotlib.pyplot as plt

def qc_intro():
# make a quantum circuit
    qc = QuantumCircuit(1) # number of qubits
    # add X gate to qubit 0
    qc.x(0)
    # measure all qubits
    qc.measure_all()
    return qc

# run qc on a simulator
def main_sim():
    # qc for intro
    qc = qc_intro()

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