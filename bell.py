from qiskit import QuantumCircuit

# bell state: (|00> + |11)/sqrt(2)
#
def qc_bell():
    # make a quantum circuit
    qc = QuantumCircuit(2) # number of qubits
    # add H gate to qubit 0
    qc.h(0)
    # add CX gate to qubit 0 (ctrl) and 1 (target)
    qc.cx(0, # control qubit
    1) # target qubit
    # measure qubits
    qc.measure_all()
    return qc
