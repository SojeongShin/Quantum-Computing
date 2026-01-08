%
% wavefunction.m
%    Quantum Harmonic Oscillator 
%    HCl example: H is vibrating while attached to Cl
%
script = 1;

% HCl parameters
%
global hbar m w;
global hscl mscl wscl;
h    = 4.135667696;  % (eV/Hz)
hscl = 1e-15;        % scale factor for h
hbar = h/(2*pi);
m    = 1.67;         % (kg)
mscl = 1e-27;        % scale factor for m
w    = 2*pi*8.88;    % (rad/sec)
wscl = 1e13;         % scale factor for w

%
% P1. [1 pt] Implement the position operator
%   position psi(x) = x psi(x)
%
function ret = position(psi)
    ret = @(x) x .* psi(x);
end    

% test
%
r = position(@(x) x^3);
assert(isa(r, 'function_handle'));
assert(abs(r(2) - 16) < 1e-10);

rr = position(r);
assert(isa(rr, 'function_handle'));
assert(abs(rr(2) - 32) < 1e-10);
fprintf('Success!\n');

%
% P2. [1 pt] Implement the momentum operator
%   momentum psi = -i hbar psi'
%   hint: use derivative function
%
function ret = momentum(psi)
    global hbar m w;
    dpsi_dx = derivative(psi);
    ret = @(x) -1i * hbar * dpsi_dx(x);
end
function ret = derivative(f)
    eps = 1e-6;
    ret = @(x) (f(x+eps) - f(x)) / eps;
end

% test
%
p = momentum(@(x) x^3);
assert(isa(p, 'function_handle'));
assert(abs(p(2)/hbar - -12i) < 1e-5);

pp = momentum(p);
assert(isa(pp, 'function_handle'));
assert(abs(pp(2)/hbar^2 - -12) < 1e-3);
fprintf('Success!\n')

%
% P3. [2 pt] Implement the Hamiltonian operator
%   H = Kinetic energy op + Potential energy op
%     = 1/(2m) * p^2      + 1/2 *m * w^2 * r^2
%
function ret = hamiltonian(psi)
    global hbar m w;
    global hscl mscl wscl
    r  = position(psi);
    rr = position(r);       % rr: r^2
    p  = momentum(psi);
    pp = momentum(p);       % pp: p^

    ret = @(x)  (1/(2*m)) * pp(x) * (hscl^2/mscl) + ...   % Kinetic E
                0.5 * m * (w^2) * rr(x) * (mscl*wscl^2);       % Potential E
end    

% test
%
h = hamiltonian(@(x) x^3);
assert(isa(h, 'function_handle'));
assert(abs(h(2) - 8.31805985e3) < 1e-3);
fprintf('Success!\n')


%
% Quantum Harmonic Oscillator
%     psi_n(x) = 1/sqrt( 2^n n! ) *
%                ( (m w)/(pi hbar) )^{1/4} *
%                exp( (-m w x .^2)/(2 hbar) ) .*
%                H_n( sqrt((m w)/hbar) .* x )
%     E_n = hbar w (n + 1/2)
%

%
% P4. [1 pt] Implement the energy function for E_n
%
function ret = energy(n)
    global hbar m w;
    global hscl mscl wscl
    ret = (hbar * w * (n + 0.5)) * (hscl*wscl);
end

% test
%
assert(energy(1) - 0.550870937 < 1e-5);
assert(energy(2) - 0.918118229 < 1e-5);
assert(energy(3) - 1.285365520 < 1e-5);
fprintf('Success!\n')

% 
% P5. [3 pt] Implement the wave function psi_n and the Hermite polynomial
%
function ret = wave(n)
    global hbar m w;
    global hscl mscl wscl
    hbs = hbar * hscl;  % use this scaled hbar (hbs)
    ms  = m * mscl;     % use this scaled m (ms)
    ws  = w * wscl;     % use this scaled w (ws)
    prefactor = 1 / sqrt( (2^n) * factorial(n) );
    norm_const = ((ms*ws) / (pi * hbs))^(1/4);

    ret = @(x) prefactor * norm_const .* ...
               exp( (-ms*ws .* x.^2) / (2*hbs) ) .* ...
               hermite(n, sqrt((ms*ws)/hbs) .* x);
end

% Implement the hermite polynomial function
% Hermite Polynomial
%     H_{0} = 1,
%     H_{1} = 2x,
%     H_{n} = 2*x*H_{n-1} - 2*(n-1)*H_{n-2}
%
function ret = hermite(n, x)
    if n == 0
        ret = ones(size(x));
    elseif n == 1
        ret = 2 .* x;
    else
        H0 = ones(size(x));   % H_0
        H1 = 2 .* x;          % H_1
        for k = 2:n
            Hn = 2 .* x .* H1 - 2*(k-1) .* H0;
            H0 = H1;
            H1 = Hn;
        end
        ret = Hn;
    end
end

% test
%
wf = wave(1);
assert(wf(0)    -  0 < 1e-5);
assert(wf(0.1)  -  0.020676533 < 1e-5);
assert(wf(-0.1) - -0.020676533 < 1e-5);

wf = wave(2);
assert(wf(0)    - -3.257867510 < 1e-5);
assert(wf(0.1)  -  0.075046864 < 1e-5);
assert(wf(-0.1) -  0.075046864 < 1e-5);

% orthonormality of eigenfunctions
iprod = @(f, g) integral(@(x) f(x) .* conj(g(x)), -Inf, Inf);
wf1 = wave(1);
wf2 = wave(2);
wf3 = wave(3);
assert(abs(iprod(wf1, wf1) - 1) < 1e-10);
assert(abs(iprod(wf2, wf2) - 1) < 1e-10);
assert(abs(iprod(wf3, wf3) - 1) < 1e-10);

assert(abs(iprod(wf1, wf2)) < 1e-10);
assert(abs(iprod(wf1, wf3)) < 1e-10);
assert(abs(iprod(wf2, wf3)) < 1e-10);
fprintf('Success!\n')

% 
% P6. [2 pt] Implement the Schrodinger equation
%         H psi_n = E_n * psi_n
%
function [lhs, rhs] = schrodinger_eq(n)
    % Schrodinger eq: H psi_n = E_n * psi_n
    %   lhs: H psi_n
    %   rhs: E_n * psi_n
    %   E_n is an eigenvalue and
    %   psi_n is the corresponding eigenfunction
    
    % eigenvalue
    E_n = energy(n);

    % eigenfunction
    psi_n = wave(n);

    % lhs and rhs of time indep. Schrodinger eq.
    lhs = hamiltonian(psi_n); % H psi_n
    rhs = @(x) E_n * psi_n(x); % E_n * psi_n
end

% test
%
function [] = check_schrodinger_eq(n)
    % Schrodinger eq.
    [lhs, rhs] = schrodinger_eq(n);

    assert(isa(lhs, 'function_handle'));
    assert(isa(rhs, 'function_handle'));

    % check the equality
    xs = (-1:0.01:1)/5;
    for x = xs
        assert( abs(lhs(x) - rhs(x)) < 1e-3)
    end
end

check_schrodinger_eq(0)
check_schrodinger_eq(1)
check_schrodinger_eq(2)
check_schrodinger_eq(3)
check_schrodinger_eq(4)
fprintf('Success!\n')

%
% plot the wavefunctions
%
function [] = plot_wave_fun() 
    global hbar m w;    
    xs = (-1:0.01:1)/5;
    ys = [];
    for n = 0:7
        offset = 20*energy(n);
        psi = wave(n);
        y = [];
        for x = xs
            y = [y, offset + psi(x)];
        end
        ys = [ys; y];
    end
    plot(xs, ys);
    grid;
end

plot_wave_fun()
