function pn_darst(command_str)
% PN_DARST
%
% Die Funktion stellt das quantisierte und oder nicht quantisierte
% PN-Diagramm der aktuellen Struktur dar
% Funktionsaufruf
%   pn_darst
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

farbe = [0.752 0.752 0.752];

if nargin == 0
 command_str = 'init';
end

if strcmp(command_str,'init')
  h_fig = findobj...                  % Finde Figure-Objekt 'netzwerk'
    ('tag','netzwerk');
  h_push_ueber = findobj...           % Finde Pushbutton 'quant_uebernehmen'
    ('tag','quant_uebernehmen');
  callback_string = get...            % Lies callback des Pushbuttons
    (h_push_ueber,'callback');
  set(h_push_ueber,...                % Aktualisiere Callback des Pushbuttons
    'callback','pn_darst(''matrix'');');
  h_axes = findobj...                 % Finde Axes-Objekt 'axes' fuer Struktur
    ('tag','axes');
  h_children = get...                 % Ermittle Nachkommen von Axes
    (h_axes,'children');
  set(h_children,'visible','off');    % Entferne Nachkommen
  h_quit = findobj...                 % Finde Pushbutton 'quit'
    ('tag','quit');
  set(h_quit,...                        
    'enable','on',...                 % Setze Pushbutton bedienbar
    'callback','pn_darst(''close'');');% Setze callback
  h_pop_struktur = findobj...         % Finde Popupmenue 'struktur'
    ('tag','struktur');
  set(h_pop_struktur,...              % Setze Popupmenue unbedienbar
    'enable','off');
  h_radio_ansicht = findobj...        % Finde Radiobutton 'ansicht'
    ('tag','ansicht');
  set(h_radio_ansicht,...             % Setze Radiobutton unbedienbar
    'enable','off');
  h_slider_senk = findobj...          % Finde Handle des senkrechten sliders
    ('tag','slidery');
  set(h_slider_senk,...               % Setze senkrechten Scrollbalken unsichtbar
    'visible','off');
  h_slider_waag = findobj...          % Finde Handle des waagerechten sliders
    ('tag','slider');
  set(h_slider_waag,...               % Setze waagerechten Scrollbalken unsichtbar
    'visible','off');
  h_push_ant = findobj...             % Finde Pushbutton 'antwort'
    ('tag','antwort');
  set(h_push_ant,...                  % Setze Pushbutton unbedienbar
    'enable','off');
  h_push_pn = findobj...              % Finde Pushbutton 'p_n_dia'
    ('tag','p_n_dia');
  set(h_push_pn,...                   % Setze Pushbutton unbedienbar
    'enable','off');
  h_push_tausch = findobj...          % Finde Pushbutton 'tauschen'
    ('tag','tauschen');
  set(h_push_tausch,...               % Setze Pushbutton unbedienbar
    'enable','off');
  h_push_rueck = findobj...           % Finde Pushbutton 'rueckgaengig'
    ('tag','rueckgaengig');
  set(h_push_rueck,...                % Setze Pushbutton unbedienbar
    'enable','off');
  h_skalieren= findobj('tag','Skalierung');% Checkbox Skalierung finden
  set (h_skalieren,'enable','off');	% inaktiv setzen
  h_push_filt = findobj...            % Finde Pushbutton 'filterung'
    ('tag','filterung');
  set(h_push_filt,...                 % Setze Pushbutton unbedienbar
    'enable','off');
  h_push_gene = findobj...            % Finde Pushbutton 'generator'
    ('tag','generator_mat');
  set(h_push_gene,...                 % Setze Pushbutton unbedienbar
    'enable','off');
  h_check_quant = findobj...          % Finde Checkbox 'quantisierung'
    ('tag','quantisierung');
  command_str = 'matrix';
  h_filterbank = findobj...           % Finde Pushbutton 'filterbank'
    ('tag','filterbank');
  set(h_filterbank,...                % Setze Pushbutton inaktiv
    'enable','off');
  h_speichern = findobj...            % Finde Pushbutton 'speichern'
    ('tag','speichern');
  set(h_speichern,...                 % Setze Pushbutton inaktiv
    'enable','off');
   h_laden = findobj...            % Finde Pushbutton 'laden'
    ('tag','laden');
  set(h_laden,...                 % Setze Pushbutton inaktiv
    'enable','off');
  h_pn = findobj...                   % Finde Pushbutton 'p_n_dia'
    ('tag','p_n_dia');
  set(h_pn,...                        % Setze Pushbutton inaktiv
    'enable','off');
  h_pop_fft = findobj...              % Finde Popupmenue 'FFT'
    ('tag','FFT');
  set(h_pop_fft,...                   % Setze Popupmenue inaktiv
    'enable','off');
  h_push_hilfe = findobj...           % Finde Pushbutton 'Hilfe'
    ('tag','hilfe');
  callback_str = get(h_push_hilfe,... % Finde alten callback
    'callback');
  set(h_push_hilfe,...                % Sichere alten Callback in Userdata
    'userdata',callback_str,...
    'callback','!winhelp struktur\pn_darst.hlp');% Setze aktuelle Hilfe
  screen = get(0,'screensize');       % Ermittle Bildschirmdaten
  breite = screen(3);                 % Extrahiere Bildschirmbreite
  hoehe = screen(4);                  % Extrahiere Bildschirmhoehe
  hoehe_axes = 0.6;
  breite_axes = hoehe_axes * hoehe / breite;
  y_lim = [-1.5 1.5];                 % Senkrechte Grenzwerte
  x_lim = y_lim;                      % Waagerechte Grenzwerte
  h_axes_pn=axes('position',[0.37 0.35 breite_axes hoehe_axes],...% Position und Ausdehnung
        'xcolor',[0 0 0],...          % Farbe x-Achse = Schwarz
        'ycolor',[0 0 0],...          % Farbe y-Achse = Schwarz
        'xgrid','on',...              % Gitter in x-Richtung an
        'ygrid','on',...              % Gitter in y-Richtung an
        'xlim',x_lim,...
        'ylim',y_lim,...
        'box','on',...
        'tag','pn_diagramm',...
        'drawmode','fast',...
        'userdata',callback_string,...% Alter Callback von Pushbutton uebernehmen
        'color',[1 1 1],...           % Farbe = Weiss
        'nextplot','add');            % Aeltere Plots bleiben erhalten


  uicontrol(h_fig,...                 % Rahmen fuer untere Bedienelemente
      'style','frame',...       
      'units','normalized',...
      'tag','pn_frame',...            % Bezeichnung des Rahmens
      'backgroundcolor',farbe,...
      'position',[0.2 0 0.8 0.16]);

  % ------------------ Darstellung Quantisiert/nicht Quantisiert ------------
  unten = 0.01;
  links = 0.21;
  uicontrol(h_fig,...                 % Rahmen fuer Radiobuttons
      'style','frame',...             % Darstellung Ein/Ausgangsfolge
      'units','normalized',...
      'tag','pn_frame',...            % Bezeichnung des Rahmens
      'backgroundcolor',farbe,...
      'position',[links unten 0.19 0.08]);
  uicontrol(h_fig,...                 % Radiobutton fuer nur Ausgangsfolge
      'style','checkbox',...      
      'string','Quantisiert',...      % Beschriftung des Radiobuttons
      'units','normalized',...
      'enable','on',...
      'visible','on',...
      'value',1,...
      'tag','pn_quantisiert',...      % Bezeichnung des Radiobuttons
      'callback','pn_darst(''darstellung'');',...% Bei Betaetigung
      'backgroundcolor',farbe,...
      'position',[links+0.01 unten+0.01 0.17 0.03]);
  uicontrol(h_fig,...                 % Radiobutton fuer Ein- Ausgangsfolge
      'style','checkbox',...       
      'string','Rechnergenau',...     % Beschriftung des Radiobuttons
      'units','normalized',...
      'enable','on',...
      'visible','on',...
      'value',1,...
      'tag','pn_unquantisiert',...    % Bezeichnung des Radiobuttons
      'callback','pn_darst(''darstellung'');',...% Bei Betaetigung
      'backgroundcolor',farbe,...
      'position',[links+0.01 unten+0.04 0.17 0.03]);

    % ---------------- Bediengruppe Zoom ------------------------------------
    unten = 0.1;
    links = 0.21;
    uicontrol(h_fig,...               % Checkbox fuer Zoom
        'style','checkbox',...      
        'string','Zoom',...           % Beschriftung der Checkbox
        'units','normalized',...
        'enable','on',...
        'visible','on',...
        'value',0,...
        'tag','zoom_an',...           
        'callback','zoompn(''zoom_on_off'');',...% Bei Betaetigung
        'backgroundcolor',farbe,...
        'position',[links unten 0.08 0.04]);
    h_push_zoom = uicontrol(h_fig,... % Pushbutton fuer Zoom
        'style','pushbutton',...      % Bei Betaetigung Ursprungskoordinaten
        'string','1:1',...            % Beschriftung des Pushbuttons
        'units','normalized',...
        'enable','on',...
        'visible','on',...
        'tag','zoom_ursprung',...           
        'callback','zoompn(''ursprung'');',...% Bei Betaetigung
        'backgroundcolor',farbe,...
        'position',[links+0.09 unten 0.1 0.04]);

    matrix_lim=[x_lim;y_lim];         % Speichere Grenzwerte in Matrix
    set(h_push_zoom,'userdata',matrix_lim);% Sichere Matrix in userdata

    % ------------------ Bediengruppe Marker --------------------------------
    links = 0.42;
    unten = 0.01;
    uicontrol(h_fig,...               % Rahmen fuer Marker
        'style','frame',...       
        'units','normalized',...
        'visible','on',...
        'tag','marker',...            
        'backgroundcolor',farbe,...
        'position',[links-0.01 unten 0.43 0.14]);

    uicontrol(h_fig,...               % Checkbox fuer Marker
        'style','checkbox',...        % Ein- und Ausschalten des Markers
        'string','Marker',...         % Beschriftung der Checkbox
        'units','normalized',...
        'enable','on',...
        'visible','on',...
        'value',0,...
        'tag','marker_an',...         % Bezeichnung der Checkbox
        'callback','markerpn(''marker_on_off'');',...% Bei Betaetigung
        'backgroundcolor',farbe,...
        'position',[links unten+0.10 0.1 0.03]);

    uicontrol(h_fig,...               % Pushbutton fuer Marker
        'style','pushbutton',...      % Bei Betaetigung Ursprungskoordinaten
        'string','N',...              % Beschriftung des Pushbuttons
        'units','normalized',...
        'enable','on',...
        'visible','on',...
        'callback','markerpn(''moved'');',...% Bei Betaetigung
        'backgroundcolor',farbe,...
        'tag','marker',...
        'position',[links+0.26 unten+0.1 0.03 0.03]);
    uicontrol(h_fig,... % Pushbutton fuer Marker
        'style','pushbutton',...      % Bei Betaetigung Ursprungskoordinaten
        'string','<',...              % Beschriftung des Pushbuttons
        'units','normalized',...
        'enable','on',...
        'visible','on',...
        'callback','markerpn(''moved'');',...% Bei Betaetigung
        'tag','marker',...
        'backgroundcolor',farbe,...
        'position',[links+0.29 unten+0.1 0.03 0.03]);
    uicontrol(h_fig,... % Pushbutton fuer Marker
        'style','pushbutton',...      % Bei Betaetigung Ursprungskoordinaten
        'string','>',...              % Beschriftung des Pushbuttons
        'units','normalized',...
        'enable','on',...
        'visible','on',...
        'callback','markerpn(''moved'');',...% Bei Betaetigung
        'tag','marker',...
        'backgroundcolor',farbe,...
        'position',[links+0.32 unten+0.1 0.03 0.03]);
    uicontrol(h_fig,... % Pushbutton fuer Marker
        'style','pushbutton',...      % Bei Betaetigung Ursprungskoordinaten
        'string','P',...              % Beschriftung des Pushbuttons
        'units','normalized',...
        'enable','on',...
        'visible','on',...
        'callback','markerpn(''moved'');',...% Bei Betaetigung
        'tag','marker',...
        'backgroundcolor',farbe,...
        'position',[links+0.35 unten+0.1 0.03 0.03]);


    uicontrol(h_fig,...               % Text fuer Marker Pol- oder Nullstelle
        'style','text',...       
        'string','',...
        'units','normalized',...
        'visible','on',...
        'tag','marker_objekt',...            
        'backgroundcolor',farbe,...
        'position',[links unten+0.04 0.07 0.03]);
    uicontrol(h_fig,...               % Text fuer Marker Pol- oder Nullstelle
        'style','text',...       
        'string','',...
        'units','normalized',...
        'visible','on',...
        'tag','marker_objekt',...            
        'backgroundcolor',farbe,...
        'position',[links unten+0.01 0.07 0.03]);
    uicontrol(h_fig,...               % Text fuer Marker
        'style','text',...       
        'string','Rechnergenau',...
        'units','normalized',...
        'visible','on',...
        'tag','marker',...            
        'backgroundcolor',farbe,...
        'position',[links+0.07 unten+0.04 0.14 0.03]);
    uicontrol(h_fig,...               % Text fuer Marker
        'style','text',...       
        'string','Quantisiert',...
        'units','normalized',...
        'visible','on',...
        'tag','marker',...            
        'backgroundcolor',farbe,...
        'position',[links+0.07 unten+0.01 0.14 0.03]);
    uicontrol(h_fig,...               % Text fuer Marker
        'style','text',...       
        'string','Realteil',...
        'units','normalized',...
        'visible','on',...
        'tag','marker',...            
        'backgroundcolor',farbe,...
        'position',[links+0.2 unten+0.07 0.1 0.03]);
    uicontrol(h_fig,...               % Text fuer Marker
        'style','text',...       
        'string','',...
        'units','normalized',...
        'visible','on',...
        'tag','marker_unqu_real',...            
        'backgroundcolor',farbe,...
        'position',[links+0.2 unten+0.04 0.1 0.03]);
    uicontrol(h_fig,...               % Markerposition
        'style','text',...            % Stellt aktuelle Markerposition auf
        'string','',...               % Bildschirm dar
        'units','normalized',...
        'visible','on',...
        'tag','marker_quant_real',...          
        'backgroundcolor',farbe,...
        'position',[links+0.2 unten+0.01 0.1 0.03]);
    uicontrol(h_fig,...               % Text fuer Marker
        'style','text',...       
        'string','Imaginärteil',...
        'units','normalized',...
        'visible','on',...
        'tag','marker',...            
        'backgroundcolor',farbe,...
        'position',[links+0.3 unten+0.07 0.1 0.03]);
    uicontrol(h_fig,...               % Text fuer Marker
        'style','text',...       
        'string','',...
        'units','normalized',...
        'visible','on',...
        'tag','marker_unqu_imag',...            
        'backgroundcolor',farbe,...
        'position',[links+0.3 unten+0.04 0.1 0.03]);
    uicontrol(h_fig,...               % Markerposition
        'style','text',...            % Stellt aktuelle Markerposition auf
        'string','',...               % Bildschirm dar
        'units','normalized',...
        'visible','on',...
        'tag','marker_quant_imag',...          
        'backgroundcolor',farbe,...
        'position',[links+0.3 unten+0.01 0.1 0.03]);
end                                   % Ende von init



if strcmp(command_str,'matrix')
  h_pop_struktur = findobj...         % Finde Popupmenue 'struktur'
    ('tag','struktur');
  f_struktur = get...                 % Lies dargestellte Struktur
    (h_pop_struktur,'value');
  [matrix,rech,spei,quantisierung,arithmetik,sort_folge]= quamat (f_struktur);		% Quantisierungsdaten ermitteln
											% und Filter-Matrix erstellen
  command_str = 'pn';
end;                                  % Ende von matrix


if strcmp(command_str,'pn')           % Berechnen der Pole
  h_axes_pn = findobj...              % Finde Axes-Objekt 'pn_diagramm'
    ('tag','pn_diagramm');
  h_child = get(h_axes_pn,'children');% Finde Nachkommen von Axes-Objekt
  delete(h_child);                    % Entferne sie
  axes(h_axes_pn);                    % Aktuelles Axes-Objekt
  x = cos([0:10:360]*(pi/180));       % Einheitskreis
  y = sin([0:10:360]*(pi/180));
  h_line = plot(x,y,'k:');
  x_lim = get(h_axes_pn,'xlim');
  y_lim = get(h_axes_pn,'ylim');
  minimum = min(y_lim);               % Minimum senkrechter Grenzwert
  hoehe = minimum - (y_lim(2)-y_lim(1))/10;% Senkrechte Position der Ueberschrift
  breite = x_lim(1) + (x_lim(2)-x_lim(1))/2;   % Waagerechte Position der Ueberschrift
  text('string','Re(z)',...           % Ueberschrift fuer Axes-Objekt
       'erasemode','normal',...
       'color',[0 0 0],...            % Farbe = Schwarz
       'tag','text_real',...
       'verticalalignment','top',...  % Textausrichtung = unten
       'horizontalalignment','center',...% Textausrichtung = zentriert
       'position',[breite hoehe]);
  breite = x_lim(1)-(x_lim(2)-x_lim(1))/8;
  hoehe = (y_lim(2)-y_lim(1))/2 + y_lim(1);
  text('string','Im(z)',...           % Beschriftung senkrechte Achse
       'erasemode','normal',...
       'color',[0 0 0],...            % Farbe = Schwarz
       'tag','text_im',...
       'rotation',90,...
       'verticalalignment','middle',...% Textausrichtung = unten
       'horizontalalignment','center',...% Textausrichtung = zentriert
       'position',[breite hoehe]);

  minimum = min(y_lim);
  hoehe = minimum - 0.2*abs(y_lim(2) - y_lim(1));
  breite = min(x_lim);
  links = breite + 0.3*abs(x_lim(2) - x_lim(1));
  text('string','-- rechnergenau',...     % Beschriftung Legende
        'erasemode','normal',...
        'FontSize',9,...
        'color',[1 0 0],...          % Farbe = rot
	'tag','rech_text',...
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[breite hoehe]);
  text('string','-- quantisiert',...     % Beschriftung Legende
        'erasemode','normal',...
        'FontSize',9,...
        'color',[0 0 0],...          % Farbe = Schwarz
        'tag','quant_text',...
        'horizontalalignment','center',...% Textausrichtung = zentriert
        'position',[links hoehe]);



  h_pop_struktur = findobj...         % Finde Popupmenue 'struktur'
    ('tag','struktur');
  f_struktur = get...                 % Lies dargestellte Struktur
    (h_pop_struktur,'value');
  h_check_quant = findobj...          % Finde Checkbox 'quantisierung'
    ('tag','quantisierung');
  quantisierung = get...              % Lies Zustand der Checkbox
    (h_check_quant,'value');
  h_pop_arit = findobj...             % Finde Popupmenue 'arithmetik'
    ('tag','arithmetik');
  arithmetik = get...                 % Lies Zustand des Popupmenues
    (h_pop_arit,'value');
  h_systemantwort = findobj...        % Finde Pushbutton 'antwort'
    ('tag','antwort');
  matrix = get...                     % Lies Koeffizienten-Matrix
    (h_systemantwort,'userdata');     % aus Userdata
  if (f_struktur == 1) | (f_struktur == 2) | (f_struktur == 3)  %Direktform, 1. und 2. kanonische
    if (quantisierung == 1)           % Wenn Quantisierung an
      groesse = size(matrix);         % Ermittle Groesse der Matrix
      reihen = groesse(1);            % Extrahiere Reihen
      ahilf=matrix(2:reihen,2);       % Koeffizienten zuweisen
      ahilf = ahilf';                 % Umwandlung in Reihenvektor
      pol_quant = roots(ahilf);       % Quantisierte Pole ermitteln
      bhilf=matrix(2:reihen,1);       % Koeffizienten zuweisen
      bhilf = bhilf';                 % Umwandlung in Reihenvektor
      null_quant = roots(bhilf);      % Quantisierte Nullstellen ermitteln
    end                               % Ende von Quantisierung an
  end                                 % Ende von direkt oder 1.kano oder 2.kano

  if (f_struktur == 4)                % Kaskade
    if (quantisierung == 1)           % Wenn Quantisierung an
      groesse = size(matrix);         % Ermittle Groesse der Matrix
      pol_quant = [];
      null_quant = [];
      for index = 2:groesse(1)        % 2. bis letzte Reihe
        pol_quant = [pol_quant;roots(matrix(index,4:6))];
        null_quant = [null_quant;roots(matrix(index,1:3))];
      end
    end                               % Ende von Quantisierung an
  end                                 % Ende von Kaskade


  if (f_struktur == 5)                % Kaskade normiert
    if (quantisierung == 1)           % Wenn Quantisierung an
      groesse = size(matrix);         % Ermittle Groesse der Matrix
      pol_quant = [];
      null_quant = [];
      matrix_hilf = matrix;
      for index = 2:groesse(1)
        matrix_hilf(index,2:7) = matrix_hilf(index,2:7) .* matrix_hilf(index,1);
        pol_quant = [pol_quant;roots(matrix(index,5:7))];
        null_quant = [null_quant;roots(matrix(index,2:4))];
      end
    end                               % Ende von Quantisierung an
  end                                 % Ende von Kaskade normiert


  if (f_struktur == 6)                % Lattice Ladder
    if (quantisierung == 1)           % Wenn Quantisierung an
      groesse = size(matrix);         % Ermittle Groesse der Matrix
      k = matrix(2:(groesse(1)-1),1); % kappa = 1.Spalte ab 2.Reihe bis vorletzte Reihe
      k = k';                         % Umwandlung in Reihenvektor
      c = matrix(2:groesse(1),2);     % nu = 2.Spalte ab 2.Reihe
      c = c';                         % Umwandlung in Reihenvektor
      [bhilf,ahilf] = lat2dir(k,c);   % Lattice- in Direktform
      pol_quant = roots(ahilf);       % Quantisierte Pole ermitteln
      null_quant = roots(bhilf);      % Quantisierte Nullstellen ermitteln
    end                               % Ende von Quantisierung an
  end                                 % Ende von Parallelformd


  if (f_struktur == 7)                % Parallelform
    if (quantisierung == 1)           % Wenn Quantisierung an
      groesse = size(matrix);         % Ermittle Groesse der Matrix
      C = matrix(2:groesse(1),1);     % Ab 2.Reihe jeweils erste Spalte
      C = C';                         % Spaltenvektor in Reihenvektor
      while (C(length(C)) == 0 & length(C) > 1)  % Solange der letzte Koeffizient = 0
         C = C(1:(length(C))-1);       % Letzten Koeffizienten abspalten
      end
      pol_quant = [];
      matrix_hilf = matrix;
      for index = 2:groesse(1)
        pol_quant = [pol_quant;roots(matrix(index,5:7))];
      end
      B = matrix(2:groesse(1),2:3);   % B = 2. und 3.Spalte ab 2.Reihe
      A = matrix(2:groesse(1),5:7);   % A = 5. bis 7.Spalte ab 2.Reihe
      [bhilf,ahilf] = par2dir(C,B,A); % Parallel- in Direktform
      null_quant = roots(bhilf);      % Quantisierte Nullstellen ermitteln
    end                               % Ende von Quantisierung an
  end                                 % Ende von Parallelformd
  
  if (f_struktur == 4) | (f_struktur == 5) | (f_struktur == 7)  
    h_axes_z = findobj('tag','axes_h(z)','type','axes');
    set (h_axes_z,'buttondownfcn','');  
 end
 pol_quant=sort(pol_quant);
 null_quant=sort(null_quant);
  
    % ----------unquantisierte nullstellen plotten --------------------------
    null = sort(roots(b));            % Ermittle unquantisierte Polstellen
    laenge_null = length(null);       % Laenge des Polstellenvektors
    old = [];                         % Alte Nullstelle
    hilf = 1;                         % Anzahl der Nullstellen einer Mehrfachnullstelle
    h_radio_unqu = findobj...         % Finde Radiobutton 'unquantisiert'
      ('tag','pn_unquantisiert');
    set(h_radio_unqu,...              % Speichere Anzahl Pol- bzw. Nullstellen
      'userdata',laenge_null);        % in Userdata
    for n = 1:laenge_null             % Mit Nullstellenvektor
      zahl = null(n);                 % Aktuelle Nullstelle
      real_zahl = real(zahl);         % Realteil der Nullstelle
      imag_zahl = imag(zahl);         % Imaginaerteil der Nullstelle
      if ~isempty(old)
        if (zahl == old)                % Wenn Mehrfachnullstelle
          hilf = hilf + 1;              % Erhoehe Anzahl Nullstellen
        end
      end 
      h_null = plot...                % Plotte Nullstelle
        (real_zahl,imag_zahl,'or');
      set(h_null,...
        'tag','nullstelle',...        % Kennzeichne Plot als Nullstelle
        'userdata',n');               % Nummer der Nullstelle
      if (hilf > 1) & ((n == laenge_null) | (old ~= zahl)) % Mehrfachnullstelle
        real_old = real(old);         % Waagerechte Koordinate der Mehrfachnullstelle
        imag_old = imag(old);         % Senkrechte Koordinate der Mehrfachnullstelle
        hoehe = imag_old - (y_lim(2)-y_lim(1))/20;% Senkrechte Position 
        breite = real_old - (x_lim(2)-x_lim(1))/20;% Waagerechte Position
        string = num2str(hilf);
        text('string',string,...      % Ueberschrift fuer Axes-Objekt
             'erasemode','normal',...
             'color',[1 0 0],...      % Farbe = rot
             'tag','null_text',...
             'verticalalignment','middle',...% Textausrichtung = zentriert
             'horizontalalignment','center',...% Textausrichtung = zentriert
             'position',[breite hoehe]);
        hilf = 1;
      end                             % Ende von hilf > 1
      old = zahl;                     % Speicherung der letzten Polstelle
    end                               % Ende von for n = 1:laenge


    % ----------unquantisierte Polstellen plotten --------------------------
    pol = sort(roots(a));             % Ermittle unquantisierte Polstellen
    laenge_pol = length(pol);         % Laenge des Polstellenvektors
    old = [];                         % Alter Pol
    hilf = 1;                         % Anzahl der Pole einer Mehrfachpolstelle
    for n = 1:laenge_pol              % Mit Polstellenvektor
      zahl = pol(n);                  % Aktueller Pol
      real_zahl = real(zahl);         % Realteil der Polstelle
      imag_zahl = imag(zahl);         % Imaginaerteil der Polstelle
      if ~isempty(old)
        if (zahl == old)                % Wenn Mehrfachpolstelle
          hilf = hilf + 1;              % Erhoehe Anzahl Pole
        end
      end 
      h_pol = plot...                 % Plotte Polstelle
        (real_zahl,imag_zahl,'xr');
      set(h_pol,...
        'tag','polstelle',...         % Kennzeichne Plot als Polstelle
        'userdata',n');               % Nummer der Polstelle
      if (hilf > 1) & ((n == laenge_pol) | (old ~= zahl)) % Mehrfachpolstelle
        real_old = real(old);         % Waagerechte Koordinate der Mehrfachpolstelle
        imag_old = imag(old);         % Senkrechte Koordinate der Mehrfachpolstelle
        hoehe = imag_old - (y_lim(2)-y_lim(1))/20;% Senkrechte Position 
        breite = real_old + (x_lim(2)-x_lim(1))/20;% Waagerechte Position
        string = num2str(hilf);
        text('string',string,...      % Ueberschrift fuer Axes-Objekt
             'erasemode','normal',...
             'color',[1 0 0],...      % Farbe = rot
             'tag','pol_text',...
             'verticalalignment','middle',...% Textausrichtung = zentriert
             'horizontalalignment','center',...% Textausrichtung = zentriert
             'position',[breite hoehe]);
        hilf = 1;
      end                             % Ende von hilf > 1
      old = zahl;                     % Speicherung der letzten Polstelle
    end                               % Ende von for n = 1:laenge

    if (quantisierung == 1)           % Wenn Quantisierung an

      % ----------quantisierte nullstellen plotten --------------------------
      null = null_quant;
      laenge_null = length(null);     % Laenge des Polstellenvektors
      old = [];                       % Alte Nullstelle
      hilf = 1;                       % Anzahl der Nullstellen einer Mehrfachnullstelle
      for n = 1:laenge_null           % Mit Nullstellenvektor
        zahl = null(n);               % Aktuelle Nullstelle
        real_zahl = real(zahl);       % Realteil der Nullstelle
        imag_zahl = imag(zahl);       % Imaginaerteil der Nullstelle
        if ~isempty (old)
        if (zahl == old)              % Wenn Mehrfachnullstelle
          hilf = hilf + 1;            % Erhoehe Anzahl Nullstellen
        end              
        end;
        h_null = plot...              % Plotte Nullstelle
          (real_zahl,imag_zahl,'ok');
        set(h_null,...
          'tag','nullstelle_quant',...% Kennzeichne Plot als Nullstelle
          'userdata',n');             % Nummer der Nullstelle
        if (hilf > 1) & ((n == laenge_null) | (old ~= zahl)) % Mehrfachnullstelle
          real_old = real(old);       % Waagerechte Koordinate der Mehrfachnullstelle
          imag_old = imag(old);       % Senkrechte Koordinate der Mehrfachnullstelle
          hoehe = imag_old - (y_lim(2)-y_lim(1))/20;% Senkrechte Position 
          breite = real_old - (x_lim(2)-x_lim(1))/20;% Waagerechte Position
          string = num2str(hilf);
          text('string',string,...    % Ueberschrift fuer Axes-Objekt
             'erasemode','normal',...
             'color',[0 0 0],...      % Farbe = rot
             'tag','null_text_quant',...
             'verticalalignment','middle',...% Textausrichtung = zentriert
             'horizontalalignment','center',...% Textausrichtung = zentriert
             'position',[breite hoehe]);
          hilf = 1;
        end                           % Ende von hilf > 1
        old = zahl;                   % Speicherung der letzten Polstelle
      end                             % Ende von for n = 1:laenge


      % ----------quantisierte Polstellen plotten --------------------------
      pol = pol_quant;
      laenge_pol = length(pol);       % Laenge des Polstellenvektors
      old = [];                       % Alter Pol
      hilf = 1;                       % Anzahl der Pole einer Mehrfachpolstelle
      for n = 1:laenge_pol            % Mit Polstellenvektor
        zahl = pol(n);                % Aktueller Pol
        real_zahl = real(zahl);       % Realteil der Polstelle
        imag_zahl = imag(zahl);       % Imaginaerteil der Polstelle
        if ~isempty(old)
        if (zahl == old)              % Wenn Mehrfachpolstelle
          hilf = hilf + 1;            % Erhoehe Anzahl Pole
        end             
        end;
        h_pol = plot...               % Plotte Polstelle
          (real_zahl,imag_zahl,'xk');
        set(h_pol,...
          'tag','polstelle_quant',... % Kennzeichne Plot als Polstelle
          'userdata',n');             % Nummer der Polstelle
        if (hilf > 1) & ((n == laenge_pol) | (old ~= zahl)) % Mehrfachpolstelle
          real_old = real(old);       % Waagerechte Koordinate der Mehrfachpolstelle
          imag_old = imag(old);       % Senkrechte Koordinate der Mehrfachpolstelle
          hoehe = imag_old - (y_lim(2)-y_lim(1))/20;% Senkrechte Position 
          breite = real_old + (x_lim(2)-x_lim(1))/20;% Waagerechte Position
          string = num2str(hilf);
          text('string',string,...    % Ueberschrift fuer Axes-Objekt
             'erasemode','normal',...
             'color',[0 0 0],...      % Farbe = rot
             'tag','pol_text_quant',...
             'verticalalignment','middle',...% Textausrichtung = zentriert
             'horizontalalignment','center',...% Textausrichtung = zentriert
             'position',[breite hoehe]);
          hilf = 1;
        end                           % Ende von hilf > 1
        old = zahl;                   % Speicherung der letzten Polstelle
      end                             % Ende von for n = 1:laenge
    end                               % Ende von Quantisierung
  command_str = 'darstellung';
end                                   % Ende von pn


% ------------------------- Darstellung -------------------------------------
if strcmp(command_str,'darstellung')  % Wenn Radiobutton Quantisierung
  h_radio_quant = findobj...          % Finde Radiobutton 'pn_quantisiert'
    ('tag','pn_quantisiert');
  quantisiert = get...                % Lies Zustand des Radiobuttons
    (h_radio_quant,'value');
  h_radio_unquant = findobj...        % Finde Radiobutton 'pn_unquantisiert'
    ('tag','pn_unquantisiert');
  unquantisiert = get...              % Lies Zustand des Radiobuttons
    (h_radio_unquant,'value');
  h_pol_quant = findobj...            % Finde quantisierte Polstellen
    ('tag','polstelle_quant');
  h_null_quant = findobj...           % Finde quantisierte Nullstellen
    ('tag','nullstelle_quant');
  h_pol = findobj...                  % Finde unquantisierte Polstellen
    ('tag','polstelle');
  h_null = findobj...                 % Finde unquantisierte Nullstellen
    ('tag','nullstelle');
  h_pol_quant_text = findobj...       % Finde quantisierte Mehrfachpolstellen
    ('tag','pol_text_quant');
  h_null_quant_text = findobj...      % Finde quantisierte Mehrfachnullstellen
    ('tag','null_text_quant');
  h_pol_text = findobj...             % Finde unquantisierte Mehrfachpolstellen
    ('tag','pol_text');
  h_null_text = findobj...            % Finde unquantisierte Mehrfachnullstellen
    ('tag','null_text');
  h_axes_pn = findobj...              % Finde Axes-Objekt 'pn_diagramm'
    ('tag','pn_diagramm');
  x_lim = get(h_axes_pn,'xlim');      % Lies x-Grenzwerte
  y_lim = get(h_axes_pn,'ylim');      % Lies y-Grenzwerte
  h_check_marker = findobj...         % Finde Radiobutton 'marker_an'
    ('tag','marker_an');
  marker_on = get(h_check_marker,...  % Lies Zustand des Radiobuttons
    'value');
  % Finde Markerlinien
  h_line_senkrecht_unqu = findobj('tag','marker_senkrecht_unqu');
  h_line_waagerecht_unqu = findobj('tag','marker_waagerecht_unqu');
  h_line_senkrecht_quant = findobj('tag','marker_senkrecht_quant');
  h_line_waagerecht_quant = findobj('tag','marker_waagerecht_quant');
  if (quantisiert == 1)               % Wenn Quantisierte Darstellung
    set(h_pol_quant,...               % Setze quantisierte Objekte sichtbar
      'visible','on');
    set(h_null_quant,...
      'visible','on');
    set(h_pol_quant_text,...
      'visible','on');
    set(h_null_quant_text,...
      'visible','on');
    if (marker_on)
      position = get...               % Lies alte Markerposition aus
        (h_radio_quant,'userdata');   % Userdata
      if isempty(h_line_senkrecht_quant)  % Wenn Markerlinie nicht exestiert
        objekt = get(h_check_marker,...% Polstelle oder Nullstelle
          'userdata');
        string = [objekt '_quant'];   % Endung _quant an Objekt
        h_marker_objekt = findobj...  % Finde die entsprechende Pol- oder 
          ('tag',string,...           % Nullstelle
           'userdata',position);
        if ~isempty(h_marker_objekt)  % Wenn Markerobjekt exestiert
          x_data = get(h_marker_objekt,'xdata');% Lies x-Koordinate des Objekts
          y_data = get(h_marker_objekt,'ydata');% Lies y-Koordinate des Objekts
          line('xdata',[x_data x_data],...
            'ydata',y_lim,...         % Senkrechte Markerlinie der Ausgangsfolge
            'erasemode','normal',...
            'color','b',...           % Farbe Blau
            'tag','marker_senkrecht_quant');
          line('xdata',x_lim,...
            'ydata',[y_data y_data],...
            'erasemode','normal',...  % Waagerechte Markerlinie der Ausgangsfolge
            'color','b',...
            'tag','marker_waagerecht_quant');

        end                           % Ende von ~isempty(h_marker_objekt)
      end                             % Ende von isempty(h_line_senkrecht_quant)
      markerpn('ausgabe');            % Aufruf markerpn mit Parameter 'ausgabe'
    end                               % Ende von marker_on
  elseif (quantisiert == 0)           % Wenn Quantisierte Darstellung
    set(h_pol_quant,...               % Setze quantisierte Objekte unsichtbar
      'visible','off');
    set(h_null_quant,...
      'visible','off');
    set(h_pol_quant_text,...
      'visible','off');
    set(h_null_quant_text,...
      'visible','off');
    delete(h_line_senkrecht_quant);   % Entferne Markerlinie senkrecht quantisiert
    delete(h_line_waagerecht_quant);  % Entferne Markerlinie waagerecht quantisiert
    if (marker_on)                    % Wenn Marker an
      markerpn('ausgabe');            % Aufruf markerpn mit Parameter 'ausgabe'
    end                               % Ende von Marker an
  end                                 % Ende von Quantisiert ja oder nein
  if (unquantisiert == 1)             % Wenn unquantisierte Darstellung
    set(h_pol,...                     % Setze unquantisierte Objekte sichtbar
      'visible','on');
    set(h_null,...
      'visible','on');
    set(h_pol_text,...
      'visible','on');
    set(h_null_text,...
      'visible','on');
    if (marker_on)                    % Wenn Marker an
      position = get...               % Lies alte Markerposition aus
        (h_radio_quant,'userdata');   % Userdata
      if isempty(h_line_senkrecht_unqu)% Wenn Markerlinie nicht exestiert
        objekt = get(h_check_marker,...% Objekt = Polstelle oder Nullstelle
          'userdata');
        h_marker_objekt = findobj...  % Finde entsprechende Pol- oder Nullstelle
          ('tag',objekt,...
           'userdata',position);
        if ~isempty(h_marker_objekt)  % Wenn Markerobjekt exestiert
          x_data = get(h_marker_objekt,'xdata');% Lies x-Koordinate des Objekts
          y_data = get(h_marker_objekt,'ydata');% Lies y-Koordinate des Objekts
          line('xdata',[x_data x_data],...
            'ydata',y_lim,...         % Senkrechte Markerlinie der Ausgangsfolge
            'erasemode','normal',...
            'color','r',...           % Farbe rot
            'buttondownfcn','',...
            'tag','marker_senkrecht_unqu');
          line('xdata',x_lim,...
            'ydata',[y_data y_data],...
            'erasemode','normal',...  % Waagerechte Markerlinie der Ausgangsfolge
            'color','r',...
            'tag','marker_waagerecht_unqu');
        end                           % Ende von ~isempty(h_marker_objekt)
      end                             % Ende von isempty(h_line_senkrecht_unqu)
      markerpn('ausgabe');            % Aufruf markerpn mit Parameter 'ausgabe'
    end                               % Ende von marker_on
  elseif (unquantisiert == 0)         % Wenn nicht unquantisierte Darstellung
    set(h_pol,...                     % Setze unquantisierte Objekte unsichtbar
      'visible','off');
    set(h_null,...
      'visible','off');
    set(h_pol_text,...
      'visible','off');
    set(h_null_text,...
      'visible','off');
    delete(h_line_senkrecht_unqu);    % Entferne Markerlinie senkrecht unquantisiert
    delete(h_line_waagerecht_unqu);   % Entferne Markerlinie waagerecht unquantisiert
    if (marker_on)                    % Wenn Marker an
      markerpn('ausgabe');            % Aufruf markerpn mit Parameter 'ausgabe'
    end                               % Ende von Marker an
  end                                 % Ende von unquantisierte Darstellung ja/nein
end


% ------------------------- PN-Diagramm schliessen --------------------------
if strcmp(command_str,'close')        % Wenn PN-Diagramm beenden
  h_pop_struktur = findobj...         % Finde Popupmenue 'struktur'
    ('tag','struktur');
  f_struktur = get...                 % Lies dargestellte Struktur
    (h_pop_struktur,'value');
  if (f_struktur == 4)|(f_struktur == 5)% Kaskade
    h_push_tausch = findobj...        % Finde Pushbutton 'tauschen'
      ('tag','tauschen');
    set(h_push_tausch,...             % Setze Pushbutton bedienbar
      'enable','on');
  end
  h_skalieren= findobj('tag','Skalierung');	% Checkbox Skalierung finden
  set (h_skalieren,'enable','on');	% aktiv setzen
  h_figure = findobj...               % Finde Figure-Objekt 'netzwerk'
    ('tag','netzwerk');
  set(h_figure,...
    'windowbuttondownfcn','');        % Ruecksetzen Windowbuttondownfcn
  h_quit = findobj...                 % Finde Pushbutton 'quit'
    ('tag','quit');
  set(h_quit,...                        
    'enable','off',...                % Setze Pushbutton unbedienbar
    'callback','');                   % Ruecksetzen callback
  h_pop_struktur = findobj...         % Finde Popupmenue 'struktur'
    ('tag','struktur');
  set(h_pop_struktur,...              % Setze Popupmenue bedienbar
    'enable','on');
  h_radio_ansicht = findobj...        % Finde Radiobutton 'ansicht'
    ('tag','ansicht');
  set(h_radio_ansicht,...             % Setze Radiobutton bedienbar
    'enable','on');
  h_push_ant = findobj...             % Finde Pushbutton 'antwort'
    ('tag','antwort');
  set(h_push_ant,...                  % Setze Pushbutton bedienbar
    'enable','on');
  h_push_filt = findobj...            % Finde Popupmenue 'filterung'
    ('tag','filterung');
  set(h_push_filt,...                 % Setze Pushbutton bedienbar
    'enable','on');
  h_push_gene = findobj...            % Finde Pushbutton 'generator'
    ('tag','generator_mat');
  set(h_push_gene,...                 % Setze Pushbutton bedienbar
    'enable','on');
  h_push_pn = findobj...              % Finde Pushbutton 'pn'
    ('tag','pn');
  set(h_push_pn,...                   % Setze Pushbutton bedienbar
    'enable','on');
  h_check_quant = findobj...          % Finde Checkbox 'quantisierung'
    ('tag','quantisierung');
  h_axes_pn = findobj...              % Finde Axes-Objekt 'pn'
    ('tag','pn_diagramm');
  callback_string = get...            % Lies alten callback des Pushbuttons
  (h_axes_pn,'userdata');             % 'quant_uebernehmen' aus Userdata
  delete(h_axes_pn);                  % Entferne es
  h_push_ueber = findobj...           % Finde Pushbutton 'quant_uebernehmen'
    ('tag','quant_uebernehmen');
  set(h_push_ueber,...                % Aktualisiere Callback des Pushbuttons
    'callback',callback_string);
  h_radio_quant = findobj...          % Finde Radiobutton 'quantisiert'
    ('tag','pn_quantisiert');
  delete(h_radio_quant);              % Entferne es
  h_radio_unquant = findobj...        % Finde Radiobutton 'unquantisiert'
    ('tag','pn_unquantisiert');
  delete(h_radio_unquant);            % Entferne es
  h_frame_pn = findobj...             % Finde Rahmen 'pn_frame'
    ('tag','pn_frame');
  delete(h_frame_pn);                 % Entferne es
  h_check_zoom = findobj...           % Finde Checkbox 'zoom_an'
    ('tag','zoom_an');
  delete(h_check_zoom);               % Entferne es
  h_push_zoom = findobj...            % Finde Pushbutton 'zoom_ursprung'
    ('tag','zoom_ursprung');
  delete(h_push_zoom);                % Entferne es
  h_check_marker = findobj...         % Finde Checkbox 'marker_an'
    ('tag','marker_an');
  delete(h_check_marker);             % Entferne es
  h_marker = findobj...               % Finde Marker Objekte
    ('tag','marker');
  delete(h_marker);                   % Entferne es
  h_marker_objekt = findobj...        % Finde Marker Objekte
    ('tag','marker_objekt');
  delete(h_marker_objekt);            % Entferne es
  h_quant_real = findobj...           % Finde Marker Objekte
    ('tag','marker_quant_real');
  delete(h_quant_real);               % Entferne es
  h_unqu_real = findobj...            % Finde Marker Objekte
    ('tag','marker_unqu_real');
  delete(h_unqu_real);                % Entferne es
  h_quant_imag = findobj...           % Finde Marker Objekte
    ('tag','marker_quant_imag');
  delete(h_quant_imag);               % Entferne es
  h_unqu_imag = findobj...            % Finde Marker Objekte
    ('tag','marker_unqu_imag');
  delete(h_unqu_imag);                % Entferne es
  h_axes = findobj('tag','axes');     % Finde Axes-Objekt fuer Struktur
  h_children = get(h_axes,'children');% Finde Nachkommen
  set(h_children,'visible','on');     % Setze Nachkomen sichtbar
  netzwerk;                           % Aufruf von Netzwerk.m
  h_push_pn = findobj...              % Finde Pushbutton 'p_n_dia'
    ('tag','p_n_dia');
  set(h_push_pn,...                   % Setze Pushbutton bedienbar
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
  h_pop_fft = findobj...              % Finde Popupmenue 'FFT'
    ('tag','FFT');
  set(h_pop_fft,...                   % Setze Popupmenue aktiv
    'enable','on');
  h_push_hilfe = findobj...           % Finde Pushbutton 'Hilfe'
    ('tag','hilfe');
  callback_str = get(h_push_hilfe,... % Finde alten callback
    'userdata');
  set(h_push_hilfe,...                % Sichere alten Callback in Userdata
    'callback',callback_str);         % alte Hilfe
  if (f_struktur == 4) | (f_struktur == 5) | (f_struktur == 7)  
    h_axes_z = findobj('tag','axes_h(z)','type','axes');
    set (h_axes_z,'buttondownfcn','netzwerk(''quant'');');  
  end 
end                                   % Ende von close
