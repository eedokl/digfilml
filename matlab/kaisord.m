function [order,alpha,fc]=kaisord(F,Rp,Rs,Fs)

%KAISORD Berechnung der notwendigen Filterordnung beim
%        Entwurf eines FIR-Filters nach der Fenstermethode
%        unter Verwendung eines Kaiserfensters.
%        Angabe von zwei Eckfrequenzen -> TP,HP
%        Angabe von vier Eckfrequenzen -> BP,BS
%
%Aufruf: [order,beta,fc]=kaisord(Eckfrequenzen,Passband-Ripple,...
%                                Stopband-Ripple, Abtastfrequenz);
%
%       order = approximierte Filterordnung
%       beta  = beta-Wert für den Entwurf des Kaiserfensters
%       fc    = Grenzfrequenzen für die Funktion fir1
%
%       Hinweis : bei Hochpaß- und Bandstopfiltern muß die Filterordnung
%                 gerade sein. Dies wird hier nicht berücksichtigt !
%                 Abhilfe : n=n+rem(n,2);
%
% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover
%
%       Referenz : S.J.Orfanidis, Introduction to Signal Processing,
%                  Chapter 10, pp. 551-556, Prentice-Hall 1996
%
%       Siehe auch : fir1, fir2, kaiser
%

% Eingabewerte aufbereiten
F=F(:);
len=length(F);

% untere Eckfrequenz(en)
f1=F(1:2:(len-1));

% obere Eckfrequenz(en)
f2=F(2:2:len);

% minimaler Übergangsbereich
dF=min(f2-f1);

% berechne Grenzfrequenz(en)
fc=f1+dF/2;

% berechne maximal zulässige Welligkeit (linear)
devs = min([ (10^(Rp/20)-1)/(10^(Rp/20)+1)  10^(-Rs/20) ]);

% berechne Welligkeit in dB
A = -20*log10(devs);

% berechne alpha(beta)-Wert für Kaiserfenster Entwurf
% berechne D für Filterordnungsschätzung
if A >= 50,
    alpha = .1102*(A - 8.7);
    D = (A-7.95)/14.36;
elseif A > 21,
    alpha = .5842*((A-21).^(.4)) + .07886*(A-21);
    D = (A-7.95)/14.36;
else
    alpha = 0;
    D = 0.922;
end

% berechne Filterordnung
order = ceil(D*Fs./dF);

