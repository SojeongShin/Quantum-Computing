from qiskit import QuantumCircuit

#
def qc_boolean4():
    # make a quantum circuit
    qc = QuantumCircuit(5) # number of qubits
    # add H gate to qubit 0
    qc.h(0)
    qc.h(1)    
    qc.h(2)
    qc.h(3)
    qc.barrier()

    # encode (0011)
    # -q0, q1, q2
    qc.mcx([0, 1, 2, 3], 4, ctrl_state='0011'[::-1])
    qc.barrier()
    # encode (0101)
    # q0, -q1, q2
    qc.mcx([0, 1, 2, 3], 4, ctrl_state='0101'[::-1])

    # encode (1111)
    # q0, -q1, q2
    qc.mcx([0, 1, 2, 3], 4, ctrl_state='1111'[::-1])

    qc.measure_all()
    return qc
