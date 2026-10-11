function [k,c] =lattice(b,a)
% [k,c] = lattice (b,a)
% 
% Ermittelt die Lattice-Ladder-Koeffizienten k und c eines allgemeinen IIR-Filters.
% b,a sind die Koeffizientensätze der Übertragungsfunktion.
%
%
% ------------------- Funktions Header --------------------------------------
% Autor:               Jörg Rose / Roman Ußkurat
% Erstellungsdatum:    7-10/97
% Version:             MATLAB Version 5 / Student Edition
% 
% Betreuer: Prof. Dr.-Ing. Stark
%
if nargin < 2
    return;     %Auch Ausschluß von FIR-Filtern in Lattice Struktur.
                %Für diese würden Bedingungen gelten, die die gängigen Entwurfsverfahren
                %nicht einhalten. (Bed. ist: Keine symmetrische Impulsantwort, damit würde der letzte
                %Koeffizient ==1, was bei der Berechnung der Lattice-Koeffizienten zu einer Division
                %durch Null führen würde!)
end;            

ahilf=a;	% a-Koeffizienten zwischenspeichern
a = (1/a(1))*a(:).'; %Normierung auf ersten Koeffizienten
a(1) = [];    % ersten Koeffizienten löschen
Faktor=a;
for i = length(a):-1:1		% Rekursionsgleichung rückwärts anwenden
    k(i) = a(i);
    a(i) = [];			% jeweiligen Koeffizienten löschen
    a = (a - k(i)*a(i-1:-1:1)  ) / (1 - k(i)^2);	% Rekursionsgleichung

  if i > 1
    Faktor =[Faktor;[a zeros(1,size(Faktor,2)-length(a))]] ;   % Zwischenwerte für die Berechnung
                                                               % der Nullstellenkoeffizienten.
  end;
end 
a=ahilf;

    na = max(size(a));       
    nb = max(size(b));
if nb > na
    error (' Die Länge von b muss <= der Länge von a sein!');
end;

    ahilf = [a zeros(1,nb-na)];     % Koeffizientensätze auf gleiche Länge bringen.
    bhilf = [b zeros(1,na-nb)];


notanumbers=isnan(k);
if any(notanumbers)
    error ('Keine Lattice-Ladder-Struktur möglich');
end;

Faktor(length(bhilf),length(bhilf))=0;  %Matrix anpassen, falls b > a

for zaehler1= length(bhilf):-1:1    %Berechnung der Vorwärtskoeffizienten (c-Parameter)
    c(zaehler1)=bhilf(zaehler1);
    for zaehler2=zaehler1+1:length(bhilf)
        index1=length(bhilf)-zaehler2+1;
        index2=zaehler2-zaehler1;
        c(zaehler1)=c(zaehler1)-c(zaehler2)*Faktor(index1,index2);
    end;
end;

