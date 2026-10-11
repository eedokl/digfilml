function [b,a] = shank(x,P,Q)
%shank  Shank (AR)MA-Modell.
%
%Aufruf:[B,A] = SHANK(h,P,Q) berechnet die Koeffizienten
%       des MA-Modells nach der Shank-Methode basierend auf
%       einem AR-Modell Koeffizienten die mittels
%       der Kovarianz-Methode berechnet werden.
%
%       See also durbin, lpc, stmcb, prony

% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover

if nargin ~= 3
    error('shank: falsche Anzahl an Eingangswerten');
end;

% sichere Länge von x
Ns = length(x);

% x=vektor ?
if min(size(x)) ~= 1,
	error('shank: "x" muss ein 1xN oder Nx1 Vector sein.');
end;

% Nx1 Vector
x = x(:);

% berechne "a"
  old_x=x;

  % Nullen an x anfügen
  x = [x ;zeros(P,1)];

  % X Matrix erstellen
  X = zeros(length(x),P+1);
  t = length(x);
  for k=1:P+1,	X(:,k) = x; x = [x(t:t); x(1:t-1)]; end

  % entferne Nullen aus der Matrix
  X = X(P+1:length(x)-P,:);

  % ermittle Korrelations-Matrix
  R = X' * X;

  % berechne a's mit Yule-Walker-  bzw. Normalgleichungen
  a = pinv(R(2:(P+1),2:(P+1))) * (-(R(2:(P+1),1)));

  % a0=1 hinzufügen
  a = [1;a].';

  x=old_x;


% filtere x mit 1/A(z)
h = filter(1,a,[1;zeros(Ns-1,1)]);

% nullen an h anfügen
h = [h ;zeros(Q,1)];

% erstelle Ha Matrix
Ha = zeros(length(h),Q+1);
t = length(h);
for k=1:Q+1
	Ha(:,k) = h;
	h = [h(t:t); h(1:t-1)];
end

% Nullen aus Ha entfernen
Ha = Ha(1:Ns,:);

% berechne MA Koeffizienten
b = pinv(Ha) * x;

% Rückgabe als Zeilenvektor
a = reshape(a,1,length(a));
b = reshape(b,1,length(b));

