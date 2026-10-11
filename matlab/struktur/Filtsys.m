function filtsys(command_str)
% FILTSYS
%
% Die Funktion ermöglicht den Aufbau und die Untersuchung von Kaskadierten
% Filtern aus den abgespeicherten Einzelfiltern mit ihren Quantisierungsspezifikationen. 
%
%
% ------------------- Funktions Header --------------------------------------
% Autor:               Jörg Rose / Roman Ußkurat
% Erstellungsdatum:    7-10/97
% Version:             MATLAB Version 5 / Student Edition
%
% Bugfixing: 12/15/97   - Loop index is Teilfilter instead of Nummer in 'ampliphase' (635)
% by: Oliver Klein      - userdata of handle h_entfernen must be set to zero
%                         else there will löschen active on tauschen if activated before
%                         -> see 'tauschen' (174)
% 
% Betreuer: Prof. Dr.-Ing. Stark
%
if nargin==0
	command_str='init';
end;

%---------Initialisierung-----------
if strcmp(command_str,'init')	% Initialisierung
	h_fig=findobj('tag','netzwerk');	% Figure für Netzwerk
	h_struktur= findobj('tag','axes');	% Axes-Objekt mit der Filterstruktur
	h_children= get(h_struktur,'children');	% Objekte in der Struktur
	set (h_children,'visible','off');	% Objekte unsichtbar setzen
	h_axes_h=findobj('tag','axes_h(z)');	% Objekte für Überschrift in Kaskaden- und Parallelform
	set (h_axes_h,'visible','off');		% wenn vorhanden, unsichtbar setzen
	h_visible= findobj('type','uicontrol','visible','on');	% aktive UIControl-Objekte
	set (h_visible,'visible','off');	% unsichtbar setzen
	h_enable=uicontrol(h_fig,...                   % Pushbutton für enable-Objekte
	        'style','pushbutton',...
	        'string','enable',...   % Beschriftung des Pushbuttons
	        'units','normalized',...
	        'visible','off',...
	        'enable','off',...
	        'tag','filtsys',...      	% Bezeichnung des Pushbuttons
	        'position',[0.01 0.95 0.1 0.02]);
	set (h_enable,'userdata',h_visible);	% aktive UIControl-Objekte merken
	h_frame= findobj('tag','strukt','style','frame');	% Rahmen finden
	set(h_frame,'visible','on');		% sichtbar setzen
	set (h_fig,'name','Filtersysteme');
	uicontrol(h_fig,...                   % Pushbutton Teilfilter laden
	        'style','pushbutton',...
	        'string','Teilfilter laden',...   % Beschriftung des Pushbuttons
	        'units','normalized',...
	        'clipping','off',...
	        'tag','filtsys',...      	% Bezeichnung des Pushbuttons
	        'callback','filtsys(''laden'');',...	% Bei Betätigung
	        'userdata',0,...		% letze Teilfilternummer 0, kein Filter vorhanden
	        'position',[0.01 0.9 0.18 0.04]);
	uicontrol(h_fig,...                   % Pushbutton Teilfilter entfernen
	        'style','pushbutton',...
	        'string','Teilfilter entfernen',...   % Beschriftung des Pushbuttons
	        'units','normalized',...
	        'clipping','off',...
	        'enable','off',...
	        'tag','filtsys',...      	% Bezeichnung des Pushbuttons
	        'callback','filtsys(''entfernen'');',...	% Bei Betätigung
	        'position',[0.01 0.86 0.18 0.04]);
	uicontrol(h_fig,...                   % Pushbutton Teilfilter tauschen
	        'style','pushbutton',...
	        'string','Tauschen',...   % Beschriftung des Pushbuttons
	        'units','normalized',...
	        'clipping','off',...
	        'enable','off',...
	        'tag','filtsys',...      	% Bezeichnung des Pushbuttons
	        'callback','filtsys(''tauschen'');',...	% Bei Betätigung
	        'position',[0.01 0.80 0.18 0.035]);
	uicontrol(h_fig,...                   % Pushbutton Teilfilter tauschen-rückgängig
	        'style','pushbutton',...
	        'string','Rückgängig',...   % Beschriftung des Pushbuttons
	        'clipping','off',...
	        'units','normalized',...
	        'enable','off',...
	        'tag','filtsys',...      	% Bezeichnung des Pushbuttons
	        'callback','filtsys(''Filtertausch'');',...	% Bei Betätigung
	        'position',[0.01 0.765 0.18 0.035]);

	uicontrol(gcf,...                   % Textfeld
        	'style','Text',...            % 
	        'units','normalized',...
		'backgroundcolor',[0.752 0.752 0.752],...   % Hintergrundfarbe
	        'tag','filtsys',...
		'horizontalalignment','left',...
	        'string','Einheitsimpuls:',...
	        'position',[0.01 0.42 0.135 0.03]);
	uicontrol(gcf,...                   % Editierbares Textfeld fuer 
	        'style','edit',...            % Aussteuerung
	        'backgroundcolor',[1 1 1],...
	        'units','normalized',...
	        'tag','filtsys',...
	        'userdata','einheits',...              % Kennzeichnung für Einheitsimpuls
	        'string','1',...
		'callback','eingabe(''Einheitsimpuls_Filtsys'');',...
	        'position',[0.142 0.42 0.05 0.03]);
	uicontrol(h_fig,...                   % Pushbutton Amplitude/Phase
	        'style','pushbutton',...
	        'string','Amplitude/Phase',...   % Beschriftung des Pushbuttons
	        'units','normalized',...
	        'enable','off',...
	        'tag','filtsys',...      	% Bezeichnung des Pushbuttons
	        'callback','filtsys(''ampliphase_gesamt'');',...	% Bei Betätigung
	        'position',[0.01 0.35 0.18 0.04]);
	uicontrol(h_fig,...                   % Pushbutton Zurück
	        'style','pushbutton',...
	        'string','Zurück',...   % Beschriftung des Pushbuttons
	        'units','normalized',...
	        'enable','off',...
	        'tag','filtsys',...      	% Bezeichnung des Pushbuttons
	        'callback','filtsys(''ampliphase_beenden'');',...% Bei Betätigung
	        'position',[0.01 0.31 0.12 0.035]);
	uicontrol(h_fig,...                   % Pushbutton Drucken
	        'style','pushbutton',...
	        'string','Drucken',...	% Beschriftung des Pushbuttons
	        'units','normalized',...
	        'tag','filtsys',...      	% Bezeichnung des Pushbuttons
	        'callback','hard;',...	% Bei Betätigung
	        'position',[0.01 0.12 0.18 0.05]);
	uicontrol(h_fig,...                   % Pushbutton Hilfe
	        'style','pushbutton',...
	        'string','Hilfe',...	% Beschriftung des Pushbuttons
	        'units','normalized',...
	        'tag','filtsys',...      	% Bezeichnung des Pushbuttons
	        'callback','!winhelp struktur\filtsys.hlp',...% Bei Betätigung
	        'position',[0.01 0.07 0.18 0.05]);
	uicontrol(h_fig,...                   % Pushbutton Filterbank beenden
	        'style','pushbutton',...
	        'string','Filtersysteme beenden',...   % Beschriftung des Pushbuttons
	        'units','normalized',...
	        'tag','filtsys',...      	% Bezeichnung des Pushbuttons
	        'callback','filtsys(''close'');',...		% Bei Betätigung
	        'position',[0.01 0.02 0.18 0.05]);
	screensize = get(0,'screensize');% Ermittle Bildschirmaufloesung
	width = screensize(3);           % Breite des Bildschirms
	height = screensize(4);          % Hoehe des Bildschirms
	x_lim = [0 100];                % Festsetzen der waagerechten Grenzwerte
	y_lim = x_lim .*(height/width);  % Anpassen der senkrechten Grenzwerte
	axes('position',[0.2 0.2 0.8 0.8],...	% Axes-Objekt für Blockschaltbild
		'ylim',y_lim,...		% Begrenzungen
		'xlim',x_lim,...
		'visible','off',...		% ohne Rahmen und Koordinaten
		'tag','filtsys_axes',...	% Bezeichnung
		'drawmode','fast',...
		'color',[1 1 1],...
		'nextplot','add');		% Plots hinzufügen
	 uicontrol(gcf,...               % waagerechter Scrollbalken
	        'callback','filtsys(''moved_x'');',...
	        'style','slider',...
	        'tag','filtsys_sliderx',...
	        'units','normalized',...
	        'value',0,...               % Aktuelle Sliderposition
	        'userdata',0,...            % Alte Sliderposition
	        'min',0,'max',10,...       % Linker und rechter Grenzwert
	        'position',[0.2 0 0.8 0.05]); % Position des Scrollbalkens


end;	% Initialisierung

%-----------Laden----------------
if strcmp(command_str,'laden')
	[Matrix,a_Origin,b_Origin,Quantisierungsdaten,dos_name]=sichern('laden');	% Laden eines Teilfilters
	if ~isempty(Matrix)				% wenn gültige Daten
		command_str='Blockschaltbild';		% Blockschaltbild aktualisieren
		action_str='laden';		% Mitteilung über die erfolgte Aktion
	end;
end;	% Laden

%-----------Tauschen-------------
if strcmp(command_str,'tauschen')
	command_str='Auswahl vorbereiten';	% neuer Kommandostring
	h_entfernen= findobj('tag','filtsys','string','Teilfilter entfernen');	% Pushbutton finden
	set (h_entfernen,'userdata',0);		% merken, daß NICHT entfernt werden soll !!!
end;	% Tauschen

%-----------Entfernen-------------
if strcmp(command_str,'entfernen')
	command_str='Auswahl vorbereiten';	% neuer Kommandostring
	h_entfernen= findobj('tag','filtsys','string','Teilfilter entfernen');	% Pushbutton finden
	set (h_entfernen,'userdata',1);		% merken, daß entfernt werde soll
end;	% Entfernen

%---------Auswahl vorbereiten-----------------------
if strcmp(command_str,'Auswahl vorbereiten')
	h_enable= findobj('visible','on','enable','on');	% aktive UIControl-Objekte
	set (h_enable,'enable','off');			% inaktiv setzen
	Slider=findobj('tag','filtsys_sliderx');		% Handle auf Slider
	set(Slider,'enable','on');			% Slider aktiv belassen
	h_ende= findobj('string','Filtersysteme beenden');	% Beenden-Pushbutton
	set (h_ende,'UserData',h_enable);			% vormals aktive Objekte merken
	h_pfeil=findobj('tag','Pfeil');				% verbindende Pfeile finden
	set (h_pfeil,'ButtonDownFcn','');			% ButtonDownFunction zurücksetzen
	h_fig=findobj('tag','netzwerk');			% Handle auf Fenster
	set (h_fig,'WindowButtonDownFcn','filtsys(''auswahl'');');% Aufruf der Funktion bei Mausklick
	uicontrol('style','Text','units','normalized',...
	'backgroundcolor','y',...   % Hintergrundfarbe
        'tag','meldetext',...
        'string','Wählen Sie einen Filter aus         Esc: rechte Maustaste',...       % Auszugebender Text
        'position',[0.2 0.05 0.8 0.03]);
end;	% Auswahl vorbereiten

%---------Auswahl-------------------------------
if strcmp(command_str,'auswahl')
	beenden=0;				% Flag für Beenden der Auswahl
	h_meld=findobj('tag','meldetext');	% Handle auf Meldetext
	h_fig=findobj('tag','netzwerk');	% Handle auf Fenster
	sel_typ=get (h_fig,'SelectionType');	% Maus Aktion
	if strcmp(sel_typ,'extend')		% rechte Maustaste
		beenden=1;			% Auswahl beenden anzeigen
	end;
	if strcmp(sel_typ,'normal')		% linke Maustaste
		h_objekt=gco;		% angewähltes Objekt
		tag_str= get (h_objekt,'tag');	% tag des Objekts
		num_str= tag_str (max(find(tag_str=='_'))+1:size(tag_str,2));
		obj_num= str2num(num_str);		% Filter-Nummer des angewählten Objekts
		if isempty(obj_num)			% kein gültiges Objekt angewählt
						 	% Meldung über ungültige Auswahl ausgeben
			set(h_meld,'string','Kein Filter, wählen Sie einen Filter aus       Esc: rechte Maustaste');
			return;			% keine weitere Handlung, Funktion verlassen
		end;
		h_entf=findobj('string','Teilfilter entfernen');	% Pushbutton finden
      entf_flag= get(h_entf,'UserData');			% Kennung, ob entfert werden soll
      if isempty(entf_flag)
         entf_flag=1;
      end;
		if entf_flag==1					% Entfernen ist gesetzt
			command_str='Blockschaltbild';		% neuer Kommandostring
			action_str='entfernen';			% Aktionshinweis für Teilfunktion Blockschaltbild
			beenden=1;				% Auswahl beenden anzeigen
		else					% nicht Entfernen, sondern Tauschen
			h_rueck=findobj('tag','filtsys','string','Rückgängig');	% Pushbutton rückgängig
			Auswahl=get(h_rueck,'UserData');	% ausgewählte Filternummern
			if (size(Auswahl,2)~=1)			% wenn noch kein Filter zu Tauschen ausgewählt
				set(h_rueck,'UserData',obj_num);	% ausgewählte Filter-Nummer merken
				set(h_meld,'string','Wählen Sie den zweiten Filter aus       Esc: rechte Maustaste');
				h_block=findobj('tag',['Matrix_' num2str(obj_num)]);	% Rahmen des angewählten Blocks
				set (h_block,'color','r');				% Farbe auf rot setzen
			else			% wenn ein Filter schon ausgewählt wurde ==> Tauschen
				Filter1=obj_num;	% Nummern der beiden zu tauschenden Filter
				Filter2=Auswahl;
				h_block=findobj('tag',['Matrix_' num2str(Auswahl)]);	% Rahmen des angewählten Blocks
				set (h_block,'color','k');				% Farbe auf schwarz zurücksetzen
				beenden =1;					% Beenden anzeigen
				set(h_rueck,'UserData',[Filter1 Filter2],'enable','on');	% Getauschte Filter merken und rückgängig aktivieren
				command_str='Filtertausch';			% Nach beenden zu Filtertausch
			end;
		end;
	end; % linke Maustaste

	if beenden==1		% Auswahl beenden
		h_ende= findobj('string','Filtersysteme beenden');	% Beenden-Pushbutton
		h_enable=get (h_ende,'UserData');			% vormals aktive UIControl-Objekte
		set (h_enable,'enable','on');
		h_pfeil=findobj('tag','Pfeil');				% verbindende Pfeile finden
		set (h_pfeil,'ButtonDownFcn','filtsys(''ampliphase_teil'');');	% ButtonDownFunction setzen
		delete (h_meld);					% Meldetext löschen
		set (h_fig,'WindowButtonDownFcn','');		% WindowButtonDownFcn löschen
		h_rueck=findobj('tag','filtsys','string','Rückgängig');	% Pushbutton Rückgängig
		Auswahl=get(h_rueck,'UserData');	% ausgewählte Filter
		if (size(Auswahl,2)==1)			% wenn nur ein Filter zu Tauschen ausgewählt
			set (h_rueck,'UserData',[],'enable','off');	% Auswahl löschen
			h_block=findobj('tag',['Matrix_' num2str(Auswahl)]);	% Rahmen des angewählten Blocks
			set (h_block,'color','k');				% Farbe auf schwarz zurücksetzen
		end;
	end;
end;	%Auswahl

%---------- Filtertausch----------------
if strcmp(command_str,'Filtertausch')		% Tauschen von zwei Filtern (aus Auswahl oder Rückgängig)
		h_rueck=findobj('tag','filtsys','string','Rückgängig');	% Pushbutton Rückgängig
		Auswahl=get(h_rueck,'UserData');	% ausgewählte Filter
		Filter1=Auswahl(1,1);		% Nummern der auszutauschenden Filter
		Filter2=Auswahl(1,2);
		h_filter1= findobj('tag',['Matrix_' num2str(Filter1)]);	% Nacheinander die Handles auf die Filterobjekte finden
		h_filter2= findobj('tag',['Matrix_' num2str(Filter2)]);	% und deren Strings und UserDaten austauschen
		dat_1=get(h_filter1,'UserData');
		dat_2=get(h_filter2,'UserData');
		set(h_filter1,'UserData',dat_2);
		set(h_filter2,'UserData',dat_1);
		h_filter1= findobj('tag',['Origin_' num2str(Filter1)]);
		h_filter2= findobj('tag',['Origin_' num2str(Filter2)]);
		str_1=get(h_filter1,'String');
		str_2=get(h_filter2,'String');
		dat_1=get(h_filter1,'UserData');
		dat_2=get(h_filter2,'UserData');
		set(h_filter1,'String',str_2,'UserData',dat_2);
		set(h_filter2,'String',str_1,'UserData',dat_1);
		h_filter1= findobj('tag',['Quantisierungsdaten_' num2str(Filter1)]);
		h_filter2= findobj('tag',['Quantisierungsdaten_' num2str(Filter2)]);
		str_1=get(h_filter1,'String');
		str_2=get(h_filter2,'String');
		dat_1=get(h_filter1,'UserData');
		dat_2=get(h_filter2,'UserData');
		set(h_filter1,'String',str_2,'UserData',dat_2);
		set(h_filter2,'String',str_1,'UserData',dat_1);
		h_filter1= findobj('tag',['dos_name_' num2str(Filter1)]);
		h_filter2= findobj('tag',['dos_name_' num2str(Filter2)]);
		str_1=get(h_filter1,'String');
		str_2=get(h_filter2,'String');
		dat_1=get(h_filter1,'UserData');
		dat_2=get(h_filter2,'UserData');
		set(h_filter1,'String',str_2,'UserData',dat_2);
		set(h_filter2,'String',str_1,'UserData',dat_1);
end;	% Filtertausch

%---------Blockschaltbild---------------------------
if strcmp(command_str,'Blockschaltbild')
	x_start=10;	% Werte für Bildschirmaufbau des Blockschaltbildes
	y_start=50;
	x_abstand=20;
	x_pfeil=[x_start-5 x_start x_start-2 x_start x_start-2 ];	% Koordinaten für Pfeil
	y_pfeil=[y_start y_start y_start-1 y_start y_start+1];
	x_block=[x_start x_start+15 x_start+15 x_start x_start];	% Koordinaten für Blockrahmen
	y_block=[y_start-5 y_start-5 y_start+5 y_start+5 y_start-5];
	h_letzte=findobj('string','Teilfilter laden','tag','filtsys');	% Pushbutton Teilfilter laden finden
	Nummer= get(h_letzte,'userdata');	% Nummer des letzten Teilfilters

	if strcmp(action_str,'laden')		% neues Teilfilter in Blockschaltbild einfügen
		if Nummer==0		% Kein existentes Blockschaltbild
			x_text=text ('string','X(z)',...			% Eingangssignal
				'position',[x_start-5 y_start+3],...   
				'tag','x(z)',...	% Bezeichnung = x(z)
				'horizontalalignment','left',... % Ausrichtung zentriert
				'color','k',...         % Zeichenfarbe = schwarz
				'fontsize',10,...	% Schriftgröße
				'clipping','on');       % Nur innerhalb axes sichtbar
			x_text=text ('string','\_',...		% Unterstrich Eingangssignal
				'position',[x_start-5 y_start+2.7],...   
				'tag','x(z)_',...	% Bezeichnung = x(z)_
				'horizontalalignment','left',... % Ausrichtung zentriert
				'color','k',...         % Zeichenfarbe = schwarz
				'fontsize',10,...	% Schriftgröße
				'clipping','on');       % Nur innerhalb axes sichtbar
			line('xdata',x_pfeil,'ydata',y_pfeil,...			% Pfeil zeichnen
					'color','k');

			%------- Block mit innerer Beschriftung--------
			tag_str=['Matrix_' num2str(Nummer+1)];
			block= line('xdata',x_block,...		% Rahmen für Block
					'ydata',y_block,...
					'color','k',...
					'tag',tag_str,...
					'userdata',Matrix);	% Filterdaten hier abgelegt
			if (any (a_Origin(2:size(a_Origin,2))))	% über Filtertyp FIR/IIR entscheiden
				type_str='IIR-Filter';
			else
				type_str='FIR-Filter';
			end;
			tag_str=['Origin_' num2str(Nummer+1)];
			type_text=text ('string',type_str,...		% Text für Filtertyp
				'position',[x_start+7 y_start+3],...   
				'tag',tag_str,...	% Bezeichnung
				'horizontalalignment','center',... % Ausrichtung zentriert
				'color','k',...         % Zeichenfarbe = schwarz
				'fontsize',10,...	% Schriftgröße
				'userdata',[a_Origin;b_Origin],... % nichtquantisierte Koeffizienten hier abgelegt
				'clipping','on');       % Nur innerhalb axes sichtbar
			tag_str=['Quantisierungsdaten_' num2str(Nummer+1)];
			ord_str=[num2str(max(length(a_Origin),length(b_Origin))-1) '. Ordnung'];
			type_text=text ('string',ord_str,...		% Text für Filterordnung
				'position',[x_start+7 y_start],...   
				'tag',tag_str,...	% Bezeichnung
				'horizontalalignment','center',... % Ausrichtung zentriert
				'color','k',...         % Zeichenfarbe = schwarz
				'fontsize',10,...	% Schriftgröße
				'userdata',Quantisierungsdaten,...	% Quantisierungsdaten hier abgelegt
				'clipping','on');       % Nur innerhalb axes sichtbar
			tag_str=['dos_name_' num2str(Nummer+1)];
			file_name= dos_name(max(find(dos_name=='\'))+1:size(dos_name,2)-4);	% File-Namen aus DOS-Namen extrahieren
			type_text=text ('string',file_name,...		% Text für DOS-Name
				'position',[x_start+7 y_start-3],...   
				'tag',tag_str,...	% Bezeichnung
				'horizontalalignment','center',... % Ausrichtung zentriert
				'color','k',...         % Zeichenfarbe = schwarz
				'fontsize',10,...	% Schriftgröße
				'userdata',dos_name,...	% Pfad und DOS-Name hier abgelegt
				'clipping','on');       % Nur innerhalb axes sichtbar
			%------- Ausgangspfeil----------
			x_pfeil=x_pfeil+x_abstand;			% Ausgangspfeil
			line('xdata',x_pfeil,'ydata',y_pfeil,...	% Pfeil zeichnen
					'color','k',...
					'tag','Pfeil',...
					'userdata',Nummer+1,...
					'buttondownfcn','filtsys(''ampliphase_teil'');');

			y_text=text ('string','Y(z)',...		% Ausgangssignal
				'position',[x_start+x_abstand y_start+3],...   
				'tag','y(z)',...	% Bezeichnung = y(z)
				'horizontalalignment','left',... % Ausrichtung zentriert
				'color','k',...         % Zeichenfarbe = schwarz
				'fontsize',10,...	% Schriftgröße
				'clipping','on');       % Nur innerhalb axes sichtbar
			y_text=text ('string','\_',...		% Unterstrich Ausgangssignal
				'position',[x_start+x_abstand y_start+2.7],...   
				'tag','y(z)_',...	% Bezeichnung = y(z)_
				'horizontalalignment','left',... % Ausrichtung zentriert
				'color','k',...         % Zeichenfarbe = schwarz
				'fontsize',10,...	% Schriftgröße
				'clipping','on');       % Nur innerhalb axes sichtbar
		end;	% Nummer == 0    
		if (Nummer ~= 0)
			h_y=findobj('tag','y(z)');		% Handle auf Ausgangssignal-Beschriftung
			x_pos=get (h_y,'position');		% X-Position der Beschriftung
			set (h_y,'position',x_pos+[x_abstand 0 0]); % um eine Blocklänge versetzen
			h_y_=findobj('tag','y(z)_');		% Handle auf Unterstrich der Beschriftung
			x_pos=get (h_y_,'position');		% X-Position des Unterstrichs
			set (h_y_,'position',x_pos+[x_abstand 0 0]); % um eine Blocklänge versetzen
		
			%------- Block mit innerer Beschriftung--------
			tag_str=['Matrix_' num2str(Nummer+1)];
			block= line('xdata',x_block+x_abstand*Nummer,...	% Rahmen für Block
					'ydata',y_block,...
					'color','k',...
					'tag',tag_str,...
					'userdata',Matrix);	% Filterdaten hier abgelegt
			if (any (a_Origin(2:size(a_Origin,2))))	% über Filtertyp FIR/IIR entscheiden
				type_str='IIR-Filter';
			else
				type_str='FIR-Filter';
			end;
			tag_str=['Origin_' num2str(Nummer+1)];
			type_text=text ('string',type_str,...		% Text für Filtertyp
				'position',[x_start+7+x_abstand*Nummer y_start+3],...
				'tag',tag_str,...	% Bezeichnung
				'horizontalalignment','center',... % Ausrichtung zentriert
				'color','k',...         % Zeichenfarbe = schwarz
				'fontsize',10,...	% Schriftgröße
				'userdata',[a_Origin;b_Origin],... % nichtquantisierte Koeffizienten hier abgelegt
				'clipping','on');       % Nur innerhalb axes sichtbar
			tag_str=['Quantisierungsdaten_' num2str(Nummer+1)];
			ord_str=[num2str(max(length(a_Origin),length(b_Origin))-1) '. Ordnung'];
			type_text=text ('string',ord_str,...		% Text für Filterordnung
				'position',[x_start+7+x_abstand*Nummer y_start],...   
				'tag',tag_str,...	% Bezeichnung
				'horizontalalignment','center',... % Ausrichtung zentriert
				'color','k',...         % Zeichenfarbe = schwarz
				'fontsize',10,...	% Schriftgröße
				'userdata',Quantisierungsdaten,...	% Quantisierungsdaten hier abgelegt
				'clipping','on');       % Nur innerhalb axes sichtbar
			tag_str=['dos_name_' num2str(Nummer+1)];
			file_name= dos_name(max(find(dos_name=='\'))+1:size(dos_name,2)-4);	% File-Namen aus DOS-Namen extrahieren
			type_text=text ('string',file_name,...		% Text für DOS-Name
				'position',[x_start+7+x_abstand*Nummer y_start-3],...   
				'tag',tag_str,...	% Bezeichnung
				'horizontalalignment','center',... % Ausrichtung zentriert
				'color','k',...         % Zeichenfarbe = schwarz
				'fontsize',10,...	% Schriftgröße
				'userdata',dos_name,...	% Pfad und DOS-Name hier abgelegt
				'clipping','on');       % Nur innerhalb axes sichtbar
			%------- Ausgangspfeil----------
			x_pfeil=x_pfeil+x_abstand*(Nummer+1);		% Ausgangspfeil
			line('xdata',x_pfeil,'ydata',y_pfeil,...	% Pfeil zeichnen
					'color','k',...
					'tag','Pfeil',...
					'userdata',Nummer+1,...
					'buttondownfcn','filtsys(''ampliphase_teil'');');
		end; % Nummer ~= 0
		set (h_letzte,'UserData',Nummer+1);	% neue Nummer des letzten Blocks merken
	end;	% action_str 'laden'

	if strcmp(action_str,'entfernen')		% Entfernen eines ausgewählten Blocks
		h_letzte=findobj('string','Teilfilter laden','tag','filtsys');	% Pushbutton Teilfilter laden finden
		h_pfeil_letzter=findobj('tag','Pfeil','UserData',Nummer);	% letzter Pfeil
		delete (h_pfeil_letzter);					% löschen
		h_block=findobj('tag',['Matrix_' num2str(obj_num)]);		% Objekte der Filters finden und löschen
		delete (h_block);
		h_text= findobj('tag',['Origin_' num2str(obj_num)]);
		delete (h_text);
		h_text= findobj('tag',['Quantisierungsdaten_' num2str(obj_num)]);
		delete (h_text);
		h_text= findobj('tag',['dos_name_' num2str(obj_num)]);
		delete (h_text);
		for (i=obj_num+1:Nummer)			% alle weiteren Blöcke mit ihren Objekten nach vorn schieben
			h_block=findobj('tag',['Matrix_' num2str(i)]);		
			x_pos= get (h_block,'XData');
			set (h_block,'XData',x_pos-x_abstand,...
				'tag',['Matrix_' num2str(i-1)]);

			h_text= findobj('tag',['Origin_' num2str(i)]);
			pos = get (h_text,'position');
			set (h_text,'position',pos-[x_abstand 0 0],...
				'tag',['Origin_' num2str(i-1)]);

			h_text= findobj('tag',['Quantisierungsdaten_' num2str(i)]);
			pos = get (h_text,'position');
			set (h_text,'position',pos-[x_abstand 0 0],...
				'tag',['Quantisierungsdaten_' num2str(i-1)]);

			h_text= findobj('tag',['dos_name_' num2str(i)]);
			pos = get (h_text,'position');
			set (h_text,'position',pos-[x_abstand 0 0],...
				'tag',['dos_name_' num2str(i-1)]);		
		end; % of for
		h_y=findobj('tag','y(z)');		% Handle auf Ausgangssignal-Beschriftung
		x_pos=get (h_y,'position');		% X-Position der Beschriftung
		set (h_y,'position',x_pos-[x_abstand 0 0]); % um eine Blocklänge versetzen
		h_y_=findobj('tag','y(z)_');		% Handle auf Unterstrich der Beschriftung
		x_pos=get (h_y_,'position');		% X-Position des Unterstrichs
		set (h_y_,'position',x_pos-[x_abstand 0 0]); % um eine Blocklänge versetzen
		h_rueck= findobj('tag','filtsys','string','Rückgängig');	% Pushbutton Rückgängig
		set (h_rueck,'UserData',[],'enable','off');	% Rückgängig neu initialisieren
		set (h_entf,'Userdata',0);			% Kennung für entfernen löschen
		set (h_letzte,'UserData',Nummer-1);	% neue Nummer des letzten Blocks merken
		if Nummer==1			% Kein Filter mehr vorhanden
			h_axe= findobj('tag','filtsys_axes');	% restliche Objekte in Axes löschen
			h_child= get (h_axe,'children');
			delete (h_child);
		end;
	end;	% action_str 'entfernen'

	h_letzte=findobj('string','Teilfilter laden','tag','filtsys');	% Pushbutton Teilfilter laden finden
	Nummer= get(h_letzte,'userdata');	% Nummer des letzten Teilfilters
	h_entf=findobj('string','Teilfilter entfernen');	% Pushbutton finden
	h_ampli=findobj('string','Amplitude/Phase');	% Pushbutton Amplituden-/Phasengang finden
	if Nummer > 0
		set (h_entf,'enable','on');	% aktiv setzen
		set (h_ampli,'enable','on');
	else
		set (h_entf,'enable','off');	% inaktiv setzen
		set (h_ampli,'enable','off');
	end;
	h_tausch=findobj('tag','filtsys','string','Tauschen');	% Pushbutton Tauschen
	h_rueck=findobj ('tag','filtsys','string','Rückgängig');% Pushbutton Rückgängig
	if Nummer > 1
		set (h_tausch,'enable','on');	% aktiv setzen
	else
		set (h_tausch,'enable','off');	% inaktiv setzen
		set (h_rueck,'enable','off');
	end;

	Slider=findobj('tag','filtsys_sliderx');		% Handle auf Slider
	Axes_Breite= 20 * Nummer + 25;	% Gesamter Darstellungsbereich im Axes-Objekt
	h_axes=findobj('tag','filtsys_axes');	% Axes-Objekt
	x_lim= get (h_axes,'XLim');		% angezeigter Bereich
	value=x_lim(1)/((Axes_Breite-100)/10);	% Slider-Sollposition berechnen
	if value <0
		value=0;
	end;
	set (Slider,'Value',value);		% Sliderposition an eventuell veränderte Größe des Bildes anpassen	
	set(Slider,'UserData',value);	% und als alte Position merken


end;	%Blockschaltbild

%-----------Amplituden-/Phasengang-------------
if strcmp(command_str,'ampliphase_gesamt')
	h_letzte=findobj('string','Teilfilter laden','tag','filtsys');	% Pushbutton Teilfilter laden finden
	Nummer= get(h_letzte,'userdata');	% Nummer des letzten Teilfilters
        disp(Nummer);
	command_str='ampliphase';	% Aufruf der Anzeige Amplituden-/Phasengang
end;
if strcmp(command_str,'ampliphase_teil')
	h_obj=gco;
	Nummer= get(h_obj,'userdata');	% Nummer des angewählten Pfeils
        disp(Nummer);
	command_str='ampliphase';	% Aufruf der Anzeige Amplituden-/Phasengang
end;
if strcmp(command_str,'ampliphase_aktual')
	h_zurueck=findobj('tag','filtsys','string','Zurück');	% Pushbutton Zurück finden
	Nummer=get(h_zurueck,'UserData');		% Nummer des zuletzt simulierten Filters	
	command_str='ampliphase';	% Aufruf der Anzeige Amplituden-/Phasengang
end;
if strcmp(command_str,'ampliphase')	% Amplituden-/Phasengang darstellen
	% Initialisierung
	h_referenz= findobj('tag','messen','string','Referenzkurven'); 	% Checkbox Refrenzkurven
	set (h_referenz,'callback','filtsys(''ampliphase_aktual'');');	% Callback: Diagramm aktualisieren
	h_pop_fft= findobj('tag','FFT');	% Finde Objekt Popupmenü FFT-Länge
	set (h_pop_fft,'callback','filtsys(''ampliphase_aktual'');');	% Callback: Diagramm aktualisieren
	h_dB_Text= findobj('tag','messen','style','popupmenu');	% Popup-Menü Amlitude lin/log
	set (h_dB_Text,'callback','filtsys(''ampliphase_aktual'');');	% Callback: Diagramm aktualisieren
	h_zurueck=findobj('tag','filtsys','string','Zurück');		% Pushbutton Zurück finden
	set (h_zurueck,'enable','on');				% aktiv setzen
	h_axes=findobj('tag','filtsys_axes');				% Axes-Objekt mit Blockschaltbild
	h_child= get (h_axes,'children');				% Objekte im Blockschaltbild
	set (h_child,'visible','off');					% unsichtbar setzen
	h_slider=findobj('tag','filtsys_sliderx');			% Slider im Blockschaltbild
	set (h_slider,'visible','off');					% unsichtbar setzen
	h_exist= findobj('tag','bode_amplitude');			% exisieren die Diagramm--Objekte
	if isempty(h_exist)					% wenn erster Aufruf
		h_button= findobj('tag','filtsys','style','pushbutton','clipping','off');	% Pushbuttons Teilfilter laden/entfernen,
		h_button= findobj(h_button,'enable','on');				% Tauschen und Rückgängig, wenn aktiv finden
		h_ende= findobj('string','Filtersysteme beenden');			% Beenden Pushbutton für enable-Objekte
		set (h_ende,'UserData',h_button);					% hier merken
		set (h_button,'enable','off');					% Pushbuttons inaktiv setzen
	end;	
	h_hilfe=findobj('tag','filtsys','string','Hilfe');			% Pushbutton Hilfe
	set (h_hilfe,'callback','!winhelp struktur\amplisy.hlp');	% Hilfeaufruf aktualisieren
	h_axes_amp = findobj('tag',...  % Suche axes Objekt 'bode_amplitude'
	        'bode_amplitude');
	delete(h_axes_amp);             % Entferne es
	h_axes_phase = findobj('tag',...% Suche axes Objekt 'bode_phase'
	        'bode_phase');
	delete(h_axes_phase);           % Entferne es	
	h_axes_amp=axes('position',[0.35 0.65 0.6 0.3],...% Position und Ausdehnung
	        'xcolor',[0 0 0],...        % Farbe x-Achse = Schwarz
	        'ycolor',[0 0 0],...        % Farbe y-Achse = Schwarz
	        'xgrid','on',...            % Gitter in x-Richtung an
	        'ygrid','on',...            % Gitter in y-Richtung an
           'xlim',[0 0.5],...
           'box','on',...
	        'tag','bode_amplitude',...
	        'drawmode','fast',...       % Schneller Zeichenmodus
	        'color',[1 1 1],...         % Farbe = Weiss
	        'nextplot','add');          % Ältere Plots bleiben erhalten
	h_axes_phase = axes('position',[0.35 0.28 0.6 0.3],...
	        'visible','on',...          % Begrenzung und Koordinaten sichtbar
	        'xcolor',[0 0 0],...
	        'ycolor',[0 0 0],...
	        'xgrid','on',...
           'ygrid','on',...
           'box','on',...
	        'ylim',[-200 200],...       % Festlegen der y-Ausdehnung
	        'xlim',[0 0.5],...
	        'tag','bode_phase',...
	        'drawmode','fast',...
	        'color',[1 1 1],...         % Farbe = Weiss
	        'nextplot','add');          % Ältere Plots bleiben erhalten
	h_ui_text = uicontrol(gcf,...   % Textfeld
	        'style','Text',...            
	        'units','normalized',...
	        'backgroundcolor','y',...
	        'string','Berechnung läuft',...
	        'position',[0.2 0 0.8 0.04]);
   drawnow;
	%-------- Berechnung--------
	fftvalue= get (h_pop_fft,'value');  % Wert des Popupmenüs lesen
	valuematrix=[16 32 64 128 256 512 1024];   % Mögliche FFT-Längen
	fft_laenge = valuematrix(fftvalue);    % FFT länge
	h_einheits=findobj('tag','filtsys','userdata','einheits');	% Editierfeld Höhe des Einheitsimpulses
	wert_str=get(h_einheits,'string');			% wert lesen
	x = [ str2num(wert_str) zeros(1,fft_laenge-1)];	% Eingangsfolge = Einheitsimpuls
	x2=x;		% Einheitsimpuls für Referenzkurve
	hoechste=0;					% Überlaufkennung für Festkommaquantisierung
	for Teilfilter=1:Nummer			% jeden Teilfilter
		h_matrix=findobj('tag',['Matrix_' num2str(Teilfilter)]);	%Handle auf Matrixobjekt
		matrix= get (h_matrix,'UserData');			% Matrix in UserData
		f_struktur=matrix(1,1);				% Strukturkennung
		h_origin=findobj('tag',['Origin_' num2str(Teilfilter)]);	%Handle auf Originaldaten
		origin= get (h_origin,'UserData');			% unquantisierte Koeffizienten in UserData
		a_origin=origin(1,:)
		b_origin=origin(2,:)
		h_quant=findobj('tag',['Quantisierungsdaten_' num2str(Teilfilter)]);	%Handle auf Quantisierungsdaten
		Quanti= get (h_quant,'UserData');			% Quantisierungsdaten in UserData
		quantisierung = Quanti(1);				% erstes Elemen enthält Kennung, ob quantisiert

		if (quantisierung==1)			% wenn quantisiert
			arithmetik= Quanti(2);		% Kennung Gleit-/Festpunkt-Quantisierung
			if (arithmetik == 1)            % Gleitkommaarithmetik
				rech=Quanti(3:5);	% Quantisierungsspezifikationen
				spei=Quanti(6:8);
				mantisse=rech(1);exponent=rech(2);runden=rech(3);
				x= flpoint(x,mantisse,exponent,runden); % Gleitkomma-Quantisierung der Eingangsfolge
				if (f_struktur == 1)                    % Direktform
				        bhilf=matrix(2:size(matrix,1),1)';   % b-Koeffizienten
				        ahilf=matrix(2:size(matrix,1),2)';   % a-Koeffizienten
				        y = gfildir (bhilf,ahilf,x,rech,spei);   % Gleitkomma Direktform
				end
				if (f_struktur == 2)                    % 1. kanonische Form
				        bhilf=matrix(2:size(matrix,1),1)';   % b-Koeffizienten
				        ahilf=matrix(2:size(matrix,1),2)';   % a-Koeffizienten
				        y = gfilka1 (bhilf,ahilf,x,rech,spei);   % Gleitkomma 1. kanonische Form
				end
				if (f_struktur == 3)                    % 2. kanonische Form
				        bhilf=matrix(2:size(matrix,1),1)';   % b-Koeffizienten
				        ahilf=matrix(2:size(matrix,1),2)';   % a-Koeffizienten
				        y = gfilka2 (bhilf,ahilf,x,rech,spei);   % Gleitkomma 2. kanonische Form
				end
				if (f_struktur == 4)                    % Kaskadenform (3. kanonische)
				        sos=matrix(2:size(matrix,1),:);     % sos-Matrix extrahieren
				        y = gfilkas (sos,2,x,rech,spei); % Gleitkomma 3. kanonische Form
				end
				if (f_struktur==5)                      % normierte Kaskadenform
				        sos=matrix(2:size(matrix,1),2:7);
				        norm_Koeff=matrix(2:size(matrix,1),1)'; % Normierungskoeffizienten
				        y=gfilkasn (sos,norm_Koeff,2,x,rech,spei);   %Gleitkomma normierte Kaskadenform
				end
				if (f_struktur==6)                      % Lattice-Ladder
				        K=matrix(2:size(matrix,1)-1,1)';     %Lattice-Koeffizienten
				        C=matrix(2:size(matrix,1),2)';       %Ladder-Koeffizienten
				        y=gfillat(K,C,x,rech,spei);     % Gleitkomma Lattice-Ladder
				end
				if (f_struktur==7)                      % Parallelform
				        sos=matrix(2:size(matrix,1),2:7);
				        Dir_term=matrix(2:size(matrix,1),1)';  % Direktterme
				        nicht_null=find(Dir_term);             % Elemente ungleich Null
				        Dir_term=Dir_term(1:max(nicht_null));  % Nullen abschneiden
				        if isempty(Dir_term)                   % Wenn leere Menge, eine Null
				            Dir_term=0;
				        end;
				        y=gfilpar(sos,Dir_term,2,x,rech,spei);     % Gleitkomma Parallelform
				end
			end;	% arithmetik ==1
			if (arithmetik == 2)            % Festkommaarithmetik
				rech=Quanti(3:7);	% Quantisierungsspezifikationen
				spei=Quanti(8:12);
				maxi=rech(1);mini=rech(2);bits=rech(3);overflow=rech(4);runden=rech(5);
				x=fixpoint(x,maxi,mini,bits,overflow,runden);	% Festkomma-Quantisierung der Eingangsfolge
				if (f_struktur == 1)                % Direktform
				        bhilf=matrix(2:size(matrix,1),1)';   % b-Koeffizienten
				        ahilf=matrix(2:size(matrix,1),2)';   % a-Koeffizienten
				        y = ffildir (bhilf,ahilf,x,rech,spei,hoechste);   % Festkomma Direktform
				end
				if (f_struktur == 2)                    % 1. kanonische Form
				        bhilf=matrix(2:size(matrix,1),1)';   % b-Koeffizienten
				        ahilf=matrix(2:size(matrix,1),2)';   % a-Koeffizienten
				        y = ffilka1 (bhilf,ahilf,x,rech,spei,hoechste);   % Festkomma 1. kanonische Form
				end
				if (f_struktur == 3)
				        bhilf=matrix(2:size(matrix,1),1)';   % b-Koeffizienten
				        ahilf=matrix(2:size(matrix,1),2)';   % a-Koeffizienten
				        y = ffilka2 (bhilf,ahilf,x,rech,spei,hoechste);   % Festkomma 2. kanonische Form
				end
				if (f_struktur == 4)                    % Kaskadenform (3. kanonische)
				        sos=matrix(2:size(matrix,1),:);     % sos-Matrix extrahieren
				        y = ffilkas (sos,2,x,rech,spei,hoechste); % Festkomma 3. kanonische Form
				end
				if (f_struktur==5)                      % normierte Kaskadenform
				        sos=matrix(2:size(matrix,1),2:7);
				        norm_Koeff=matrix(2:size(matrix,1),1)'; % Normierungskoeffizienten
				        y=ffilkasn (sos,norm_Koeff,2,x,rech,spei,hoechste);   %Festkomma normierte Kaskadenform
				end
				if (f_struktur==6)                      % Lattice-Ladder
				        K=matrix(2:size(matrix,1)-1,1)';     %Lattice-Koeffizienten
				        C=matrix(2:size(matrix,1),2)';       %Ladder-Koeffizienten
				        y=ffillat(K,C,x,rech,spei,hoechste); % Festkomma Lattice-Ladder
				end
				if (f_struktur==7)                      % Parallelform
				        sos=matrix(2:size(matrix,1),2:7);
				        Dir_term=matrix(2:size(matrix,1),1)';  % Direktterme
				        nicht_null=find(Dir_term);             % Elemente ungleich Null
				        Dir_term=Dir_term(1:max(nicht_null));  % Nullen abschneiden
				        if isempty(Dir_term)                   % Wenn leere Menge, eine Null
				            Dir_term=0;
				        end;
				        y=ffilpar(sos,Dir_term,2,x,rech,spei,hoechste);  % Festkomma Parallelform
				end
			end;	% arithmetik ==2
		end;	% quantisierung ==1
		if (quantisierung ==0)			% keine Quantisierung
			y=filter(b_origin,a_origin,x);
		end;
		y2= filter(b_origin,a_origin,x2);		% Filterung für nichtquantisierte Referenz
		
		x=y;		% Ausgangsfolge ist Eingangsfolge des nächsten Filters
		x2=y2;
	end; % jedes Teilfilter

	delete(h_ui_text);              % Entferne Textfeld 'Berechnung läuft'

	H2=fft(y2,fft_laenge);
	x_koo=[0:fft_laenge/2-1]./fft_laenge;  % x-Koordinaten
	axes(h_axes_amp);                  % Axes Objekt für Amplitude
	h_linlog= findobj('tag','messen','style','popupmenu');	% Popup-Menü Amplitude lin/log
	wert_linlog = get(h_linlog,'value');		% Wert feststellen
	struktur('dB_Text');
	H=fft(y,fft_laenge);
	if (wert_linlog==1)
	 	plot(x_koo,abs (H (1:length(H)/2)),'k'); % Zeichne Amplitude quantisiert
	else
	  	plot(x_koo,log10(abs (H (1:length(H)/2)))*20,'k'); % Zeichne Amplitude [dB] quantisiert
	end;
	h_referenz=findobj('tag','messen','string','Referenzkurven');	% Checkbox Referenzkurven
	referenz= get(h_referenz,'value');		% Wert der Checkbox
	if (referenz ==1)	% Referenzkurven sollen erscheinen
  		if (wert_linlog==1)
			plot(x_koo,abs (H2(1:length(H2)/2)),'r');% Zeichne Amplitude Referenz
		else
			plot(x_koo,log10(abs (H2(1:length(H2)/2)))*20,'r');% Zeichne Amplitude [dB] Referenz
		end;
	end;
	pause(0.01);
	axes(h_axes_phase);                % Axes Objekt für Phase
   	winkel = (angle(H).*180./pi);      % Umrechnung in Grad
  	plot (x_koo,(winkel (1:length(H)/2)) ,'k');% Zeichne Phase quantisiert
 	if (referenz ==1)	% Referenzkurven sollen erscheinen
		winkel2 = (angle(H2).*180./pi);    % Umrechnung in Grad
		plot (x_koo,(winkel2 (1:length(H2)/2)) ,'r');% Zeichne Phase Referenz
	end;
	y_lim=get(h_axes_amp,'ylim');      % Senkrechte Begrenzung Amplitudengang
	maximum = y_lim(2);                % Maximum der Amplitude
	hoehe = maximum + (maximum/10);    % Senkrechte Position der Überschrift
	if isempty(h_exist)
		messen;		% Aufruf von messen.m
	end;
	set(h_zurueck,'UserData',Nummer);		% Nummer des letzten simulierten Filters
 	y_lim_pha=get(h_axes_phase,'ylim');
	y_pos=(y_lim_pha(1)+y_lim_pha(2))/2;
	text('string','Phase [°]',...     % y-Achsen-Beschriftung
	        'tag','phase_text',...
	        'erasemode','normal',...
	        'color',[0 0 0],...          % Farbe = Schwarz
	        'Rotation',90,...
	        'horizontalalignment','center',...% Textausrichtung = zentriert
	        'position',[-0.05 y_pos]);
	text('string','f/fa',...     % Beschriftung x-Achse
	        'erasemode','normal',...
	        'color',[0 0 0],...          % Farbe = Schwarz
	        'tag','f_fa',...
	        'horizontalalignment','center',...% Textausrichtung = zentriert
	        'position',[0.52 -280]);
	text('string','-- rechnergenau',...     % Beschriftung Legende
	        'erasemode','normal',...
	        'FontSize',8,...
	        'color',[1 0 0],...          % Farbe = rot
	        'tag','rech_text',...
	        'horizontalalignment','center',...% Textausrichtung = zentriert
	        'position',[-0.06 -280]);
	text('string','-- quantisiert',...     % Beschriftung Legende
	        'erasemode','normal',...
	        'FontSize',8,...
	        'color',[0 0 0],...          % Farbe = Schwarz
	        'tag','quant_text',...
	        'horizontalalignment','center',...% Textausrichtung = zentriert
	        'position',[0.03 -280]);

	axes(h_axes_amp);
	pause(0.01);
	y_pos=(y_lim(1)+y_lim(2))/2;
	if (wert_linlog == 1)
		string_amplitude='Amplitude';	% lineare Amplitude
	else
		string_amplitude='Amplitude [dB]';	% lineare Amplitude
	end;
	text('string',string_amplitude,...      % Überschrift für Axes-Objekt
	        'tag','amplitude_text',...
	        'erasemode','normal',...
	        'color',[0 0 0],...             % Farbe = Schwarz
	        'Rotation',90,...
	        'horizontalalignment','center',...% Textausrichtung = zentriert
	        'position',[-0.05 y_pos]);
	axes(h_axes_amp);                 % Aktuelles axes Objekt 
	pause(0.01);
	messen('marker_aktualisieren');    % evtl. Marker bei Aktualisierung neu setzen


 if (hoechste ~=0)	% Überläufe angezeigt
	info_str= ('Bei der Filterung mit Festkommaquantisierung sind Überläufe aufgetreten! ');
	taste=fenster(info_str,'Info',2,1);	% Informations-Fenster mit Meldung öffnen
 end;

end;	% Amplituden-/Phasengang

%----------Amplituden-/Phasengang beenden
if strcmp(command_str,'ampliphase_beenden')
	messen;						% Aufruf, um Messen-Objekte zu löschen
	h_ende= findobj('string','Filtersysteme beenden');	% Beenden Pushbutton für enable-Objekte
	h_enable= get (h_ende,'UserData');			% vormals aktive Pushbuttons
	set (h_enable,'enable','on');				% aktiv setzen
 	h_axes_amp = findobj('tag',...    % Finde axes Objekt 'bode_amplitude'
	        'bode_amplitude');
	delete(h_axes_amp);               % und entferne es
	h_axes_phase = findobj('tag',...  % Finde axes Objekt 'bode_phase'
	        'bode_phase');
	delete(h_axes_phase);             % und entferne es
	h_zurueck=findobj('tag','filtsys','string','Zurück');	% Pushbutton Zurück finden
	set (h_zurueck,'enable','off');			% inaktiv setzen
	h_axes=findobj('tag','filtsys_axes');			% Axes-Objekt mit Blockschaltbild
	h_child= get (h_axes,'children');			% Objekte im Blockschaltbild
	set (h_child,'visible','on');				% sichtbar setzen
	h_slider=findobj('tag','filtsys_sliderx');		% Slider im Blockschaltbild
	set (h_slider,'visible','on');				% sichtbar setzen
	h_hilfe=findobj('tag','filtsys','string','Hilfe');			% Pushbutton Hilfe
	set (h_hilfe,'callback','!winhelp struktur\filtsys.hlp');	% Hilfeaufruf aktualisieren
end;	% Amplituden-/Phasengang beenden

%-------------Slider Moved------------------------
if strcmp(command_str,'moved_x')
	Slider=findobj('tag','filtsys_sliderx');		% Handle auf Slider
	value_new=get(Slider,'Value');		% neuen Wert lesen
	value_old=get(Slider,'UserData');		% alten Wert lesen
	diff=value_new-value_old;		% Differenz bilden
	h_letzte=findobj('string','Teilfilter laden','tag','filtsys');	% Pushbutton Teilfilter laden finden
	Nummer= get(h_letzte,'userdata');	% Nummer des letzten Teilfilters
	Axes_Breite= 20 * Nummer + 25;	% Gesamter Darstellungsbereich im Axes-Objekt
	Slider_Step=Axes_Breite-100;	% Slider muß den gesamten Darstellungsbereich minus des dargestellten überfahren können
	if  Slider_Step<0			% Gesamter Bereich kann dargestellt werden
		Slider_Step=0;
	end;
	h_axes=findobj('tag','filtsys_axes');	% Axes-Objekt
	x_lim= get (h_axes,'XLim');		% angezeigter Bereich
	x_lim=x_lim+(Slider_Step/10*diff);	% Neuen Bereich berechnen
	set(h_axes,'XLim',x_lim);		% neuen Bereich einstellen
	set (Slider,'UserData',value_new);	% neuen Sliderwert merken
end;	% Slider Moved

%-----------Close-------------------
if strcmp(command_str,'close')
	h_referenz= findobj('tag','messen','string','Referenzkurven'); 	% Checkbox Refrenzkurven
	set (h_referenz,'callback','');				% Callback zurücksetzen
	h_pop_fft= findobj('tag','FFT');		% Finde Objekt Popupmenü FFT-Länge
	set (h_pop_fft,'callback','');					% Callback zurücksetzen
	h_dB_Text= findobj('tag','messen','style','popupmenu');	% Popup-Menü Amlitude lin/log
	set (h_dB_Text,'callback','');				% Callback zurücksetzen
	h_marker = findobj ('tag','messen','string','Marker'); 	% Objekt Checkbox Marker
	existiert = get(h_marker,'visible');	% Prüfen, ob aktiv
	if strcmp(existiert,'on')		% nicht aktiv
		messen;			% Aufruf, um Messen-Objekte zu löschen
	end;
	h_enable=findobj('tag','filtsys','string','enable');	% Pushbutton Enable
	h_visible=get(h_enable,'userdata');	% vormals aktive UIControl-Objekte laden
	h_filtsys=findobj('tag','filtsys');	% Objekte in Filerbank
	delete (h_filtsys);		% Objekte löschen
	h_axes_amp = findobj('tag',...    % Finde axes Objekt 'bode_amplitude'
	        'bode_amplitude');
	delete(h_axes_amp);               % und entferne es
	h_axes_phase = findobj('tag',...  % Finde axes Objekt 'bode_phase'
	        'bode_phase');
	delete(h_axes_phase);             % und entferne es
	h_axes=findobj('tag','filtsys_axes');	% Axes-Objekt für Blockschaltbild
	delete (h_axes);			% Axes löschen
	h_slider=findobj('tag','filtsys_sliderx');	% slider finden
	delete (h_slider);			% slider löschen
	set (h_visible,'visible','on');		% sichtbar setzen
	h_axes_h=findobj('tag','axes_h(z)');	% Objekte für Überschrift in Kaskaden- und Parallelform
	set (h_axes_h,'visible','on');		% wenn vorhanden, sichtbar setzen
	h_struktur= findobj('tag','axes');	% Axes-Objekt mit der Filterstruktur
	h_children= get(h_struktur,'children');	% Objekte in der Struktur
	set (h_children,'visible','on');	% Objekte sichtbar setzen
	netzwerk;			% Netzwerk neu aufbauen
end; % Close
