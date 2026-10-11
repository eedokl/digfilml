function impulant(command_str)
% IMPULANT
%
% Die Funktion stellt das Bodediagramm fuer die ausgewaehlte
% Position dar.
% Funktionsaufruf
%   Betaetigen der Maustaste auf der Verbindungslinie zwischen zwei Kaskaden
%
%
% ------------------- Funktions Header --------------------------------------
% Autor:               Jörg Rose / Roman Ußkurat
% Erstellungsdatum:    7-10/97
% Version:             MATLAB Version 5 / Student Edition
% 
% Betreuer: Prof. Dr.-Ing. Stark
%

% ------------------------- Globale Variablen -------------------------------
global a b



% -------------- Initialisierung --------------------------------------------
if (~strcmp(command_str,'existiert'))
	h_objekt = gco;                     % Handle des Objektes, das mit der Maus
        	                            % angeklickt wurde
	kaskadennummer = get...
	       (h_objekt,'userdata');       % Kaskadennummer aus userdata
end;
if nargin == 0                      % wenn kein Parameter uebergeben
  command_str = 'init';             % setze command_str = init
end                                 % Ende von nargin == 0
h_ueber= findobj('tag','quant_uebernehmen');		% Pushbutton Übernehmen
set (h_ueber,'callback','impulant(''existiert'');');	% Callback: Impulant aktualisieren
h_fft= findobj('tag','FFT');				% PopUpMenü FFT-Länge
set (h_fft,'callback','impulant(''existiert'');');	% Callback: Impulant aktualisieren
h_dB_Text= findobj('tag','messen','style','popupmenu');	% Popup-Menü Amlitude lin/log
set (h_dB_Text,'callback','impulant(''existiert'');');	% Callback: Impulant aktualisieren
h_referenz= findobj('tag','messen','string','Referenzkurven');	% Checkbox Referenzkurven
set (h_referenz,'callback','impulant(''existiert'');');	% Callback: Impulant aktualisieren
h_hilfe=findobj('tag','hilfe');	% Pushbutton Hilfe
set(h_hilfe, 'callback','!winhelp struktur\ampliph.hlp');	% Hilfe aktualisieren


% ----------- Quantisierungsdaten und Filtermatrix ermitteln ------------
h_popup= findobj('tag','struktur');	% Popup-Menü Struktur
f_struktur=get (h_popup,'value');	% Wert lesen
[matrix,rech,spei,quantisierung,arithmetik,sort_folge]= quamat (f_struktur);
if (f_struktur==4)		% Kaskade
	sos = matrix(2:size(matrix,1),:); % sos aus Koeffizienten-Matrix lesen
end;
if (f_struktur==5)		% normierte Kaskade
	sos = matrix(2:size(matrix,1),2:7);   % sos aus Koeffizienten-Matrix lesen
	norm_faktor=matrix(2:size(matrix,1),1); % Normierungs-Koeffizienten lesen
end;


% ------------- existiert----------------------------------------------------
if (strcmp(command_str,'existiert'))
	h_quit= findobj('tag','quit');	% Pushbutton quit
	kaskadennummer = get(h_quit,'userdata');  % Nummer aus UserData
	if (f_struktur==4)			% Strukturwert auswerten
		command_str='kaskade';	% Kommandostring dementsprechend setzen
	end;
	if (f_struktur==5)
		command_str='kaskade_norm';
	end;
end;

% ------------------ kaskade oder kaskade_norm ------------------------------
if ((strcmp(command_str,'kaskade'))|(strcmp(command_str,'kaskade_norm')))
  h_tauschen = findobj...           % Finde Pushbutton 'tauschen'
    ('tag','tauschen');
  set(h_tauschen,...                % Setze Pushbutton inaktiv
    'enable','off');
  h_skalieren= findobj('tag','Skalierung');	% Checkbox Skalierung finden
  set (h_skalieren,'enable','off');	% inaktiv setzen
  h_filter=findobj('tag','filterung');% Finde Pushbutton 'filterung' 
  set(h_filter,'enable','off');     % Setze Pushbutton inaktiv
  h_push=findobj('tag','generator_mat');% Finde Pushbutton 'FunktionsGen' 
  set(h_push,'enable','off');     % Setze Pushbutton inaktiv
  h_push=findobj('tag','p_n_dia');% Finde Pushbutton 'PN-Diagramm' 
  set(h_push,'enable','off');     % Setze Pushbutton inaktiv
  h_push=findobj('tag','filterbank');% Finde Pushbutton 'Filterbank' 
  set(h_push,'enable','off');     % Setze Pushbutton inaktiv
  h_push=findobj('tag','laden');% Finde Pushbutton 'Laden' 
  set(h_push,'enable','off');     % Setze Pushbutton inaktiv 
  h_push=findobj('tag','speichern');% Finde Pushbutton 'Speichern' 
  set(h_push,'enable','off');     % Setze Pushbutton inaktiv
  h_slider=findobj('tag','slider'); % Finde waagerechten slider
  set(h_slider,'enable','off',...   % Setze Slider unsichtbar und
        'visible','off');           % unbedienbar
  h_axes = get(gcf,'children');     % Ermittle Handles der axes Objekte
  axes_help = 0;                    % Setze axes_help = 0
  axes_exists = 0;                  % Setze axes_exists = 0
  for handle = h_axes'              % lokale Variable handle wird mit den
                                    % Werten des h_axes Vektors beaufschlagt
    axes_help = strcmp(get(handle,'tag'),...
                     'bode_amplitude');
    if axes_help == 1               % Wenn ein Objekt die Kennzeichnung
      axes_exists = 1;              % 'bode_amplitude' aufweist, setze
    end                             % axes_exists aus 1
  end                               % Ende von for handle = h_axes'
 
  h_axes_amp = findobj('tag',...    % Suche axes Objekt 'bode_amplitude'
        'bode_amplitude');
  delete(h_axes_amp);               % Entferne es
  h_axes_phase = findobj('tag',...  % Suche axes Objekt 'bode_phase'
        'bode_phase');
  delete(h_axes_phase);             % Entferne es

  h_amplitude_text = findobj...     % Suche Textobjekt 'amplitude_text'
        ('tag','amplitude_text');

  h_struktur = findobj('tag','axes');% Finde axes Objekt, in dem Netzwerk
  h_children = get(h_struktur,...   % dargestellt und ermittle die Handles
        'children');                % der Netzwerkkomponenten
  for h_objekt = h_children'
    set(h_objekt,'visible','off');  % Setze Netzwerkkomponenten unsichtbar
  end
  h_axes_h=findobj('tag','axes_h(z)');	% Objekte für Überschrift in Kaskaden- und Parallelform
  set (h_axes_h,'visible','off');		% wenn vorhanden, unsichtbar setzen
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
        'nextplot','add');          % Aeltere Plots bleiben erhalten

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
        'nextplot','add');          % Aeltere Plots bleiben erhalten

  h_figure = findobj('tag',...      % Ermittle Handle der Figur Netzwerk
        'netzwerk');

  %--------------------------------------------------------------------------
  % Dieser Block wird nur beim jeweils ersten Funktionsaufruf ausgefuehrt
  if ~axes_exists                   % Wenn erster Funktionsaufruf
    old_name = get(h_figure,'name');% Ermittle Namen der Figur
    set(h_figure,...                % Sichere Namen des dargestellten
        'userdata',old_name);       % Netzwerkes in userdata der Figur
    h_systemantwort = findobj...    % Handle fuer Pushbutton Systemantwort
       ('tag','antwort');
    set(h_systemantwort,...
        'enable','off');            % Sperre Systemantwort
    h_quit = findobj('tag','quit'); % Handle fuer Pushbutton 'quit'
    set(h_quit,'enable','on',...    % Setze Pushbutton aktiv
        'userdata',kaskadennummer); % Kaskadennummer in userdata
    if strcmp(command_str,'kaskade')% Wenn command_str = kaskade
      set(h_quit,'callback',...     % Setze callback = impulant('kaskade')
        'impulant(''kaskade'');');
    end
    if strcmp(command_str,'kaskade_norm')% Wenn command_str = kaskade_norm
      set(h_quit,'callback',...     % Setze callback = 
        'impulant(''kaskade_norm'');');% impulant('kaskade_norm')
    end
  end                               % Ende von ~axes_exists

  string = ['Amplituden-/Phasengang bis Teilsystem ' num2str(kaskadennummer) ':'];
                                      % Konstruiere Ueberschrift
  set(h_figure,...                    % Uebergebe Ueberschrift an Figure
          'name',string);             % mit dem Handle h_figur
 

  
% ********** fft_laenge aus Pull-Down lesen ********

  h_pop_fft= findobj('tag','FFT');    % Finde Objekt Popupmenü FFT-Länge
  fftvalue= get (h_pop_fft,'value');  % Wert des Popupmenüs lesen
  valuematrix=[16 32 64 128 256 512 1024];	% Mögliche FFT-Längen
  fft_laenge = valuematrix(fftvalue);		% FFT laenge
  if arithmetik==2			% Festpunktarithmetik
	h_einheits=findobj('tag','festkomma','userdata',1);	% Handle auf Editierfeld Einheitsimpuls
 	wert_str=get(h_einheits,'string');		% Wert lesen
	bitspei=spei(3);				% Anzahl der Bit für Speicher feststellen
	x=[ str2num(wert_str)-2^(-bitspei+1) zeros(1,fft_laenge-1)];   % angepaßter Einheitsimpuls
  else
  	x = [1 zeros(1,fft_laenge-1)];    % Eingangsfolge = Einheitsimpuls
  end;
  if strcmp(command_str,'kaskade')
	sos=sos(1:kaskadennummer+1,:);
  end;
  if strcmp(command_str,'kaskade_norm')
	sos=sos(1:kaskadennummer+1,:);
	norm_faktor=norm_faktor(1:kaskadennummer+1);
  end;

  [z,p,k] = tf2zp(b,a);                 % Unquantisierte sos-Matrix ermitteln
  sos_ref= zp2sos (z,p,k);
  sos_ref= sos_ref(sort_folge,:);             % Referenz-sos wie quantisierte Teilsysteme ordnen
	h_skal= findobj('tag','Skalierung');		% Checkbox Skalierung
	skal_wert= get (h_skal,'value');
	if skal_wert ==1				% neues Skalieren der Teilsysteme
		Hconvb=[1];				
		Hconva=[1];
		for Reihe=1:size(sos_ref,1)		% jede Reihe der SOS
			Hb= sos_ref(Reihe,1:3);		% mit den vorhergehenden Teilsystemen
			Ha= sos_ref(Reihe,4:6);		% ausmultiplizieren und das Betragsmaximum der
			Htestb= conv (Hb,Hconvb);	% Übertragungsfunktion bestimmen
			Htesta= conv (Ha,Hconva);		
			Hmax=max(abs(freqz(Htestb,Htesta)));
			sos_ref (Reihe,1:3) = sos_ref (Reihe,1:3)./Hmax;	% Damit skalieren
			Hconvb = conv (Hconvb,sos_ref(Reihe,1:3));
			Hconva = Htesta;
		end;

	end;
  sos_ref= sos_ref(1:size(sos,1),:);    % und auf die Reihenanzahl der quantisierten sos abschneiden
  [bhilf,ahilf]= sos2tf(sos_ref);       % b,a-Koeffizienten für Referenzfilter berechnen

  h_check_quant = findobj('tag',...   % Check Box 'Quantisierung'
        'quantisierung'); 
  quantisierung = get(h_check_quant,'value'); % 0: keine Quantisierung
                                              % 1: Quantisierung
  hoechste=0;	% zeigt nach einer festkommaquantisierten Filterung an, ob Überläufe stattgefunden haben

   if (quantisierung == 1)             % Wenn Quantisierung an
    h_ui_text = uicontrol(gcf,...     % Textfeld
        'style','Text',...            
        'units','normalized',...
        'backgroundcolor','y',...
        'string','Berechnung läuft',...
        'position',[0.2 0 0.8 0.04]);
     drawnow;
    if (arithmetik == 1)            % Wenn Gleitkommaarithmetik
     if (strcmp(command_str,'kaskade'))
        y=gfilkas(sos,2,x,rech,spei);      % Berechne Kaskade
     else
        y=gfilkasn(sos,norm_faktor',2,x,rech,spei);    % Berechne normierte Kaskade
     end;
    end                             % Ende Gleitkommaarithmetik

    if (arithmetik == 2)            % Festkommaarithmetik
  
     if (strcmp(command_str,'kaskade'))
        y=ffilkas(sos,2,x,rech,spei,hoechste);      % Berechne Kaskade
     else
        y=ffilkasn(sos,norm_faktor',2,x,rech,spei,hoechste); % Berechne normierte Kaskade
     end;
    end                             % Ende Festkommaarithmetik
    delete(h_ui_text);              % Entferne Textobjekt 'Berechnung laeuft'
  end                               % Ende Quantisierung

  H2=freqz(bhilf,ahilf,fft_laenge/2);         % Nichtquantisierte Referenz
  H2=[H2.' zeros(1,fft_laenge/2)];            % Fouriertransformation nicht quantisiert
  x_koo=[0:fft_laenge/2-1]./fft_laenge;  % x-Koordinaten
  axes(h_axes_amp);                 % Axes Objekt fuer Amplitude
  h_linlog= findobj('tag','messen','style','popupmenu');	% Popup-Menü Amplitude lin/log
  wert_linlog = get(h_linlog,'value');		% Wert feststellen
  struktur('dB_Text');
  if (quantisierung == 1)	% Quantisierung eingeschaltet
	H=fft(y,fft_laenge);              % Fouriertransformation quantisiert
	if (wert_linlog==1)
	 	plot(x_koo,abs (H (1:length(H)/2)),'k'); % Zeichne Amplitude quantisiert
	else
	  	plot(x_koo,log10(abs (H (1:length(H)/2)))*20,'k'); % Zeichne Amplitude [dB] quantisiert
	end;
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
  y_lim=get(h_axes_amp,'ylim');     % Senkrechte Begrenzung Amplitudengang
  maximum = y_lim(2);               % Maximum der Amplitude
  hoehe = maximum + (maximum/10);   % Senkrechte Position der Ueberschrift
  pause(0.01);
  axes(h_axes_phase);               % Axes Objekt fuer Phase
  if (quantisierung == 1)	% Quantisierung eingeschaltet
  	winkel = (angle(H).*180./pi);     % Umrechnung in Grad
  	plot(x_koo,(winkel(1:length(H)/2)),'k');% Zeichne Phase quantisiert
  end;
  if (referenz ==1)	% Referenzkurven sollen erscheinen
	winkel2 = (angle(H2).*180./pi);   % Umrechnung in Grad
	plot(x_koo,(winkel2(1:length(H2)/2)),'r');% Zeichne Phase Referenz
  end;
  y_lim_pha=get(h_axes_phase,'ylim');
  y_pos=(y_lim_pha(1)+y_lim_pha(2))/2;
  text('string','Phase [°]',...  % y-Achsen-Beschriftung
        'tag','phase_text',...
        'erasemode','normal',...
        'color',[0 0 0],...         % Farbe = Schwarz
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
  text('string',string_amplitude,...% Achsenbeschriftung y-Achse
        'tag','amplitude_text',...
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
	'Rotation',90,...
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[-0.05 y_pos]);
  messen('marker_aktualisieren');    % evtl. vorhanden Marker bei Aktualisierung neu setzen
  if ~axes_exists                   % Wenn erstes Bodediagramm
    h_popup = findobj('tag','struktur');% Finde Handle Popup Struktur
    old_value = get(h_popup,'value');% Sichere alte Netzwerkstruktur 
    set(h_popup,'enable','off');    % Aendere Callback in Popup 'struktur'
    h_quit = findobj('tag','quit'); % Finde Pushbutton 'quit'
    set(h_quit,...
      'enable','on',...             % Setze Pushbutton aktiv
      'callback','impulant(''closed'');');% Setze Callback
    messen;		% Aufruf von messen.m 
  end
 if (hoechste ~=0)	% Überläufe angezeigt
	info_str= ('Bei der Filterung mit Festkommaquantisierung sind Überläufe aufgetreten! Verkleinern Sie falls erforderlich den Wert des Einheitsimpulses.');
	taste=fenster(info_str,'Info',2,1);	% Informations-Fenster mit Meldung öffnen
  end;
end

% -------------------- closed -----------------------------------------------
if strcmp(command_str,'closed')     % Wenn command_str = closed
  messen;		% Aufruf von messen.m, um Objekte zu löschen
  h_quit = findobj('tag','quit');   % Finde Pushbutton 'quit'
  set(h_quit,...
      'enable','off',...            % Setze Pushbutton inaktiv
      'callback','');               % Ruecksetzen Callback
  h_axes_amp = findobj('tag',...    % Finde axes Objekt 'bode_amplitude'
        'bode_amplitude');
  delete(h_axes_amp);               % und entferne es
  h_axes_phase = findobj('tag',...  % Finde axes Objekt 'bode_phase'
        'bode_phase');
  delete(h_axes_phase);             % und entferne es
  h_struktur = findobj('tag','axes');% Handle axes fuer Netzwerkstruktur
  h_children = get(h_struktur,...   % Handles der Netzwerkkomponenten
        'children');
  for h_objekt = h_children'
    set(h_objekt,'visible','on');   % Setze Netzwerkkomponenten sichtbar
  end
  h_axes_h=findobj('tag','axes_h(z)');	% Objekte für Überschrift in Kaskaden- und Parallelform
  set (h_axes_h,'visible','on');		% wenn vorhanden, sichtbar setzen
  h_axes_axis=findobj('tag','axes_h(z)','type','axes');	% Diagramm suchen
  set (h_axes_axis,'visible','off');
  h_ueber= findobj('tag','quant_uebernehmen');	% Pushbutton Übernehmen
  set (h_ueber,'callback','netzwerk');	% Callback: Netzwerk aktualisieren
  h_fft= findobj('tag','FFT');		% PopUpMenü FFT-Länge
  set (h_fft,'callback','');		% Callback löschen
  h_dB_Text= findobj('tag','messen','style','popupmenu'); % Popup-Menü Amlitude lin/log
  set (h_dB_Text,'callback','');	% Callback: löschen
  old_value = get(h_quit,'userdata');% Lies alte Netzwerkstruktur
  h_slider = findobj('tag','slider');
  set(h_slider,'enable','on',...    % Setze Slider sichtbar und
        'visible','on');            % bedienbar
  h_hilfe=findobj('tag','hilfe');	% Pushbutton Hilfe
  set(h_hilfe, 'callback','!winhelp struktur\struktur.hlp');	% Hilfe aktualisieren
  h_popup = findobj('tag','struktur');% Finde Handle Popup Struktur
  set(h_popup,'enable','on');
  h_figure = findobj('tag','netzwerk');% Handle der Fifur 'netzwerk'
  old_name = get(h_figure,'userdata');% Alter Name aus userdata
  set(h_figure,'name',old_name);     % Setze alten Namen
  h_systemantwort = findobj('tag',...% Handle fuer Pushbutton Systemantwort
        'antwort');
  set(h_systemantwort,'enable','on');% Ermoegliche Systemantwort
  h_filter=findobj('tag','filterung');% Finde Pushbutton 'filterung' 
  set(h_filter,'enable','on');       % Setze Pushbutton aktiv
  h_push=findobj('tag','generator_mat');% Finde Pushbutton 'FunktionsGen' 
  set(h_push,'enable','on');     % Setze Pushbutton aktiv
  h_push=findobj('tag','p_n_dia');% Finde Pushbutton 'PN-Diagramm' 
  set(h_push,'enable','on');     % Setze Pushbutton aktiv
  h_push=findobj('tag','filterbank');% Finde Pushbutton 'Filterbank' 
  set(h_push,'enable','on');     % Setze Pushbutton aktiv
 h_push=findobj('tag','laden');% Finde Pushbutton 'Laden' 
  set(h_push,'enable','on');     % Setze Pushbutton aktiv 
 h_push=findobj('tag','speichern');% Finde Pushbutton 'Speichern' 
  set(h_push,'enable','on');     % Setze Pushbutton aktiv
  h_tauschen = findobj...            % Finde Pushbutton 'tauschen'
    ('tag','tauschen');
  set(h_tauschen,...                 % Setze Pushbutton aktiv
    'enable','on');
  h_skalieren= findobj('tag','Skalierung');	% Checkbox Skalierung finden
  set (h_skalieren,'enable','on');	% aktiv setzen
end                                  % Ende von command_str = closed
