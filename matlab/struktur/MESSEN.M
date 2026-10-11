function messen(command_str)
% MESSEN
%
% Die Funktion setzt die Markerobjekte und führt die Meßfunktion
% innerhalb der Amplituden- und Phasendarstellung von FFTRANS
% und IMPULANT aus.
%
% ------------------- Funktions Header --------------------------------------
% Autor:               Jörg Rose / Roman Ußkurat
% Erstellungsdatum:    7-10/97
% Version:             MATLAB Version 5 / Student Edition
% 
% Betreuer: Prof. Dr.-Ing. Stark
%
maus_alt= get(0,'pointerlocation');	% Mausposition wird hier festgestellt, um Zeitdifferenzen zu unterdrücken
h_fig= findobj('tag','netzwerk');	% Handle auf Figure
if nargin ==0		% Ein- bzw. Ausschalten der Objekte
	command_str=[];
	h_marker = findobj ('tag','messen','string','Marker'); % Objekt Checkbox Marker
	existiert = get(h_marker,'visible');	% Prüfen, ob aktiv
	if strcmp(existiert,'off')		% nicht aktiv
		h_messen= findobj('tag','messen'); % alle Objekte für Messen finden
		set(h_messen,'visible','on');	% sichtbar setzen
		h_zoom= findobj ('tag','messen_zoom');	% Pushbuttons für Zoom
		set(h_zoom,'visible','on');	% sichtbar setzten
		h_fft=findobj('tag','FFT');	% Popup-Menü für FFT-Länge sichtbar setzen
		set(h_fft,'visible','on');
		h_ffttext=findobj('tag','FFT_Text');
		set(h_ffttext,'visible','on');
		struktur('dB_Text');	% Amlitude lin/log beschriften
		set (h_fig,'keypressfcn','messen(''verschieben'');');	%Tastatureingabe für Zoom-Bereich-Verschiebung
	else
		set(h_marker,'value',0);	% Marker-Checkbox aus
		h_messen= findobj('tag','messen');	% alle Objekte für Messen finden
		set(h_messen,'visible','off');		% unsichtbar setzen	
		h_zoom= findobj ('tag','messen_zoom');	% Pushbuttons für Zoom
		set(h_zoom,'visible','off');	% unsichtbar setzten
		h_fft=findobj('tag','FFT');	% Popup-Menü für FFT-Länge unsichtbar setzen
		set(h_fft,'visible','off');
		h_ffttext=findobj('tag','FFT_Text');
		set(h_ffttext,'visible','off');
		set(h_fig,'keypressfcn','');
		command_str= 'marker';		% weitere Handlungen in marker
	end;
end;	% nargin == 0

% ------------------------ benötigte Daten ermitteln -------------------------------
h_ampli= findobj('tag','bode_amplitude');	% Handle auf Axes-Objekt Amplitudengang
h_phase= findobj('tag','bode_phase');		% Handle auf Axes-Objekt Phasengang
h_ampli_rech= findobj('parent',h_ampli,'type','line','color',[1 0 0]);	% Line-Objekt Amplitude rechnergenau
h_ampli_quant= findobj('parent',h_ampli,'type','line','color',[0 0 0]);	% Line-Objekt Amplitude quantisiert
h_phase_rech= findobj('parent',h_phase,'type','line','color',[1 0 0]);	% Line-Objekt Phase rechnergenau
h_phase_quant= findobj('parent',h_phase,'type','line','color',[0 0 0]);	% Line-Objekt Phase quantisert
if (~isempty(h_ampli_rech))			% wenn Refenzkurve vorhanden
	ampli_rech=get(h_ampli_rech,'YData');	% Werte ermitteln
	phase_rech=get(h_phase_rech,'YData');
	x_daten= get(h_ampli_rech,'XData');	% x-Koordinaten der Meßpunkte
end;
if (~isempty(h_ampli_quant))		% wenn quantisierte Kurve vorhanden
	ampli_quant= get(h_ampli_quant,'YData');
	phase_quant= get(h_phase_quant,'YData');
	x_daten= get(h_ampli_quant,'XData');	% x-Koordinaten der Meßpunkte
end;
if isempty(h_ampli_rech) & isempty (h_ampli_quant)	% Keine Kurve zur Darstellung ausgewählt
	info_str=('     Weder Quantisierung, noch Referenzkurven ausgewählt!');
	taste=fenster(info_str,'MATLABML-Info',2,1);	% Informations-Fenster mit Meldung öffnen
	return;		% Keine weitere Bearbeitung, 'messen' verlassen
end;
h_wert1= findobj('tag','messen','userdata',1);	% erstes Ausgabefeld
h_wert2= findobj('tag','messen','userdata',2);	% zweites Ausgabefeld
h_wert3= findobj('tag','messen','userdata',3);	% drittes Ausgabefeld
h_wert4= findobj('tag','messen','userdata',4);	% viertes Ausgabefeld
h_wert5= findobj('tag','messen','userdata',5);	% Ausgabefeld f/fa

% ------------ marker ------------------------------------------------
if strcmp(command_str,'marker') | strcmp(command_str,'marker_aktualisieren')	% Wenn Marker betätigt
	h_marker = findobj ('tag','messen','string','Marker'); % Objekt Checkbox Marker
	messen_an= get(h_marker,'value');	% Zustand feststellen
	h_urbild= findobj('tag','messen_zoom','String','1:1');	% Pushbutton 'Ursprungsbild' finden
	if (strcmp(command_str,'marker_aktualisieren'))
		Ursprungswerte= get(h_urbild,'userdata');	% Ursprungswerte der Axes-Objekte feststellen
		y_lim_ampli= get(h_ampli,'YLim');	% X- und Y-Begrenzungen der Koordinaten-
		y_lim_phase= get(h_phase,'YLim');	% systeme feststellen
		x_lim_ampli= get(h_ampli,'XLim');
		x_lim_phase= get(h_phase,'XLim');
		Ursprungswerte=[x_lim_ampli y_lim_ampli x_lim_phase y_lim_phase];
		set (h_urbild,'Userdata',Ursprungswerte);	% Ursprungswerte merken, Callback setzen und
		set (h_urbild,'enable','on','callback','messen(''Ursprungsbild'');');	% Enable setzen
	end;
	if (messen_an==1)	% Marker einschalten
		h_move= findobj('tag','messen','style','pushbutton');	% Pushbuttons zur Markerbewegung
		set (h_move,'enable','on');				% Enable setzen			
		marker_wert= str2num(get(h_wert5,'string'));
		if isempty(marker_wert)
			x_lim= get(h_ampli,'XLim');
			marker_wert= (x_lim(1)+x_lim(2))/2;	% Marker erscheint in der Mitte
		end;
		x_abstand=x_daten-marker_wert;		% X-Datum mit dem kleinsten Abstand zum momentanen Punkt
		index= find (abs(x_abstand)== min(abs(x_abstand)));	% Index des nächsten Elements
		x_marke= x_daten(index);		% x-Position der Marker
		Ursprungswerte= get(h_urbild,'userdata');	% Ursprungswerte der Axes-Objekte feststellen
		if ~isempty(Ursprungswerte)			% Wenn Daten vorhanden, damit den Marker festlegen
			y_lim=Ursprungswerte(3:4);
		else
			y_lim= get(h_ampli,'ylim');	% y-Begrenzung des Axes-Objekts
		end;
		axes(h_ampli);
		if (~isempty(h_ampli_rech))			% wenn Refenzkurve vorhanden
			x_koord =[x_marke x_marke NaN 0 0.5];	% Koordinaten des Markerkreuzes setzen
			y_koord =[y_lim	NaN ampli_rech(index) ampli_rech(index)];
		else
			x_koord =[x_marke x_marke];		% Koordinaten des Frequenzmarkers setzen
			y_koord =[y_lim];
		end;
		marker1= line (x_koord,y_koord);	% Marker-Linie zeichnen (zunächst mittig)
		set (marker1,'color',[0 0 1],...
			'tag','marker_linie1');
		if (~isempty(h_ampli_quant))		% wenn quantisierte Kurve vorhanden 
			marker1b= line ([0 0.5],[ampli_quant(index) ampli_quant(index)]);
			set (marker1b,'color',[0 0 1],'linestyle','--',...
				'tag','marker_linie1b');
		end;
		Ursprungswerte= get(h_urbild,'userdata');	% Ursprungswerte der Axes-Objekte feststellen
		if ~isempty(Ursprungswerte)			% Wenn Daten vorhanden, damit den Marker festlegen
			y_lim=Ursprungswerte(7:8);
		else
			y_lim= get(h_phase,'ylim');	% y-Begrenzung des Axes-Objekts
		end;
		axes(h_phase);
		if (~isempty(h_ampli_rech))			% wenn Refenzkurve vorhanden
			x_koord =[x_marke x_marke NaN 0 0.5];
			y_koord= [y_lim	NaN phase_rech(index) phase_rech(index)];	
		else
			x_koord =[x_marke x_marke];
			y_koord =[y_lim];
		end;
		marker2= line (x_koord,y_koord);	% Marker-Linie zeichnen
		set (marker2,'color',[0 0 1],...
			'tag','marker_linie2');		
		if (~isempty(h_ampli_quant))		% wenn quantisierte Kurve vorhanden 
			marker2b= line ([0 0.5],[phase_quant(index) phase_quant(index)]);
			set (marker2b,'color',[0 0 1],'linestyle','--',...
				'tag','marker_linie2b');
		end;
		set (h_wert5,'string',num2str(x_marke));	% Wert für f/fa ausgeben
		if (~isempty(h_ampli_rech))			% wenn Refenzkurve vorhanden
			wert1= num2str(ampli_rech(index));	% Werte an den Positionen feststellen
			wert3= num2str(phase_rech(index));
			set (h_wert1,'string',wert1);		% Werte ausgeben
			set (h_wert3,'string',wert3);
		else
			set (h_wert1,'string','');	
			set (h_wert3,'string','');
		end;
		if (~isempty(h_ampli_quant))		% wenn quantisierte Kurve vorhanden
			wert2= num2str(ampli_quant(index));	% Werte an den Positionen feststellen
			wert4= num2str(phase_quant(index));
			set (h_wert2,'string',wert2);		% Werte ausgeben
			set (h_wert4,'string',wert4);
		else
			set (h_wert2,'string','');
			set (h_wert4,'string','');
		end;
	else			% Marker ausschalten
		h_move= findobj('tag','messen','style','pushbutton');	% Pushbuttons zur Markerbewegung
		set (h_move,'enable','off');				% Enable ausschalten
		marker1= findobj('tag','marker_linie1');	% Marker finden
		marker2= findobj('tag','marker_linie2');
		marker1b= findobj('tag','marker_linie1b');
		marker2b= findobj('tag','marker_linie2b');
		delete(marker1);				% und löschen
		delete(marker2);
		delete(marker1b);
		delete(marker2b);
		set (h_wert1,'string','');		% Wert-Ausgabe löschen
		set (h_wert2,'string','');
		set (h_wert3,'string','');
		set (h_wert4,'string','');
		set (h_wert5,'string','');
	end;
	
	set(h_ampli,'ButtonDownFcn','messen(''messen_ampli'');'); % alle ButtonDownFcn auf Zoon-Funktion
	set(h_phase,'ButtonDownFcn','messen(''messen_phase'');');
	set(h_ampli_rech,'ButtonDownFcn','messen(''messen_ampli'');');
	set(h_phase_rech,'ButtonDownFcn','messen(''messen_phase'');');
	marker1= findobj('tag','marker_linie1');	% Marker finden
	marker2= findobj('tag','marker_linie2');
	set (marker1,'ButtonDownFcn','messen(''messen_ampli'');');
	set (marker2,'ButtonDownFcn','messen(''messen_phase'');');
	if (~isempty(h_ampli_quant))			% Quanisierte Kurven vorhanden
		set(h_ampli_quant,'ButtonDownFcn','messen(''messen_ampli'');');
		set(h_phase_quant,'ButtonDownFcn','messen(''messen_phase'');');
		marker1b= findobj('tag','marker_linie1b');
		marker2b= findobj('tag','marker_linie2b');
		set (marker1b,'ButtonDownFcn','messen(''messen_ampli'');');		
		set (marker2b,'ButtonDownFcn','messen(''messen_phase'');');
	end;
end;	% command_str 'marker'


% ------------- Auswertung der motion-Pushbuttons ----------------
if strcmp(command_str,'motion1')
	command_str='move';
	Distanz = -fix(size(x_daten,2)/10);
end;
if strcmp(command_str,'motion2')
	command_str='move';
	Distanz = -1;
end;
if strcmp(command_str,'motion3')
	command_str='move';
	Distanz = 1;
end;
if strcmp(command_str,'motion4')
	command_str='move';
	Distanz = fix(size(x_daten,2)/10);
end;

% --------------- move ----------------------------
if strcmp(command_str,'move')
	marker1= findobj('tag','marker_linie1');	% Marker finden
	marker2= findobj('tag','marker_linie2');
	marker1b= findobj('tag','marker_linie1b');	
	marker2b= findobj('tag','marker_linie2b');
	x_pos= get(marker1,'XData');			% aktuelle x-Position lesen
	x_pos= x_pos(1);
	index = find( x_daten==x_pos);		% Index für x-Position bestimmen
	index = index + Distanz;		% neue Position
	if (index < 1)
		index=1;
	end;
	if (index > size (x_daten,2))
		index = size (x_daten,2);
	end;
	x_marke= x_daten(index);		% x-Position der Marker
	set(marker1,'Erasemode','xor');		% Erase-Mode auf XOR, um neuen
	set(marker2,'Erasemode','xor');		% Bildaufbau zu verhindern
	set(marker1b,'Erasemode','xor');
	set(marker2b,'Erasemode','xor');
	y_lim= get(marker1,'YData');		% y-Begrenzung des Markers 1
	y_lim=y_lim(1:2);			% stehen in den ersten beiden Werten	
	if isempty(h_ampli_rech)	% Referenzkurve nicht vorhanden
		x_koord =[x_marke x_marke];
		y_koord =[y_lim];
	else				% Referenzkurve vorhanden
		x_koord =[x_marke x_marke NaN 0 0.5];
		y_koord= [y_lim	NaN ampli_rech(index) ampli_rech(index)];	
	end;
	set (marker1,'XData',x_koord,'YData',y_koord);	% Marker neu positionieren
	y_lim= get(marker2,'YData');		% y-Begrenzung des Markers 2
	y_lim=y_lim(1:2);			% stehen in den ersten beiden Werten
	if isempty(h_ampli_rech)	% Referenzkurve nicht vorhanden
		x_koord =[x_marke x_marke];
		y_koord =[y_lim];
	else				% Referenzkurve vorhanden
		x_koord =[x_marke x_marke NaN 0 0.5];
		y_koord= [y_lim	NaN phase_rech(index) phase_rech(index)];	
	end;
	set (marker2,'XData',x_koord,'YData',y_koord);	% Marker neu positioneren
	if (~isempty(h_ampli_quant))		% wenn quantisierte Kurve vorhanden
		set (marker1b,'YData',[ampli_quant(index) ampli_quant(index)]);
		set (marker2b,'YData',[phase_quant(index) phase_quant(index)]);
	end;
	set(marker1,'Erasemode','normal');	% Auf NORMAL zurückschalten, um Farbverfälschungen
	set(marker2,'Erasemode','normal');	% zu verhindern
	set(marker1b,'Erasemode','normal');
	set(marker2b,'Erasemode','normal');
	set (h_wert5,'string',num2str(x_marke));	% Wert für f/fa ausgeben
	if ~isempty(h_ampli_rech)	% Referenzkurve vorhanden
		wert1= num2str(ampli_rech(index));	% Werte an den Positionen feststellen
		wert3= num2str(phase_rech(index));
		set (h_wert1,'string',wert1);		% Werte ausgeben
		set (h_wert3,'string',wert3);
	else
		set (h_wert1,'string','');	% Strings löschen
		set (h_wert3,'string','');
	end;
	if (~isempty(h_ampli_quant))		% wenn quantisierte Kurve vorhanden
		wert2= num2str(ampli_quant(index));	% Werte an den Positionen feststellen
		wert4= num2str(phase_quant(index));
		set (h_wert2,'string',wert2);		% Werte ausgeben
		set (h_wert4,'string',wert4);
	else
		set (h_wert2,'string','');	% Strings löschen
		set (h_wert4,'string','');
	end;
end;	% command_str 'move'


%--------------- messen_ampli/_phase ----------------------------
if strcmp(command_str,'messen_ampli') | strcmp(command_str,'messen_phase')
	if strcmp(command_str,'messen_ampli')
		h_axes=h_ampli;
	end;
	if strcmp(command_str,'messen_phase')
		h_axes=h_phase;
	end;
	selec_type= get(h_fig,'SelectionType'); % 'normal'=linke Maustaste
						% 'extend'= rechte Maustaste
	if strcmp(selec_type,'normal')		% linke Maustaste => Zoombereich aufziehen
		h_zoom=findobj('tag','messen_zoom','style','checkbox');		% Checkbox Zoom
		zoom_an=get(h_zoom,'value');		% Zustand der Checkbox
		if (zoom_an==1)				% Wenn Zoom eingeschaltet
			koordinate= get(h_axes,'currentpoint');	% Mausposition innherhalb Axes
			x_pos=koordinate(1,1);			% in x- und y_Position zerlegen
         y_pos=koordinate(1,2);
         koord_fig= get(h_fig,'currentpoint');
         rect= [koord_fig 0 0];	% Rechteck für RubberBox definieren
         rbbox (rect,[koord_fig(1) koord_fig(2)]);			% Rubberbox aufrufen, um Zoom-Bereich festzulegen
         koordinate_neu= get(h_axes,'currentpoint');	% Mausposition innherhalb Axes
         x_diff= koordinate_neu(1,1)-x_pos; 
			y_diff= koordinate_neu(1,2)-y_pos;
     
         
			if (x_diff~=0 & y_diff~=0)			% wenn Bereich aufgezogen
				x_lim=sort([x_pos x_pos+x_diff]);	% neue Grenzen festlegen, wobei der kleinere
				y_lim=sort([y_pos y_pos+y_diff]);	% Zahlenwert an erster Stelle stehen muß
				ausserhalb=find(x_lim > 0.5);
				x_lim(ausserhalb)=ones(1,length(ausserhalb))*0.5;
				ausserhalb=find(x_lim < 0);
				x_lim(ausserhalb)=zeros(1,length(ausserhalb));
				set(h_axes,'YLim',y_lim);		% Y-Grenzen für das ausgewählte Diagramm
				set(h_ampli,'XLim',x_lim);		% X-Grenzen für beide Diagramme gleichermaßen
				set(h_phase,'XLim',x_lim);
				command_str='anpassen';		% Anpassen der Diagrammbeschriftung aufrufen
			end;
		end;	% Zoom eingeschaltet
	end;	% Zoombereich aufziehen
	if strcmp(selec_type,'alt')			% rechte Maustaste betätigt
		command_str='messen';
	end;

end;	% command_str 'messen_ampli/-_phase/-_figure'

% -------------- verschieben --------------------------------------------
if strcmp(command_str,'verschieben')	% Zoom-Bereich verschieben

	%Prüfung, ob Zoom an ??

	char = get(h_fig,'currentcharacter');
	x_lim=get(h_ampli,'XLim');		% Grenzen des Diagramms in X
	diff_x=x_lim(2)-x_lim(1);
	if char =='6' 			% Verschieben nach rechts
		x_lim(1)=x_lim(1)+(diff_x/2);
		x_lim(2)=x_lim(2)+(diff_x/2);
		if x_lim(2) >=0.5
			x_lim(2)=0.5;
			x_lim(1)=0.5-diff_x;
		end;
	end;
	if char =='4' 			% Verschieben nach rechts
		x_lim(1)=x_lim(1)-(diff_x/2);
		x_lim(2)=x_lim(2)-(diff_x/2);
		if x_lim(1) <= 0
			x_lim(1)=0;
			x_lim(2)=diff_x;
		end;
	end;
	
	set(h_ampli,'XLim',x_lim);
	set(h_phase,'XLim',x_lim);
	command_str='anpassen';		% Anpassen der Diagrammbeschriftung aufrufen	

end;	% command_str 'verschieben'

% -------------- messen --------------------------------------------
if strcmp(command_str,'messen')		% Markerposition mit Mausklick
	h_marker = findobj ('tag','messen','string','Marker'); % Objekt Checkbox Marker
	messen_an= get(h_marker,'value');	% Zustand feststellen
	if (messen_an==1)			% Marker eingeschaltet
		point = get(h_axes,'CurrentPoint');	% angeklickter Punkt in Axes-Objekt
		point= point(1,1);		% x-Wert des angeklickten Punktes
		x_abstand=x_daten-point;	% X-Datum mit dem kleinsten Abstand zum momentanen Punkt
		index= find (abs(x_abstand)== min(abs(x_abstand)));	% Index des nächsten Elements
		x_marke= x_daten(index);		% x-Position der Marker
		marker1= findobj('tag','marker_linie1');	% Marker finden
		marker2= findobj('tag','marker_linie2');
		marker1b= findobj('tag','marker_linie1b');	
		marker2b= findobj('tag','marker_linie2b');
		set(marker1,'Erasemode','xor');		% Erasemode auf XOR, um Bildneuaufbau
		set(marker2,'Erasemode','xor');		% zu unterdrücken
		set(marker1b,'Erasemode','xor');
		set(marker2b,'Erasemode','xor');
		y_lim= get(marker1,'YData');		% y-Begrenzung des Markers 1
		y_lim=y_lim(1:2);			% stehen in den ersten beiden Werten
		if isempty(h_ampli_rech)	% Referenzkurve nicht vorhanden
			x_koord =[x_marke x_marke];
			y_koord =[y_lim];
		else				% Referenzkurve vorhanden
			x_koord =[x_marke x_marke NaN 0 0.5];
			y_koord= [y_lim	NaN ampli_rech(index) ampli_rech(index)];
		end;
		set (marker1,'XData',x_koord,'YData',y_koord);% Marker neu positionieren
		y_lim= get(marker2,'YData');		% y-Begrenzung des Markers 2
		y_lim=y_lim(1:2);			% stehen in den ersten beiden Werten	
		if isempty(h_ampli_rech)	% Referenzkurve nicht vorhanden
			x_koord =[x_marke x_marke];
			y_koord =[y_lim];
		else				% Referenzkurve vorhanden
			x_koord =[x_marke x_marke NaN 0 0.5];
			y_koord= [y_lim	NaN phase_rech(index) phase_rech(index)];	
		end;
		set (marker2,'XData',x_koord,'YData',y_koord);	% Marker neu positioneren
		if (~isempty(h_ampli_quant))		% wenn quantisierte Kurve vorhanden
			set (marker1b,'YData',[ampli_quant(index) ampli_quant(index)]);
			set (marker2b,'YData',[phase_quant(index) phase_quant(index)]);
		end;
		set(marker1,'Erasemode','normal');	% Auf NORMAL zurückschalten, um Farbverfälschungen
		set(marker2,'Erasemode','normal');	% zu verhindern
		set(marker1b,'Erasemode','normal');
		set(marker2b,'Erasemode','normal');
		set (h_wert5,'string',num2str(x_marke));	% Wert für f/fa ausgeben
		if ~isempty(h_ampli_rech)	% Referenzkurve vorhanden
			wert1= num2str(ampli_rech(index));	% Werte an den Positionen feststellen
			wert3= num2str(phase_rech(index));
			set (h_wert1,'string',wert1);		% Werte ausgeben
			set (h_wert3,'string',wert3);
		else
			set (h_wert1,'string','');	% Strings löschen
			set (h_wert3,'string','');
		end;
		if ~isempty(h_ampli_quant)	% wenn quantisierte Kurve vorhanden
			wert2= num2str(ampli_quant(index));	% Werte an den Positionen feststellen
			wert4= num2str(phase_quant(index));
			set (h_wert2,'string',wert2);		% Werte ausgeben
			set (h_wert4,'string',wert4);
		else
			set (h_wert2,'string','');	% Strings löschen
			set (h_wert4,'string','');
		end;
	end;	% Marker eingeschaltet
end;		% command_str  'messen'

% -------------- Ursprungsbild --------------------------
if strcmp(command_str,'Ursprungsbild')	% Pushbutton 'Ursprungsbild' betätigt
	h_urbild= findobj('tag','messen_zoom','string','1:1');	% Pushbutton 'Ursprungsbild'
	Ursprungswerte= get(h_urbild,'userdata');	% Ursprungswerte der Axes-Objekte feststellen
	y_lim_ampli= Ursprungswerte(3:4);	% X- und Y-Begrenzungen der Koordinaten-
	y_lim_phase= Ursprungswerte(7:8);	% systeme feststellen
	x_lim_ampli= Ursprungswerte(1:2);
	x_lim_phase= Ursprungswerte(5:6);
	set (h_ampli,'XLim',x_lim_ampli,'YLim',y_lim_ampli);	% alte Werte setzen
	set (h_phase,'XLim',x_lim_phase,'YLim',y_lim_phase);
	command_str='anpassen';		% Anpassen der Diagrammbeschriftung aufrufen
end;	% command_str 'Ursprungsbild'

% -------------- Anpassen der Diagrammbeschriftung --------------------------
if strcmp(command_str,'anpassen')
	y_lim=get(h_ampli,'YLim');					% Y-Grenzen des Amplidudengang-Diagramms
	x_lim=get(h_ampli,'XLim');					% X-Grenzen des Amplidudengang-Diagramms
	h_ampli_text= findobj('tag','amplitude_text');			% Textobjekt 'Amplitude'
	x_pos=x_lim(1)-(x_lim(2)-x_lim(1))/10;				% angepaßte x-Position für Textobjekte
	set (h_ampli_text,'position',[x_pos (y_lim(1)+y_lim(2))/2]);	% Textobjekt neu Positionieren
	y_lim=get(h_phase,'YLim');					% Y-Grenzen des Phasengang-Diagramms
	h_phase_text= findobj('tag','phase_text');	% Textobjekt 'Phase'
	h_rechnergenau=findobj('tag','rech_text');	% Textobjekte für Legende
	h_quantisiert= findobj('tag','quant_text');	
	h_ffa= findobj('tag','f_fa');			% Textobjekt 'f/fa'
	x_Diff=x_lim(2)-x_lim(1);			% Bereiche des Phasengang-Diagramms
	y_Diff=y_lim(2)-y_lim(1);
	y_pos= y_lim(1)-y_Diff/5;
	set (h_phase_text,'position',[x_pos (y_lim(1)+y_lim(2))/2]);	% Textobjekte neu Positionieren
	set (h_ffa,'position',[x_lim(2)+x_Diff/25 y_pos]);
	set (h_rechnergenau,'position',[x_lim(1)-x_Diff/8 y_pos]);
	set (h_quantisiert,'position',[x_lim(1)+x_Diff/16 y_pos]);
end;	% command_str 'anpassen'
