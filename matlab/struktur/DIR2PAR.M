function [C,sos] = dir2par (b,a);
% DIR2PAR wandelt die Direktform (Transferfunction) in die Parallelform um.
%
% C   : Direktterme nach Partialbruchzerlegung
% sos : Second-Order-Section der paralellen Teilsysteme
%
% ------------------- Funktions Header --------------------------------------
% Autor:               Jörg Rose / Roman Ußkurat
% Erstellungsdatum:    7-10/97
% Version:             MATLAB Version 5 / Student Edition
% 
% Betreuer: Prof. Dr.-Ing. Stark
%


[Res,Pol,C] = residuez (b,a);	% Residuen, Pole, Direktterme

Anzahl=length(Pol);		% Anzahl Pole
Pol_sort=cplxpair(Pol);		% Polstellen sortieren (evtl. einzelne Polstelle nicht am Ende)
for i=1:Anzahl			% Sortierreihenfolge feststellen, um die Residuen entsprechend zu sortieren
	sort_folge(i)=find(Pol_sort(i)==Pol);
end;	% of i
Res=Res(sort_folge);		% Residuen umsortieren
Pol=Pol_sort;

if (fix(Anzahl/2)==Anzahl/2)	% ungerade oder gerade Anzahl von Polstellen
	gerade =1;
else
	gerade =0;
end;
if (gerade ==0)
	Anzahl= Anzahl-1;
end;
Teil = 1;
for Paar=1:2:Anzahl			% Teilsysteme zurück in b,a Koeffizienten
	[B(Teil,:),A(Teil,:)]=residuez(Res(Paar:Paar+1),Pol(Paar:Paar+1),[]);
	Teil=Teil+1;
end;

if (gerade == 0)			% Teilsystem 1. Ordnung
	[HilfB,HilfA]=residuez(Res(Anzahl+1),Pol(Anzahl+1),[]);
	B(Teil,:)= [HilfB 0];
	A(Teil,:)= [HilfA 0];
end;
sos=[real(B) zeros(size(B,1),1) real(A)];	% Matrix aufbauen
