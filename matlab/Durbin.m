function b = durbin(h,p,N)

%Aufruf:b = durbin(h,p,N)
%
%	MA-Modell durch die Impulsantwort x eines Systems
%	unter Verwendung von Durbin's Methode.
%	Ergebnis :
%		b = [b(0), b(1), ... , b(N) ]
%
%	N :  Ordnung des MA-Modells
%	p :  Ordnung des all-pole Modells zur Approximation von 1/B(z).
%	     Dieser Parameter sollte mindestens 4N betragen.
%
% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover

h   = h(:);

if p>=length(h) | N>=40,
  disp('Modell-Ordnung zu groﬂ !'); b=-1;
else
  [a,epsilon] = lpc(h,p);  epsilon=epsilon^2;
  [b,epsilon] = lpc(length(h)*a.'/sqrt(epsilon),N); epsilon=epsilon^2;
  b = b.'*length(h)/sqrt(epsilon);
end;



