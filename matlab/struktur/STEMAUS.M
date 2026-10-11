function stemaus(x,y)
%STEMAUS   Plot discrete sequence data.
% ------------------- Funktions Header --------------------------------------
% Autor:               Jörg Rose / Roman Ußkurat
% Erstellungsdatum:    7-10/97
% Version:             MATLAB Version 5 / Student Edition
% 
% Betreuer: Prof. Dr.-Ing. Stark
%
h_axes_aus = findobj...
  ('tag','ausgangsfolge');
minimum = -1000;
senkrecht = [minimum y(1) minimum];
waagerecht = [x(1) x(1) x(1)];
for n = 2:length(y)
  senkrecht = [senkrecht minimum y(n) minimum];
  waagerecht = [waagerecht x(n) x(n) x(n)];
end
h=plot(waagerecht,senkrecht,'-r');        % Zeichne Objekt rot
set (h,'linewidth',2);

