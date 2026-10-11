function [b,a] = par2dir(C,B,A);
% PARALLEL-form to DIRECT-form conversion
% --------------------------------------
% [b,a] = par2dir(C,B,A)
%  C = Polynomial part when length(b) >= length(a)
%  B = K by 2 matrix of real coefficients containing bk's
%  A = K by 3 matrix of real coefficients containing ak's
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
groesse = size(A);
a = 1;                                % Hauptnenner
for n = 1:groesse(1)                  % Mit jeder Reihe
  if (A(n,3)==0)                      % Wenn der letzte A-Koeffizient = 0
    A(n,3)=A(n,2);                    % Verschiebe A-Koeffizienten um 1
    A(n,2)=A(n,1);                    % nach rechts
    A(n,1)=0;                         % Setze ersten Koeffizienten = 0
  end                                 % Ende von letzter A-Koeffizient = 0
  if (A(n,3)==0)                      % Wenn der letzte A-Koeffizient = 0
    A(n,3)=A(n,2);                    % Verschiebe A-Koeffizienten um 1
    A(n,2)=A(n,1);                    % nach rechts
    A(n,1)=0;                         % Setze ersten Koeffizienten = 0
  end                                 % Ende von letzter A-Koeffizient = 0
  a = conv(a,A(n,:));                 % Polynommultiplikation mit aktueller Reihe
  if (a(1)==0)                        % Wenn erster Koeffizient = 0
    a=a(2:length(a));                 % Ersten Koeffizienten abspalten
  end                                 % Ende von erster Koeffizient = 0
end                                   % Ende von mit jeder Reihe
cpol = conv(C,a);                     % Polynommultiplikation Hauptnenner mit C-Koeffizienten
laenge = length(cpol);                % Laenge des entstandenen Polynoms
laenge_a = length(a);                 % Laenge des Hauptnennerpolynoms
if laenge < (laenge_a + 1)            % Wenn Laenge des ent. Pol. < Hauptnpol.
  laenge = laenge_a + 1;              % laenge = Laenge des Hauptnennerpolynoms
end                                   
b = 0;
for n = 1:groesse(1)                  % n mit jeder Reihe
   nenner = 1;
   for x = 1:groesse(1)               % x mit jeder Reihe (innere Schleife)
     if (x ~= n)                      % Wenn x-index ungleich n-index
       if (A(x,3)==0)                 % Wenn der letzte A-Koeffizient = 0
         A(x,3)=A(x,2);               % Verschiebe A-Koeffizienten um 1
         A(x,2)=A(x,1);               % nach rechts
         A(x,1)=0;                    % Setze ersten Koeffizienten = 0
       end                            % Ende von letzter A-Koeffizient = 0
       if (A(x,3)==0)                 % Wenn der letzte A-Koeffizient = 0
         A(x,3)=A(x,2);               % Verschiebe A-Koeffizienten um 1
         A(x,2)=A(x,1);               % nach rechts
         A(x,1)=0;                    % Setze ersten Koeffizienten = 0
       end                            % Ende von letzter A-Koeffizient = 0
       nenner = conv(nenner,A(x,:));  % Bilde Nenner fuer Polynom B(n)
     end                              % Ende von x-index ungleich n-index
   end                                % Ende von x mit jeder Reihe (innere Schleife)
   bn = conv(nenner,B(n,:));          % Polynommultiplikation B(n) mit aktuellen Nenner
   while (length(bn) < laenge)        % Solange Polynom B(n) < laenge
     bn = [0,bn];                     % Auffuellen mit Nullen von vorne
   end
   b = b + bn;                        % Addition von B(n) zum Zaehlerpolynom
end                                   % Ende von n mit jeder Reihe (aeussere Schleife)
while ( b(1) == 0 )                   % Solange erster b-Koeffizient = 0
  b = b(2:length(b));                 % Abspalten des ersten Koeffizienten
end
while(length(b)<length(cpol))         % Solange b-Polynom < c-Polynom
  b = [b,0];                          % Auffuellen mit Null
end
while (length(cpol) < length(b))      % Solange c-Polynom < b-Polynom
  cpol = [0,cpol];                    % Auffuellen mit Null
end
b = b + cpol;                         % Zaehlerpolynom
