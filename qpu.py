from intro import qc_intro
from bell import qc_bell
from boolean import qc_boolean4
from qiskit_aer import Aer
from qiskit_ibm_runtime import QiskitRuntimeService, SamplerV2 as Sampler
from qiskit.transpiler import generate_preset_pass_manager
from qiskit.visualization import plot_histogram
import matplotlib.pyplot as plt

# run qc on a QPU
def main_qpu():
    # qc for intro
    qc = qc_boolean4()

    # display the quantum circuit
    qc.draw(output='mpl')
    plt.show()

    # find a backend
    service = QiskitRuntimeService()
    print(service.backends())

    backend = service.least_busy(operational=True, simulator=False, min_num_qubits=4)

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
    main_qpu()