function filtant(command_str)
% FILTANT
% Die Funktion Filtant beaufschlagt das aktuelle Filter in der 
% gewaehlten Struktur mit dem Eiheitsimpuls als
% Eingangsfolge und stellt die zugehoerige Ausgangsfolge dar
%
% ------------------- Funktions Header --------------------------------------
% Autor:               Jörg Rose / Roman Ußkurat
% Erstellungsdatum:    7-10/97
% Version:             MATLAB Version 5 / Student Edition
% 
% Betreuer: Prof. Dr.-Ing. Stark
%


% ------------------------- Globale Variablen -------------------------------

global b a

farbe = [0.752 0.752 0.752];

h_systemantwort = findobj...        % Finde Pushbutton Systemantwort
  ('tag','antwort');

% -------------- Initialisierung --------------------------------------------
if nargin == 0                        % Wenn keine Parameteruebergabe
  command_str = 'init';               % Setze command_str = init
end


% ----------------------- IIR oder FIR --------------------------------------
filter_check = a(2:length(a));        % Matrix der a-Koeffizienten bis auf den ersten
if any(filter_check)                  % Wenn einer der Koeffizienten ungleich Null
  filter_type = 'IIR';                % dann IIR Filter
else
  filter_type = 'FIR';                % sonst FIR Filter
end                                   % Ende von IIR oder FIR Filter

h_pop_struktur = findobj...           % Finde Popup-Menue 'struktur'
  ('tag','struktur');
h_check_ansicht = findobj...          % Finde Checkbox 'ansicht'
  ('tag','ansicht');
set(h_check_ansicht,...               % Setze Checkbox 'ansicht' unbedienbar
  'enable','off');
struktur = get...                     % Lies Struktur aus Popupmenue
  (h_pop_struktur,'value');
if ((struktur == 6) | (struktur==7) & strcmp(filter_type,'FIR')) % Wenn Struktur = Lattice und Filter = FIR
  command_str = 'message';            % Struktur bei FIR nicht zulaessig
  taste=fenster('Diese Struktur ist nur bei IIR-Filtern möglich!','Info',2,1);
  old_value = get...
    (h_pop_struktur,'userdata');           % Ausgewaehlte Struktur
  set(h_pop_struktur,'value',old_value);   % Ruecksetzen auf alten Wert
else
  set(h_pop_struktur,'userdata',struktur); % Sichern in userdata
end
h_ueber= findobj('tag','axes_h(z)');
if ~isempty (h_ueber)
	set (h_ueber,'visible','off');
end;
if strcmp(command_str,'init')         % Wenn command_str = init
  h_fig = findobj('tag','netzwerk');  % Finde Figure-Objekt 'netzwerk'
  h_exist=findobj('tag','fft');       % Pruefe ob Objekt 'fft' exestiert
  if (abs(h_exist) > 0)               % Wenn Filterung exestiert
    bereich = get(h_exist,'value');   % Lies Popupmenue 'fft': 1=Zeit, 2=FFT
    h_axes_aus = findobj...           % Finde Axes-Objekt fuer Ausgangsfolge
      ('tag','ausgangsfolge');
    h_axes_ein = findobj...           % Finde Axes-Objekt fuer Eingangsfolge
      ('tag','eingangsfolge');
    h_pop_fft = h_exist;              % Handlezuweisung
    h_exist = 1;                      % Objekte fuer Filterung exestieren
  else
    h_exist = 0;                      % Objekte fuer Filterung exestieren nicht
  end                                 % Ende von Filterung exestiert
  h_push_ueber = findobj...           % Finde Pushbutton 'quant_uebernehmen'
    ('tag','quant_uebernehmen');
  callback_string = get...            % Lies callback des Pushbuttons
    (h_push_ueber,'callback');
  set(h_push_ueber,...                % Aktualisiere Callback des Pushbuttons
    'callback','filtant');
  h_tauschen = findobj...             % Finde Pushbutton 'tauschen'
    ('tag','tauschen');
  set(h_tauschen,...                  % Setze Pushbutton inaktiv
    'enable','off');
  h_filterbank = findobj...           % Finde Pushbutton 'filterbank'
    ('tag','filterbank');
  set(h_filterbank,...                % Setze Pushbutton inaktiv
    'enable','off');
  h_speichern = findobj...            % Finde Pushbutton 'speichern'
    ('tag','speichern');
  set(h_speichern,...                 % Setze Pushbutton inaktiv
    'enable','off');
   h_laden = findobj...               % Finde Pushbutton 'laden'
    ('tag','laden');
  set(h_laden,...                     % Setze Pushbutton inaktiv
    'enable','off');
  h_pn = findobj...                   % Finde Pushbutton 'p_n_dia'
    ('tag','p_n_dia');
  set(h_pn,...                        % Setze Pushbutton inaktiv
    'enable','off');
  h_pop_fft = findobj...              % Finde Popupmenue 'FFT'
    ('tag','FFT');
  set(h_pop_fft,...                   % Setze Popupmenue inaktiv
    'enable','off');
  h_systemantwort=findobj...          % Finde Pushbutton 'antwort'
    ('tag','antwort');
  set(h_systemantwort,...             % Setze Pushbutton inaktiv
    'enable','off');     
  h_slider=findobj('tag','slider');   % Finde waagerechten slider
  set(h_slider,'enable','off',...     % Setze Slider unsichtbar und
        'visible','off');             % unbedienbar
  h_slidery=findobj('tag','slidery'); % Finde senkrechten slider 
  set(h_slidery,'enable','off',...    % Setze Slider unsichtbar und
        'visible','off');             % unbedienbar
  h_filterantwort = findobj...        % Finde Pushbutton 'filterung'
    ('tag','filterung');
  sys_data = get...                   % Ermittle Systemdaten aus userdata
    (h_filterantwort,'userdata');     % Aenderung der Systemdaten durch Funktiongenerator
  x = sys_data(1,:);                  % Eingangsfolge aus Systemdaten
  h_check_quant = findobj('tag',...   % Check Box 'Quantisierung'
        'quantisierung'); 
  quantisierung = get(h_check_quant,'value'); % 0: keine Quantisierung
                                              % 1: Quantisierung
  h_struktur = findobj('tag','axes'); % Finde axes Objekt, in dem Netzwerk
  h_children = get(h_struktur,...     % dargestellt und ermittle die Handles
        'children');                  % der Netzwerkkomponenten
  set(h_children,'visible','off');    % Setze Netzwerkkomponenten unsichtbar

  if ~h_exist                         % wenn Filterung noch nicht existiert
    h_axes_aus=axes('position',[0.37 0.25 0.6 0.3],...% Position und Ausdehnung
        'xcolor',[0 0 0],...          % Farbe x-Achse = Schwarz
        'ycolor',[0 0 0],...          % Farbe y-Achse = Schwarz
        'xgrid','on',...              % Gitter in x-Richtung an
        'ygrid','on',...              % Gitter in y-Richtung an
        'tag','ausgangsfolge',...
        'box','on',...
        'userdata',callback_string,...% Sichere callback Pushbutton 'uebernehmen'
        'drawmode','fast',...
        'color',[1 1 1],...           % Farbe = Weiss
        'nextplot','add');            % Aeltere Plots bleiben erhalten

    h_axes_ein = axes('position',[0.37 0.63 0.6 0.3],...
        'visible','on',...            % Begrenzung und Koordinaten sichtbar
        'xcolor',[0 0 0],...
        'ycolor',[0 0 0],...
        'xgrid','on',...
        'ygrid','on',...
        'tag','eingangsfolge',...
        'box','on',...
        'drawmode','fast',...
        'color',[1 1 1],...           % Farbe = Weiss
        'nextplot','add');            % Aeltere Plots bleiben erhalten

    uicontrol(h_fig,...               % Rahmen fuer untere Bedienelemente
        'style','frame',...       
        'units','normalized',...
        'tag','filtant_frame',...     % Bezeichnung des Rahmens
        'backgroundcolor',farbe,...
        'position',[0.2 0 0.8 0.16]);
    % ------------------ Ein- und Ausgangsfolge -------------------------------
    unten = 0.01;
    links = 0.21;
    uicontrol(h_fig,...               % Rahmen fuer Radiobuttons
        'style','frame',...           % Darstellung Ein/Ausgangsfolge
        'units','normalized',...
        'tag','filtant_frame',...     % Bezeichnung des Rahmens
        'backgroundcolor',farbe,...
        'position',[links unten 0.19 0.08]);

    uicontrol(h_fig,...               % Radiobutton fuer nur Ausgangsfolge
        'style','radiobutton',...      
        'string','Ausgangsfolge',...  % Beschriftung des Radiobuttons
        'units','normalized',...
        'enable','on',...
        'visible','on',...
        'value',0,...
        'userdata',0,...              % Alter Wert
        'tag','filtant_aus',...       % Bezeichnung des Radiobuttons
        'callback','filtant(''darstellung'');',...% Bei Betaetigung
        'backgroundcolor',farbe,...
        'position',[links+0.01 unten+0.01 0.17 0.03]);

    uicontrol(h_fig,...               % Radiobutton fuer Ein- Ausgangsfolge
        'style','radiobutton',...       
        'string','Ein/Ausgangsfolge',...% Beschriftung des Radiobuttons
        'units','normalized',...
        'enable','on',...
        'visible','on',...
        'value',1,...
        'userdata',1,...              % Alter Wert
        'tag','filtant_ein_aus',...   % Bezeichnung des Radiobuttons
        'callback','filtant(''darstellung'');',...% Bei Betaetigung
        'backgroundcolor',farbe,...
        'position',[links+0.01 unten+0.04 0.17 0.03]);

    % ------------------ Linear/dB ------------------------------------------
    unten = 0.01;
    links = 0.41;
    uicontrol(h_fig,...               % Rahmen fuer Radiobuttons
        'style','frame',...           % Darstellung Linear/dB
        'units','normalized',...
        'tag','lin_db_frame',...      % Bezeichnung des Rahmens
        'backgroundcolor',farbe,...
        'position',[links unten 0.19 0.08]);

    uicontrol(h_fig,...               % Radiobutton fuer Lineare Darstellung
        'style','radiobutton',...      
        'string','Amplitude (lin)',...% Beschriftung des Radiobuttons
        'units','normalized',...
        'enable','off',...
        'visible','on',...
        'value',1,...
        'userdata',1,...              % Alter Wert
        'tag','filtant_lin',...       % Bezeichnung des Radiobuttons
        'callback','filtant(''amplitude'');',...% Bei Betaetigung
        'backgroundcolor',farbe,...
        'position',[links+0.01 unten+0.01 0.17 0.03]);

    uicontrol(h_fig,...               % Radiobutton fuer Darstellung in dB
        'style','radiobutton',...       
        'string','Amplitude (dB)',... % Beschriftung des Radiobuttons
        'units','normalized',...
        'enable','off',...
        'visible','on',...
        'value',0,...
        'userdata',0,...              % Alter Wert
        'tag','filtant_db',...        % Bezeichnung des Radiobuttons
        'callback','filtant(''amplitude'');',...% Bei Betaetigung
        'backgroundcolor',farbe,...
        'position',[links+0.01 unten+0.04 0.17 0.03]);

    % ---------------- Bediengruppe Zoom ------------------------------------
    unten = 0.1;
    links = 0.41;
    uicontrol(h_fig,...               % Checkbox fuer Zoom
        'style','checkbox',...      
        'string','Zoom',...           % Beschriftung der Checkbox
        'units','normalized',...
        'enable','on',...
        'visible','on',...
        'value',0,...
        'tag','zoom_an',...           
        'callback','zoomfilt(''zoom_on_off'');',...% Bei Betaetigung
        'backgroundcolor',farbe,...
        'position',[links unten 0.08 0.04]);
    h_push_zoom = uicontrol(h_fig,... % Pushbutton fuer Zoom
        'style','pushbutton',...      % Bei Betaetigung Ursprungskoordinaten
        'string','1:1',...            % Beschriftung des Pushbuttons
        'units','normalized',...
        'enable','on',...
        'visible','on',...
        'tag','zoom_ursprung',...           
        'callback','zoomfilt(''ursprung'');',...% Bei Betaetigung
        'backgroundcolor',farbe,...
        'position',[links+0.09 unten 0.1 0.04]);

    % ------------------ Zeitbereich oder FFT -------------------------------
    string_value = str2mat('Zeitbereich','FFT');
    h_pop_fft = uicontrol(h_fig,...   % Popupmenue Umschaltung Zeitbereich/FFT
        'style','popup',...       
        'string',string_value,...     % Beschriftung Popupmenue
        'units','normalized',...
        'enable','on',...
        'visible','on',...
        'value',1,...
        'tag','fft',...               
        'backgroundcolor',[1 1 1],... % Hintergrundfarbe = Weiss
        'callback','filtant(''zeit_fft'');',...% Bei Betaetigung
        'position',[0.21 0.1 0.19 0.03]);

       % ------------------ Bediengruppe Marker --------------------------------
    links = 0.65;
    unten = 0.01;
    uicontrol(h_fig,...               % Rahmen fuer Marker
        'style','frame',...       
        'units','normalized',...
        'visible','on',...
        'tag','marker',...            
        'backgroundcolor',farbe,...
        'position',[links-0.01 unten 0.3 0.14]);

    uicontrol(h_fig,...               % Checkbox fuer Marker
        'style','checkbox',...        % Ein- und Ausschalten des Markers
        'string','Marker',...         % Beschriftung der Checkbox
        'units','normalized',...
        'enable','on',...
        'visible','on',...
        'value',0,...
        'tag','marker_an',...         % Bezeichnung der Checkbox
        'callback','markerfi(''marker_on_off'');',...% Bei Betaetigung
        'backgroundcolor',farbe,...
        'position',[links unten+0.10 0.1 0.03]);

    uicontrol(h_fig,... % Pushbutton fuer Marker
        'style','pushbutton',...      % Bei Betaetigung Ursprungskoordinaten
        'string','<<',...       % Beschriftung des Pushbuttons
        'units','normalized',...
        'enable','on',...
        'visible','off',...
        'userdata',-10,...
        'tag','marker',...
        'callback','markerfi(''moved'');',...% Bei Betaetigung
        'backgroundcolor',farbe,...
        'position',[links+0.16 unten+0.1 0.03 0.03]);
    uicontrol(h_fig,... % Pushbutton fuer Marker
        'style','pushbutton',...      % Bei Betaetigung Ursprungskoordinaten
        'string','<',...       % Beschriftung des Pushbuttons
        'units','normalized',...
        'tag','marker',...
        'enable','on',...
        'visible','off',...
        'userdata',-1,...
        'callback','markerfi(''moved'');',...% Bei Betaetigung
        'backgroundcolor',farbe,...
        'position',[links+0.19 unten+0.1 0.03 0.03]);
    uicontrol(h_fig,... % Pushbutton fuer Marker
        'style','pushbutton',...      % Bei Betaetigung Ursprungskoordinaten
        'string','>',...       % Beschriftung des Pushbuttons
        'units','normalized',...
        'enable','on',...
        'visible','off',...
        'tag','marker',...
        'userdata',1,...
        'callback','markerfi(''moved'');',...% Bei Betaetigung
        'backgroundcolor',farbe,...
        'position',[links+0.22 unten+0.1 0.03 0.03]);
    uicontrol(h_fig,... % Pushbutton fuer Marker
        'style','pushbutton',...      % Bei Betaetigung Ursprungskoordinaten
        'string','>>',...       % Beschriftung des Pushbuttons
        'units','normalized',...
        'enable','on',...
        'visible','off',...
        'tag','marker',...
        'userdata',10,...
        'callback','markerfi(''moved'');',...% Bei Betaetigung
        'backgroundcolor',farbe,...
        'position',[links+0.25 unten+0.1 0.03 0.03]);


    uicontrol(h_fig,...               % Text fuer Marker
        'style','text',...       
        'string','x: ',...
        'units','normalized',...
        'visible','off',...
        'tag','marker',...            
        'horizontalalignment','left',...
        'backgroundcolor',farbe,...
        'position',[links unten+0.07 0.09 0.03]);
    uicontrol(h_fig,...               % Markerposition
        'style','text',...            % Stellt aktuelle Markerposition auf
        'string','0',...              % Bildschirm dar
        'units','normalized',...
        'visible','off',...
        'userdata',0,...              % Aktuelle Markerposition
        'tag','marker_ein_x',...          
        'horizontalalignment','right',...
        'backgroundcolor',farbe,...
        'position',[links+0.09 unten+0.07 0.17 0.03]);
    uicontrol(h_fig,...               
        'style','text',...            
        'string','y Eing.: ',...      
        'units','normalized',...
        'visible','off',...
        'tag','marker',...          
        'horizontalalignment','left',...
        'backgroundcolor',farbe,...
        'position',[links unten+0.04 0.09 0.03]);
    uicontrol(h_fig,...               % Textfeld stellt Wert der Eingangsfolge
        'style','text',...            % an der aktuellen Markerposition auf dem
        'string','',...               % Bildschirm dar
        'units','normalized',...
        'visible','off',...
        'tag','marker_ein_y',...          
        'horizontalalignment','right',...
        'backgroundcolor',farbe,...
        'position',[links+0.09 unten+0.04 0.17 0.03]);
    uicontrol(h_fig,...                  
        'style','text',...       
        'string','y Ausg: ',...
        'units','normalized',...
        'visible','off',...
        'tag','marker',...         
        'horizontalalignment','left',...
        'backgroundcolor',farbe,...
        'position',[links unten+0.01 0.09 0.03]);
    uicontrol(h_fig,...               % Textfeld stellt Wert der Ausgangsfolge   
        'style','text',...            % an der aktuellen Markerposition auf dem
        'string','',...               % Bildschirm dar
        'units','normalized',...
        'visible','off',...
        'tag','marker_aus_y',...          
        'horizontalalignment','right',...
        'backgroundcolor',farbe,...
        'position',[links+0.09 unten+0.01 0.17 0.03]);
    bereich = 1;                      % Bei Erstaufruf Zeitbereich darstellen
  end;                                % Ende von Filterung exestiert
  h_push_zoom = findobj...            % Finde Pushbutton 'zoom_ursprung'
    ('tag','zoom_ursprung');
  h_figure = findobj('tag',...        % Ermittle Handle der Figur Netzwerk
        'netzwerk');
  h_radio_lin = findobj...            % Finde Radiobutton 'filtant_lin'
    ('tag','filtant_lin');
  radio_lin = get...                  % Lies Zustand des Radiobuttons
    (h_radio_lin,'value');            % 0: Amlitude in dB, 1: Amplitude linear
  hoechste=0;
  h_axes_aus = findobj('tag','ausgangsfolge');
  h_axes_ein = findobj('tag','eingangsfolge');
   % zeigt an, ob ein Überlauf stattgefunden hat,
   % wenn Zahl ungleich Null zurückgegeben wird
  if (quantisierung == 1)             % Wenn Quantisierung an
    h_ui_text = uicontrol(h_fig,...   % Textfeld
        'style','Text',...            % Gibt bei eingeschalteter Quantisierung
        'units','normalized',...      % Meldung aus, solange Berechnung laeuft                         
        'backgroundcolor','y',...
        'string','Berechnung läuft',...
        'position',[0.2 0 0.8 0.04]);
     drawnow;
 % -------- Quantisierungsdaten ermitteln und neue Filter-Matrix erstellen-------------------
	[matrix,rech,spei,quantisierung,arithmetik,sort_folge]= quamat (struktur);

    if (arithmetik == 2)            % Festkommaarithmetik
      h_einheitsimpuls = findobj... % Finde Textobjekt 'Einheitsimpuls:'
        ('tag','festkomma',...
         'string','Einheitsimpuls:');
      set(h_einheitsimpuls,...      % Setze Textobjekt unsichtbar
        'visible','off');
      h_edit_puls = findobj...      % Finde Editobjekt 'Einheitsimpuls'
        ('tag','festkomma',...
         'userdata',1);
      set(h_edit_puls,...           % Setze Editobjekt unsichtbar
        'visible','off');
    end;
% -------- Filterung durchführen -------------
     if (arithmetik == 1)            % Gleitkommaarithmetik
      if (struktur == 1)                    % Direktform
        bhilf=matrix(2:size(matrix,1),1)';   % b-Koeffizienten
        ahilf=matrix(2:size(matrix,1),2)';   % a-Koeffizienten
        y = gfildir (bhilf,ahilf,x,rech,spei);   % Gleitkomma Direktform
      end
      if (struktur == 2)                    % 1. kanonische Form
        bhilf=matrix(2:size(matrix,1),1)';   % b-Koeffizienten
        ahilf=matrix(2:size(matrix,1),2)';   % a-Koeffizienten
        y = gfilka1 (bhilf,ahilf,x,rech,spei);   % Gleitkomma 1. kanonische Form
      end
      if (struktur == 3)                    % 2. kanonische Form
        bhilf=matrix(2:size(matrix,1),1)';   % b-Koeffizienten
        ahilf=matrix(2:size(matrix,1),2)';   % a-Koeffizienten
        y = gfilka2 (bhilf,ahilf,x,rech,spei);   % Gleitkomma 2. kanonische Form
      end
      if (struktur == 4)                    % Kaskadenform (3. kanonische)
        sos=matrix(2:size(matrix,1),:);     % sos-Matrix extrahieren
        y = gfilkas (sos,2,x,rech,spei); % Gleitkomma 3. kanonische Form
      end
      if (struktur==5)                      % normierte Kaskadenform
        sos=matrix(2:size(matrix,1),2:7);
        norm_Koeff=matrix(2:size(matrix,1),1)'; % Normierungskoeffizienten
        y=gfilkasn (sos,norm_Koeff,2,x,rech,spei);   %Gleitkomma normierte Kaskadenform
      end
      if (struktur==6)                      % Lattice-Ladder
        K=matrix(2:size(matrix,1)-1,1)';     %Lattice-Koeffizienten
        C=matrix(2:size(matrix,1),2)';       %Ladder-Koeffizienten
        y=gfillat(K,C,x,rech,spei);     % Gleitkomma Lattice-Ladder
      end
      if (struktur==7)                      % Parallelform
        sos=matrix(2:size(matrix,1),2:7);
        Dir_term=matrix(2:size(matrix,1),1)';  % Direktterme
        nicht_null=find(Dir_term);             % Elemente ungleich Null
        Dir_term=Dir_term(1:max(nicht_null));  % Nullen abschneiden
        if isempty(Dir_term)                      % Wenn leere Menge, eine Null
            Dir_term=0;
        end;
        y=gfilpar(sos,Dir_term,2,x,rech,spei);     % Gleitkomma Parallelform
      end
    end                             % Ende von Gleitkommaarithmetik

    if (arithmetik == 2)            % Festkommaarithmetik

      if (struktur == 1)                % Direktform
        bhilf=matrix(2:size(matrix,1),1)';   % b-Koeffizienten
        ahilf=matrix(2:size(matrix,1),2)';   % a-Koeffizienten
        y = ffildir (bhilf,ahilf,x,rech,spei,hoechste);   % Festkomma Direktform
      end
      if (struktur == 2)                    % 1. kanonische Form
        bhilf=matrix(2:size(matrix,1),1)';   % b-Koeffizienten
        ahilf=matrix(2:size(matrix,1),2)';   % a-Koeffizienten
        y = ffilka1 (bhilf,ahilf,x,rech,spei,hoechste);   % Festkomma 1. kanonische Form
      end
      if (struktur == 3)
        bhilf=matrix(2:size(matrix,1),1)';   % b-Koeffizienten
        ahilf=matrix(2:size(matrix,1),2)';   % a-Koeffizienten
        y = ffilka2 (bhilf,ahilf,x,rech,spei,hoechste);   % Festkomma 2. kanonische Form
      end
      if (struktur == 4)                    % Kaskadenform (3. kanonische)
        sos=matrix(2:size(matrix,1),:);     % sos-Matrix extrahieren
        y = ffilkas (sos,2,x,rech,spei,hoechste); % Festkomma 3. kanonische Form
      end
      if (struktur==5)                      % normierte Kaskadenform
        sos=matrix(2:size(matrix,1),2:7);
        norm_Koeff=matrix(2:size(matrix,1),1)'; % Normierungskoeffizienten
        y=ffilkasn (sos,norm_Koeff,2,x,rech,spei,hoechste);   %Festkomma normierte Kaskadenform
      end
      if (struktur==6)                      % Lattice-Ladder
        K=matrix(2:size(matrix,1)-1,1)';     %Lattice-Koeffizienten
        C=matrix(2:size(matrix,1),2)';       %Ladder-Koeffizienten
        y=ffillat(K,C,x,rech,spei,hoechste); % Festkomma Lattice-Ladder
      end
      if (struktur==7)                      % Parallelform
        sos=matrix(2:size(matrix,1),2:7);
        Dir_term=matrix(2:size(matrix,1),1)';  % Direktterme
        nicht_null=find(Dir_term);             % Elemente ungleich Null
        Dir_term=Dir_term(1:max(nicht_null));  % Nullen abschneiden
        if isempty(Dir_term)                      % Wenn leere Menge, eine Null
            Dir_term=0;
        end;
        y=ffilpar(sos,Dir_term,2,x,rech,spei,hoechste);  % Festkomma Parallelform
      end
    end                             % Ende von Festkommaarithmetik

    delete(h_ui_text);                % Entferne Textfeld 'Berechnung laeuft'



  end                                 % Ende von Quantisierung an
  if (quantisierung == 0)             % Wenn Quantisierung aus
    y = filter(b,a,x);                % Berechne Ausgangsfolge
  end

  % ----- Ueberschrift fuer Systemantwort -----------------------------------
  h_pop_struktur = findobj('tag','struktur');% Finde Popupmenue 'struktur'
  struktur = get(h_pop_struktur,'value');% Lies Zustand des Popupmenues
  if (struktur == 1)
    set(h_figure,'name','Systemantwort: Nichtkanonische Direktform');
  end
  if (struktur == 2)
    set(h_figure,'name','Systemantwort: 1. kanonische Form');
  end
  if (struktur == 3)
    set(h_figure,'name','Systemantwort: 2. kanonische Form');
  end
  if (struktur == 4)
    set(h_figure,'name','Systemantwort: 3. kanonische Form');
  end
  if (struktur == 5)
    set(h_figure,'name','Systemantwort: 3. kanonische Form normiert');
  end
  if (struktur == 6)
    set(h_figure,'name','Systemantwort: Lattice Gitterstruktur');
  end
if (struktur == 7)
    set(h_figure,'name','Systemantwort: Parallelform');
  end 
  matrix_folge = [x;y];               % matrix = Eingangsfolge; Ausgangsfolge
  h_pop_fft = findobj...              % Finde Popupmenue 'FFT'
    ('tag','fft');
  set(h_pop_fft,...                   % Speichern in Popupmenue 'fft'
    'userdata',matrix_folge);
  ausgang = y;                        % Ausgangsfolge
  eingang = x;                        % Eingangsfolge
  zeit =(0:1:(length(eingang)-1));    % Ermittle Zeitachse
  ausgang_fourier = abs(fft(ausgang));% Fouriertransformierte der Ausgangsfolge  
  eingang_fourier = abs(fft(eingang));% Fouriertransformierte der Eingangsfolge  
  laenge = length(ausgang_fourier);   % Beide Folgen gleiche Laenge
  ausgang_spektrum = ausgang_fourier(1:(laenge/2));% Darstellung bis zur halben Abtastfrequenz
  eingang_spektrum = eingang_fourier(1:(laenge/2));% Darstellung bis zur halben Abtastfrequenz
  h_filterantwort = findobj...        % Finde Pushbutton 'filterung'
    ('tag','filterung');
  sys_data = get...                   % Ermittle Systemdaten aus userdata
    (h_filterantwort,'userdata');     % Aenderung der Systemdaten durch Funktiongenerator
  fft_laenge = sys_data(2,1);     % FFT-Laenge = 2.Reihe, 1.Spalte
  funktion = sys_data(2,6);           % 1 fuer dirac-Impuls
  if (funktion > 1)
    ausgang_spektrum = ausgang_spektrum .* 2 ./ fft_laenge;
    ausgang_spektrum(1) = ausgang_spektrum(1) / 2;
    eingang_spektrum = eingang_spektrum .* 2 ./ fft_laenge;
    eingang_spektrum(1) = eingang_spektrum(1) / 2;
  end;
  ausgang_spek_db = 20.*log10(ausgang_spektrum);% Umwandlung in dB
  eingang_spek_db = 20.*log10(eingang_spektrum);% Umwandlung in dB
  ny = (0:1:(laenge/2-1))./laenge;    % Normierte Frequenz
  h_child_ein = get...                % Finde Nachkommen des Axes-Objktes
    (h_axes_ein,'children');          % 'eingangsfolge'
  delete(h_child_ein);                % Entferne die Nachkommen
  h_child_aus = get...                % Finde Nachkommen des Axes-Objktes
    (h_axes_aus,'children');          % 'ausgangsfolge'
  delete(h_child_aus);                % Entferne die Nachkommen
  h_radio_aus = findobj...            % Finde Radiobutton 'filtant_aus'
    ('tag','filtant_aus');
  nur_aus = get...                    % value = 1 => nur Ausgangsfolge
    (h_radio_aus,'value');            % value = 0 => Ein- und Ausgangsfolge
  if (nur_aus == 0)&(bereich == 1)    % Ein- und Ausgang Zeitbereich
    axes(h_axes_ein);                 % Aktuelles Axes-Objekt = h_axes_ein
    pause(0.1);                       % Pause zum umschalten auf aktuelles Objekt
    max_aus = max(ausgang);
    min_aus = min(ausgang);
    if (min_aus == max_aus)
      min_aus = max_aus - 1;
    end;
    max_ein = max(eingang);
    min_ein = min(eingang);
    if (min_ein == max_ein)
      min_ein = max_ein - 1;
    end;
    set(h_axes_ein,...                % Aktualisieren der Grenzwerte h_axes_ein
      'xlim',[0 max(zeit)],...
      'ylim',[min_ein max_ein]);
    set(h_axes_aus,...                % Aktualisieren der Grenzwerte h_axes_aus
      'xlim',[0 max(zeit)],...
      'ylim',[min_aus max_aus]);
    stemm(zeit,eingang);              % Zeichne Eingangsfolge im Zeitbereich
    y_lim=get(h_axes_ein,'ylim');     % Senkrechte Begrenzung Ausgangsfolge
    maximum = max(y_lim);             % Maximum der Amplitude
    hoehe = maximum + abs(maximum/100);% Senkrechte Position der Ueberschrift
    x_lim = get(h_axes_ein,'xlim');   % Waagerechte Begrenzung Ausgangsfolge
    breite = (x_lim(2)-x_lim(1))/2;   % Waagerechte Position der Ueberschrift
    text('string','Eingangsfolge',... % Ueberschrift fuer Axes-Objekt
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_ein',...
        'verticalalignment','bottom',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    breite = x_lim(1)-breite/4;
    hoehe = (y_lim(2)-y_lim(1))/2 + y_lim(1);
    text('string','Amplitude(lin)',... % Beschriftung senkrechte Achse
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_amp_ein',...
        'rotation',90,...
        'verticalalignment','middle',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    axes(h_axes_aus);                 % Aktuelles Axes-Objekt = h_axes_aus
    pause(0.1);                       % Pause zum Umschalten auf aktuelles Objekt
    stemm(zeit,ausgang);              % Zeichne Ausgangsfolge im Zeitbereich
    y_lim=get(h_axes_aus,'ylim');     % Senkrechte Begrenzung Ausgangsfolge
    maximum = max(y_lim);             % Maximum der Amplitude
    hoehe = maximum + abs(maximum/100);% Senkrechte Position der Ueberschrift
    x_lim = get(h_axes_aus,'xlim');   % Waagerechte Begrenzung Ausgangsfolge
    breite = (x_lim(2)-x_lim(1))/2;   % Waagerechte Position der Ueberschrift
    text('string','Ausgangsfolge',... % Ueberschrift fuer Axes-Objekt
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_aus',...
        'verticalalignment','bottom',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    hoehe = (y_lim(2)-y_lim(1))/2 + y_lim(1);
    breite = x_lim(1)-breite/4 ;
    text('string','Amplitude(lin)',... % Beschriftung senkrechte Achse
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_amp_aus',...
        'rotation',90,...
        'verticalalignment','middle',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    text('string','n',...             % Beschriftung waagerechte Achse
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_x_aus',...
        'verticalalignment','bottom',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[x_lim(2) y_lim(1)-(y_lim(2)-y_lim(1))/4]);
    x_lim_ein=get(h_axes_ein,'xlim'); % Lies x-Grenzwerte der Eingangsfolge
    y_lim_ein=get(h_axes_ein,'ylim'); % Lies y-Grenzwerte der Eingangsfolge
    x_lim_aus=get(h_axes_aus,'xlim'); % Lies x-Grenzwerte der Ausgangsfolge
    y_lim_aus=get(h_axes_aus,'ylim'); % Lies y-Grenzwerte der Ausgangsfolge
    matrix_lim=[x_lim_ein;y_lim_ein;...% Speichere Grenzwerte in Matrix
      x_lim_aus;y_lim_aus];
    set(h_push_zoom,'userdata',matrix_lim);% Sichere Matrix in userdata
  end                                 % Ende von Ein- und Ausgangsfolge Zeitbereich
  if (nur_aus == 1)&(bereich == 1)    % Nur Ausgang Zeitbereich
    axes(h_axes_aus);                 % Aktuelles Axes-Objekt = h_axes_aus
    max_aus = max(ausgang);
    min_aus = min(ausgang);
    if (min_aus == max_aus)
      min_aus = max_aus - 1;
    end;
    max_ein = max(eingang);
    min_ein = min(eingang);
    if (min_ein == max_ein)
      min_ein = max_ein - 1;
    end;
    set(h_axes_ein,...                % Aktualisieren der Grenzwerte h_axes_ein
      'xlim',[0 max(zeit)],...
      'ylim',[min_ein max_ein]);
    set(h_axes_aus,...                % Aktualisieren der Grenzwerte h_axes_aus
      'xlim',[0 max(zeit)],...
      'ylim',[min_aus max_aus]);
    stemm(zeit,ausgang);              % Zeichne Ausgangsfolge im Zeitbereich
    y_lim=get(h_axes_aus,'ylim');     % Senkrechte Begrenzung Ausgangsfolge
    maximum = max(y_lim);             % Maximum der Amplitude
    hoehe = maximum + abs(maximum/100);% Senkrechte Position der Ueberschrift
    x_lim = get(h_axes_aus,'xlim');   % Waagerechte Begrenzung Ausgangsfolge
    breite = (x_lim(2)-x_lim(1))/2;   % Waagerechte Position der Ueberschrift
    text('string','Ausgangsfolge',... % Ueberschrift fuer Axes-Objekt
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_aus',...
        'verticalalignment','bottom',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    hoehe = (y_lim(2)-y_lim(1))/2 + y_lim(1);
    breite = x_lim(1)-breite/4;
    text('string','Amplitude(lin)',... % Beschriftung senkrechte Achse
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_amp_aus',...
        'rotation',90,...
        'verticalalignment','middle',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    text('string','n',...             % Beschriftung waagerechte Achse
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_x_aus',...
        'verticalalignment','bottom',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[x_lim(2) y_lim(1)-(y_lim(2)-y_lim(1))/4]);
    x_lim_ein=get(h_axes_ein,'xlim'); % Lies x-Grenzwerte der Eingangsfolge
    y_lim_ein=get(h_axes_ein,'ylim'); % Lies y-Grenzwerte der Eingangsfolge
    x_lim_aus=get(h_axes_aus,'xlim'); % Lies x-Grenzwerte der Ausgangsfolge
    y_lim_aus=get(h_axes_aus,'ylim'); % Lies y-Grenzwerte der Ausgangsfolge
    matrix_lim=[x_lim_ein;y_lim_ein;...% Speichere Grenzwerte in Matrix
      x_lim_aus;y_lim_aus];
    set(h_push_zoom,'userdata',matrix_lim);% Sichere Matrix in Userdata
  end                                 % Ende von nur Ausgangsfolge Zeitbereich
  if (nur_aus == 0)&(bereich == 2)    % Ein- und Ausgang Fourier
    axes(h_axes_ein);                 % Aktuelles Axes-Objekt = h_axes_ein
    pause(0.1);                       % Pause zum Umschalten auf aktuelles Objekt
    if (radio_lin == 1)               % Wenn Amplitude linear
      ylim_ein = [0 max(eingang_spektrum)];% Festlegen der y-Grenzwerte Eingangsfolge
      ylim_aus = [0 max(ausgang_spektrum)];% Festlegen der y-Grenzwerte Ausgangsfolge
    elseif (radio_lin == 0)           % Wenn Amplitude in dB
      ylim_ein = [min(eingang_spek_db) max(eingang_spek_db)];% Festlegen der y-Grenzwerte Ausgangsfolge
      if (ylim_ein(1) == ylim_ein(2))
        ylim_ein(1) = ylim_ein(1)-10;
      end
      ylim_aus = [min(ausgang_spek_db) max(ausgang_spek_db)];% Festlegen der y-Grenzwerte Ausgangsfolge
    end                               % Ende von Amplitude linear oder in dB
    set(h_axes_ein,...                % Aktualisiere Grenzwerte Eingangsfolge
      'xlim',[0 0.5],...
      'ylim',ylim_ein);
    set(h_axes_aus,...                % Aktualisiere Grenzwerte Ausgangsfolge
      'xlim',[0 0.5],...
      'ylim',ylim_aus);
    if (radio_lin == 1)               % Wenn Amplitude linear
      stemm(ny,eingang_spektrum);     % Zeichne fouriertransformierte Eingangsfolge
      string_amp = 'Amplitude(lin)';
    elseif (radio_lin == 0)           % Wenn Amplitude in dB
      stemein(ny,eingang_spek_db);    % Zeichne fouriertransformierte Eingangsfolge in dB
      string_amp = 'Amplitude(dB)';
    end                               % Ende von Amplitude linear oder in dB
    y_lim=get(h_axes_ein,'ylim');     % Senkrechte Begrenzung Ausgangsfolge
    maximum = max(y_lim);             % Maximum der Amplitude
    hoehe = maximum + abs(maximum/100);% Senkrechte Position der Ueberschrift
    x_lim = get(h_axes_ein,'xlim');   % Waagerechte Begrenzung Ausgangsfolge
    breite = (x_lim(2)-x_lim(1))/2;   % Waagerechte Position der Ueberschrift
    text('string','Fouriertransformierte Eingangsfolge',...      % Ueberschrift fuer Axes-Objekt
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_ein',...
        'verticalalignment','bottom',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    breite = x_lim(1)-breite/4;
    hoehe = (y_lim(2)-y_lim(1))/2 + y_lim(1);
    text('string',string_amp,...      % Beschriftung senkrechte Achse
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_amp_ein',...
        'rotation',90,...
        'verticalalignment','middle',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    axes(h_axes_aus);                 % Aktuelles Axes-Objekt = h_axes_aus
    pause(0.1);                       % Pause zum Umschalten auf aktuelles Objekt
    if (radio_lin == 1)               % Wenn Amplitude linear
      stemm(ny,ausgang_spektrum);     % Zeichne fouriertransformierte Ausgangsfolge 
    elseif (radio_lin == 0)           % Wenn Amplitude in dB
      stemaus(ny,ausgang_spek_db);    % Zeichne fouriertransformierte Ausgangsfolge in dB
    end                               % Ende von Amplitude linear oder in dB
    y_lim=get(h_axes_aus,'ylim');     % Senkrechte Begrenzung Ausgangsfolge
    maximum = max(y_lim);             % Maximum der Amplitude
    hoehe = maximum + abs(maximum/100);% Senkrechte Position der Ueberschrift
    x_lim = get(h_axes_aus,'xlim');   % Waagerechte Begrenzung Ausgangsfolge
    breite = (x_lim(2)-x_lim(1))/2;   % Waagerechte Position der Ueberschrift
    text('string','Fouriertransformierte Ausgangsfolge',...      % Ueberschrift fuer Axes-Objekt
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_aus',...
        'verticalalignment','bottom',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    breite = x_lim(1)-breite/4;
    hoehe = (y_lim(2)-y_lim(1))/2 + y_lim(1);
    text('string',string_amp,... % Beschriftung senkrechte Achse
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_amp_aus',...
        'rotation',90,...
        'verticalalignment','middle',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    text('string','f/fa',...             % Beschriftung waagerechte Achse
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_x_aus',...
        'verticalalignment','bottom',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[x_lim(2) y_lim(1)-(y_lim(2)-y_lim(1))/4]);
    x_lim_ein=get(h_axes_ein,'xlim'); % Lies x-Grenzwerte der Eingangsfolge
    y_lim_ein=get(h_axes_ein,'ylim'); % Lies y-Grenzwerte der Eingangsfolge
    x_lim_aus=get(h_axes_aus,'xlim'); % Lies x-Grenzwerte der Ausgangsfolge
    y_lim_aus=get(h_axes_aus,'ylim'); % Lies y-Grenzwerte der Ausgangsfolge
    matrix_lim=[x_lim_ein;y_lim_ein;...% Speichere Grenzwerte in Matrix
      x_lim_aus;y_lim_aus];
    set(h_push_zoom,'userdata',matrix_lim);% Sichere Matrix in Userdata
  end                                 % Ende von Ein- und Ausgangsfolge FFT
  if (nur_aus == 1)&(bereich == 2)    % Nur Ausgang Fourier
    axes(h_axes_aus);                 % Aktuelles Axes-Objekt = h_axes_aus
    pause(0.1);                       % Pause zum Umschalten auf aktuelles Objekt
    if (radio_lin == 1)               % Wenn Amplitude linear
      ylim_ein=[0 max(eingang_spektrum)];% Festlegen der y-Grenzwerte Eingangsfolge
      ylim_aus=[0 max(ausgang_spektrum)];% Festlegen der y-Grenzwerte Ausgangsfolge
      string_amp = 'Amplitude(lin)';
    elseif (radio_lin == 0)           % Wenn Amplitude in dB
      ylim_ein=[min(eingang_spek_db) max(eingang_spek_db)];% Festlegen der y-Grenzwerte Eingangsfolge in dB
      if(min(eingang_spek_db) == max(eingang_spek_db))% Wenn alle Amplitudenwerte gleich
        ylim_ein(1) = min(eingang_spek_db) - 10;% Bilde beliebige Differenz fuer Grenzwerte
      end
      ylim_aus = [min(ausgang_spek_db) max(ausgang_spek_db)];% Festlegen der y-Grenzwerte Ausgangsfolge in dB
      if(min(ausgang_spek_db) == max(ausgang_spek_db))% Wenn alle Amplitudenwerte gleich
        ylim_aus(1) = min(ausgang_spek_db) - 10;% Bilde beliebige Differenz fuer Grenzwerte
      end
      string_amp = 'Amplitude(dB)';
    end                               % Ende von Amplitude linear oder in dB
    set(h_axes_ein,...                % Aktualisiere Grenzwerte der Eingangsfolge
      'xlim',[0 0.5],...
      'ylim',ylim_ein);
    set(h_axes_aus,...                % Aktualisiere Grenzwerte der Ausgangsfolge
      'xlim',[0 0.5],...
      'ylim',ylim_aus);
    if (radio_lin == 1)               % Wenn Amplitude linear
      stemm(ny,ausgang_spektrum);     % Zeichne fouriertransformierte Ausgangsfolge
    elseif (radio_lin == 0)           % Wenn Amplitude in dB
      stemaus(ny,ausgang_spek_db);    % Zeichne fouriertransformierte Ausgangsfolge in dB
    end                               % Ende von Amplitude linear oder in dB
    y_lim=get(h_axes_aus,'ylim');     % Senkrechte Begrenzung Ausgangsfolge
    maximum = max(y_lim);             % Maximum der Amplitude
    hoehe = maximum + abs(maximum/100);% Senkrechte Position der Ueberschrift
    x_lim = get(h_axes_aus,'xlim');   % Waagerechte Begrenzung Ausgangsfolge
    breite = (x_lim(2)-x_lim(1))/2;   % Waagerechte Position der Ueberschrift
    text('string','Fouriertransformierte Ausgangsfolge',...      % Ueberschrift fuer Axes-Objekt
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_aus',...
        'verticalalignment','bottom',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    breite = x_lim(1)-breite/4;
    hoehe = (y_lim(2)-y_lim(1))/2 + y_lim(1);
    text('string',string_amp,... % Beschriftung senkrechte Achse
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_amp_aus',...
        'rotation',90,...
        'verticalalignment','middle',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    text('string','f/fa',...             % Beschriftung waagerechte Achse
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_x_aus',...
        'verticalalignment','bottom',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[x_lim(2) y_lim(1)-(y_lim(2)-y_lim(1))/4]);
    x_lim_ein=get(h_axes_ein,'xlim'); % Lies x-Grenzwerte der Eingangsfolge
    y_lim_ein=get(h_axes_ein,'ylim'); % Lies y-Grenzwerte der Eingangsfolge
    x_lim_aus=get(h_axes_aus,'xlim'); % Lies x-Grenzwerte der Ausgangsfolge
    y_lim_aus=get(h_axes_aus,'ylim'); % Lies y-Grenzwerte der Ausgangsfolge
    matrix_lim=[x_lim_ein;y_lim_ein;...% Speichere Grenzwerte in Matrix
      x_lim_aus;y_lim_aus];
    set(h_push_zoom,'userdata',matrix_lim);% Sichere Matrix in Userdata
  end                                 % Ende von nur Ausgangsfolge FFT
  if ~h_exist                         % Wenn erstes Bodediagramm
    h_popup = findobj('tag','struktur');% Finde Handle Popup Struktur
    set(h_popup,'callback','filtant;');% Aendere Callback in Popup 'struktur'
    h_quit = findobj('tag','quit');   % Finde Pushbutton 'quit'
    set(h_quit,...
      'enable','on',...               % Setze Pushbutton aktiv
      'callback','filtant(''closed'');'); % Setze Callback
  end                                 % Ende von Filterung exestiert
  hilf_matrix = [zeit;x;y];                % Generiere Matrix fuer Marker
  h_radio_marker = findobj...         % Finde Radiobutton 'marker_an'
    ('tag','marker_an');
  set(h_radio_marker,...              % Speichere Matrix in userdata
    'userdata',hilf_matrix);
  matrix_four = [ny;eingang_spektrum;ausgang_spektrum;...
    eingang_spek_db;ausgang_spek_db]; % Generiere Matrix fuer Marker
  h_text_marker = findobj...          % Finde Text-Objekt 'marker_ein_y'
    ('tag','marker_ein_y');
  set(h_text_marker,...               % Speichere Matrix in userdata
    'userdata',matrix_four);
  if (hoechste ~=0)  % Überläufe angezeigt
      info_str= ('Bei der Filterung mit Festkommaquantisierung Überläufe aufgetreten! Verkleinern Sie falls erforderlich die Aussteuerung.');
      taste=fenster(info_str,'Info',2,1);  % Informations-Fenster mit Meldung öffnen
  end;
  h_check_marker = findobj...         % Finde Radiobutton 'marker_an'
    ('tag','marker_an');
  marker_on = get(h_check_marker,...  % Lies Zustand der Checkbox
    'value');
  if marker_on == 1                   % Wenn Marker eingeschaltet
    markerfi('marker_on_off');
  end                                 % Ende von Marker ein
  child_aus = get(h_axes_aus,'children');
  set(child_aus,'visible','off');
  set(child_aus,'visible','on');
  if (bereich == 2)
   child_ein = get(h_axes_ein,'children');
    set(child_ein,'visible','off');
    set(child_ein,'visible','on');
  end
  drawnow;
end                                   % Ende von command_str = init


% ------------------ darstellung --------------------------------------------
if strcmp(command_str,'darstellung')  % Wenn command_str = darstellung
  h_radio_aus = findobj...            % Finde Radiobutton 'filtant_aus'
    ('tag','filtant_aus');
  h_radio_ein_aus = findobj...        % Finde Radiobutton 'filtant_ein_aus'
    ('tag','filtant_ein_aus');
  h_objekt = gco;                     % Aktuelles Objekt
  old_value=get(h_objekt,'userdata'); % Lies alten Zustand des Radiobuttons
  if (old_value == 1)                 % Wenn Radiobutton vorher 1 war
    set(h_objekt,'value',1);          % Setze Radiobutton wieder auf 1
  elseif (old_value == 0)             % Wenn Radiobutton vorher 0 war
    if strcmp(get(h_objekt,'tag'),'filtant_aus')% Nur Ausgangssignal
      set(h_radio_aus,...             % Sichere aktuellen Radiobuttonzustand
        'value',1,...
        'userdata',1);
      set(h_radio_ein_aus,...         % Sichere aktuellen Radiobuttonzustand
        'value',0,...
        'userdata',0);
    end                               % Ende von nur Ausgangssignal
    if strcmp(get(h_objekt,'tag'),'filtant_ein_aus')% Ein- und Ausgangssignal
      set(h_radio_aus,...             % Sichere aktuellen Radiobuttonzustand
        'value',0,...
        'userdata',0);
      set(h_radio_ein_aus,...         % Sichere aktuellen Radiobuttonzustand
        'value',1,...
        'userdata',1);
    end                               % Ende von Ein- und Ausgangssignal
    command_str = 'zeit_fft';
  end                                 % Ende von if old_value ==...
end                                   % Ende von command_str = darstellung


% ------------------ amplitude ----------------------------------------------
if strcmp(command_str,'amplitude')    % Wenn command_str = amplitude
  h_radio_lin = findobj...            % Finde Radiobutton 'filtant_lin'
    ('tag','filtant_lin');
  h_radio_db = findobj...             % Finde Radiobutton 'filtant_db'
    ('tag','filtant_db');
  h_objekt = gco;                     % Aktuelles Objekt
  old_value=get(h_objekt,'userdata'); % Lies alten Zustand des Radiobuttons
  if (old_value == 1)                 % Wenn Radiobutton vorher 1 war
    set(h_objekt,'value',1);          % Setze Radiobutton wieder auf 1
  elseif (old_value == 0)             % Wenn Radiobutton vorher 0 war
    if strcmp(get(h_objekt,'tag'),'filtant_lin')% Amplitude linear
      set(h_radio_lin,...             % Sichere aktuellen Radiobuttonzustand
        'value',1,...
        'userdata',1);
      set(h_radio_db,...              % Sichere aktuellen Radiobuttonzustand
        'value',0,...
        'userdata',0);
    end                               % Ende Amplitude linear
    if strcmp(get(h_objekt,'tag'),'filtant_db')% Amplitude in dB
      set(h_radio_lin,...             % Sichere aktuellen Radiobuttonzustand
        'value',0,...
        'userdata',0);
      set(h_radio_db,...              % Sichere aktuellen Radiobuttonzustand
        'value',1,...
        'userdata',1);
    end                               % Ende von Ein- und Ausgangssignal
    command_str = 'zeit_fft';
  end                                 % Ende von if old_value ==...
end                                   % Ende von command_str = darstellung


%-------------- zeit_fft ----------------------------------------------------
if strcmp(command_str,'zeit_fft')     % Wenn command_str = zeit_fft
  h_radio_lin = findobj...            % Finde Radiobutton 'filtant_lin'
    ('tag','filtant_lin');
  radio_lin = get...                  % Lies Zustand des Radiobuttons
    (h_radio_lin,'value');            % 0: Amplitude in dB, 1: Amplitude linear
  h_radio_db = findobj...             % Finde Radiobutton 'filtant_db'
    ('tag','filtant_db');
  h_push_zoom = findobj...            % Finde Pushbutton 'zoom_ursprung'
    ('tag','zoom_ursprung');
  h_pop_fft=findobj('tag','fft');     % Finde Popupmenue 'fft'
  matrix_folge = get...               % Lies Matrix aus Userdata
    (h_pop_fft,'userdata');
  ausgang = matrix_folge(2,:);        % Ausgangsfolge aus Matrix Reihe 2
  eingang = matrix_folge(1,:);        % Eingangsfolge aus Matrix Reihe 1
  zeit =(0:1:(length(eingang)-1));    % Ermittle Zeitachse
  ausgang_fourier = abs(fft(ausgang));% Fouriertransformierte der Asugangsfolge
  eingang_fourier = abs(fft(eingang));% Fouriertransformierte der Ausgangsfolge
  laenge = length(ausgang_fourier);   % Beide Folgen gleiche Laenge
  ausgang_spektrum = ausgang_fourier(1:(laenge/2));% Darstellung bis halbe Abtastfrequenz
  eingang_spektrum = eingang_fourier(1:(laenge/2));% Darstellung bis halbe Abtastfrequenz
  h_filterantwort = findobj...        % Finde Pushbutton 'filterung'
    ('tag','filterung');
  sys_data = get...                   % Ermittle Systemdaten aus userdata
    (h_filterantwort,'userdata');     % Aenderung der Systemdaten durch Funktiongenerator
  fft_laenge = sys_data(2,1);     % FFT-Laenge = 2.Reihe, 1.Spalte
  funktion = sys_data(2,6);           % 1 fuer dirac-Impuls
  if (funktion > 1)
    ausgang_spektrum = ausgang_spektrum .* 2 ./ fft_laenge;
    ausgang_spektrum(1) = ausgang_spektrum(1) / 2;
    eingang_spektrum = eingang_spektrum .* 2 ./ fft_laenge;
    eingang_spektrum(1) = eingang_spektrum(1) / 2;
  end;
  ny = (0:1:(laenge/2-1))./laenge;    % Normierte Frequenz
  ausgang_spek_db = 20.*log10(ausgang_spektrum);% Ausgangsfolge in dB
  eingang_spek_db = 20.*log10(eingang_spektrum);% Ausgangsfolge in dB
  h_axes_ein = findobj...             % Finde Axes Objekt 'eingangsfolge'
    ('tag','eingangsfolge');
  h_child_ein = get...                % Finde Nachkommen Axes-Objekt 'eingangsfolge'
    (h_axes_ein,'children');
  delete(h_child_ein);                % Entferne Nachkommen
  h_axes_aus = findobj...             % Finde Axes Objekt 'ausgangsfolge'
    ('tag','ausgangsfolge');
  h_child_aus = get...                % Finde Nachkommen Axes-Objekt 'ausgangsfolge'
    (h_axes_aus,'children');
  delete(h_child_aus);                % Entferne Nachkommen
  h_radio_aus = findobj...            % Finde Radiobutton 'filtant_aus'
    ('tag','filtant_aus');
  nur_aus = get...                    % value = 1 => nur Ausgangsfolge
    (h_radio_aus,'value');            % value = 0 => Ein- und Ausgangsfolge
  bereich = get...                    % bereich = 1 => Zeitbereich darstellen
    (h_pop_fft,'value');              % bereich = 2 => Fouriertransformierte
  h_text_ein = findobj...             % Finde Text-Objekt Ueberschrift
    ('tag','text_ein');               % fuer Eingangsfolge
  h_text_aus = findobj...             % Finde Text-Objekt Ueberschrift
    ('tag','text_aus');               % fuer Ausgangsfolge
  if (nur_aus == 0)&(bereich == 1)    % Ein- und Ausgang Zeitbereich
    set(h_radio_lin,...               % Setze Radiobutton unbedienbar
      'enable','off');
    set(h_radio_db,...                % Setze Radiobutton unbedienbar
      'enable','off');
    set(h_axes_ein,...                % Aktualisiere Grenzwerte Eingangsfolge
      'xlim',[0 max(zeit)],...
      'ylim',[min(eingang) max(eingang)],...
      'visible','on');                % Setze Axes Objekt sichtbar
    set(h_axes_aus,...                % Aktualisiere Grenzwerte Ausgangsfolge
      'xlim',[0 max(zeit)],...
      'ylim',[min(ausgang) max(ausgang)],...
      'position',[0.37 0.25 0.6 0.3]);% Aktualisiere Koordinaten
    axes(h_axes_ein);                 % Aktuelles Axes-Objekt = h_axes_ein
    pause(0.1);                       % Pause zum Umschalten auf aktuelles Objekt
    stemm(zeit,eingang);              % Zeichne Eingangsfolge im Zeitbereich
    y_lim=get(h_axes_ein,'ylim');     % Senkrechte Begrenzung Ausgangsfolge
    maximum = max(y_lim);             % Maximum der Amplitude
    hoehe = maximum + abs(maximum/100);% Senkrechte Position der Ueberschrift
    x_lim = get(h_axes_ein,'xlim');   % Waagerechte Begrenzung Ausgangsfolge
    breite = (x_lim(2)-x_lim(1))/2;   % Waagerechte Position der Ueberschrift
    text('string','Eingangsfolge',... % Ueberschrift fuer Axes-Objekt
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_ein',...
        'verticalalignment','bottom',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    hoehe = (y_lim(2)-y_lim(1))/2 + y_lim(1);
    breite = x_lim(1)-breite/4;
    text('string','Amplitude(lin)',... % Beschriftung senkrechte Achse
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_amp_ein',...
        'rotation',90,...
        'verticalalignment','middle',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    axes(h_axes_aus);                 % Aktuelles Axes-Objekt = h_axes_aus
    pause(0.1);                       % Pause zum Umschalten auf aktuelles Objekt
    stemm(zeit,ausgang);              % Zeichne Ausgangsfolge im Zeitbereich
    y_lim=get(h_axes_aus,'ylim');     % Senkrechte Begrenzung Ausgangsfolge
    maximum = max(y_lim);             % Maximum der Amplitude
    hoehe = maximum + abs(maximum/100);% Senkrechte Position der Ueberschrift
    x_lim = get(h_axes_aus,'xlim');   % Waagerechte Begrenzung Ausgangsfolge
    breite = (x_lim(2)-x_lim(1))/2;   % Waagerechte Position der Ueberschrift
    text('string','Ausgangsfolge',... % Ueberschrift fuer Axes-Objekt
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_aus',...
        'verticalalignment','bottom',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    hoehe = (y_lim(2)-y_lim(1))/2 + y_lim(1);
    breite = x_lim(1)-breite/4;
    text('string','Amplitude(lin)',... % Beschriftung senkrechte Achse
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_amp_aus',...
        'rotation',90,...
        'verticalalignment','middle',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    text('string','n',...             % Beschriftung waagerechte Achse
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_x_aus',...
        'verticalalignment','bottom',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[x_lim(2) y_lim(1)-(y_lim(2)-y_lim(1))/4]);
    x_lim_ein=get(h_axes_ein,'xlim'); % Lies x-Grenzwerte der Eingangsfolge
    y_lim_ein=get(h_axes_ein,'ylim'); % Lies y-Grenzwerte der Eingangsfolge
    x_lim_aus=get(h_axes_aus,'xlim'); % Lies x-Grenzwerte der Ausgangsfolge
    y_lim_aus=get(h_axes_aus,'ylim'); % Lies y-Grenzwerte der Ausgangsfolge
    matrix_lim=[x_lim_ein;y_lim_ein;...
      x_lim_aus;y_lim_aus];           % Speichere Grenzwerte in Matrix
    set(h_push_zoom,'userdata',matrix_lim);% Sichere Matrix in Userdata
  end                                 % Ende von Ein- und Ausgangsfolge Zeitbereich
  if (nur_aus == 1)&(bereich == 1)    % Nur Ausgang Zeitbereich
    set(h_radio_lin,...               % Setze Radiobutton unbedienbar
      'enable','off');
    set(h_radio_db,...                % Setze Radiobutton unbedienbar
      'enable','off');
    max_aus = max(ausgang);
    min_aus = min(ausgang);
    if (min_aus == max_aus)
      min_aus = max_aus - 1;
    end;
    max_ein = max(eingang);
    min_ein = min(eingang);
    if (min_ein == max_ein)
      min_ein = max_ein - 1;
    end;
    set(h_axes_ein,...                % Aktualisiere Grenzwerte eingangsfolge
      'xlim',[0 max(zeit)],...
      'ylim',[min_ein max_ein],...
      'visible','off');               % Setze Axes Objekt unsichtbar
    set(h_axes_aus,...                % Aktualisiere Grenzwerte Ausgangsfolge
      'xlim',[0 max(zeit)],...
      'ylim',[min_aus max_aus],...
      'position',[0.37 0.25 0.6 0.6]);% Aktualisiere Koordinaten
    axes(h_axes_aus);                 % Aktuelles Objekt = h_axes_aus
    pause(0.1);                       % Pause zum Umschalten auf aktuelles Objekt
    stemm(zeit,ausgang);              % Zeichne Ausgangsfolge im Zeitbereich
    y_lim=get(h_axes_aus,'ylim');     % Senkrechte Begrenzung Ausgangsfolge
    maximum = max(y_lim);             % Maximum der Amplitude
    hoehe = maximum + abs(maximum/100);% Senkrechte Position der Ueberschrift
    x_lim = get(h_axes_aus,'xlim');   % Waagerechte Begrenzung Ausgangsfolge
    breite = (x_lim(2)-x_lim(1))/2;   % Waagerechte Position der Ueberschrift
    text('string','Ausgangsfolge',... % Ueberschrift fuer Axes-Objekt
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_aus',...
        'verticalalignment','bottom',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    hoehe = (y_lim(2)-y_lim(1))/2 + y_lim(1);
    breite = x_lim(1)-breite/4;
    text('string','Amplitude(lin)',... % Beschriftung senkrechte Achse
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_amp_aus',...
        'rotation',90,...
        'verticalalignment','middle',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    text('string','n',...             % Beschriftung waagerechte Achse
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_x_aus',...
        'verticalalignment','bottom',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[x_lim(2) y_lim(1)-(y_lim(2)-y_lim(1))/8]);
    x_lim_ein=get(h_axes_ein,'xlim'); % Lies x-Grenzwerte Eingangsfolge
    y_lim_ein=get(h_axes_ein,'ylim'); % Lies y-Grenzwerte Eingangsfolge
    x_lim_aus=get(h_axes_aus,'xlim'); % Lies x-Grenzwerte Ausgangsfolge
    y_lim_aus=get(h_axes_aus,'ylim'); % Lies y-Grenzwerte Ausgangsfolge
    matrix_lim=[x_lim_ein;y_lim_ein;...
      x_lim_aus;y_lim_aus];           % Speichere Grenzwerte in Matrix
    set(h_push_zoom,'userdata',matrix_lim);% Sichere Matrix in Userdata
  end                                 % Ende von nur Ausgangsfolge Zeitbereich
  if (nur_aus == 0)&(bereich == 2)    % Ein- und Ausgang Fourier
    set(h_radio_lin,...               % Setze Radiobutton bedienbar
      'enable','on');
    set(h_radio_db,...                % Setze Radiobutton bedienbar
      'enable','on');
    if (radio_lin == 1)               % Wenn Amplitude linear
      ylim_ein=[0 max(eingang_spektrum)];% Festlegen der y-Grenzwerte Eingangsspektrum
      ylim_aus=[0 max(ausgang_spektrum)];% Festlegen der y-Grenzwerte Ausgangsspektrum
    elseif (radio_lin == 0)           % Wenn Amplitude in dB
      ylim_ein = [min(eingang_spek_db) max(eingang_spek_db)];% Festlegen der y-Grenzwerte Eingangsspektrum in dB
      if(min(eingang_spek_db) == max(eingang_spek_db))% Wenn alle Amplitudenwerte gleich
        ylim_ein(1) = min(eingang_spek_db) - 10;% Bilde beliebige Differenz fuer Grenzwert
      end
      ylim_aus = [min(ausgang_spek_db) max(ausgang_spek_db)];% Festlegen der y-Grenzwerte Ausgangsspektrum in dB
      if(min(ausgang_spek_db) == max(ausgang_spek_db))% Wenn alle Amplitudenwerte gleich
        ylim_aus(1) = min(ausgang_spek_db) - 10;% Bilde beliebige Differenz fuer Grenzwert
      end
    end                               % Ende von Amplitude linear oder in dB
    set(h_axes_ein,...                % Aktualisiere Grenzwerte Eingangsfolge
      'xlim',[0 0.5],...
      'ylim',ylim_ein,...
      'visible','on');                % Setze Axes Objekt sichtbar
    set(h_axes_aus,...                % Aktualisiere Grenzwerte Ausgangsfolge
      'xlim',[0 0.5],...
      'ylim',ylim_aus,...
      'position',[0.37 0.25 0.6 0.3]);% Aktualisiere Koordinaten
    axes(h_axes_ein);                 % Aktuelles axes-Objekt = h_axes_ein
    pause(0.1);                       % Pause zum Umschalten auf aktuelles Objekt
    if (radio_lin == 1)               % Wenn Amplitude linear
      stemm(ny,eingang_spektrum);     % Zeichne Eingangsspektrum
      string_amp = 'Amplitude(lin)';
    elseif (radio_lin == 0)           % Wenn Amplitude in dB
      stemein(ny,eingang_spek_db);    % Zeichne Eingangsspektrum in dB
      string_amp = 'Amplitude(dB)';
    end                               % Ende von Amplitude linear oder in dB
    y_lim=get(h_axes_ein,'ylim');     % Senkrechte Begrenzung Ausgangsfolge
    maximum = max(y_lim);             % Maximum der Amplitude
    hoehe = maximum + abs(maximum/100);% Senkrechte Position der Ueberschrift
    x_lim = get(h_axes_ein,'xlim');   % Waagerechte Begrenzung Ausgangsfolge
    breite = (x_lim(2)-x_lim(1))/2;   % Waagerechte Position der Ueberschrift
    text('string','Fouriertransformierte Eingangsfolge',...% Ueberschrift fuer Axes-Objekt
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_ein',...
        'verticalalignment','bottom',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    breite = x_lim(1)-breite/4;
    hoehe = (y_lim(2)-y_lim(1))/2 + y_lim(1);
    text('string',string_amp,... % Beschriftung senkrechte Achse
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_amp_ein',...
        'rotation',90,...
        'verticalalignment','middle',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    axes(h_axes_aus);                 % Aktuelles Axes-Objekt = h_axes_aus
    pause(0.1);                       % Pause zum Umschalten auf aktuelles Objekt
    if (radio_lin == 1)               % Wenn Amplitude linear
      stemm(ny,ausgang_spektrum);     % Zeichne Ausgangsspektrum
    elseif (radio_lin == 0)           % Wenn Amplitude in dB
      stemaus(ny,ausgang_spek_db);    % Zeichne Ausgangsspektrum in dB
    end                               % Ende von Amplitude linear oder in dB
    y_lim=get(h_axes_aus,'ylim');     % Senkrechte Begrenzung Ausgangsfolge
    maximum = max(y_lim);             % Maximum der Amplitude
    hoehe = maximum + abs(maximum/100);% Senkrechte Position der Ueberschrift
    x_lim = get(h_axes_aus,'xlim');   % Waagerechte Begrenzung Ausgangsfolge
    breite = (x_lim(2)-x_lim(1))/2;   % Waagerechte Position der Ueberschrift
    text('string','Fouriertransformierte Ausgangsfolge',...% Ueberschrift fuer Axes-Objekt
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_aus',...
        'verticalalignment','bottom',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    breite = x_lim(1)-breite/4;
    hoehe = (y_lim(2)-y_lim(1))/2 + y_lim(1);
    text('string',string_amp,... % Beschriftung senkrechte Achse
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_amp_aus',...
        'rotation',90,...
        'verticalalignment','middle',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    text('string','f/fa',...             % Beschriftung waagerechte Achse
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_x_aus',...
        'verticalalignment','bottom',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[x_lim(2) y_lim(1)-(y_lim(2)-y_lim(1))/4]);
    x_lim_ein=get(h_axes_ein,'xlim'); % Lies x-Grenzwerte Eingangsfolge
    y_lim_ein=get(h_axes_ein,'ylim'); % Lies y-Grenzwerte Eingangsfolge
    x_lim_aus=get(h_axes_aus,'xlim'); % Lies x-Grenzwerte Ausgangsfolge
    y_lim_aus=get(h_axes_aus,'ylim'); % Lies y-Grenzwerte Ausgangsfolge
    matrix_lim=[x_lim_ein;y_lim_ein;...
      x_lim_aus;y_lim_aus];           % Speichere Grenzwerte in Matrix
    set(h_push_zoom,'userdata',matrix_lim);% Sichere Matrix in Userdata
  end                                 % Ende von Ein- und Ausgangsspektrum
  if (nur_aus == 1)&(bereich == 2)    % Nur Ausgang Fourier
    set(h_radio_lin,...               % Setze Radiobutton bedienbar
      'enable','on');
    set(h_radio_db,...                % Setze Radiobutton bedienbar
      'enable','on');
    if (radio_lin == 1)               % Wenn Amplitude linear
      ylim_aus=[0 max(ausgang_spektrum)];% Festlegen y-Grenzwerte Ausgangsfolge
    elseif (radio_lin == 0)           % Wenn Amplitude in dB
      ylim_aus = [min(ausgang_spek_db) max(ausgang_spek_db)];% Festlegen y-Grenzwerte Ausgangsfolge dB
      if(min(ausgang_spek_db) == max(ausgang_spek_db))% Wenn alle Amplitudenwerte gleich
        ylim_aus(1) = min(ausgang_spek_db) - 10;% Bilde beliebige Differenz fuer Grenzwert
      end
    end                               % Ende von Amplitude linear oder in dB
    set(h_axes_ein,...                
      'visible','off');               % Setze Axes Objekt unsichtbar
    set(h_axes_aus,...                % Aktualisiere Grenzwerte Ausgangsfolge
      'xlim',[0 0.5],...
      'ylim',ylim_aus,...
      'position',[0.37 0.25 0.6 0.6]);% Aktualisiere Koordinaten
    axes(h_axes_aus);                 % Aktuelles Axes-Objekt = h_axes_aus
    pause(0.1);                       % Pause zum Umschalten auf aktuelles Objekt
    if (radio_lin == 1)               % Wenn Amplitude linear
      stemm(ny,ausgang_spektrum);     % Zeichne Ausgangsspektrum
      string_amp = 'Amplitude(lin)';
    elseif (radio_lin == 0)           % Wenn Amplitude in dB
      stemaus(ny,ausgang_spek_db);    % Zeichne Ausgangsspektrum in dB
      string_amp = 'Amplitude(dB)';
    end                               % Ende von Amplitude linear oder in dB
    y_lim=get(h_axes_aus,'ylim');     % Senkrechte Begrenzung Ausgangsfolge
    maximum = max(y_lim);             % Maximum der Amplitude
    hoehe = maximum + abs(maximum/100);% Senkrechte Position der Ueberschrift
    x_lim = get(h_axes_aus,'xlim');   % Waagerechte Begrenzung Ausgangsfolge
    breite = (x_lim(2)-x_lim(1))/2;   % Waagerechte Position der Ueberschrift
    text('string','Fouriertransformierte Ausgangsfolge',...      % Ueberschrift fuer Axes-Objekt
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_aus',...
        'verticalalignment','bottom',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    breite = x_lim(1)-breite/4;
    hoehe = (y_lim(2)-y_lim(1))/2 + y_lim(1);
    text('string',string_amp,... % Beschriftung senkrechte Achse
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_amp_aus',...
        'rotation',90,...
        'verticalalignment','middle',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
    text('string','f/fa',...             % Beschriftung waagerechte Achse
        'erasemode','normal',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'tag','text_x_aus',...
        'verticalalignment','bottom',...% Textausrichtung = unten
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[x_lim(2) y_lim(1)-(y_lim(2)-y_lim(1))/8]);
    x_lim_ein=get(h_axes_ein,'xlim'); % Lies x-Grenzwerte Eingangsfolge
    y_lim_ein=get(h_axes_ein,'ylim'); % Lies y-Grenzwerte Eingangsfolge
    x_lim_aus=get(h_axes_aus,'xlim'); % Lies x-Grenzwerte Ausgangsfolge
    y_lim_aus=get(h_axes_aus,'ylim'); % Lies y-Grenzwerte Ausgangsfolge
    matrix_lim=[x_lim_ein;y_lim_ein;...% Speichere Grenzwerte in Matrix
      x_lim_aus;y_lim_aus];
    set(h_push_zoom,'userdata',matrix_lim);% Sichere Matrix in Userdata
  end                                 % Ende von nur Ausgangsspektrum
  h_check_marker = findobj...         % Finde Radiobutton 'marker_an'
    ('tag','marker_an');
  marker_on = get(h_check_marker,...  % Lies Zustand der Checkbox
    'value');
  if marker_on == 1                   % Wenn Marker eingeschaltet
    h_marker = findobj...             % Finde Markerspezifische Objekte
      ('tag','marker');
    h_marker_ein_x = findobj...       % Finde Text-Objekt Eingangsfolge x
      ('tag','marker_ein_x');
    h_marker_ein_y = findobj...       % Finde Text-Objekt Eingangsfolge y
      ('tag','marker_ein_y');
    h_marker_aus_y = findobj...       % Finde Text-Objekt Ausgangsfolge y
      ('tag','marker_aus_y');
    set(h_check_marker,...            % Setze String des Radiobuttons
      'string','Marker an');
    set(h_marker,...                  % Setze Marker-Objekte sichtbar
      'visible','on');
    set(h_marker_ein_x,...            % Setze Text-Objekt sichtbar
      'visible','on');
    set(h_marker_ein_y,...            % Setze Text-Objekt sichtbar
      'visible','on');
    set(h_marker_aus_y,...            % Setze Text-Objekt sichtbar
      'visible','on');
   
     marker_position = get...          % Lies aktuelle Markerposition aus userdata
      (h_marker_ein_x,'userdata');
   h_fig=findobj('tag','netzwerk');
   if (bereich == 1)                 % Zeitbereich darstellen
      set(h_fig,...                   % Setze keypressfcn (Aufruf bei Tastendruck)
        'keypressfcn','markerfi(''key_zeit'');');
      matrix = get(h_check_marker,... % Lies Ein- und Ausgangsfolge aus
        'userdata');                  % userdata
      zeit = matrix(1,:);             % Extrahiere Zeitachse
      eingangsfolge = matrix(2,:);    % Extrahiere Eingangsfolge
      ausgangsfolge = matrix(3,:);    % Extrahiere Ausgangsfolge
      marker_wert_ein=eingangsfolge(marker_position+1);
      marker_wert_aus=ausgangsfolge(marker_position+1);
      axes(h_axes_aus);               % Setze aktuelles Axes-Objekt
      pause(1);                       % Pause zum Umschalten auf aktuelles Objekt
      x_lim_aus=get(h_axes_aus,'xlim');% Lies x-Grenzwerte Ausgangsfolge
      y_lim_aus=get(h_axes_aus,'ylim');% Lies y-Grenzwerte Ausgangsfolge
      line('xdata',[marker_position marker_position],...
        'ydata',y_lim_aus,...         % Senkrechte Markerlinie Ausgangsfolge
        'erasemode','xor',...
        'color','b',...
        'buttondownfcn','markerfi(''catch_zeit'');',...
        'tag','marker_senkrecht_aus');
      line('xdata',x_lim_aus,...      % Waagerechte Markerlinie Ausgangsfolge
        'ydata',[marker_wert_aus marker_wert_aus],...
        'erasemode','xor',...
        'color','b',...
        'userdata',0,...              % Kennzeichnung fuer Zeitbereich
        'tag','marker_waagerecht_aus');
      set(h_marker_aus_y,...          % Amplitude Ausgangsfolge an der aktuellen
        'string',marker_wert_aus);    % Markerposition
      set(h_marker_ein_x,...          % Aktuelle Markerposition
        'string',marker_position);    
      if (nur_aus == 0)               % Ein- und Ausgangsfolge
        axes(h_axes_ein);             % Setze aktuelles Axes-Objekt
        pause(1);                     % Pause zum Umschalten auf aktuelles Objekt
        x_lim_ein=get(h_axes_ein,'xlim');% Lies x-Grenzwerte Eingangsfolge
        y_lim_ein=get(h_axes_ein,'ylim');% Lies y-Grenzwerte Eingangsfolge
        line('xdata',[marker_position marker_position],...
          'ydata',y_lim_ein,...       % Senkrechte Markerlinie Eingangsfolge
          'erasemode','xor',...
          'color','b',...
          'buttondownfcn','markerfi(''catch_zeit'');',...
          'tag','marker_senkrecht_ein');
        line('xdata',x_lim_ein,...    % Waagerechte Markerlinie Eingangsfolge
          'ydata',[marker_wert_ein marker_wert_ein],...
          'erasemode','xor',...
          'color','b',...
          'tag','marker_waagerecht_ein');
        set(h_marker_ein_y,...        % Amplitude Eingangsfolge an der aktuellen
          'string',marker_wert_ein);  % Markerposition
      end                             % Ende von Ein- und Ausgangsfolge
    end                               % Ende von bereich = 1
    if (bereich == 2)                 % Frequenzbereich darstellen
      matrix = get(h_marker_ein_y,... % Lies Spektrum aus userdata
        'userdata');
      ny = matrix(1,:);               % Extrahiere Frequenz
      eingang_spektrum = matrix(2,:); % Extrahiere Spektrum des Eingangssignals
      ausgang_spektrum = matrix(3,:); % Extrahiere Spektrum des Aingangssignals
      eingang_spek_db = matrix(4,:);  % Extrahiere Spektrum des Eingangssignals dB
      ausgang_spek_db = matrix(5,:);  % Extrahiere Spektrum des Aingangssignals dB
      marker_index = marker_position; % Position entspricht Index der Matrix
      marker_position = 0.5 / length(ny) *  marker_position;% Berechne Markerposition Frequenz
      if (radio_lin == 1)             % Amplitude linear
        marker_wert_ein=eingang_spektrum(marker_index+1);% Lies Amplitudenwert aus Matrix
        marker_wert_aus=ausgang_spektrum(marker_index+1);% Lies Amplitudenwert aus Matrix
        string_ein = [num2str(marker_wert_ein)];
        string_aus = [num2str(marker_wert_aus)];
      elseif (radio_lin == 0)         % Amplitude in dB
        marker_wert_ein = eingang_spek_db(marker_index+1);% Lies Amplitudenwert aus Matrix
        marker_wert_aus = ausgang_spek_db(marker_index+1);% Lies Amplitudenwert aus Matrix
        string_ein = [num2str(marker_wert_ein) ' dB'];
        string_aus = [num2str(marker_wert_aus) ' dB'];
      end                             % Ende von Amplitude linear oder in dB
      axes(h_axes_aus);               % Setze aktuelles Axes-Objekt
      pause(1);                       % Pause zum Umschalten auf aktuelles Objekt
      x_lim_aus=get(h_axes_aus,'xlim');% Lies x-Grenzwerte Ausgangsfolge
      y_lim_aus=get(h_axes_aus,'ylim');% Lies y-Grenzwerte Ausgangsfolge
      line('xdata',[marker_position marker_position],...
        'ydata',y_lim_aus,...         % Senkrechte Markerlinie Ausgangsfolge
        'erasemode','xor',...
        'color','b',...
        'buttondownfcn','markerfi(''catch_fft'');',...
        'tag','marker_senkrecht_aus');
      line('xdata',x_lim_aus,...      % Waagerechte Markerlinie Ausgangsfolge
        'ydata',[marker_wert_aus marker_wert_aus],...
        'erasemode','xor',...
        'color','b',...
        'userdata',1,...     % Kennzeichnung fuer FFT
        'tag','marker_waagerecht_aus');
      set(h_marker_aus_y,...          % Amplitudenwert Ausgangsspektrum an aktueller
        'string',string_aus);         % Markerposition
      set(h_marker_ein_x,...          % Aktuelle Markerposition
        'string',marker_position);
      if (nur_aus == 0)               % Ein- und Ausgangsfolge
        axes(h_axes_ein);             % Setze aktuelles Axes-Objekt
        pause(1);                     % Pause zum Umschalten auf aktuelles Objekt
        x_lim_ein=get(h_axes_ein,'xlim');% Lies x-Grenzwerte Eingangsfolge
        y_lim_ein=get(h_axes_ein,'ylim');% Lies y-Grenzwerte Eingangsfolge
        line('xdata',[marker_position marker_position],...
          'ydata',y_lim_ein,...       % Senkrechte Markerline Eingangsfolge
          'erasemode','xor',...
          'color','b',...
          'buttondownfcn','markerfi(''catch_fft'');',...
          'tag','marker_senkrecht_ein');
        line('xdata',x_lim_ein,...    % Waagerechte Markerline Eingangsfolge
          'ydata',[marker_wert_ein marker_wert_ein],...
          'erasemode','xor',...
          'color','b',...
          'tag','marker_waagerecht_ein');
        set(h_marker_ein_y,...        % Wert Amplitude Eingangsspektrum aktuelle
          'string',string_ein);       % Markerposition
      end                             % Ende von Ein- und Ausgangsfolge
    end                               % Ende von Bereich = 2
  end                                 % Ende von Marker ein
end                                   % Ende von zeit_fft


% ------------------ closed -------------------------------------------------
if strcmp(command_str,'closed')       % Wenn command_str = closed
  h_check_zoom = findobj...           % Finde ton 'zoom_ursprung'
    ('tag','zoom_an');
  set(h_check_zoom,...                % Schalte Zoom aus
    'value',0);
  zoomfilt('zoom_on_off');            % Aufruf von zoomfilt.m
  delete(h_check_zoom);               % Entferne es
  h_push_zoom = findobj...            % Finde Pushbutton 'zoom_ursprung'
    ('tag','zoom_ursprung');
  delete(h_push_zoom);                % Entferne es
  h_radio_marker = findobj...         % Finde Radiobutton 'marker_an'
    ('tag','marker_an');
  delete(h_radio_marker);             % Entferne es
  h_marker = findobj...               % Finde Markerspezifische Objekte
    ('tag','marker');
  delete(h_marker);                   % Entferne sie
  h_marker = findobj...               % Finde Text-Objekt 'Marker_ein_y'
    ('tag','marker_ein_y');
  delete(h_marker);                   % Entferne es
  h_marker = findobj...               % Finde Text-Objekt 'Marker_ein_x'
    ('tag','marker_ein_x');
  delete(h_marker);                   % Entferne es
  h_marker = findobj...               % Finde Text-Objekt 'Marker_aus_y'
    ('tag','marker_aus_y');
  delete(h_marker);                   % Entferne es
  h_quit = findobj('tag','quit');     % Finde Pushbutton 'quit'
  set(h_quit,...
      'enable','off',...              % Setze Pushbutton inaktiv
      'callback','');                 % Ruecksetzen Callback
  h_axes_aus = findobj('tag',...      % Finde axes Objekt 'ausgangsfolge'
        'ausgangsfolge');
  h_push_ueber = findobj...           % Finde Pushbutton 'quant_uebernehmen'
    ('tag','quant_uebernehmen');
  callback_string = get...            % Lies callback des Pushbuttons
    (h_axes_aus,'userdata');
  set(h_push_ueber,...                % Aktualisiere Callback des Pushbuttons
    'callback',callback_string);
  delete(h_axes_aus);                 % und entferne es
  h_axes_ein = findobj('tag',...      % Finde axes Objekt 'eingangsfolge'
        'eingangsfolge');
  delete(h_axes_ein);                 % und entferne es
  h_frame = findobj('tag',...         % Finde Objekt 'filtant_frame'
        'filtant_frame');
  delete(h_frame);                    % und entferne es
  h_fft = findobj('tag',...           % Finde Objekt 'fft'
        'fft');
  delete(h_fft);                      % und entferne es
  h_radio_aus = findobj...            % Finde Radiobutton 'filtant_aus'
    ('tag','filtant_aus');
  delete(h_radio_aus);                % Entferne es
  h_radio_ein_aus = findobj...        % Finde Radiobutton 'filtant_ein_aus'
    ('tag','filtant_ein_aus');
  delete(h_radio_ein_aus);            % Entferne es
  h_radio_lin = findobj...            % Finde Radiobutton 'filtant_lin'
    ('tag','filtant_lin');
  delete(h_radio_lin);                % Entferne es
  h_radio_db = findobj...             % Finde Radiobutton 'filtant_db'
    ('tag','filtant_db');
  delete(h_radio_db);                 % Entferne es
  h_frame = findobj('tag',...         % Finde Objekt 'filtant_frame'
    'lin_db_frame');
  delete(h_frame);                    % und entferne es
  h_struktur = findobj('tag','axes'); % Handle axes fuer Netzwerkstruktur
  h_children = get(h_struktur,...     % Handles der Netzwerkkomponenten
        'children');
  set(h_children,'visible','on');     % Setze Netzwerkkomponenten sichtbar
  h_popup = findobj('tag','struktur',...% Finde Popupmenue 'struktur'
        'style','popupmenu');
  set(h_popup,'callback','netzwerk;');% Setze Callback auf urspruenglichen Wert
  h_systemantwort=findobj...          % Finde Pushbutton 'filterung'
    ('tag','antwort');
  set(h_systemantwort,...             % Setze Pushbutton aktiv
    'enable','on');
  netzwerk;                           % Aufruf von netzwerk.m
  set(h_check_ansicht,...             % Setze Checkbox 'ansicht' enable
    'enable','on');
  h_filterbank = findobj...           % Finde Pushbutton 'filterbank'
    ('tag','filterbank');
  set(h_filterbank,...                % Setze Pushbutton aktiv
    'enable','on');
  h_speichern = findobj...            % Finde Pushbutton 'speichern'
    ('tag','speichern');
  set(h_speichern,...                 % Setze Pushbutton aktiv
    'enable','on');
   h_laden = findobj...            % Finde Pushbutton 'laden'
    ('tag','laden');
  set(h_laden,...                 % Setze Pushbutton aktiv
    'enable','on');
  h_pn = findobj...                   % Finde Pushbutton 'p_n_dia'
    ('tag','p_n_dia');
  set(h_pn,...                        % Setze Pushbutton aktiv
    'enable','on');
  h_pop_fft = findobj...              % Finde Popupmenue 'FFT'
    ('tag','FFT');
  set(h_pop_fft,...                   % Setze Popupmenue aktiv
    'enable','on');
  h_check_quant = findobj('tag',...   % Check Box 'Quantisierung'
        'quantisierung'); 
  quantisierung = get(h_check_quant,'value'); % 0: keine Quantisierung
                                              % 1: Quantisierung
  h_pop_arith = findobj('tag',... % Finde Popupmenü 'arithmetik'
        'arithmetik');
  arithmetik = get(h_pop_arith,'value'); % 1: Gleitkomma, 2: Festkomma
  if (arithmetik == 2)            % Wenn Festkommaarithmetik
    h_einheitsimpuls = findobj... % Finde Textobjekt 'Einheitsimpuls:'
      ('tag','festkomma',...
       'string','Einheitsimpuls:');
    set(h_einheitsimpuls,...      % Setze Textobjekt sichtbar
       'visible','on');
    h_edit_puls = findobj...      % Finde Editobjekt 'Einheitsimpuls'
      ('tag','festkomma',...
       'userdata',1);
    set(h_edit_puls,...           % Setze Editobjekt sichtbar
       'visible','on');
  end                             % Ende von Festkomaarithmetik
h_fig = findobj('tag','netzwerk');  % Finde Figure-Objekt 'netzwerk'
set(h_fig,'windowbuttondownfcn','');
end                                   % Ende von command_str = closed
