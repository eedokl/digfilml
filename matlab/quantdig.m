function [out,shift]=quantdig(in,bit);

% out=QUANTDIG(in,digits);
%
% quantisiert die Eingangsmatrix IN
% auf eine Genauigkeit von BIT Bits.
%
% QUANTDIG normiert zunächst den Eingangsvektor
% auf einen Wert, der dem Maximalwert als 2er-Potenz
% am nächsten kommt, so daß in der Hardwarerealisierung
% ein SHIFT-Befehl möglich wird.
% Der so normierte Vektor wird dann mit n Bit quantisiert,
% wobei gilt : -1 <= out < 1.
%
% Version 1.0 : 24-Mar-97
%
% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover

  % Normierung auf 2^x, so daß
  % 0.5 < max(abs(in)) <= 1

  max_in=max(abs(in));
  shift=ceil(log(max_in)/log(2));
  max_in_pow2=2^shift;
  in=in/max_in_pow2;

  % Runden auf DIGITS Stellen
  swing=(2^bit-1)/2;
  out=round(swing*in+swing)/2^(bit-1)-1;

  % Normierung aufheben
  out=out*max_in_pow2;


