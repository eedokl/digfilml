function [b,a] = lat2dir(kappa,nu);
% Lattice-form to DIRECT-form conversion
% --------------------------------------
% [b,a] = lat2dir(kappa,nu)
%  kappa = lattice coefficients
%  nu = lattice coefficients
%  b = numerator polynomial coefficients of DIRECT form
%  a = denominator polynomial coefficients of DIRECT form
%
% ------------------- Funktions Header --------------------------------------
% Autor:               Jörg Rose / Roman Ußkurat
% Erstellungsdatum:    7-10/97
% Version:             MATLAB Version 5 / Student Edition
% 
% Betreuer: Prof. Dr.-Ing. Stark
%

order = length(kappa);       % Anzahl der Gitterstrukturen
p = 1;                       % P0(z) = 1
q = 1;                       % Q0(z) = P0(z) = 1
q_n = 1.*nu(1);              % Q1(z) fuer aufsummierung Zaehler
for n=2:(order+1);
  p_n=[p 0];                 % Angleichen der Vektorlaenge fuer Addition
  q=[0 q];                   % Qn(z) * z^-1
  p=p_n+q.*kappa(n-1);       % Pn(z) = Pn-1(z) + z^-1 * kappa(n-1) * Qn-1(z)
  q=p_n.*kappa(n-1)+q;       % Qn(z) = Pn-1(z) * kappa(n-1) + z^-1 * Qn-1(z)
  q_n = [q_n 0];             % q_n = Aufsummierung Zaehler mit
  q_n = (q_n + q.*nu(n));    % Qn(z) = Qn-1(z) + nu(n) * Qn(z)
end                          % Ende von for n = 2:order
b = q_n;                     % b = sum(n) nu(n) * Qn(z)
a = p;                       % a = Pn(z)
