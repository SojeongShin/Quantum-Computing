function print_qr(state, n_qubits)
% print_qr(state, n_qubits)
%   state: column vector (2^n × 1)
%   n_qubits: number of qubits
%
%   Displays each basis state and its amplitude.

    if ~isvector(state)
        error('print_qr: input must be a state vector');
    end
    state = state(:);  % columnize

    N = length(state);
    if N ~= 2^n_qubits
        error('State size %d does not match 2^%d', N, n_qubits);
    end

    fprintf('\nQuantum register (%d qubits):\n', n_qubits);
    for i = 0:(N-1)
        bin_str = dec2bin(i, n_qubits);
        amp = state(i+1);
        if abs(amp) > 1e-12
            fprintf('|%s⟩ : (%.4f %+ .4fi)\n', bin_str, real(amp), imag(amp));
        end
    end
end
