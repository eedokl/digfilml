function fftrans(command_str)
% FFTRANS
% Die Funktion fftrans stellt den Amplitudengang und den Phasengang der
% Impulsantwort y(n) 
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

if nargin==0                        % Wenn keine Parameterübergabe
    command_str = 'init';           % Setze command_str = init
end;

if strcmp(command_str,'init')
   
    h_ueber=findobj('tag','quant_uebernehmen');	% Pushbutton Übernehmen
    set (h_ueber,'callback','fftrans');	% neuer Callback: fftrans aktualisieren 
    h_fft= findobj('tag','FFT');	% Popup-Menü FFT-Länge
    set (h_fft,'callback','fftrans'); 	% Callback: fftrans aktualisieren
    h_dB_Text= findobj('tag','messen','style','popupmenu');	% Popup-Menü Amlitude lin/log
    set (h_dB_Text,'callback','fftrans'); % Callback: fftrans aktualisieren
    h_referenz= findobj('tag','messen','string','Referenzkurven'); % Checkbox Refrenzkurven
    set (h_referenz,'callback','fftrans'); % Callback: fftrans aktualisieren
   h_hilfe=findobj('tag','hilfe');	% Pushbutton Hilfe
   set(h_hilfe, 'callback','!winhelp struktur\ampliph.hlp');	% Hilfe aktualisieren
    h_systemantwort = findobj...        % Finde Pushbutton Systemantwort
            ('tag','antwort');
    matrix = get...                     % Lies Koeffizientenmatrix aus userdata
        (h_systemantwort,'userdata');
    struktur_alt = matrix(1,1);
    h_pop_struktur = findobj...         % Finde Popup-Menü 'struktur'
        ('tag','struktur');
    f_struktur = get...                   % Lies Struktur
        (h_pop_struktur,'value');

% ----------------------- IIR oder FIR --------------------------------------
    filter_check = a(2:length(a));
    if any(filter_check)                % Prüfe, ob IIR- oder FIR-Filter
        filter_type = 'IIR';
    else
        filter_type = 'FIR';
    end
 h_popup=findobj('tag','struktur');% Finde Handle Popup Struktur
 if ((f_struktur == 6) | (f_struktur ==7)) & strcmp(filter_type,'FIR') % Wenn Struktur = Lattice und Filter = FIR
	taste=fenster('Diese Struktur ist nur bei IIR-Filtern möglich!','Info',2,1);
	command_str = '';
	old_value = get...
	 (h_popup,'userdata');           % Ausgewaehlte Struktur
  set(h_popup,'value',old_value);   % Ruecksetzen auf alten Wert
else
	set(h_popup,'userdata',f_struktur); % Sichern in userdata
end

end;        % of command_str == 'init'
 

% ------------- neue Koeffizienten-Matrix aufbauen ----------------------
if strcmp(command_str,'init')  % wenn immer noch 'init'

	[matrix,rech,spei,quantisierung,arithmetik,sort_folge]= quamat (f_struktur);

end;        % neue Koeffizienten-Matrix aufbauen

% -------------- Initialisierung --------------------------------------------
if strcmp(command_str,'init')       % Wenn command_str = init
  h_tauschen = findobj...           % Finde Pushbutton 'tauschen'
    ('tag','tauschen');
  set(h_tauschen,...                % Setze Pushbutton inaktiv
    'enable','off');
  h_skalieren= findobj('tag','Skalierung');	% Checkbox Skalierung finden
  set (h_skalieren,'enable','off');	% inaktiv setzen
  h_slider=findobj('tag','slider'); % Finde waagerechten slider
  set(h_slider,'enable','off',...   % Setze Slider unsichtbar und
        'visible','off');           % unbedienbar
  h_slidery=findobj('tag','slidery');% Finde senkrechten slider 
  set(h_slidery,'enable','off',...  % Setze Slider unsichtbar und
        'visible','off');           % unbedienbar
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
  h_axes = findobj('parent',gcf);   % Ermittle handles der exestierenden Figuren
   axes_exists = 0;                % Setze fig_exists = 0
  handle = findobj('tag','bode_amplitude'); % Axis-Objekt suchen
  if ~isempty(handle)             % Wenn vorhanden
      axes_exists = 1;            % 'bode_amplitude' 
  end;
 
  h_axes_amp = findobj('tag',...  % Suche axes Objekt 'bode_amplitude'
        'bode_amplitude');
  delete(h_axes_amp);             % Entferne es
  h_axes_phase = findobj('tag',...% Suche axes Objekt 'bode_phase'
        'bode_phase');
  delete(h_axes_phase);           % Entferne es

  h_amplitude_text = findobj...   % Suche Textobjekt 'amplitude_text'
        ('tag','amplitude_text');

  h_pop_fft= findobj('tag','FFT');    % Finde Objekt Popupmenü FFT-Länge
  fftvalue= get (h_pop_fft,'value');  % Wert des Popupmenüs lesen
  valuematrix=[16 32 64 128 256 512 1024];   % Mögliche FFT-Längen
  fft_laenge = valuematrix(fftvalue);        % FFT länge
if arithmetik==2			% Festpunktarithmetik
	h_einheits=findobj('tag','festkomma','userdata',1);	% Handle auf Editierfeld Einheitsimpuls
 	wert_str=get(h_einheits,'string');		% Wert lesen
	bitspei=spei(3);				% Bit für Speicher feststellen
	x=[ str2num(wert_str)-2^(-bitspei+1) zeros(1,fft_laenge-1)];   % angepaßter Einheitsimpuls 
else
  x = [1 zeros(1,fft_laenge-1)];    % Eingangsfolge = Einheitsimpuls
end;
  h_struktur = findobj('tag','axes');% Finde axes Objekt, in dem Netzwerk
  h_children = findobj('parent',h_struktur);   % dargestellt und ermittle die Handles
                  % der Netzwerkkomponenten
  set (h_children,'visible','off'); % Setze Netzwerkkomponenten unsichtbar
  
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

  h_figure = findobj('tag',...      % Ermittle Handle der Figur Netzwerk
        'netzwerk');
hoechste=0;
 % zeigt an, ob ein Überlauf stattgefunden hat,
 % wenn Zahl ungleich Null zurückgegeben wird

  if (quantisierung == 1)           % Wenn Quantisierung an
    h_ui_text = uicontrol(gcf,...   % Textfeld
        'style','Text',...            
        'units','normalized',...
        'backgroundcolor','y',...
        'string','Berechnung läuft',...
        'position',[0.2 0 0.8 0.04]);
     drawnow;
     if (arithmetik == 1)            % Gleitkommaarithmetik
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
        if (isempty(Dir_term))                      % Wenn leere Menge, eine Null
            Dir_term=0;
        end;
        y=gfilpar(sos,Dir_term,2,x,rech,spei);     % Gleitkomma Parallelform
      end
    end                             % Ende von Gleitkommaarithmetik

    if (arithmetik == 2)            % Festkommaarithmetik

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
        if (isempty(Dir_term))                      % Wenn leere Menge, eine Null
            Dir_term=0;
        end;
        y=ffilpar(sos,Dir_term,2,x,rech,spei,hoechste);  % Festkomma Parallelform
      end
    end                             % Ende von Festkommaarithmetik
  
    delete(h_ui_text);              % Entferne Textfeld 'Berechnung läuft'
  
  end                               % Ende von Quantisierung an

  % ----- Überschrift für Systemantwort -----------------------------------
  h_pop_struktur = findobj('tag','struktur');
  f_struktur = get(h_pop_struktur,'value');
  if (f_struktur == 1)
    name_str='nichtkanonischer Direktform';
  end
  if (f_struktur == 2)
    name_str='1. kanonischer Form';
  end
  if (f_struktur == 3)
    name_str='2. kanonischer Form';
  end
  if (f_struktur == 4)
    name_str='3. kanonischer Form';
  end
  if (f_struktur == 5)
    name_str='3. kanonischer Form, b0 normiert';
  end
  if (f_struktur == 6)
    name_str='Lattice-Ladder Struktur';
  end
  if (f_struktur == 7)
    name_str='Parallelform';
  end
  name_str=['Amplituden-/Phasengang des ' filter_type '-Filters in ' name_str];
 set(h_figure,'name',name_str);
  set (h_pop_struktur,'userdata',f_struktur);         % aktuelle Struktur merken
  

  H2=freqz(b,a,fft_laenge/2);                  % Nichtquantisierte Referenz
  H2=[H2.' zeros(1,fft_laenge/2)];
  x_koo=[0:fft_laenge/2-1]./fft_laenge;  % x-Koordinaten
  axes(h_axes_amp);                  % Axes Objekt für Amplitude
  h_linlog= findobj('tag','messen','style','popupmenu');	% Popup-Menü Amplitude lin/log
  wert_linlog = get(h_linlog,'value');		% Wert feststellen
  struktur('dB_Text');
  if (quantisierung == 1)	% Quantisierung eingeschaltet
	H=fft(y,fft_laenge);
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
  pause(0.01);
  axes(h_axes_phase);                % Axes Objekt für Phase
  if (quantisierung == 1)	% Quantisierung eingeschaltet
  	winkel = (angle(H).*180./pi);      % Umrechnung in Grad
  	plot (x_koo,(winkel (1:length(H)/2)) ,'k');% Zeichne Phase quantisiert
  end;
 if (referenz ==1)	% Referenzkurven sollen erscheinen
	winkel2 = (angle(H2).*180./pi);    % Umrechnung in Grad
	plot (x_koo,(winkel2 (1:length(H2)/2)) ,'r');% Zeichne Phase Referenz
  end;
  y_lim=get(h_axes_amp,'ylim');      % Senkrechte Begrenzung Amplitudengang
  maximum = y_lim(2);                % Maximum der Amplitude
  hoehe = maximum + (maximum/10);    % Senkrechte Position der Überschrift
  if ~axes_exists                    % Wenn erstes Bodediagramm
    h_popup = findobj('tag','struktur');% Finde Handle Popup Struktur
    old_value = get(h_popup,'value');% Lies alte Netzwerkstruktur 
    set(h_popup,'callback','fftrans;');% Ändere Callback in Popup 'struktur'
    h_quit = findobj('tag','quit');  % Finde Pushbutton 'quit'
    set(h_quit,...
      'enable','on',...              % Setze Pushbutton aktiv
      'callback','fftrans(''closed'');'); % Setze Callback
    messen;		% Aufruf von messen.m
  end
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
	info_str=('Bei der Filterung mit Festkommaquantisierung sind Überläufe aufgetreten! Verkleinern Sie falls erforderlich den Wert des Einheitsimpulses.');
	taste=fenster(info_str,'Info',2,1);	% Informations-Fenster mit Meldung öffnen
 end;

end                                 % Ende von command_str = init

%-------------- message -----------------------------------------------------
if strcmp(command_str,'message')      % Wenn Struktur=lattice und Filter=FIR
 	
end                                   % Ende von message



% ------------------ closed -------------------------------------------------
if strcmp(command_str,'closed')     % Wenn command_str = closed
  messen;		% Aufruf von messen.m, um Objekte zu löschen
  h_quit = findobj('tag','quit');   % Finde Pushbutton 'quit'
  set(h_quit,...
      'enable','off',...            % Setze Pushbutton inaktiv
      'callback','');               % Rücksetzen Callback
  h_ueber=findobj('tag','quant_uebernehmen');	% Pushbutton Übernehmen
  set (h_ueber,'callback','netzwerk');	% neuer Callback: Netzwerk aktualisieren 
  h_fft= findobj('tag','FFT');		% Popup-Menü FFT-Länge
  set (h_fft,'callback',''); 		% Callack löschen
  h_dB_Text= findobj('tag','messen','style','popupmenu'); % Popup-Menü Amlitude lin/log
  set (h_dB_Text,'callback','');	% Callback zurücksetzen
  h_axes_amp = findobj('tag',...    % Finde axes Objekt 'bode_amplitude'
        'bode_amplitude');
  delete(h_axes_amp);               % und entferne es
  h_axes_phase = findobj('tag',...  % Finde axes Objekt 'bode_phase'
        'bode_phase');
  delete(h_axes_phase);             % und entferne es
  h_struktur = findobj('tag','axes');% Handle axes für Netzwerkstruktur
  h_children = findobj('parent',h_struktur);   % Handles der Netzwerkkomponenten
  set(h_children,'visible','on');   % Setze Netzwerkkomponenten sichtbar
  h_axes_h=findobj('tag','axes_h(z)');	% Objekte für Überschrift in Kaskaden- und Parallelform
  set (h_axes_h,'visible','on');		% wenn vorhanden, sichtbar setzen
  h_popup = findobj('tag','struktur');% Finde Handle Popup Struktur
  set(h_popup,'callback','netzwerk;');
  h_hilfe=findobj('tag','hilfe');	% Pushbutton Hilfe
  set(h_hilfe, 'callback','!winhelp struktur\struktur.hlp');	% Hilfe aktualisieren
  h_filter=findobj('tag','filterung');% Finde Pushbutton 'filterung' 
  set(h_filter,'enable','on');        % Setze Pushbutton aktiv
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
  h_skalieren= findobj('tag','Skalierung');	% Checkbox Skalierung finden
  set (h_skalieren,'enable','on');	% aktiv setzen
  netzwerk;
end                                   % Ende von command_str = closed
