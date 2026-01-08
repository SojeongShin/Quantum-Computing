% function ret = basis_time(N, t)
%     et = zeros(N, 1);
%     et(t + 1) = 1;
%     ret = et;
% 
% end
% 
% function ret = basis_freq(N, f)
%     wf = zeros(N, 1);
%     for k = 0:N-1
%         wf(k+1) = exp(1)^((2*pi*i*f/N)*k) / sqrt(N);
%     end
%     ret = wf;
% 
% end
% 
% global iprod
% iprod = @(a,b) b' * a;
% % quiz
% function ret = dft_mat(N)
%     global iprod
%     DFT = zeros(N, N);
%     for f = 0:(N-1)
%         w = basis_freq(N, f);
%         for t = 0:(N-1)
%             e = basis_time(N, t);
%             DFT(f+1, t+1) = iprod(e, w);
%         end
%     end
%     ret = DFT;
% end
% 
% equ = @(a, b) max(max(abs(a-b))) < 1e-10;
% e = basis_time(8, 2);
% w = basis_freq(8, 2);
% DFT = dft_mat(8);
% equ(DFT*w, e)

function ret = ket_t(n, t)
    et = zeros(2^n, 1);
    et(t + 1) = 1;
    ret = et;
end

function ret = ket_f(n, f)
    N = 2^n;
    wf = zeros(N, 1);
    for k = 0:N-1
        wf = wf + exp(1)^((2*pi*i*f/N)*k) / sqrt(N) * ket_t(n, k);
    end
    ret = wf;
end

function ret = qft_mat(n)
    global bra
    N = 2^n;
    Q = zeros(N, N);
    for f = 0:(N-1)
        kf = ket_t(n, f)
        kw = ket_f(n, f);
        Q = Q + kf * bra(kw)
    end
    ret = Q;
end

kt = ket_t(3, 2)
kf = ket_f(3, 2)
QFT = qft_mat(3);
equ(QFT * kf, kt)
