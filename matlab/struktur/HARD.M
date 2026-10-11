function hard 
% Hard		gibt eine Hardcopy mit Überschrift des aktuellen Fensterinhalts aus.
%
% ------------------- Funktions Header --------------------------------------
% Autor:               Jörg Rose / Roman Ußkurat
% Erstellungsdatum:    7-10/97
% Version:             MATLAB Version 5 / Student Edition
% 
% Betreuer: Prof. Dr.-Ing. Stark
%
%
global a b


% ------ Hardcopy -------------

	h_axes_text=axes('position',[0.35 0.95 0.6 0.1],...% Position und Ausdehnung
        		'ylim',[0 0.9],...            % Zuweissung waagerechte Grenzwerte
		        'xlim',[0 0.2],...            % Zuweisung senkrechte Grenzwerte
		        'visible','off',...         % Begrenzung und Koordinaten unsichtbar
			'tag','Beschriftungs-Axes',...
		        'drawmode','fast',...
		        'color',[1 1 1],...         % Farbe = Weiss
		        'nextplot','add');          % Ältere Plots bleiben erhalten
	h_fig=findobj('tag','netzwerk');	% Figure für Struktur
	name_str= get(h_fig,'name');		% Fenstertitel als Überschrift
	h_text=text(0.0,0.3,name_str);		% Überschrift ausgeben
	set(h_text,'color','k');
	h_uicontrol= findobj('type','uicontrol','visible','on');
	set (h_uicontrol,'visible','off');
   print;		% Druckaufruf MATLAB
	set (h_uicontrol,'visible','on');
	delete(h_axes_text);		% Text-Axes-Objekt schließen
	drawnow;
% end of Hardcopy

