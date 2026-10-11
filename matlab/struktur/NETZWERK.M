function netzwerk(command_str, a, b)
% NETZWERK
%
% Die Funktion stellt ein digitales Netzwerk dar.
% Funktionsaufruf
%   netzwerk('System')
% Zur Zeit stehen folgende Systeme zur Verfügung:
%   direkt = Nichtkanonische Direktform
%   kano1 = 1. kanonische Form
%   kano2 = 2. kanonische Form
%   kano3 = 3. kanonische Form (Kaskade)
%   kano3n = 3. kanonische Form (Kaskade), b0 normiert auf 1
%   lattice = Gitterstruktur in Lattice ladder
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

if nargin == 0
  h_popup = findobj('tag','struktur');% Finde Handle Popup Struktur
  f_struktur = get(h_popup,'value');    % Ausgewaehlte Struktur
  if (f_struktur == 1)
    command_str = 'direkt';
  end
  if (f_struktur == 2)
    command_str = 'kano1';
  end
  if (f_struktur == 3)
    command_str = 'kano2';
  end
  if (f_struktur == 4)
    command_str = 'kano3';
  end
  if (f_struktur == 5)
    command_str = 'kano3n';
  end
  if (f_struktur == 6)
    command_str = 'lattice';
  end
 if (f_struktur == 7)
    command_str = 'parallel';
  end
end

% -------- Filter auf möglichen Aufbau der Struktur prüfen ------------
filter_check = a(2:length(a));
if any(filter_check)                % Pruefe, ob IIR- oder FIR-Filter
  filter_type = 'IIR';
else
  filter_type = 'FIR';
end
order_num = length(b);              % Ordnung des Nenners
order_den = length(a);              % Ordnung des Zaehlers
ordnung = max(order_num, order_den); % Ordnung des Filters
if  (strcmp(command_str,'lattice') | strcmp(command_str,'parallel') ) &strcmp(filter_type,'FIR')
   taste=fenster('Diese Struktur ist nur bei IIR-Filtern möglich!','Info',2,1);
  command_str = 'message';          % Pruefe bei lattice ob IIR-Filter
  h_popup=findobj('tag','struktur');% Finde Handle Popup Struktur
  old_value = get...
    (h_popup,'userdata');           % Ausgewaehlte Struktur
  set(h_popup,'value',old_value);   % Ruecksetzen auf alten Wert
else
  h_popup=findobj('tag','struktur');% Finde Handle Popup Struktur
  f_struktur=get(h_popup,'value');    % Ermittle aktuelle Struktur
  set(h_popup,'userdata',f_struktur); % Sichern in userdata
end

% -------- Koeffizienten-Matrix neu erstellen --------
if ((~strcmp(command_str,'message') & nargin==0)...    % wenn Aufbau möglich oder
    | (strcmp(command_str,'quant')))                   % Kommando-String = 'quant'
		null_korrektur=0;
		if (nargin==0)
			h_kaskade=findobj('ButtonDownFcn','kaskade(''kaskade'');');
			if isempty(h_kaskade)
				h_kaskade=findobj('ButtonDownFcn','kaskade(''kaskadenorm'');');
			end;
			if isempty(h_kaskade)
				null_korrektur = 1;		% Abfrage nach Nullstellenkorrektur ermöglichen
			end;
		end;
		[matrix,rech,spei,quantisierung,arithmetik,sort_folge]= quamat (f_struktur,null_korrektur);

end;        % neue Koeffizienten-Matrix aufbauen


% -------------- Initialisierung --------------------------------------------
                                  % Prüfen, ob das GUI nicht bereits in einer
                           % anderen existierenden Figur initialisiert wurde.
h_figs = findobj('parent',0);   % Ermittle handles der existierenden Figuren
fig_exists = 0;               % Setze fig_exists = 0
fig_help = 0;
h_exist=findobj('tag','netzwerk');
if ~isempty(h_exist)
   fig_exists=1;
end;

h_figure = findobj('tag','netzwerk');% Ermittle handle der Figur 'netzwerk'
if fig_exists                       % Wenn die Figur bereits existiert
  figure(h_figure);                 % Bringe die Figur in den Vordergrund
  h_axes = findobj('tag','axes');
  axes(h_axes);
end

% -------------- nichtkanonische Direktform ---------------------------------
% Es wird das nichtkanonische Netzwerk aus den uebergebenen Koeffizienten
% a und b dargestellt


if strcmp(command_str,'direkt')     % Wenn command_str = direkt
  h_push_rueck = findobj('tag',...  % Suche Handle des Pushbuttons
        'rueckgaengig');              % 'Rueckgaengig'
  set(h_push_rueck,...              % Pushbutton 'Rueckgaengig' unsichtbar
        'visible','off');
  h_axes_h=findobj('tag','axes_h(z)','type','axes');	% Axes-Objekt für Überschrift in Kaskaden- und Parallelform
 delete (h_axes_h);			% Axes-Objekt löschen
 h_tauschen = findobj('tag','tauschen');% Handle Pushbutton 'tauschen'
  set(h_tauschen,'visible','off');   % Tauschen inaktiv
 h_skalierung = findobj('tag','Skalierung');% Handle Checkbox opt. Skalierung
  set(h_skalierung,'visible','off');   % skalierung inaktiv
  h_systemantwort = findobj...      % Finde Pushbutton Systemantwort
    ('tag','antwort');
  set(h_systemantwort,'enable','on');% Setze Pushbutton aktiv
  h_filterantwort = findobj...       % Finde Pushbutton 'filterung'
    ('tag','filterung');
    set(h_filterantwort,'enable','on');% Setze Pushbutton aktiv
  % -------- Ursprungskoordinaten widerherstellen ---------------------------
  screensize = get(0,'screensize'); % Ermittle Bildschirmaufloesung
  width = screensize(3);            % Breite des Bildschirms
  height = screensize(4);           % Hoehe des Bildschirms
  x_lim = [-40 40];                 % Festsetzen der waagerechten Grenzwerte
  y_lim = x_lim .*(height/width)/0.8-30;% Anpassen der senkrechten Grenzwerte
  h_axes = findobj('tag','axes');   % Suche Objekt mit Bezeichnung 'axes'
  set(h_axes,'xlim',x_lim,'ylim',y_lim);% Setze darstellbaren Bereich
  minimum = ordnung * (-15)/22;
  h_sliderx =findobj('tag','slider');% waagerechten und senkrechten
  set(h_sliderx,'value',0,...        % slider zuruecksetzen
        'userdata',0,...
        'visible','off',...
        'enable','off');
  h_slidery =findobj('tag','slidery');
  set(h_slidery,'value',0,...
        'min',minimum,...
        'userdata',0,...
        'visible','on',...
        'enable','on');
     
  h_change = findobj('tag','change');% Finde Objekte mit Bezeichnung
  delete(h_change);             % 'change' (kano3) und loesche diese
h_cur_axes=findobj('tag','axes');
h_children = findobj('parent',h_cur_axes); % Ermittle alle children von axes
delete(h_children);               % Entferne alle children von axes
string = [filter_type '-Filter ' num2str(ordnung-1) '.Ordnung ' 'in nichtkanonischer Direktform']; % Ordnungswert= Anzahl Koeff. -1


  set(h_figure,'name',string);% Setze name von 'netzwerk'
  pause(0.1);  

  for n = 0:(ordnung - 1)
      
     faktor = (-10);                 % Faktor fuer senkrechten Abstand
    senkrecht = n*faktor;           % Senkrechtes Raster
    waagerecht = 10;                % Waagerechtes Raster

    % --------------- Zeichne Multiplizierer b(n)----------------------------
    x = [cos([0:5:360]*(pi/180)),...% x-Kreiskoordinaten
         cos([5:5:45]*(pi/180)),... % Anfang 1.Diagonale bei 45ø
         cos(225*pi/180)];          % Endpunkt 1.Diagonale bei 225ø
    y = [sin([0:5:360]*(pi/180)),...% y-Kreiskoordinaten
         sin([5:5:45]*(pi/180)),... % Anfang 1.Diagonale bei 45ø
         sin(225*pi/180)];          % Endpunkt 1.Diagonale bei 225ø
    x = [x cos([230:5:315]*(pi/180)),...% 2.Diagonale 315ø,135ø
         cos(135*pi/180)] - waagerecht; % Raster links von Null
    y = [y sin([230:5:315]*(pi/180)),...% 2.Diagonale 315ø,135ø
         sin(135*pi/180)] + senkrecht;  % Raster unterhalb von Null
    
h_line = plot(x,y,'-k');        % Zeichne Objekt schwarz
    set(h_line,...
      'buttondownfcn','netzwerk(''quant'');',...
      'tag','multiplizierer_b');   % Setze tag = multiplizierer_b
    string = ['b(' num2str(n) ')']; % String fuer Beschriftung
    text('string',string,...        % Generiere Textobjekt
      'tag','multiplizierer_b',...  % Setze tag = multiplizierer_b
      'buttondownfcn','netzwerk(''quant'');',...
      'erasemode','normal',...
      'clipping','on',...
      'color',[0 0 0],...           % Farbe = Schwarz
      'position',[(1.5-waagerecht),...% waagerechte Position
                (-1.5+senkrecht)]);   % senkrechte Position

% ----------------- Zeichne Addierer ------------------------------------
    x = [cos([0:10:360]*(pi/180)) -1];% Kreis und waagerechter Strich
    y = [sin([0:10:360]*(pi/180)) 0];
    x = [x cos([190:10:270]*(pi/180)) 0];% Halbkreis + senkrechter Strich
    y = [y sin([190:10:270]*(pi/180)) 1] + senkrecht;
     
    h_line = plot(x,y,'-k');
set(h_line,'tag','addierer');

    % ------------ zeichne Verzoegerungsglied -------------------------------
    if (n>=1)                       % n-1 Verzoegerungsglieder
      x1 = -3;                      % waagerechte Koordinaten
      x2 = 3;                       % fuer alle n gleich
      y1 = -3.5+senkrecht-faktor;   % senkrechte Koordinaten
      y2 = -6.5+senkrecht-faktor;   % im senkrechten Raster
      x = [x1 x2 x2 x1 x1]-2*waagerecht; % Zusammenfassung fuer Rechteck x
      y = [y1 y1 y2 y2 y1];         % Zusammenfassung fuer Rechteck y
       
      h_verz = plot(x,y,'-k');      % Zeichne Rechteck
      set(h_verz,...
          'tag','verzoegerung');    % Setze tag = verzoegerung
      string = 'z^{-1}';              % String fuer Verzoegerungsglied
      text('string',string,...      % Generiere Textobjekt innerhalb
        'tag','verzoegerung',...    % des Rechteckes
        'clipping','on',...         % Text nur innerhalb axes sichtbar
        'horizontalalignment','center',...% waagerechte Ausrichtung
        'color',[0 0 0],...         % ist mittig, Farbe = Schwarz
        'position',[-2*waagerecht (-5+senkrecht-faktor)]);% [x y] Koordinaten
         
        
      if strcmp(filter_type,'IIR')  % Nur fuer IIR-Filter
        x = [x1 x2 x2 x1 x1]+2*waagerecht; % Zusammenfassung fuer Rechteck x
        y = [y1 y1 y2 y2 y1];       % Zusammenfassung fuer Rechteck y
        h_verz = plot(x,y,'-k');    % Zeichne Rechteck
        set(h_verz,...
          'tag','verzoegerung');    % Setze tag = verzoegerung
        string = 'z^{-1}';            % String fuer Verzoegerungsglied
         
        text('string',string,...    % Generiere Textobjekt innerhalb
          'tag','verzoegerung',...  % des Rechteckes
          'clipping','on',...       % Text nur innerhalb axes sichtbar
          'horizontalalignment','center',...% waagerechte Ausrichtung
          'color',[0 0 0],...       % ist mittig, Farbe = Schwarz
          'position',[2*waagerecht (-5+senkrecht-faktor)]);% [x y] Koordinaten
      end                           % Ende von IIR-Filter
    end                             % Ende von n>=1

% ------------ Zeichne Multiplizierer a(n) ------------------------------
    if (n >= 1)&strcmp(filter_type,'IIR') % n-1 Multiplizierer_a nur IIR-Filter
      x = [cos([0:5:360]*(pi/180)),...% Prinzip wie Multiplizierer_b
           cos([5:5:45]*(pi/180)),...
           cos(225*pi/180)];
      y = [sin([0:5:360]*(pi/180)),...
           sin([5:5:45]*(pi/180)),...
           sin(225*pi/180)];
      x = [x cos([230:5:315]*(pi/180)),...
           cos(135*pi/180)] + waagerecht;
      y = [y sin([230:5:315]*(pi/180)),...
           sin(135*pi/180)] + senkrecht;
      
     h_line = plot(x,y,'-k');
      set(h_line,...
        'buttondownfcn','netzwerk(''quant'');',...
        'tag','multiplizierer_a');
      string = ['-a(' num2str(n) ')'];
      text('string',string,...
        'buttondownfcn','netzwerk(''quant'');',...
        'tag','multiplizierer_a',...
        'clipping','on',...
        'color',[0 0 0],...
        'position',[(1.5+waagerecht) (-1.5+senkrecht)]);
     
    end                             % Ende von n>=1

    % ------------ zeichne Verbindungslinien --------------------------------
    if (n==0)
      x = [1 (1+3*waagerecht)];            % waagerechte Koordinaten Linie
      x_pfeil = [(1+(3*waagerecht-0.6)),...% Pfeilspitze
                 (1+3*waagerecht),...
                 (1+(3*waagerecht-0.6))];
      x = [x x_pfeil];
      y = [0 0 0.6 0 -0.6];
       
      plot(x,y,'-k');
       
      x = [(1-waagerecht) -1];
      x_pfeil = [-1.6 -1 -1.6];
      x = [x x_pfeil];
      y = [0 0 0.6 0 -0.6];
       
      plot(x,y,'-k');
       
      x = [(-3*waagerecht),...
           (-waagerecht-1)];
      x_pfeil =[(-waagerecht-1.6),...
                (-waagerecht-1),...
                (-waagerecht-1.6)];
      x = [x x_pfeil];
      y = [0 0 0.6 0 -0.6];
       
      plot(x,y,'-k');
    
       
      h_text= text('string','X(z)',...
        'color',[0 0 0],...
        'clipping','on',...
        'tag','(z)',...
        'position',[(-3*waagerecht-4) 0]);
   
h_text= text('string','\_',...
        'color',[0 0 0],...
        'clipping','on',...
        'tag','(z)',...
        'horizontalalignment','left',...
        'position',[(-3*waagerecht-4) -0.2]);
           
      h_text= text('string','Y(z)',...
        'color',[0 0 0],...
        'clipping','on',...
        'tag','(z)',...
        'position',[(3*waagerecht+3) 0]);
     
      h_text= text('string','\_',...
        'color',[0 0 0],...
        'clipping','on',...
        'tag','(z)',...
        'horizontalalignment','left',...
        'position',[(3*waagerecht+3) -0.2]);
          
     if strcmp(filter_type,'IIR')  % Nur fuer IIR-Filter
      end                           % Ende von nur IIR-Filter
    end                             % Ende von n==0

    if (n>=1)
      x = [(-2*waagerecht) (-2*waagerecht) (-waagerecht-1)];
      x_pfeil = [(-waagerecht-1.6),...
          (-waagerecht-1) (-waagerecht-1.6)];
      y = [senkrecht+3.5 senkrecht senkrecht];
      x = [x, x_pfeil];
      y_pfeil = [(senkrecht+0.6),...
                 senkrecht (senkrecht-0.6)];
      y = [y, y_pfeil];
       
      plot(x,y,'-k');
     
      x = [(-2*waagerecht) (-2*waagerecht)];
      x_pfeil = [(-2*waagerecht+0.6),...
          (-2*waagerecht) (-2*waagerecht-0.6)];
      y = [senkrecht-faktor senkrecht+6.5];
      y_pfeil = [(senkrecht+7.1),...
                (senkrecht+6.5) (senkrecht+7.1)];
      x = [x x_pfeil];
      y = [y y_pfeil];
       
      plot(x,y,'-k');
     
      x = [0 0];
      x_pfeil = [-0.6 0 +0.6];
      x = [x x_pfeil];
      y = [(senkrecht+1),...
           (senkrecht-faktor-1)];
      y_pfeil = [(-1.6+senkrecht-faktor) (-1+senkrecht-faktor),...
                  (-1.6+senkrecht-faktor)];
      y = [y y_pfeil];
       
      plot(x,y,'-k');
      x = [(1-waagerecht) -1];
      x_pfeil = [-1.6 -1 -1.6];
      x = [x x_pfeil];
      y = [senkrecht senkrecht];
      y_pfeil = [(senkrecht+0.6) senkrecht (senkrecht-0.6)];
      y = [y y_pfeil];
       
      plot(x,y,'-k');
     
      if strcmp(filter_type,'IIR')  % Nur fuer IIR-Filter
        x = [(waagerecht-1) 1];
        x_pfeil = [1.6 1 1.6];
        x = [x x_pfeil];
        y = [senkrecht senkrecht];
        y_pfeil = [(senkrecht+0.6) senkrecht (senkrecht-0.6)];
        y = [y y_pfeil];
        
         
        plot(x,y,'-k');
           
        x = [(2*waagerecht) (2*waagerecht) (waagerecht+1)];
        x_pfeil = [(waagerecht+1.6),...
          (waagerecht+1) (waagerecht+1.6)];
        y = [senkrecht+3.5 senkrecht senkrecht];
        y_pfeil = [(senkrecht+0.6),...
                senkrecht (senkrecht-0.6)];
        x = [x x_pfeil];
        y = [y y_pfeil];
         
        plot(x,y,'-k');
             
        x = [(2*waagerecht) (2*waagerecht)];
        x_pfeil = [(2*waagerecht+0.6),...
          (2*waagerecht) (2*waagerecht-0.6)];
        y = [senkrecht-faktor senkrecht+6.5];
        y_pfeil = [(senkrecht+7.1),...
                (senkrecht+6.5) (senkrecht+7.1)];
        x = [x x_pfeil];
        y = [y y_pfeil];
         
        plot(x,y,'-k');
      
        
      end                           % Ende von IIR-Filter    
    end                             % Ende von n>=1
  end                               % Ende von for n=0:ordnung
end                                 % Ende von command_str = direkt

% -------------- 1. kanonische Form -----------------------------------------
if strcmp(command_str,'kano1')      % Wenn command_str = kano1
 pause(0.5)
 h_push_rueck = findobj('tag',... % Suche Handle des Pushbuttons
        'rueckgaengig');              % 'Rueckgaengig'
  set(h_push_rueck,...              % Pushbutton 'Rueckgaengig' unsichtbar
        'visible','off');
 h_axes_h=findobj('tag','axes_h(z)','type','axes');	% Axes-Objekt für Überschrift in Kaskaden- und Parallelform
 delete (h_axes_h);			% Axes-Objekt löschen
  h_tauschen = findobj('tag','tauschen');% Handle Pushbutton 'tauschen'
  set(h_tauschen,'visible','off');   % Tauschen inaktiv
 h_skalierung = findobj('tag','Skalierung');% Handle Checkbox opt. Skalierung
  set(h_skalierung,'visible','off');   % skalierung inaktiv
  h_systemantwort = findobj...      % Finde Pushbutton Systemantwort
    ('tag','antwort');
  set(h_systemantwort,'enable','on');% Setze Pushbutton aktiv
  h_filterantwort = findobj...       % Finde Pushbutton 'filterung'
    ('tag','filterung');
  set(h_filterantwort,'enable','on');% Setze Pushbutton aktiv
  screensize = get(0,'screensize'); % Ermittle Bildschirmaufloesung
  width = screensize(3);            % Breite des Bildschirms
  height = screensize(4);           % Hoehe des Bildschirms
  x_lim = [-40 40];                 % Festsetzen der waagerechten Grenzwerte
  y_lim = x_lim .*(height/width)/0.8-30;% Anpassen der senkrechten Grenzwerte
  h_axes = findobj('tag','axes');   % Suche Objekt mit Bezeichnung 'axes'
  set(h_axes,'xlim',x_lim,'ylim',y_lim);% Setze darstellbaren Bereich
  minimum = ordnung * (-15)/22;
  h_sliderx =findobj('tag','slider');% waagerechten und senkrechten
  set(h_sliderx,'value',0,...        % slider zuruecksetzen
        'userdata',0,...
        'visible','off',...
        'enable','off');
  h_slidery =findobj('tag','slidery');
  set(h_slidery,'value',0,...
        'min',minimum,...
        'userdata',0,...
        'visible','on',...
        'enable','on');
  h_change = findobj('tag','change');% Finde Objekte mit Bezeichnung
  delete(h_change);             % 'change' (kano3) und loesche diese
  h_children = findobj('parent',gca); % Ermittle alle children von axes
  delete(h_children);               % Entferne alle children von axes
  string = [filter_type,'-Filter ',num2str(ordnung-1),'.Ordnung ','in 1. kanonischer Form']; % Ordnungswert= Anzahl Koeff. -1
  set(h_figure,'name',string); % Setze name von 'netzwerk'

  % --------------- Zeichne Multiplizierer b(n) -----------------------------
  for n = 0:(ordnung - 1)
    faktor = (-10);                 % Faktor fuer senkrechten Abstand
    senkrecht = n*faktor;           % Senkrechtes Raster
    waagerecht = 10;                % Waagerechtes Raster
    x = [cos([0:5:360]*(pi/180)),...% x-Kreiskoordinaten
         cos([5:5:45]*(pi/180)),... % Anfang 1.Diagonale bei 45ø
         cos(225*pi/180)];          % Endpunkt 1.Diagonale bei 225ø
    y = [sin([0:5:360]*(pi/180)),...% y-Kreiskoordinaten
         sin([5:5:45]*(pi/180)),... % Anfang 1.Diagonale bei 45ø
         sin(225*pi/180)];          % Endpunkt 1.Diagonale bei 225ø
    x = [x cos([230:5:315]*(pi/180)),...% 2.Diagonale 315ø,135ø
         cos(135*pi/180)] - waagerecht; % Raster links von Null
    y = [y sin([230:5:315]*(pi/180)),...% 2.Diagonale 315ø,135ø
         sin(135*pi/180)] + senkrecht;  % Raster unterhalb von Null
    h_line = plot(x,y,'-k');        % Zeichne Objekt schwarz
    set(h_line,...
        'buttondownfcn','netzwerk(''quant'');',...
        'tag','multiplizierer_b');   % Setze tag = multiplizierer_b
    string = ['b(' num2str(n) ')']; % String fuer Beschriftung
    text('string',string,...        % Generiere Textobjekt
      'tag','multiplizierer_b',...  % Setze tag = multiplizierer_b
      'buttondownfcn','netzwerk(''quant'');',...
      'erasemode','normal',...
      'clipping','on',...
      'color',[0 0 0],...           % Farbe = Schwarz
      'position',[(1.5-waagerecht),...% waagerechte Position
                (-1.5+senkrecht)]);   % senkrechte Position

    % ----------------- Zeichne Addierer ------------------------------------
    x = [cos([0:10:360]*(pi/180)) -1];% Kreis und waagerechter Strich
    y = [sin([0:10:360]*(pi/180)) 0];
    x = [x cos([190:10:270]*(pi/180)) 0];% Halbkreis + senkrechter Strich
    y = [y sin([190:10:270]*(pi/180)) 1] + senkrecht;
    h_line = plot(x,y,'-k');
    set(h_line,'tag','addierer');

    % ------------ zeichne Verzoegerungsglied -------------------------------
    if (n>=1)                       % n-1 Verzoegerungsglieder
      x1 = -3;                      % waagerechte Koordinaten
      x2 = 3;                       % fuer alle n gleich
      y1 = -3.5+senkrecht-faktor;   % senkrechte Koordinaten
      y2 = -6.5+senkrecht-faktor;   % im senkrechten Raster
      x = [x1 x2 x2 x1 x1];         % Zusammenfassung fuer Rechteck x
      y = [y1 y1 y2 y2 y1];         % Zusammenfassung fuer Rechteck y
      h_verz = plot(x,y,'-k');      % Zeichne Rechteck
      set(h_verz,...
          'tag','verzoegerung');    % Setze tag = verzoegerung
      string = 'z^{-1}';              % String fuer Verzoegerungsglied
      text('string',string,...      % Generiere Textobjekt innerhalb
        'tag','verzoegerung',...    % des Rechteckes
        'clipping','on',...         % Text nur innerhalb axes sichtbar
        'horizontalalignment','center',...% waagerechte Ausrichtung
        'color',[0 0 0],...         % ist mittig, Farbe = Schwarz
        'position',[0 (-5+senkrecht-faktor)]);% [x y] Koordinaten
    end

    % ------------ Zeichne Multiplizierer a(n) ------------------------------
    if (n >= 1)&strcmp(filter_type,'IIR') % n-1 Multiplizierer_a nur IIR-Filter
      x = [cos([0:5:360]*(pi/180)),...% Prinzip wie Multiplizierer_b
           cos([5:5:45]*(pi/180)),...
           cos(225*pi/180)];
      y = [sin([0:5:360]*(pi/180)),...
           sin([5:5:45]*(pi/180)),...
           sin(225*pi/180)];
      x = [x cos([230:5:315]*(pi/180)),...
           cos(135*pi/180)] + waagerecht;
      y = [y sin([230:5:315]*(pi/180)),...
           sin(135*pi/180)] + senkrecht;
      h_line = plot(x,y,'-k');
      set(h_line,...
        'buttondownfcn','netzwerk(''quant'');',...
        'tag','multiplizierer_a');
      string = ['-a(' num2str(n) ')'];
      text('string',string,...
        'buttondownfcn','netzwerk(''quant'');',...
        'tag','multiplizierer_a',...
        'clipping','on',...
        'color',[0 0 0],...
        'position',[(1.5+waagerecht) (-1.5+senkrecht)]);
    end
    % ------------ zeichne Verbindungslinien --------------------------------
    if (n==0)
      x = [1 (1+3*waagerecht)];            % waagerechte Koordinaten Linie
      x_pfeil = [(1+(3*waagerecht-0.6)),...% Pfeilspitze
                 (1+3*waagerecht),...
                 (1+(3*waagerecht-0.6))];
      x = [x x_pfeil];
      y = [0 0 0.6 0 -0.6];
      plot(x,y,'-k');

      x = [(1-waagerecht) -1];
      x_pfeil = [-1.6 -1 -1.6];
      x = [x x_pfeil];
      y = [0 0 0.6 0 -0.6];
      plot(x,y,'-k');

      x = [(-3*waagerecht),...
           (-waagerecht-1)];
      x_pfeil =[(-waagerecht-1.6),...
                (-waagerecht-1),...
                (-waagerecht-1.6)];
      x = [x x_pfeil];
      y = [0 0 0.6 0 -0.6];
      plot(x,y,'-k');

      h_text= text('string','X(z)',...
        'color',[0 0 0],...
        'clipping','on',...
        'tag','(z)',...
        'position',[(-3*waagerecht-4) 0]);
       h_text= text('string','\_',...
        'color',[0 0 0],...
        'clipping','on',...
        'tag','(z)',...
        'horizontalalignment','left',...
        'position',[(-3*waagerecht-4) -0.2]);
h_text= text('string','Y(z)',...
        'color',[0 0 0],...
        'clipping','on',...
        'tag','(z)',...
        'position',[(3*waagerecht+3) 0]);
h_text= text('string','\_',...
        'color',[0 0 0],...
        'clipping','on',...
        'tag','(z)',...
        'horizontalalignment','left',...
        'position',[(3*waagerecht+3) -0.2]);
    end

    if (n>=1)
      x1 = [(-2*waagerecht) (-2*waagerecht)];
      y1 = [(senkrecht-faktor) senkrecht];
      x2 = [(-2*waagerecht) (-waagerecht-1)];
      x_pfeil = [(-waagerecht-1.6),...
          (-waagerecht-1) (-waagerecht-1.6)];
      y2 = [senkrecht senkrecht];
      x = [x1, x2, x_pfeil];
      y_pfeil = [(senkrecht+0.6),...
                 senkrecht (senkrecht-0.6)];
      y = [y1, y2, y_pfeil];
      plot(x,y,'-k');

      x = [0 0];
      x_pfeil = [-0.6 0 +0.6];
      x = [x x_pfeil];
      y = [(-3.5+senkrecht-faktor),...
           (-1+senkrecht-faktor)];
      y_pfeil = [(-1.6+senkrecht-faktor) (-1+senkrecht-faktor),...
                  (-1.6+senkrecht-faktor)];
      y = [y y_pfeil];
      plot(x,y,'-k');

      x = [0 0];
      x_pfeil = [-0.6 0 0.6];
      x = [x x_pfeil];
      y = [(-9+senkrecht-faktor) (-6.5+senkrecht-faktor)];
      y_pfeil = [(-7.1+senkrecht-faktor) (-6.5+senkrecht-faktor),...
                 (-7.1+senkrecht-faktor)];
      y = [y y_pfeil];
      plot(x,y,'-k');

      x = [(1-waagerecht) -1];
      x_pfeil = [-1.6 -1 -1.6];
      x = [x x_pfeil];
      y = [senkrecht senkrecht];
      y_pfeil = [(senkrecht+0.6) senkrecht (senkrecht-0.6)];
      y = [y y_pfeil];
      plot(x,y,'-k');

      if strcmp(filter_type,'IIR')    % Nur IIR-Filter
      x1 = [(2*waagerecht) (2*waagerecht)];
      y1 = [(senkrecht-faktor) senkrecht];
      x2 = [(2*waagerecht) (waagerecht+1)];
      x_pfeil = [(waagerecht+1.6),...
          (waagerecht+1) (waagerecht+1.6)];
      y2 = [senkrecht senkrecht];
      y_pfeil = [(senkrecht+0.6),...
                senkrecht (senkrecht-0.6)];
      x = [x1 x2 x_pfeil];
      y = [y1 y2 y_pfeil];
      plot(x,y,'-k');

      x = [(waagerecht-1) 1];
      x_pfeil = [1.6 1 1.6];
      x = [x x_pfeil];
      y = [senkrecht senkrecht];
      y_pfeil = [(senkrecht+0.6) senkrecht (senkrecht-0.6)];
      y = [y y_pfeil];
      plot(x,y,'-k');

      end                             % Ende IIR-Filter
    end                               % Ende von n>=1
  end                                 % Ende for n = 0:ordnung
end                                   % Ende strcmp(command_str,'kano1')


%-------------- 2. kanonische Form ------------------------------------------
if strcmp(command_str,'kano2')        % Wenn command_str  kano2
  h_push_rueck = findobj('tag',... % Suche Handle des Pushbuttons
        'rueckgaengig');              % 'Rueckgaengig'
  set(h_push_rueck,...                % Pushbutton 'Rueckgaengig' unsichtbar
        'visible','off');
 h_axes_h=findobj('tag','axes_h(z)','type','axes');	% Axes-Objekt für Überschrift in Kaskaden- und Parallelform
 delete (h_axes_h);			% Axes-Objekt löschen
  h_tauschen = findobj('tag','tauschen');% Handle Pushbutton 'tauschen'
  set(h_tauschen,'visible','off');   % Tauschen inaktiv
 h_skalierung = findobj('tag','Skalierung');% Handle Checkbox opt. Skalierung
  set(h_skalierung,'visible','off');   % skalierung inaktiv
  h_systemantwort = findobj...      % Finde Pushbutton Systemantwort
    ('tag','antwort');
  set(h_systemantwort,'enable','on');% Setze Pushbutton aktiv
  h_filterantwort = findobj...       % Finde Pushbutton 'filterung'
    ('tag','filterung');
  set(h_filterantwort,'enable','on');% Setze Pushbutton aktiv
  screensize = get(0,'screensize'); % Ermittle Bildschirmaufloesung
  width = screensize(3);            % Breite des Bildschirms
  height = screensize(4);           % Hoehe des Bildschirms
  x_lim = [-40 40];                 % Festsetzen der waagerechten Grenzwerte
  y_lim = x_lim .*(height/width)/0.8-30;% Anpassen der senkrechten Grenzwerte
  h_axes = findobj('tag','axes');   % Suche Objekt mit Bezeichnung 'axes'
  set(h_axes,'xlim',x_lim,'ylim',y_lim);% Setze darstellbaren Bereich
  minimum = ordnung * (-15)/22;
  h_sliderx =findobj('tag','slider');% waagerechten und senkrechten
  set(h_sliderx,'value',0,...        % slider zuruecksetzen
        'userdata',0,...
        'visible','off',...
        'enable','off');
  h_slidery =findobj('tag','slidery');
  set(h_slidery,'value',0,...
        'min',minimum,...
        'userdata',0,...
        'visible','on',...
        'enable','on');
  h_change = findobj('tag','change'); % Finde Objekte mit der Bezeichnung
  delete(h_change);               % 'change' (kano3) und loesche diese
  h_children = findobj('parent',gca);   % Nachkommen des aktuellen axes Obj.
  delete(h_children);                 % Loesche Nachkommen
  string = [filter_type,'-Filter ',num2str(ordnung-1),'.Ordnung ','in 2. kanonischer Form']; % Ordnungswert= Anzahl Koeff. -1
  set(h_figure,'name',string);        % Setze name von 'netzwerk'
  for n = 0:(ordnung - 1)
    faktor = (-10);
    senkrecht = n*faktor;             % Senkrechtes Raster
    waagerecht = 10;                  % Waagerechtes Raster

    % --------------- Zeichne Multiplizierer b(n) ---------------------------
    x = [cos([0:5:360]*(pi/180)) cos([5:5:45]*(pi/180)) cos(225*pi/180)];
    y = [sin([0:5:360]*(pi/180)) sin([5:5:45]*(pi/180)) sin(225*pi/180)];
    x = [x cos([230:5:315]*(pi/180)) cos(135*pi/180)] + waagerecht;
    y = [y sin([230:5:315]*(pi/180)) sin(135*pi/180)] + senkrecht;
    h_line = plot(x,y,'-k');
    set(h_line,'tag', 'multiplizierer_b',...
      'buttondownfcn','netzwerk(''quant'');');
    string = ['b(' num2str(n) ')'];
    h_text= text('string',string,...
      'tag','multiplizierer_b',...
      'buttondownfcn','netzwerk(''quant'');',... 
      'erasemode','normal',...
      'clipping','on',...
      'color',[0 0 0],...
      'position',[(1.5+waagerecht) (-1.5+senkrecht)]);

    % ----------------- Zeichne Addierer ------------------------------------
    if(n<=(ordnung-2)) 
      xl = [cos([0:10:360]*(pi/180)) -1];
      xr = [cos([0:10:360]*(pi/180)) -1];
      y = [sin([0:10:360]*(pi/180)) 0];
      xl = [xl cos([190:10:270]*(pi/180)) 0] - 2*waagerecht;
      y = [y sin([190:10:270]*(pi/180)) 1] + senkrecht;
      xr = [xr cos([190:10:270]*(pi/180)) 0] + 2*waagerecht;
      if strcmp(filter_type,'IIR')% Nur IIR-Filter
        h_line = plot(xl,y,'-k',xr,y,'-k');
      elseif  strcmp(filter_type,'FIR')% Nur FIR-Filter
        h_line = plot(xr,y,'-k');
      end
      set(h_line,'tag','addierer');
    end

    % ------------ zeichne Verzoegerungsglied -------------------------------
    if (n>=1)
      x1 = -3;
      x2 = 3;
      y1 = -3.5+senkrecht-faktor;
      y2 = -6.5+senkrecht-faktor;
      x = [x1 x2 x2 x1 x1];
      y = [y1 y1 y2 y2 y1];
      h_verz = plot(x,y,'-k');
      set(h_verz,'tag','verzoegerung');
      string = 'z^{-1}';
      h_text= text('string',string,...
        'tag','verzoegerung',...
        'horizontalalignment','center',...
        'clipping','on',...
        'color',[0 0 0],...
        'position',[0 (-5+senkrecht-faktor)]);
    end

    % ------------ Zeichne Multiplizierer a(n) ------------------------------
    if (n >= 1) & strcmp(filter_type,'IIR')   % Nur IIR-Filter
      x = [cos([0:5:360]*(pi/180)) cos([5:5:45]*(pi/180)) cos(225*pi/180)];
      y = [sin([0:5:360]*(pi/180)) sin([5:5:45]*(pi/180)) sin(225*pi/180)];
      x = [x cos([230:5:315]*(pi/180)) cos(135*pi/180)] - waagerecht;
      y = [y sin([230:5:315]*(pi/180)) sin(135*pi/180)] + senkrecht;
      h_line = plot(x,y,'-k');
      set(h_line,'tag','multiplizierer_a',...
	'buttondownfcn','netzwerk(''quant'');');
      string = ['-a(' num2str(n) ')'];
      h_text= text('string',string,...
        'tag','multiplizierer_a',...
        'buttondownfcn','netzwerk(''quant'');',... 
        'clipping','on',...
        'color',[0 0 0],...
        'position',[(1.5-waagerecht) (-1.5+senkrecht)]);
    end

    % ------------ zeichne Verbindungslinien --------------------------------
    if (n==0)
      if strcmp(filter_type,'IIR')    % Nur IIR-Filter
        x = [(-3*waagerecht) (-2*waagerecht-1)];
        x_pfeil = [(-2*waagerecht-1.6) (-2*waagerecht-1) (-2*waagerecht-1.6)];
        x = [x x_pfeil];
        y = [0 0 0.6 0 -0.6];
        plot(x,y,'-k');

        x = [(-2*waagerecht+1) (waagerecht-1)];
        x_pfeil = [(waagerecht-1.6) (waagerecht-1) (waagerecht-1.6)];
        x = [x x_pfeil];
        y = [0 0 0.6 0 -0.6];
        plot(x,y,'-k');

      elseif strcmp(filter_type,'FIR')% Nur FIR-Filter
        x = [(-3*waagerecht) (waagerecht-1)];
        x_pfeil = [(waagerecht-1.6) (waagerecht-1) (waagerecht-1.6)];
        x = [x x_pfeil];
        y = [0 0 0.6 0 -0.6];
        plot(x,y,'-k');
      end

      x = [(waagerecht+1) (2*waagerecht-1)];
      x_pfeil =[(2*waagerecht-1.6) (2*waagerecht-1) (2*waagerecht-1.6)];
      x = [x x_pfeil];
      y = [0 0 0.6 0 -0.6];
      plot(x,y,'-k');

      x = [(2*waagerecht+1) (3*waagerecht)];
      x_pfeil =[(3*waagerecht-0.6) (3*waagerecht) (3*waagerecht-0.6)];
      x = [x x_pfeil];
      y = [0 0 0.6 0 -0.6];
      plot(x,y,'-k');

      x = [0 0];
      x_pfeil = [-0.6 0 0.6];
      x = [x x_pfeil];
      y = [0 (-3.5)];
      y_pfeil = [(-2.9) -3.5 (-2.9)];
      y = [y y_pfeil];
      plot(x,y,'-k');

      h_text= text('string','X(z)',...
        'color',[0 0 0],...
        'clipping','on',...
        'tag','(z)',...
        'position',[(-3*waagerecht-4) 0]);
      h_text= text('string','\_',...
        'color',[0 0 0],...
        'clipping','on',...
        'tag','(z)',...
        'horizontalalignment','left',...
        'position',[(-3*waagerecht-4) -0.2]);
h_text= text('string','Y(z)',...
        'color',[0 0 0],...
        'clipping','on',...
        'tag','(z)',...
        'position',[(3*waagerecht+3) 0]);
h_text= text('string','\_',...
        'color',[0 0 0],...
        'clipping','on',...
        'tag','(z)',...
        'horizontalalignment','left',...
        'position',[(3*waagerecht+3) -0.2]);
    end       % Ende n==0

    if((n>=1)&(n<(ordnung - 1)))
      x = [(waagerecht+1) (2*waagerecht-1)];
      x_pfeil =[(2*waagerecht-1.6) (2*waagerecht-1) (2*waagerecht-1.6)];
      x = [x x_pfeil];
      y = [senkrecht senkrecht (senkrecht+0.6) senkrecht (senkrecht-0.6)];
      plot(x,y,'-k');

      x = [(2*waagerecht) (2*waagerecht)];
      x_pfeil = [(2*waagerecht-0.6) (2*waagerecht) (2*waagerecht+0.6)];
      x = [x x_pfeil];
      y = [(senkrecht+1) (senkrecht-faktor-1)];
      y_pfeil = [(senkrecht-faktor-1.6) (senkrecht-faktor-1),...
                 (senkrecht-faktor-1.6)];
      y = [y y_pfeil];
      plot(x,y,'-k');

      x = [0 0];
      x_pfeil = [-0.6 0 0.6];
      x = [x x_pfeil];
      y = [(senkrecht+3.5) (senkrecht-3.5)];
      y_pfeil = [(senkrecht-2.9) (senkrecht-3.5) (senkrecht-2.9)];
      y = [y y_pfeil];
      plot(x,y,'-k');

      if strcmp(filter_type,'IIR')    % Nur IIR-Filter
        x = [(-waagerecht-1) (-2*waagerecht+1)];
        x_pfeil =[(-2*waagerecht+1.6) (-2*waagerecht+1) (-2*waagerecht+1.6)];
        x = [x x_pfeil];
        y = [senkrecht senkrecht (senkrecht+0.6) senkrecht (senkrecht-0.6)];
        plot(x,y,'-k');

        x = [(-2*waagerecht) (-2*waagerecht)];
        x_pfeil = [(-2*waagerecht-0.6) (-2*waagerecht) (-2*waagerecht+0.6)];
        x = [x x_pfeil];
        y = [(senkrecht+1) (senkrecht-faktor-1)];
        y_pfeil = [(senkrecht-faktor-1.6) (senkrecht-faktor-1),...
                 (senkrecht-faktor-1.6)];
        y = [y y_pfeil];
        plot(x,y,'-k');

      end                             % Ende von IIR-Filter
    end                               % Ende (n>=1)&(n<ordnung)  

    if (n>=1) & strcmp(filter_type,'IIR')   % Nur IIR-Filter
      x_pfeill = [(-waagerecht+1.6) (-waagerecht+1),...
        (-waagerecht+1.6) (-waagerecht+1)];
      x = (waagerecht-1);
      x_pfeilr =[(waagerecht-1.6) (waagerecht-1) (waagerecht-1.6)];
      x = [x_pfeill x x_pfeilr];
      y = [(senkrecht+0.6) senkrecht (senkrecht-0.6),...
         senkrecht senkrecht (senkrecht+0.6) senkrecht (senkrecht-0.6)];
      plot(x,y,'-k');

    elseif strcmp(filter_type,'FIR')% Nur FIR-Filter
      x = [0 (waagerecht-1)];
      x_pfeilr =[(waagerecht-1.6) (waagerecht-1) (waagerecht-1.6)];
      x = [x x_pfeilr];
      y = [senkrecht senkrecht (senkrecht+0.6) senkrecht (senkrecht-0.6)];
      plot(x,y,'-k');

    end   % Ende n>=1 und nur IIR-Filter

    if (n == (ordnung - 1))
      if strcmp(filter_type,'IIR')   % Nur IIR-Filter
      x = [(-waagerecht-1) (-2*waagerecht) (-2*waagerecht)];
      x_pfeil =[(-2*waagerecht-0.6) (-2*waagerecht) (-2*waagerecht+0.6)];
      x = [x x_pfeil];
      y = [senkrecht senkrecht (senkrecht-faktor-1),...
        (senkrecht-faktor-1.6) (senkrecht-faktor-1) (senkrecht-faktor-1.6)];
      plot(x,y,'-k');
      end  % Ende von nur IIR-Filter

      x = [(waagerecht+1) (2*waagerecht) (2*waagerecht)];
      x_pfeil =[(2*waagerecht-0.6) (2*waagerecht) (2*waagerecht+0.6)];
      x = [x x_pfeil];
      y = [senkrecht senkrecht (senkrecht-faktor-1),...
        (senkrecht-faktor-1.6) (senkrecht-faktor-1) (senkrecht-faktor-1.6)];
      plot(x,y,'-k');

      x = [0 0];
      y = [senkrecht (senkrecht+3.5)];
      plot(x,y,'-k');
    end                             % Ende n = ordnung
  end                               % Ende for n = 0:ordnung
end                                 % Ende command_str = 'kano2'


%-------------- 3. kanonische Form ------------------------------------------
if strcmp(command_str,'kano3')
  command_str='Hges(z)';		% Kommando-String neu setzen, um Überschrift-Objekte zu erzeugen
  tic;
  h_push_rueck = findobj('tag',... % Suche Handle des Pushbuttons
        'rueckgaengig');              % 'Rueckgaengig'
  set(h_push_rueck,...              % Pushbutton 'Rueckgaengig' inaktiv
        'enable','off',...          % und sichtbar
        'visible','on');
  h_axes_h=findobj('tag','axes_h(z)','type','axes');     % Axes-Objekt für Überschrift in Kaskaden- und Parallelform
  delete (h_axes_h);                     % Axes-Objekt löschen
  h_tauschen = findobj('tag','tauschen');% Handle Pushbutton 'tauschen'
  set(h_tauschen,'enable','on',...   % Tauschen aktiv
        'visible','on');             % sichtbar
 h_skalierung = findobj('tag','Skalierung');% Handle Checkbox opt. Skalierung
  set(h_skalierung,'visible','on');   % skalierung aktiv
  h_systemantwort = findobj...      % Finde Pushbutton Systemantwort
    ('tag','antwort');
  set(h_systemantwort,'enable','on');% Setze Pushbutton aktiv
  h_filterantwort = findobj...       % Finde Pushbutton 'filterung'
    ('tag','filterung');
  set(h_filterantwort,'enable','on');% Setze Pushbutton aktiv
  screensize = get(0,'screensize'); % Ermittle Bildschirmaufloesung
  width = screensize(3);            % Breite des Bildschirms
  height = screensize(4);           % Hoehe des Bildschirms
  x_lim = [-20 60];                 % Festsetzen der waagerechten Grenzwerte
  y_lim = x_lim .*(height/width)/0.8-25;   % Anpassen der senkrechten Grenzwerte
  h_axes = findobj('tag','axes');   % Suche Objekt mit Bezeichnung 'axes'
  set(h_axes,'xlim',x_lim,'ylim',y_lim);% Setze darstellbaren Bereich
  h_children = findobj('parent',gca); % Nachkommen von Axes
  delete(h_children);               % Loeschen der Nachkommen
  h_change = findobj('tag','change'); % Finde Objekte mit der Bezeichnung
  delete (h_change);               % 'change' (kano3) und loesche diese
  
  tic;
  string = [filter_type,'-Filter ',num2str(ordnung-1),'.Ordnung ','in 3. kanonischer Form']; % Ordnungswert= Anzahl Koeff. -1
  set(h_figure,'name',string); % Setze name von 'netzwerk'

  sos = matrix(2:size(matrix,1),:); % sos aus Koeffizienten-Matrix lesen
  groesse_sos = size(sos);          % Matrixgroesse ermitteln
  ordnung = groesse_sos(1);         % Ordnung = Anzahl der Reihen
  maximum = ordnung * 10/17;
  h_sliderx =findobj('tag','slider');% waagerechten und senkrechten
  set(h_sliderx,'value',0,...        % slider zuruecksetzen
        'max',maximum,...
        'userdata',0,...
        'visible','on',...
        'enable','on');
  h_slidery =findobj('tag','slidery');
  set(h_slidery,'value',0,...
        'userdata',0,...
        'visible','off',...
        'enable','off');
  for n = 0:(ordnung-1)
    faktor = 10;
    senkrecht = n*faktor;           % Senkrechtes Raster
    waagerecht = n*faktor;          % Waagerechtes Raster

    %------------- Zeichne H(z) ---------------------------------------------
    x1 = -3 + waagerecht;           % Rechteck linke Begrenzung
    x2 = 3 + waagerecht;            % Rechteck rechte Begrenzung
    y1 = 1.5;                       % Rechteck obere Begrenzung
    y2 = -1.5;                      % Rechteck untere Begrenzung
    x = [x1 x2 x2 x1 x1];           % Rechteckkoordinaten x
    y = [y1 y1 y2 y2 y1];           % Rechteckkoordinaten y
    h_verz = plot(x,y,'-k');        % Zeichne Rechteck durchgezogen schwarz
    set(h_verz,'tag','h(z)',...     % Bezeichnung fuer Rechteck = 'h(z)'
    'userdata',sos(n+1,:));         % Zugehoerige Koeffizienten in userdata
    string = ['H' num2str(sort_folge(n+1)-1) '(z)'];% String fuer Text Objekt
    kenn_matrix = [n 0 0 0 0 sort_folge(n+1)-1; sos];    % Matrix = Kaskadennummer + sos
    h_text= text('string',string,...% Text Objekt
      'tag','h(z)',...              % Bezeichnung = h(z)
      'horizontalalignment','center',... % Ausrichtung zentriert
      'color',[0 0 0],...           % Zeichenfarbe = Schwarz
      'clipping','on',...           % Nur innerhalb axes sichtbar
      'userdata',kenn_matrix,...         % Matrix -> userdata
      'buttondownfcn','kaskade(''kaskade'');',... % Ausfuerung bei Mausklick
      'position',[waagerecht 0]);   % Ausrichtung im Raster
    if sort_folge(n+1)>10
	diff=2.2;
    else
	diff=1.6;
    end;
    h_unter= text('string','\_',...% Unterstrich
      'horizontalalignment','center',... % Ausrichtung zentriert
      'color',[0 0 0],...           % Zeichenfarbe = Schwarz
      'clipping','on',...           % Nur innerhalb axes sichtbar
      'position',[waagerecht-diff -0.1]);   % Ausrichtung im Raster


    % --------------- Verbindungslinien -------------------------------------
    x = [(waagerecht+3) (waagerecht+faktor-3)];
    x_pfeil = [(waagerecht+faktor-3.6),...
      (waagerecht+faktor-3) (waagerecht+faktor-3.6)];
    x = [x x_pfeil];                % x-Koordinaten fuer Linie
    y = [0 0 -0.6 0 0.6];           % y-Koordinaten fuer Linie
    h_line=plot(x,y,'-k');          % Zeichne Linie durchgezogen schwarz
    set(h_line,...
        'tag','kaskade3',...
        'userdata',n,...            % Kaskadennummer in userdata
        'buttondownfcn','impulant(''kaskade'');'); 
                                    % Amplituden- und Phasengang mit Maus
    if n == 0
      h_text= text('string','X(z)',...% Text X(z)
        'color',[0 0 0],...
        'clipping','on',...
        'tag','(z)',...
        'position',[(-faktor-1) 0]);  % Links aussen
      h_text= text('string','\_',...% Text X(z)
        'color',[0 0 0],...
        'clipping','on',...
        'tag','(z)',...
        'horizontalalignment','left',...
        'position',[(-faktor-1) -0.2]);  % Links aussen
h_text= text('string','Y(z)',...% Text Y(z)
        'color',[0 0 0],...
        'clipping','on',...           % Rechts aussen
        'tag','(z)',...
        'position',[((ordnung)*faktor) 0]);
h_text= text('string','\_',...     % Text Y(z)
        'color',[0 0 0],...
        'clipping','on',...           % Rechts aussen
        'tag','(z)',...
        'horizontalalignment','left',...
        'position',[((ordnung)*faktor) -0.2]);

      x = [(-faktor+3) -3];           % Einzelne Verbindungslinie
      x_pfeil = [-3.6 -3 -3.6];
      x = [x x_pfeil];
      y = [0 0 -0.6 0 0.6];
      plot(x,y,'-k');

    end                               % Ende von n == 0
  end                                 % Ende von for n = 0:ordnung

  string_value = ['H0(z)'];           % Erster Menuepunkt
  for n = 1:(ordnung-1)               % Menuepunkte fuer Popupmenues
    string_help = ['H' num2str(n) '(z)'];% Hn(z) mit n = 1...Ordnung-1
    string_value = str2mat(string_value,string_help);
 end
end                                   % Ende command_str = 'kano3'
  

%-------------- 3. kanonische Form b0 normiert ------------------------------
if strcmp(command_str,'kano3n')     % Wenn command_str = kano3n
  command_str='Hges(z)';		% Kommando-String neu setzen, um Überschrift-Objekte zu erzeugen
  h_push_rueck = findobj('tag',...      % Suche Handle des Pushbuttons
        'rueckgaengig');              % 'Rueckgaengig'
  set(h_push_rueck,...              % Pushbutton 'Rueckgaengig' inaktiv
        'enable','off',...
        'visible','on');
 h_axes_h=findobj('tag','axes_h(z)','type','axes');	% Axes-Objekt für Überschrift in Kaskaden- und Parallelform
 delete (h_axes_h);			% Axes-Objekt löschen
  h_tauschen = findobj('tag','tauschen');% Handle Pushbutton 'tauschen'
  set(h_tauschen,'enable','on',...  % Tauschen aktiv
        'visible','on');
 h_skalierung = findobj('tag','Skalierung');% Handle Checkbox opt. Skalierung
  set(h_skalierung,'visible','on');   % skalierung aktiv
  h_systemantwort = findobj...      % Finde Pushbutton Systemantwort
    ('tag','antwort');
  set(h_systemantwort,'enable','on');% Setze Pushbutton aktiv
  h_filterantwort = findobj...       % Finde Pushbutton 'filterung'
    ('tag','filterung');
  set(h_filterantwort,'enable','on');% Setze Pushbutton aktiv
  screensize = get(0,'screensize'); % Ermittle Bildschirmaufloesung
  width = screensize(3);            % Breite des Bildschirms
  height = screensize(4);           % Hoehe des Bildschirms
  x_lim = [-20 60];                 % Festsetzen der waagerechten Grenzwerte
  y_lim = x_lim .*(height/width)/0.8-25;   % Anpassen der senkrechten Grenzwerte
  h_axes = findobj('tag','axes');   % Suche Objekt mit Bezeichnung 'axes'
  set(h_axes,'xlim',x_lim,'ylim',y_lim);% Setze darstellbaren Bereich
  h_children = findobj('parent',gca); % Nachkommen von Axes
  delete(h_children);               % Loeschen der Nachkommen
  h_change = findobj('tag','change'); % Finde Objekte mit der Bezeichnung
  delete(h_change);               % 'change' (kano3) und loesche diese
  string = [filter_type,'-Filter ',num2str(ordnung-1),'.Ordnung ','in 3. kanonischer Form, b0 normiert']; % Ordnungswert= Anzahl Koeff. -1
  set(h_figure,'name',string); % Setze name von 'netzwerk'
                                    % Ueberschrift der Figur
  sos = matrix(2:size(matrix,1),2:7);   % sos aus Koeffizienten-Matrix lesen
  groesse_sos = size(sos);          % Matrixgroesse ermitteln
  ordnung = groesse_sos(1);         % Ordnung = Anzahl der Reihen
  maximum = ordnung * 10/17;
  h_sliderx =findobj('tag','slider');% waagerechten und senkrechten
  set(h_sliderx,'value',0,...        % slider zuruecksetzen
        'max',maximum,...
        'userdata',0,...
        'visible','on',...
        'enable','on');
  h_slidery =findobj('tag','slidery');
  set(h_slidery,'value',0,...
        'userdata',0,...
        'visible','off',...
        'enable','off');
  norm_faktor=matrix(2:size(matrix,1),1); % Normierungs-Koeffizienten lesen
  matrix_voll=[norm_faktor,sos];    % Matrix um norm_faktor ergaenzen
  for n = 0:(ordnung-1)
    faktor = 10;
    senkrecht = n*faktor;           % Senkrechtes Raster
    waagerecht = n*faktor;          % Waagerechtes Raster

    %------------- Zeichne H(z) ---------------------------------------------
    x1 = -3 + waagerecht;           % Rechteck linke Begrenzung
    x2 = 3 + waagerecht;            % Rechteck rechte Begrenzung
    y1 = 1.5;                       % Rechteck obere Begrenzung
    y2 = -1.5;                      % Rechteck untere Begrenzung
    x = [x1 x2 x2 x1 x1];           % Rechteckkoordinaten x
    y = [y1 y1 y2 y2 y1];           % Rechteckkoordinaten y
    h_verz = plot(x,y,'-k');        % Zeichne Rechteck durchgezogen schwarz
    set(h_verz,'tag','h(z)',...     % Bezeichnung fuer Rechteck = 'h(z)'
    'userdata',sos(n+1,:));         % Zugehoerige Koeffizienten in userdata
    string = ['H' num2str(sort_folge(n+1)-1) '(z)'];% String fuer Text Objekt
    kenn_matrix = [n 0 0 0 0 0 sort_folge(n+1)-1; matrix_voll]; % Matrix = Kaskadennummer + sos
    h_text= text('string',string,...% Text Objekt
      'tag','h(z)',...              % Bezeichnung = h(z)
      'horizontalalignment','center',... % Ausrichtung zentriert
      'color',[0 0 0],...           % Zeichenfarbe = Schwarz
      'clipping','on',...           % Nur innerhalb axes sichtbar
      'userdata',kenn_matrix,...     % Matrix -> userdata
      'buttondownfcn','kaskade(''kaskadenorm'');',...
      'position',[waagerecht 0]);   % Ausrichtung im Raster
    if sort_folge(n+1)>10
	diff=2.2;
    else
	diff=1.6;
    end;
    h_unter= text('string','\_',...% Unterstrich
      'horizontalalignment','center',... % Ausrichtung zentriert
      'color',[0 0 0],...           % Zeichenfarbe = Schwarz
      'clipping','on',...           % Nur innerhalb axes sichtbar
      'position',[waagerecht-diff -0.1]);   % Ausrichtung im Raster

    % --------------- Verbindungslinien -------------------------------------
    x = [(waagerecht+3) (waagerecht+faktor-3)];
    x_pfeil = [(waagerecht+faktor-3.6),...
        (waagerecht+faktor-3) (waagerecht+faktor-3.6)];
    x = [x x_pfeil];                % x-Koordinaten fuer Linie
    y = [0 0 -0.6 0 0.6];           % y-Koordinaten fuer Linie
    h_line=plot(x,y,'-k');          % Zeichne Linie durchgezogen schwarz
    set(h_line,...
        'tag','kaskade3',...
        'userdata',n,...            % Kaskadennummer in userdata
        'buttondownfcn','impulant(''kaskade_norm'');'); 
                                    % Amplituden- und Phasengang mit Maus
    if n == 0
      h_text= text('string','X(z)',...% Text X(z)
        'color',[0 0 0],...
        'clipping','on',...
        'tag','(z)',...
        'position',[(-faktor-1) 0]);  % Links aussen
       h_text= text('string','\_',...% Text X(z)
        'color',[0 0 0],...
        'clipping','on',...
        'tag','(z)',...
        'horizontalalignment','left',...
        'position',[(-faktor-1) -0.2]);  % Links aussen
h_text= text('string','Y(z)',...% Text Y(z)
        'color',[0 0 0],...
        'clipping','on',...           % Rechts aussen
        'tag','(z)',...
        'position',[((ordnung)*faktor) 0]);
h_text= text('string','\_',...% Text Y(z)
        'color',[0 0 0],...
        'clipping','on',...           % Rechts aussen
        'tag','(z)',...
        'horizontalalignment','left',...
        'position',[((ordnung)*faktor) -0.2]);

      x = [(-faktor+3) -3];           % Einzelne Verbindungslinie
      x_pfeil = [-3.6 -3 -3.6];
      x = [x x_pfeil];
      y = [0 0 -0.6 0 0.6];
      plot(x,y,'-k');

    end                               % Ende von n == 0
  end                                 % Ende von for n = 0:ordnung
  string_value = ['H0(z)'];           % Erster Menuepunkt
  for n = 1:(ordnung-1)               % Menuepunkte fuer Popupmenues
    string_help = ['H' num2str(n) '(z)'];% Hn(z) mit n = 1...Ordnung-1
    string_value = str2mat(string_value,string_help);
  end
end                                   % Ende command_str = 'kano3'


%-------------- lattice ladder ----------------------------------------------
if strcmp(command_str,'lattice')      % Wenn command_str = lattice
  [k,c] = lattice(b,a);               % Berechne Gitterkoeffizienten
  ordnung = length(k);                % Anzahl der Gitterstrukturen
  maximum = ordnung * 30 / 11;
  h_push_rueck = findobj('tag',... % Suche Handle des Pushbuttons
        'rueckgaengig');              % 'Rueckgaengig'
  set(h_push_rueck,...                % Pushbutton 'Rueckgaengig' unsichtbar
        'visible','off');
 h_axes_h=findobj('tag','axes_h(z)','type','axes');	% Axes-Objekt für Überschrift in Kaskaden- und Parallelform
 delete (h_axes_h);			% Axes-Objekt löschen
  h_tauschen = findobj('tag','tauschen');% Handle Pushbutton 'tauschen'
  set(h_tauschen,'visible','off');   % Tauschen inaktiv
 h_skalierung = findobj('tag','Skalierung');% Handle Checkbox opt. Skalierung
  set(h_skalierung,'visible','off');   % skalierung inaktiv
  h_systemantwort = findobj...      % Finde Pushbutton Systemantwort
    ('tag','antwort');
  set(h_systemantwort,'enable','on');% Setze Pushbutton aktiv
  h_filterantwort = findobj...       % Finde Pushbutton 'filterung'
    ('tag','filterung');
  set(h_filterantwort,'enable','on');% Setze Pushbutton aktiv
  screensize = get(0,'screensize'); % Ermittle Bildschirmaufloesung
  width = screensize(3);            % Breite des Bildschirms
  height = screensize(4);           % Hoehe des Bildschirms
  x_lim = [-10 70];                 % Festsetzen der waagerechten Grenzwerte
  y_lim = x_lim .*(height/width)/0.8-55;% Anpassen der senkrechten Grenzwerte
  h_axes = findobj('tag','axes');   % Suche Objekt mit Bezeichnung 'axes'
  set(h_axes,'xlim',x_lim,'ylim',y_lim);% Setze darstellbaren Bereich
  h_sliderx =findobj('tag','slider');% waagerechten und senkrechten
  set(h_sliderx,'value',0,...      % slider zuruecksetzen
        'userdata',0,...
        'max',maximum,...
        'visible','on',...
        'enable','on');
  h_slidery =findobj('tag','slidery');
  set(h_slidery,'value',0,...
        'userdata',0,...
        'visible','off',...
        'enable','off');
  h_change = findobj('tag','change'); % Finde Objekte mit der Bezeichnung
  delete(h_change);               % 'change' (kano3) und loesche diese
  h_children = findobj('parent',gca);   % Nachkommen des aktuellen axes Obj.
  delete(h_children);                 % Loesche Nachkommen
  string = [filter_type,'-Filter ',num2str(max(length(a),length(b))-1),'.Ordnung',' in Lattice-Ladder-Struktur']; %Ordnungswert= Anzahl Koeff. -1
  set(h_figure,'name',string); % Setze name von 'netzwerk'

  % ---- Geometrische Berechnungen fuer schraege Verbindungslinien ----------
  winkel = atan(1.5/2);               % Rechtwinkliges Dreieck Addierer oben,
  hyp = (5/cos(winkel));              % Addierer unten, Schnittpunkt Schraege
  kn_unten = (hyp+1)*cos(winkel);     % Untere y-Koordinate fuer
                                      % Multiplizierer kn
  kn_oben = (hyp-1)*cos(winkel);      % Obere y-Koordinate fuer
                                      % Multiplizierer kn
  add_oben = cos(winkel);             % y-Koordinate oberer Addierer
  add_unten = (-20)+cos(winkel);      % y-Koordinate unterer Addierer
  add_rechts = sin(winkel);           % x-Koordinate der Addierer
  neg_kn_links = (hyp -1)*sin(winkel);% obere x-Koordinate von -k(n)
  neg_kn_rechts =(hyp +1)*sin(winkel);% untere x-Koordinate von -k(n)
  hyp2 = 15/cos(winkel);              % Hypothenuse von k(n)
  pos_kn_links= (hyp2 -1)*sin(winkel);% untere x-Koordinate von k(n)
  pos_kn_rechts= (hyp2+1)*sin(winkel);% obere x-Koordinate von k(n)
  alpha=atan(0.5/2);                  % Halber Pfeiloeffnungswinkel
  seite=sqrt(2^2+0.5^2);              % Seitenlaenge bezogen auf Addierer-
                                      % mittelpunkt
  xrechts = seite*cos(pi/2-winkel-alpha)-add_rechts;
  xlinks = seite*cos(pi/2-winkel+alpha)-add_rechts;
  yrechts_ob = -seite*sin(pi/2-winkel-alpha);
  ylinks_unt = seite*sin(pi/2-winkel+alpha)+2*(-10);
  ylinks_ob = -seite*sin(pi/2-winkel+alpha);
  yrechts_unt = seite*sin(pi/2-winkel-alpha)+2*(-10);

  for n = 0:(ordnung - 1)
    faktor = (-10);                   % Faktor fuer senkrechten Abstand
    senkrecht = n*faktor;             % Senkrechtes Raster
    waagerecht = 10;                  % Waagerechtes Raster
    % --------------- Zeichne Multiplizierer k(n)----------------------------
    x = [cos([0:5:360]*(pi/180)),...  % x-Kreiskoordinaten
         cos([5:5:45]*(pi/180)),...   % Anfang 1.Diagonale bei 45ø
         cos(225*pi/180)];            % Endpunkt 1.Diagonale bei 225ø
    y = [sin([0:5:360]*(pi/180)),...  % y-Kreiskoordinaten
         sin([5:5:45]*(pi/180)),...   % Anfang 1.Diagonale bei 45ø
         sin(225*pi/180)];            % Endpunkt 1.Diagonale bei 225ø
    x = [x cos([230:5:315]*(pi/180)),...% 2.Diagonale 315ø,135ø
         cos(135*pi/180)] ;           % Raster links von Null
    y = [y sin([230:5:315]*(pi/180)),...% 2.Diagonale 315ø,135ø
         sin(135*pi/180)] ;           % Raster unterhalb von Null
    y = y + (faktor/2);
    x = x + ((3*n + 1)*waagerecht) + 11.25;
    h_line = plot(x,y,'-k');          % Zeichne Objekt schwarz
    set(h_line,...
      'buttondownfcn','netzwerk(''quant'');',... 
       'tag','multiplizierer_k');    % Setze tag = multiplizierer_k
    string = ['k(' num2str(ordnung-n-1) ')'];  % String fuer Beschriftung
    text('string',string,...          % Generiere Textobjekt
      'tag','multiplizierer_k',...    % Setze tag = multiplizierer_k
      'buttondownfcn','netzwerk(''quant'');',... 
      'erasemode','normal',...
      'clipping','on',...
      'color',[0 0 0],...             % Farbe = Schwarz
      'position',[((3*n + 1)*waagerecht) + 12.75,...% waagerechte Position
                (-1.5+faktor/2)]);    % senkrechte Position

    % --------------- Zeichne Multiplizierer -k(n) --------------------------
    x = [cos([0:5:360]*(pi/180)),...  % x-Kreiskoordinaten
         cos([5:5:45]*(pi/180)),...   % Anfang 1.Diagonale bei 45ø
         cos(225*pi/180)];            % Endpunkt 1.Diagonale bei 225ø
    y = [sin([0:5:360]*(pi/180)),...  % y-Kreiskoordinaten
         sin([5:5:45]*(pi/180)),...   % Anfang 1.Diagonale bei 45ø
         sin(225*pi/180)];            % Endpunkt 1.Diagonale bei 225ø
    x = [x cos([230:5:315]*(pi/180)),...% 2.Diagonale 315ø,135ø
         cos(135*pi/180)] ;           % Raster links von Null
    y = [y sin([230:5:315]*(pi/180)),...% 2.Diagonale 315ø,135ø
         sin(135*pi/180)] ;           % Raster unterhalb von Null
    y = y + (faktor/2);
    x = x + ((3*n + 1)*waagerecht) + 3.75;
    h_line = plot(x,y,'-k');          % Zeichne Objekt schwarz
    set(h_line,...
      'buttondownfcn','netzwerk(''quant'');',... 
       'tag','multiplizierer_-k');   % Setze tag = multiplizierer_-k
    string = ['-k(' num2str(ordnung-n-1) ')'];  % String fuer Beschriftung
    text('string',string,...          % Generiere Textobjekt
      'tag','multiplizierer_-k',...   % Setze tag = multiplizierer_-k
      'buttondownfcn','netzwerk(''quant'');',... 
      'erasemode','normal',...
      'clipping','on',...
      'color',[0 0 0],...             % Farbe = Schwarz
      'position',[((3*n + 1)*waagerecht)-1.5,...% waagerechte Position
                (-1.5+faktor/2)]);    % senkrechte Position


    % --------------- Zeichne Multiplizierer ny(n) --------------------------
    x = [cos([0:5:360]*(pi/180)),...  % x-Kreiskoordinaten
         cos([5:5:45]*(pi/180)),...   % Anfang 1.Diagonale bei 45ø
         cos(225*pi/180)];            % Endpunkt 1.Diagonale bei 225ø
    y = [sin([0:5:360]*(pi/180)),...  % y-Kreiskoordinaten
         sin([5:5:45]*(pi/180)),...   % Anfang 1.Diagonale bei 45ø
         sin(225*pi/180)];            % Endpunkt 1.Diagonale bei 225ø
    x = [x cos([230:5:315]*(pi/180)),...% 2.Diagonale 315ø,135ø
         cos(135*pi/180)] ;           % Raster links von Null
    y = [y sin([230:5:315]*(pi/180)),...% 2.Diagonale 315ø,135ø
         sin(135*pi/180)] ;           % Raster unterhalb von Null
    y = y + (faktor*2.5);
    x = x + ((3*n+3.5)*waagerecht);
    h_line = plot(x,y,'-k');          % Zeichne Objekt schwarz
    set(h_line,...
        'buttondownfcn','',...   
        'buttondownfcn','netzwerk(''quant'');',... 
        'tag','multiplizierer_ny');   % Setze tag = multiplizierer_ny
    string = ['c(' num2str(ordnung-n-1) ')'];  % String fuer Beschriftung
    text('string',string,...          % Generiere Textobjekt
      'tag','multiplizierer_ny',...   % Setze tag = multiplizierer_ny
      'buttondownfcn','netzwerk(''quant'');',... 
      'erasemode','normal',...
      'clipping','on',...
      'color',[0 0 0],...             % Farbe = Schwarz
      'position',[((3*n +3.5)*waagerecht) + 1.5,...% waagerechte Position
                (-1.5+faktor*2.5)]);  % senkrechte Position

    if (n == 0)                       % Wenn n = 0
      % --------------- Zeichne Multiplizierer ny(N) ------------------------
      x = [cos([0:5:360]*(pi/180)),...% x-Kreiskoordinaten
         cos([5:5:45]*(pi/180)),...   % Anfang 1.Diagonale bei 45ø
         cos(225*pi/180)];            % Endpunkt 1.Diagonale bei 225ø
      y = [sin([0:5:360]*(pi/180)),...  % y-Kreiskoordinaten
         sin([5:5:45]*(pi/180)),...   % Anfang 1.Diagonale bei 45ø
         sin(225*pi/180)];            % Endpunkt 1.Diagonale bei 225ø
      x = [x cos([230:5:315]*(pi/180)),...% 2.Diagonale 315ø,135ø
         cos(135*pi/180)] ;           % Raster links von Null
      y = [y sin([230:5:315]*(pi/180)),...% 2.Diagonale 315ø,135ø
         sin(135*pi/180)] ;           % Raster unterhalb von Null
      y = y + (faktor*2.5);
      x = x + 0.5*waagerecht;
      h_line = plot(x,y,'-k');        % Zeichne Objekt schwarz
      set(h_line,...
        'buttondownfcn','netzwerk(''quant'');',... 
        'tag','multiplizierer_ny');   % Setze tag = multiplizierer_ny
      string = ['c(' num2str(ordnung-n) ')'];  % String fuer Beschriftung
      text('string',string,...        % Generiere Textobjekt
        'tag','multiplizierer_ny',... % Setze tag = multiplizierer_ny
        'buttondownfcn','netzwerk(''quant'');',...
        'erasemode','normal',...
        'clipping','on',...
        'color',[0 0 0],...           % Farbe = Schwarz
        'position',[0.5*waagerecht+1.5,...% waagerechte Position
                (-1.5+faktor*2.5)]);  % senkrechte Position
    end                               % Ende von n == 1

    % ----------------- Zeichne Addierer oben -------------------------------
    x = [cos([0:10:360]*(pi/180)) -1];% Kreis und waagerechter Strich
    y = [sin([0:10:360]*(pi/180)) 0];
    x = [x cos([190:10:270]*(pi/180)) 0];% Halbkreis + senkrechter Strich
    y = [y sin([190:10:270]*(pi/180)) 1];
    x = x + ((n*3+1)*waagerecht);
    h_line = plot(x,y,'-k');
    set(h_line,'tag','addierer',...
        'buttondownfcn','');

    % ----------------- Zeichne Addierer unten ------------------------------
    x = [cos([0:10:360]*(pi/180)) -1];% Kreis und waagerechter Strich
    y = [sin([0:10:360]*(pi/180)) 0];
    x = [x cos([190:10:270]*(pi/180)) 0];% Halbkreis + senkrechter Strich
    y = [y sin([190:10:270]*(pi/180)) 1];
    x = x + ((n*3+1)*waagerecht);
    y = y + 2*faktor;
    h_line = plot(x,y,'-k');
    set(h_line,'tag','addierer',...
        'buttondownfcn','');

    if (n == 0)                       % Wenn n = 0
      % ----------------- Zeichne Addierer ny -------------------------------
      horizont =((ordnung)*3/2*waagerecht)+0.5*waagerecht;
      x = [cos([0:10:360]*(pi/180)) -1];% Kreis und waagerechter Strich
      y = [sin([0:10:360]*(pi/180)) 0];
      x = [x cos([190:10:270]*(pi/180)) 0];% Halbkreis + senkrechter Strich
      y = [y sin([190:10:270]*(pi/180)) 1];
      x = x + horizont;
      y = y + 4*faktor;
      h_line = plot(x,y,'-k');
      set(h_line,'tag','addierer',...
          'buttondownfcn','');
    end                               % Ende von n = 0


    % ------------ zeichne Verzoegerungsglied -------------------------------
    x1 = -2;                          % waagerechte Koordinaten
    x2 = 2;                           % fuer alle n gleich
    y1 = 1.5;                         % senkrechte Koordinaten
    y2 = -1.5;                        % im senkrechten Raster
    x = [x1 x2 x2 x1 x1];             % Zusammenfassung fuer Rechteck x
    y = [y1 y1 y2 y2 y1];             % Zusammenfassung fuer Rechteck y
    y = y + 2*faktor;
    x = x + ((3*n + 3)*waagerecht);
    h_verz = plot(x,y,'-k');          % Zeichne Rechteck
    set(h_verz,...
        'tag','verzoegerung');        % Setze tag = verzoegerung
    string = 'z^{-1}';                  % String fuer Verzoegerungsglied
    text('string',string,...          % Generiere Textobjekt innerhalb
      'tag','verzoegerung',...        % des Rechteckes
      'clipping','on',...             % Text nur innerhalb axes sichtbar
      'horizontalalignment','center',...% waagerechte Ausrichtung
      'color',[0 0 0],...             % ist mittig, Farbe = Schwarz
      'position',[(3*n+3)*waagerecht 2*faktor]);% [x y] Koordinaten

    % ------------ zeichne Verbindungslinien --------------------------------
    x1 = (3*n+3.5)*waagerecht;
    y1 = 2.5*faktor+1;
    x2 = (3*n+4)*waagerecht-1;
    y2 = 2*faktor;
    x3 = (3*n+3)*waagerecht+2;
    x = [x1 x1 x2 x3 x3+1 x3 x3+1];
    y = [y1 y2 y2 y2 y2-0.5 y2 y2+0.5];
    h_line = plot(x,y,'-k');
    set(h_line,'tag','lattice');

    x1 = (3*n+3)*waagerecht-2;
    y1 = 2*faktor;
    x2 = (3*n+1)*waagerecht+1;
    y2 = 2*faktor;
    x = [x1 x2 x2+1 x2 x2+1];
    y = [y1 y2 y2-0.5 y2 y2+0.5];
    h_line = plot(x,y,'-k');
    set(h_line,'tag','lattice');

    x1 = (3*n+2.5)*waagerecht;
    y1 = 2*faktor;
    x2 = (3*n+1)*waagerecht+neg_kn_rechts;
    y2 = -kn_unten;
    x = [x1 x2];
    y = [y1 y2];
    h_line = plot(x,y,'-k');
    set(h_line,'tag','lattice');

    x1 = (3*n+1)*waagerecht+neg_kn_links;
    y1 = -kn_oben;
    x2 = (3*n+1)*waagerecht+add_rechts;
    y2 = -add_oben;
    x = [x1 x2 x2+xrechts x2 x2+xlinks];
    y = [y1 y2 yrechts_ob y2 ylinks_ob];
    h_line = plot(x,y,'-k');
    set(h_line,'tag','lattice');

    x1 = (3*n+2.5)*waagerecht;
    y1 = 0;
    x2 = (3*n+1)*waagerecht+pos_kn_rechts;
    y2 = -kn_oben;
    x = [x1 x2 ];
    y = [y1 y2 ];
    h_line = plot(x,y,'-k');
    set(h_line,'tag','lattice');

    x1 = (3*n+1)*waagerecht+pos_kn_links;
    y1 = -kn_unten;
    x2 = (3*n+1)*waagerecht+add_rechts;
    y2 = add_unten;
    x = [x1 x2 x2+xrechts x2 x2+xlinks];
    y = [y1 y2 yrechts_unt y2 ylinks_unt];
    h_line = plot(x,y,'-k');
    set(h_line,'tag','lattice');

    if (n == 0)
      x1 = horizont;
      y1 = 4*faktor-1;
      y2 = 5*faktor;
      x = [x1 x1 x1-0.5 x1 x1+0.5];
      y = [y1 y2 y2+1 y2 y2+1];
      h_line = plot(x,y,'-k','userdata','middle');
      set(h_line,'tag','lattice');

      x1 = 0.5*waagerecht;
      x2 = waagerecht-1;
      y1 = 0;
      y2 = 0;
      x = [x1 x2 x2-1 x2 x2-1];
      y = [y1 y2 y2-0.5 y2 y2+0.5];
      h_line = plot(x,y,'-k');
      set(h_line,'tag','lattice','userdata','min');

      x1 = 0.5*waagerecht;
      y1 = 2.5*faktor+1;
      x2 = waagerecht-1;
      y2 = 2*faktor;
      x = [x1 x1 x2];
      y = [y1 y2 y2];
      h_line = plot(x,y,'-k');
      set(h_line,'tag','lattice');

      h_text= text('string','X(z)',...
        'color',[0 0 0],...
        'clipping','on',...
        'tag','(z)',...
        'position',[0 0]);
      h_text= text('string','\_',...
        'color',[0 0 0],...
        'clipping','on',...
        'tag','(z)',...
        'horizontalalignment','left',...
        'position',[0 -0.2]);
h_text= text('string','Y(z)',...
        'color',[0 0 0],...
        'clipping','on',...
        'tag','(z)',...
        'horizontalalignment','center',...
        'position',[horizont (5*faktor-1.5)]);
h_text= text('string','\_',...
        'color',[0 0 0],...
        'clipping','on',...
        'tag','(z)',...
        'horizontalalignment','left',...
        'position',[horizont (5*faktor-1.7)]);
    end

    if (n < (ordnung-1))
      x1 = (3*n+1)*waagerecht+1;
      y1 = 0;
      x2 = (3*n+4)*waagerecht-1;
      y2 = 0;
      x = [x1 x2 x2-1 x2 x2-1];
      y = [y1 y2 y2-0.5 y2 y2+0.5];
      h_line = plot(x,y,'-k');
      set(h_line,'tag','lattice');
    end

    if (n == (ordnung-1))
      x1 = (3*n+1)*waagerecht+1;
      y1 = 0;
      x2 = (3*n+4)*waagerecht-1;
      y2 = 2*faktor;
      x = [x1 x2 x2];
      y = [y1 y1 y2];
      h_line = plot(x,y,'-k');
      set(h_line,'tag','lattice','userdata','max');
    end


  end                                 % Ende von for n=0:ordnung-1
  for n = 0:ordnung
    abstand = horizont - 3*n*waagerecht;
    if (abstand <10)&(abstand>-10)
      abstand = 0;
    end
    if abstand > 0
      winkelhor = atan(10/abstand);
      xhori = horizont-cos(winkelhor);
      yhori = 4*faktor+sin(winkelhor);
      xrechts =horizont-seite*cos(winkelhor+alpha);
      xlinks =horizont-seite*cos(winkelhor-alpha);
      yrechts = seite*sin(winkelhor+alpha)+4*(-10);
      ylinks = seite*sin(winkelhor-alpha)+4*(-10);
      x1 = (3*n+0.5)*waagerecht;
      y1 = 2.5*faktor-1;
      y2 = 3*faktor;
      x = [x1 x1 xhori xrechts xhori xlinks];
      y = [y1 y2 yhori yrechts yhori ylinks];
      h_line = plot(x,y,'-k');
      set(h_line,'tag','lattice');
    end                               % Ende von abstand>0
    if abstand == 0
      yhori = 4*faktor+1;
      xhori = horizont;
      x1 = (3*n+0.5)*waagerecht;
      y1 = 2.5*faktor-1;
      y2 = 3*faktor;
      x = [x1 x1 xhori xhori+0.5 xhori xhori-0.5];
      y = [y1 y2 yhori yhori+1 yhori yhori+1];
      h_line = plot(x,y,'-k');
      set(h_line,'tag','lattice');
    end                               % Ende von abstand>0
    if abstand < 0
      winkelhor = atan((-10)/abstand);
      xhori = horizont+cos(winkelhor);
      yhori = 4*faktor+sin(winkelhor);
      xrechts =horizont+seite*cos(winkelhor-alpha);
      xlinks =horizont+seite*cos(winkelhor+alpha);
      yrechts = seite*sin(winkelhor-alpha)+4*(-10);
      ylinks = seite*sin(winkelhor+alpha)+4*(-10);
      x1 = (3*n+0.5)*waagerecht;
      y1 = 2.5*faktor-1;
      y2 = 3*faktor;
      x = [x1 x1 xhori xrechts xhori xlinks];
      y = [y1 y2 yhori yrechts yhori ylinks];
      h_line = plot(x,y,'-k');
      set(h_line,'tag','lattice');
    end                               % Ende von abstand>0
  end                                 % Ende von for n=0:ordnung
end                                   % Ende von command_str = lattice

%-------------- Parallelform ------------------------------------------------
if strcmp(command_str,'parallel')
  command_str='Hges(z)';		% Kommando-String neu setzen, um Überschrift-Objekte zu erzeugen
  h_systemantwort = findobj...        % Finde Pushbutton Systemantwort
    ('tag','antwort');
  matrix = get...                     % Lies Koeffizientenmatrix aus userdata
    (h_systemantwort,'userdata');
  [reihen,spalten] = size(matrix);    % Matrixgroesse ermitteln
  h_push_rueck = findobj('tag',... % Suche Handle des Pushbuttons
        'rueckgaengig');              % 'Rueckgaengig'
  set(h_push_rueck,...                % Pushbutton 'Rueckgaengig' inaktiv
        'enable','off',...            % und unsichtbar
        'visible','off');
  h_axes_h=findobj('tag','axes_h(z)','type','axes');     % Axes-Objekt für Überschrift in Kaskaden- und Parallelform
  delete (h_axes_h);                     % Axes-Objekt löschen
  h_tauschen = findobj('tag','tauschen');% Handle Pushbutton 'tauschen'
  set(h_tauschen,'enable','off',...   % Tauschen inaktiv
        'visible','off');             % unsichtbar
 h_skalierung = findobj('tag','Skalierung');% Handle Checkbox opt. Skalierung
  set(h_skalierung,'visible','off');   % skalierung inaktiv
  set(h_systemantwort,'enable','on');% Setze Pushbutton aktiv
  h_filterantwort = findobj...       % Finde Pushbutton 'filterung'
    ('tag','filterung');
  set(h_filterantwort,'enable','on');% Setze Pushbutton aktiv
  screensize = get(0,'screensize'); % Ermittle Bildschirmaufloesung
  width = screensize(3);            % Breite des Bildschirms
  height = screensize(4);           % Hoehe des Bildschirms
  x_lim = [-20 60];                 % Festsetzen der waagerechten Grenzwerte
  y_lim = x_lim .*(height/width)/0.8-25;   % Anpassen der senkrechten Grenzwerte
  h_axes = findobj('tag','axes');   % Suche Objekt mit Bezeichnung 'axes'
  set(h_axes,'xlim',x_lim,'ylim',y_lim);% Setze darstellbaren Bereich
  h_children = findobj('parent',gca); % Nachkommen von Axes
  delete(h_children);               % Loeschen der Nachkommen
  h_change = findobj('tag','change'); % Finde Objekte mit der Bezeichnung
  delete(h_change);               % 'change' (kano3) und loesche diese
  string = [filter_type,'-Filter ',num2str(ordnung-1),'.Ordnung ',' in Parallelform']; %Ordnungswert= Anzahl Koeff. -1
  set(h_figure,'name',string);      % Setze name von 'netzwerk'
  ordnung = reihen - 1;             % Ordnung = Anzahl der Reihen
  c = matrix(2:reihen,1);           % Koeffizienten der Reststruktur
  maximum = (ordnung + length(c)) * 10/25;
  h_sliderx =findobj('tag','slider');% waagerechten und senkrechten
  set(h_sliderx,'value',0,...        % slider zuruecksetzen
        'max',maximum,...
        'userdata',0,...
        'visible','on',...
        'enable','on');
  h_slidery =findobj('tag','slidery');
  set(h_slidery,'value',0,...
        'userdata',0,...
        'visible','off',...
        'enable','off');
  sos = matrix(2:reihen,2:spalten); % Koeffizienten der Kaskaden
  for n = 0:(ordnung-1)
    faktor = 10;
    senkrecht = n*faktor;           % Senkrechtes Raster
    waagerecht = n*faktor;          % Waagerechtes Raster
    %------------- Zeichne H(z) ---------------------------------------------
    x1 = -3 + waagerecht;           % Rechteck linke Begrenzung
    x2 = 3 + waagerecht;            % Rechteck rechte Begrenzung
    y1 = 1.5;                       % Rechteck obere Begrenzung
    y2 = -1.5;                      % Rechteck untere Begrenzung
    x = [x1 x2 x2 x1 x1];           % Rechteckkoordinaten x
    y = [y1 y1 y2 y2 y1];           % Rechteckkoordinaten y
    h_verz = plot(x,y,'-k');        % Zeichne Rechteck durchgezogen schwarz
    set(h_verz,'tag','h(z)',...     % Bezeichnung fuer Rechteck = 'h(z)'
    'userdata',sos(n+1,:));         % Zugehoerige Koeffizienten in userdata
    string = ['H' num2str(n) '(z)'];% String fuer Text Objekt
    mat = [0 0 0 0 0 n; sos];       % Matrix = Kaskadennummer + sos
    h_text= text('string',string,...% Text Objekt
      'tag','h(z)',...              % Bezeichnung = h(z)
      'horizontalalignment','center',... % Ausrichtung zentriert
      'color',[0 0 0],...           % Zeichenfarbe = Schwarz
      'clipping','on',...           % Nur innerhalb axes sichtbar
      'userdata',mat,...            % Matrix -> userdata
      'buttondownfcn','paralle(''kaskade'');',... % Ausfuerung bei Mausklick
      'position',[waagerecht 0]);   % Ausrichtung im Raster
    if n>9
	diff=2.2;
    else
	diff=1.6;
    end;
    h_unter= text('string','\_',...% Unterstrich
      'tag','h(z)',...              % Bezeichnung = h(z)
      'horizontalalignment','center',... % Ausrichtung zentriert
      'color',[0 0 0],...           % Zeichenfarbe = Schwarz
      'clipping','on',...           % Nur innerhalb axes sichtbar
      'userdata',mat,...         % Matrix -> userdata
      'buttondownfcn','paralle(''kaskade'');',... % Ausfuerung bei Mausklick
      'position',[waagerecht-diff -0.1]);   % Ausrichtung im Raster

    if n >= 1
      % ----------------- Zeichne Addierer ----------------------------------
      x = [cos([0:10:360]*(pi/180)) -1];% Kreis und waagerechter Strich
      y = [sin([0:10:360]*(pi/180)) 0];
      x = [x cos([190:10:270]*(pi/180)) 0] + waagerecht;% Halbkreis + senkrechter Strich
      y = [y sin([190:10:270]*(pi/180)) 1] - faktor;
      h_line = plot(x,y,'-k');
    end

    % --------------- Verbindungslinien -------------------------------------
    x = [(waagerecht-faktor) waagerecht waagerecht,...
          waagerecht-0.5 waagerecht waagerecht+0.5];
    y = [faktor faktor 1.5 2.5 1.5 2.5];     % y-Koordinaten fuer Linie
    h_line=plot(x,y,'-k');          % Zeichne Linie durchgezogen schwarz

    if n == 0
      h_text= text('string','X(z)',...% Text X(z)
        'color',[0 0 0],...
        'clipping','on',...
        'tag','(z)',...
        'position',[-faktor-5 faktor]);  % Links aussen
      h_text= text('string','\_',...% Text X(z)
        'color',[0 0 0],...
        'clipping','on',...
        'tag','(z)',...
        'horizontalalignment','left',...
        'position',[-faktor-5 faktor-0.2]);  % Links aussen
      x = [0 0 faktor-1 faktor-2 faktor-1 faktor-2];  % Einzelne Verbindungslinie
      y = [-1.5 -faktor -faktor -faktor-0.5 -faktor -faktor+0.5];
      plot(x,y,'-k');

    end                               % Ende von n == 0

    if n >= 1
      x = [waagerecht waagerecht waagerecht+0.5,...
           waagerecht waagerecht-0.5];  % Einzelne Verbindungslinie
      y = [-1.5 -faktor+1 -faktor+2 -faktor+1 -faktor+2];
      plot(x,y,'-k');
    end                               % Ende von n >= 1

    if (n >= 1)&(n < ordnung - 1)
      x = [waagerecht+1 faktor+waagerecht-1 faktor+waagerecht-2,...
           faktor+waagerecht-1 faktor+waagerecht-2];  % Einzelne Verbindungslinie
      y = [-faktor -faktor -faktor-0.5 -faktor -faktor+0.5];
      plot(x,y,'-k');
    end                               % Ende von n >= 1 und n < ordnung - 1
  end                                 % Ende von for n = 0:ordnung-1

  order = 0;                          % Indexhoechstes c(n) ungleich 0
  old_waagerecht = (ordnung-1)*faktor+1;% Position des letzten Addierers
  % ------------ Zeichne Restfunktion ---------------------------------------
  if any(c)                           % Wenn einer der c-Koeffizienten ungleich Null
    index = find(abs(c)>0);           % Finde c-Koeffizienten > 0
    order = max(index);               % Anzahl der Verzoegerungsglieder
    for n = ordnung:(ordnung+order-1)
      waagerecht = n * faktor;
      % ------------ zeichne Verzoegerungsglied -------------------------------
      x1 = -2;                        % waagerechte Koordinaten
      x2 = 2;                         % fuer alle n gleich
      y1 = 1.5;                       % senkrechte Koordinaten
      y2 = -1.5;                      % im senkrechten Raster
      x = [x1 x2 x2 x1 x1];           % Zusammenfassung fuer Rechteck x
      y = [y1 y1 y2 y2 y1];           % Zusammenfassung fuer Rechteck y
      y = y + faktor;
      x = x + waagerecht - (faktor/2);
      h_verz = plot(x,y,'-k');        % Zeichne Rechteck
      set(h_verz,...
        'tag','verzoegerung');        % Setze tag = verzoegerung
      string = 'z^{-1}';                % String fuer Verzoegerungsglied
      text('string',string,...        % Generiere Textobjekt innerhalb
        'tag','verzoegerung',...      % des Rechteckes
        'clipping','on',...           % Text nur innerhalb axes sichtbar
        'horizontalalignment','center',...% waagerechte Ausrichtung
        'color',[0 0 0],...           % ist mittig, Farbe = Schwarz
        'position',[waagerecht-(faktor/2) faktor]);% [x y] Koordinaten

      % ----------------- Zeichne Verbindungslinien ------------------------- 
      if (n >= ordnung)&(n < ordnung+order-1)
        x = [waagerecht+2 waagerecht+faktor-2 waagerecht+faktor-3,...
           waagerecht+faktor-2 waagerecht+faktor-3];  % Einzelne Verbindungslinie
        x = x - faktor/2;
        y = [faktor faktor faktor-0.5 faktor faktor+0.5];
        plot(x,y,'-k');
      end                             % Ende von n>=ordnung & n < ordnung+order-2

      if (n == ordnung)
        x = [waagerecht waagerecht+faktor/2-2 waagerecht+faktor/2-3,...
           waagerecht+faktor/2-2 waagerecht+faktor/2-3];  % Einzelne Verbindungslinie
        x = x - faktor;
        y = [faktor faktor faktor-0.5 faktor faktor+0.5];
        plot(x,y,'-k');
      end                             % Ende von n=ordnung

      if (n == ordnung+order-1)
        x = [waagerecht+2 waagerecht+faktor/2];  % Einzelne Verbindungslinie
        x = x -faktor/2;
        y = [faktor faktor];
        plot(x,y,'-k');

        x = [waagerecht+1 waagerecht+faktor waagerecht+faktor-1,...
           waagerecht+faktor waagerecht+faktor-1];  % Einzelne Verbindungslinie
        y = [-faktor -faktor -faktor-0.5 -faktor -faktor+0.5];
        plot(x,y,'-k');
      end                             % Ende von n=ordnung+order-1

      index = n-ordnung+1;
      if abs(c(index))>0
        % ----------------- Zeichne Addierer --------------------------------
        x = [cos([0:10:360]*(pi/180)) -1];% Kreis und waagerechter Strich
        y = [sin([0:10:360]*(pi/180)) 0];
        x = [x cos([190:10:270]*(pi/180)) 0] + waagerecht;% Halbkreis + senkrechter Strich
        y = [y sin([190:10:270]*(pi/180)) 1] - faktor;
        h_line = plot(x,y,'-k');

        % --------------- Zeichne Multiplizierer c(index) -------------------
        x = [cos([0:5:360]*(pi/180)) cos([5:5:45]*(pi/180)) cos(225*pi/180)];
        y = [sin([0:5:360]*(pi/180)) sin([5:5:45]*(pi/180)) sin(225*pi/180)];
        x = [x cos([230:5:315]*(pi/180)) cos(135*pi/180)] + waagerecht;
        y = [y sin([230:5:315]*(pi/180)) sin(135*pi/180)];
        h_line = plot(x,y,'-k');
        set(h_line,'tag','multiplizierer_c'); % Siehe kano1
        string = ['c(' num2str(index) ')'];
        h_text= text('string',string,...
          'tag','multiplizierer_c',...
          'erasemode','normal',...
          'clipping','on',...
          'color',[0 0 0],...
          'position',[(1.5+waagerecht) -1.5]);

        % ----------------- Zeichne Verbindungslinien ----------------------- 
        x = [waagerecht waagerecht waagerecht-0.5,...
           waagerecht waagerecht+0.5];  % Einzelne Verbindungslinie
        y = [faktor 1 2 1 2];
        plot(x,y,'-k');

        x = [waagerecht waagerecht waagerecht-0.5,...
           waagerecht waagerecht+0.5];  % Einzelne Verbindungslinie
        y = [-1 -faktor+1 -faktor+2 -faktor+1 -faktor+2];
        plot(x,y,'-k');

        x = [old_waagerecht waagerecht-1 waagerecht-2,...
           waagerecht-1 waagerecht-2];  % Einzelne Verbindungslinie
        y = [-faktor -faktor -faktor+0.5 -faktor -faktor-0.5];
        plot(x,y,'-k');
        old_waagerecht = waagerecht+1;% Possition des aktuellen Addierers
      end                             % Ende von abs(c(index)>0)
    end                               % Ende von n = ordnung:ordnung+order
  end                                 % Ende von any(c)
  h_text= text('string','Y(z)',...    % Text Y(z)
        'color',[0 0 0],...
        'clipping','on',...           % Rechts aussen
        'tag','(z)',...
        'position',[((ordnung+order)*faktor) -faktor]);
 h_text= text('string','\_',...    % Text Y(z)
        'color',[0 0 0],...
        'clipping','on',...           % Rechts aussen
        'tag','(z)',...
        'horizontalalignment','left',...
        'position',[((ordnung+order)*faktor) -faktor-0.2]);

end                                   % Ende command_str = 'parallel'

%-------   Hges(z)-----------------
if strcmp(command_str,'Hges(z)')		% Überschrift erzeugen für Kaskaden- oder Parallelform
	axes ('position',[0.21 0.81 0.1 0.8],...	% Axes-Objekt für Überschrift
		'tag','axes_h(z)',...
		'visible','off',...
		'buttondownfcn','netzwerk(''quant'');');	% Aufruf der tabellarischen Koeffizientenausgabe
	h_text=text(2.5,0.1,'H       (z) =');			% Textobjekte für Überschriftsgleichung
	set (h_text,'color','k','horizontalalignment','left',...
		'tag','axes_h(z)',...
		'buttondownfcn','netzwerk(''quant'');');	% Aufruf der tabellarischen Koeffizientenausgabe
	h_text=text(2.5,0.095,'\_');
	set (h_text,'color','k','horizontalalignment','left',...
		'tag','axes_h(z)',...
		'buttondownfcn','netzwerk(''quant'');');	% Aufruf der tabellarischen Koeffizientenausgabe
	h_text=text(2.65,0.09,'ges');
	set (h_text,'color','k','horizontalalignment','left',...
		'tag','axes_h(z)',...
		'buttondownfcn','netzwerk(''quant'');');	% Aufruf der tabellarischen Koeffizientenausgabe
	h_text=text(3.45,0.13,'Y (z)');
	set (h_text,'color','k','horizontalalignment','left',...
		'tag','axes_h(z)',...
		'buttondownfcn','netzwerk(''quant'');');	% Aufruf der tabellarischen Koeffizientenausgabe
	h_text=text(3.45,0.125,'\_');
	set (h_text,'color','k','horizontalalignment','left',...
		'tag','axes_h(z)',...
		'buttondownfcn','netzwerk(''quant'');');	% Aufruf der tabellarischen Koeffizientenausgabe
	h_text=text(3.45,0.115,'\_\_\_\_');
	set (h_text,'color','k','horizontalalignment','left',...
		'tag','axes_h(z)',...
		'buttondownfcn','netzwerk(''quant'');');	% Aufruf der tabellarischen Koeffizientenausgabe
	h_text=text(3.45,0.07,'X (z)');
	set (h_text,'color','k','horizontalalignment','left',...
		'tag','axes_h(z)',...
		'buttondownfcn','netzwerk(''quant'');');	% Aufruf der tabellarischen Koeffizientenausgabe
	h_text=text(3.45,0.065,'\_');
	set (h_text,'color','k','horizontalalignment','left',...
		'tag','axes_h(z)',...
		'buttondownfcn','netzwerk(''quant'');');	% Aufruf der tabellarischen Koeffizientenausgabe

end;	% Ende command_str= 'Hges(z)'

%------ senkrechter slider betaetigt ----------------------------------------
if strcmp(command_str,'Moved_x')
        h_axe = findobj('tag','axes');       % Suche axes-Objekt
        h_slider = findobj('tag','slider');  % Ermittle handle des sliders
        h_objekt = findobj('parent',h_axe);    % children des axes-Objektes
        set(h_objekt,'erasemode','xor',...   % Modus = xor
                     'visible','off');       % unsichtbar
        old_value = get(h_slider,'userdata');% alte Sliderposition
        new_value = get(h_slider,'value');   % neue Sliderposition
        set(h_slider,'userdata',new_value);  % neue Sliderposition speichern
        differenz = new_value - old_value;   % Differenz ermitteln
        x_lim_old = get(h_axe,'xlim');       % Alte x-Grenzwerte aus xlim
        x_lim_new = x_lim_old + 10*differenz;% Neue x-Grenzwerte berechnen
        set(h_axe,'xlim',x_lim_new);         % Neue Grenzwerte in axes
        set(h_objekt,'erasemode','normal',...% Modus = normal
                     'visible','on');        % sichtbar machen
end

%------- waagerechter slider betaetigt --------------------------------------
if strcmp(command_str,'Moved_y')
        h_axe = findobj('tag','axes');
        h_slidery = findobj('tag','slidery');
        h_objekt = findobj('parent',h_axe);
        set(h_objekt,'erasemode','xor','visible','off');
        old_value = get(h_slidery,'userdata');
        new_value = get(h_slidery,'value');
        set(h_slidery,'userdata',new_value);
        differenz = new_value - old_value;
        y_lim_old = get(h_axe,'ylim');
        y_lim_new = y_lim_old + 10*differenz;
        set(h_axe,'ylim',y_lim_new);
        set(h_objekt,'erasemode','normal','visible','on');
end

%-------------- quantisierte Koeffizientenangabe -----------------------------------------------
if strcmp(command_str,'quant')
pause(0.01);
h_exist=findobj('tag','quant_ueber');		% Tabellenüberschrift suchen
 if isempty(h_exist)                              % Tabelle existiert noch nicht
    h_struktur = findobj ('tag','axes');   %axes-Objekt des Netzwerks
    h_children = findobj('parent',h_struktur);  % handles der Netzwerkkomponenten
    set(h_children,'visible','off');   % Netzwerkkomponenten unsichtbar setzen
    h_axes_h = findobj ('tag','axes_h(z)');   %Objekte der Überschriftsgleichung
    set(h_axes_h,'visible','off');		% Überschrift-Objekte unsichtbar setzen
    slider_wert=[0 0];     % Anzeigefeld, welcher Slider benutzt
    h_slider= findobj('tag','slider'); % waagerechten Slider finden
    if (strcmp(get(h_slider,'enable'),'on')) % Enable-Wert merken
        slider_wert (1) =1;
    end;
    set(h_slider,'enable','off','visible','off');  % Slider unsichtbar und unbedienbar
    h_slidery= findobj('tag','slidery');   % senkrechten Slider finden
    if (strcmp(get(h_slidery,'enable'),'on')) % Enable-Wert merken
        slider_wert (2) =1;
    end 
    set(h_slidery,'enable','off','visible','off');  % Slider unsichtbar und unbedienbar
    h_off=findobj('tag','struktur');   % Popup-Menü Struktur
    set (h_off,'enable','off');        % unbedienbar setzen
     h_off=findobj('tag','antwort');    % Pushbutton Amplitude/Phase
     set (h_off,'enable','off');        % unbedienbar setzen
     h_off=findobj('tag','FFT');        % Popup-Menü FFT-Länge
     set (h_off,'enable','off');        % unbedienbar setzen
     h_off=findobj('tag','ende');       % Pushbutton Ende
     set (h_off,'enable','off');        % unbedienbar setzen
     h_off=findobj('tag','tauschen');       % Pushbutton Tauschen
     set (h_off,'enable','off');        % unbedienbar setzen
     h_off=findobj('tag','rueckgaengig');       % Pushbutton Rückgängig
     set (h_off,'enable','off');        % unbedienbar setzen
     h_off=findobj('tag','filterung');  % Pushbutton Filterung
     set (h_off,'enable','off');        % unbedienbar setzen
     h_off=findobj('tag','generator_mat');% Pushbutton Funktionsgenerator
     set (h_off,'enable','off');        % unbedienbar setzen
     h_off=findobj('tag','p_n_dia');      % Pushbutton PN-Diagramm
     set (h_off,'enable','off');        % unbedienbar setzen
     h_off=findobj('tag','filterbank');      % Pushbutton Filtersysteme
     set (h_off,'enable','off');        % unbedienbar setzen
     h_off=findobj('tag','hilfe');      % Pushbutton Hilfe
     set (h_off,'callback','!winhelp struktur\tabelle');        % aktualisierte Hilfe
     h_ueber=findobj('tag','quant_uebernehmen');	% Pushbutton Übernehmen
     set (h_ueber,'callback','netzwerk(''quant'');');	% neuer Callback: Tabelle aktualisieren 
     h_skalierung = findobj('tag','Skalierung');		% Handle Checkbox opt. Skalierung
     set(h_skalierung,'callback','netzwerk(''quant'');');   	% neuer Callback: Tabelle aktualisieren
     h_quit= findobj('tag','quit');			% Pushbutton quit
     set(h_quit,'callback','netzwerk(''close'');',...
            'userdata',slider_wert,...
            'enable','on');
 end; % of not exist
pause(0.01);
 h_axes_exist=findobj('tag','axes_quant');	% Handle auf möglicherweise vorhandene Tabelle 
 delete (h_axes_exist);			% Tabelle löschen
 h_slider_exist= findobj('tag','quant','style','slider');	% Slider finden
 slider_exist_pos=[];
  if ~isempty(h_slider_exist)             % Wenn Slider existiert
	slider_exist_pos= get (h_slider_exist,'userdata');	% alten Value ermitteln
	delete (h_slider_exist);				% Slider löschen
  end;
    screensize = get(0,'screensize');   % Bildschirmauflösung ermitteln
    width= screensize(3);   % Breite des Bildschirms
    height= screensize(4);  % Höhe des Bildschirms
    x_lim=[0 100];      % waagerechte Grenzwerte
    y_lim=x_lim .*(height/width);  % Senkrechte Grenzwerte
    h_tabelle = axes ('position',[0.2 0.1 0.8 0.8],...  % Axes-Objekt für Tabelle
        'ylim',y_lim,...            % der quantisierten Koeffizienten
        'xlim',x_lim,...
        'visible','off',...
        'tag','axes_quant',...
        'drawmode','fast',...
        'color',[1 1 1],...
        'nextplot','add');
   if isempty(slider_exist_pos)            % Wenn kein alter Slider-Value
	slider_exist_pos=0;	% auf Null setzen
   else
	command_str='tabelle_move'; % sonst neue Tabelle anpassen
   end;
    uicontrol (gcf,'style','slider',...
        'callback','netzwerk(''tabelle_move'');',...
        'tag','quant',...
        'units','normalized',...
        'visible','on',...
        'value',slider_exist_pos,...
        'userdata',0,...
        'min',-10,'max',0,...
        'position',[0.975 0 0.025 1]);

pause(0.01);
    
    h_matrix= findobj('tag','antwort'); % Handle auf Pushbutton mit Matrix suchen
    Matrix= get(h_matrix,'userdata');   % Matrix ermitteln
% ---------- Direktform, 1. oder 2. kanonische Form -------------
    if (Matrix(1,1)==1 | Matrix(1,1)==2 | Matrix(1,1)==3)   % eine der Direktstrukturen
        bhilf=Matrix(2:size(Matrix,1),1);   % b-Koeffizienten
        ahilf=Matrix(2:size(Matrix,1),2);   % a-Koeffizienten
        Ueberschrift= ['Koeffizienten des ' filter_type '-Filters ' num2str(ordnung-1)  '. Ordnung'];
        if (Matrix(1,1) ==1)
            Ueberschrift=[Ueberschrift ' in Direktform'];
        end;
        if (Matrix(1,1) ==2)
            Ueberschrift=[Ueberschrift ' in 1. kanonischer Form'];
        end;
        if (Matrix(1,1) ==3)
            Ueberschrift=[Ueberschrift ' in 2. kanonischer Form'];
        end;
h_ueber= text ('string',Ueberschrift,...         % Überschrift ausgeben
        'tag','quant_ueber',...
        'clipping','on',...
        'color',[0 0 0],...
        'horizontalalignment','center',...
        'FontSize',10,...
        'position',[53 y_lim(2)-5]);
     for i=1:ordnung                % Für jeden einzelnen Koeffizienten
        if length(bhilf)>=i
	if (i<11)			% Ausrichtung der Indizes
		leer_str='  ';
	else
		leer_str=' ';
	end;
	if (bhilf(i)<0)		% Ausrichtung der Vorzeichen
		vorzeichen_str=' ';
	else
		vorzeichen_str='  ';
	end;

            b_Zeile=['b' num2str(i-1) leer_str  '= '  vorzeichen_str num2str(bhilf(i))];
            text ('string',b_Zeile,...  % b-Koeffizient ausgeben
                'tag','quant',...
                'clipping','on',...
	'FontSize',10,...
                'color',[0 0 0],...
                'position',[35 y_lim(2)-10-3*i]);
        end;
        if (strcmp(filter_type,'IIR') & length(ahilf)>=i)
	if (i<11)			% Ausrichtung der Indizes
		leer_str='  ';
	else
		leer_str=' ';
	end;
	if (ahilf(i)<0)		% Ausrichtung der Vorzeichen
		vorzeichen_str=' ';
	else
		vorzeichen_str='  ';
	end;
            a_Zeile=['a' num2str(i-1) leer_str  '= ' vorzeichen_str num2str(ahilf(i))];
            text ('string',a_Zeile,...  % a-Koeffizient ausgeben
	'tag','quant',...
	'clipping','on',...
	'FontSize',10,...
	'color',[0 0 0],...
	'position',[60 y_lim(2)-10-3*i]);
            end;
     end; % of for-Schleife
    set (h_ueber,'userdata',y_lim(2)-10-3*i);	% unterste Position merken
    end; % eine der Direktstrukturen
% ------------- Lattice-Ladder-Struktur ---------------
    if (Matrix(1,1) ==6)        % Lattice-Ladder-Struktur
        khilf=Matrix(2:size(Matrix,1)-1,1); % k-Koeffizienten
        chilf=Matrix(2:size(Matrix,1),2);   % c-Koeffizienten
        Ueberschrift= ['Koeffizienten des ' filter_type '-Filters ' num2str(ordnung-1)  '. Ordnung'];
        Ueberschrift=[Ueberschrift ' in Lattice-Ladder-Struktur'];
        h_ueber= text ('string',Ueberschrift,...         % Überschrift ausgeben
            'tag','quant_ueber',...
            'clipping','on',...
            'color',[0 0 0],...
            'horizontalalignment','center',...
            'FontSize',10,...
            'position',[50 y_lim(2)-5]);
        for i=1:length(chilf)              % Für jeden einzelnen Koeffizienten
        if length(khilf)>=i
	if (i<11)			% Ausrichtung der Indizes
		leer_str='  ';
	else
		leer_str=' ';
	end;
	if (khilf(i)<0)		% Ausrichtung der Vorzeichen
		vorzeichen_str=' ';
	else
		vorzeichen_str='  ';
	end
            k_Zeile=['k' num2str(i-1) leer_str '= ' vorzeichen_str num2str(khilf(i))];
            text ('string',k_Zeile,...  % k-Koeffizient ausgeben
                'tag','quant',...
                'clipping','on',...
                'color',[0 0 0],...
	'FontSize',10,...
                'position',[30 y_lim(2)-10-3*i]);
        end;
        if length(chilf)>=i
	if (i<11)			% Ausrichtung der Indizes
		leer_str='  ';
	else
		leer_str=' ';
	end;
	if (chilf(i)<0)		% Ausrichtung der Vorzeichen
		vorzeichen_str=' ';
	else
		vorzeichen_str='  ';
	end
            c_Zeile=['c' num2str(i-1) leer_str '= ' vorzeichen_str num2str(chilf(i))];
            text ('string',c_Zeile,...  % c-Koeffizient ausgeben
                'tag','quant',...
                'clipping','on',...
                'color',[0 0 0],...
	'FontSize',10,...
                'position',[60 y_lim(2)-10-3*i]);
        end;
     end; % of for-Schleife
    set (h_ueber,'userdata',y_lim(2)-10-3*i);	% letzte Position merken
    end; % Lattice-Ladder-Struktur
% ------------ Kaskade -----------------------------
if (Matrix(1,1)==4)		% Kaskadenstruktur
  sos_Matrix= Matrix(2:size(Matrix,1),:);	% sos-Matrix extrahieren
        Ueberschrift= ['Koeffizienten des ' filter_type '-Filters ' num2str(ordnung-1)  '. Ordnung'];
        Ueberschrift=[Ueberschrift ' in Kaskaden-Struktur'];
        h_ueber= text ('string',Ueberschrift,...         % Überschrift ausgeben
            'tag','quant_ueber',...
            'clipping','on',...
            'color',[0 0 0],...
            'horizontalalignment','center',...
            'FontSize',10,...
            'position',[50 y_lim(2)-5]);
 for i=0:size(sos_Matrix,1)-1                      % alle Teilsysteme suchen und Reihenfolge feststellen
	    suchtext=['H' num2str(i) '(z)'];
	    h_teilsyst= findobj ('string',suchtext);    % Teilsystem mit dem entsprechenden
        	                                        		% String ermitteln
	    kennung = get(h_teilsyst,'userdata');
	    sort_folge(kennung(1,1)+1)= i;  % Position aus UserData ermitteln
  end;
   for Teilsystem=1:size(sos_Matrix,1)	% Jede Zeile der sos-Matrix
	bhilf= sos_Matrix(Teilsystem,1:3);	% b-Koeffizienten des Teilsystems
	ahilf= sos_Matrix(Teilsystem,4:6);	% a-Koeffizienten des Teilsystems
 Teil_str=['H' num2str(sort_folge(Teilsystem)) '(z):'];
 text ('string',Teil_str,...  % Teilsystembezeichnung Hn(z)
                'tag','quant',...
                'clipping','on',...
	'FontSize',10,...
                'color',[0 0 0],...
                'position',[25 y_lim(2)-10-3*2-(Teilsystem-1)*12]);
text ('string','\_',...  % Unterstrich
                'tag','quant',...
                'clipping','on',...
	'FontSize',10,...
                'color',[0 0 0],...
                'position',[25.2 y_lim(2)-10-3*2-(Teilsystem-1)*12]);

     for i=1:3	                % Für jeden einzelnen Koeffizienten des Teilsysrems
        if length(bhilf)>=i
	if (i<11)			% Ausrichtung der Indizes
		leer_str='  ';
	else
		leer_str=' ';
	end;
	if (bhilf(i)<0)		% Ausrichtung der Vorzeichen
		vorzeichen_str=' ';
	else
		vorzeichen_str='  ';
	end;
            b_Zeile=['b' num2str(i-1) leer_str  '= '  vorzeichen_str num2str(bhilf(i))];
            text ('string',b_Zeile,...  % b-Koeffizient ausgeben
                'tag','quant',...
                'clipping','on',...
	'FontSize',10,...
                'color',[0 0 0],...
                'position',[35 y_lim(2)-10-3*i-(Teilsystem-1)*12]);
        end;
        if (strcmp(filter_type,'IIR') & length(ahilf)>=i)
	if (i<11)			% Ausrichtung der Indizes
		leer_str='  ';
	else
		leer_str=' ';
	end;
	if (ahilf(i)<0)		% Ausrichtung der Vorzeichen
		vorzeichen_str=' ';
	else
		vorzeichen_str='  ';
	end;
            a_Zeile=['a' num2str(i-1) leer_str  '= ' vorzeichen_str num2str(ahilf(i))];
            text ('string',a_Zeile,...  % a-Koeffizient ausgeben
	'tag','quant',...
	'clipping','on',...
	'FontSize',10,...
	'color',[0 0 0],...
	'position',[60 y_lim(2)-10-3*i-(Teilsystem-1)*12]);
            end;
     end; % of for-Schleife
  end; % jede Zeile sos-Matrix
 set(h_ueber,'userdata',y_lim(2)-10-3*i-(Teilsystem-1)*12);	% letzte Position merken
end; % Kaskadenstruktur

% ------------ Kaskade normiert -----------------------------
if (Matrix(1,1)==5)		% normierte Kaskadenstruktur
  sos_Matrix= Matrix(2:size(Matrix,1),2:7);	% sos-Matrix extrahieren
  norm_koeff= Matrix(2:size(Matrix,1),1);	% Normierungs-Koeffizienten extrahieren
        Ueberschrift= ['Koeffizienten des ' filter_type '-Filters ' num2str(ordnung-1)  '. Ordnung'];
        Ueberschrift=[Ueberschrift ' in normierter Kaskaden-Struktur'];
        h_ueber=text ('string',Ueberschrift,...         % Überschrift ausgeben
            'tag','quant_ueber',...
            'clipping','on',...
            'color',[0 0 0],...
            'horizontalalignment','center',...
            'FontSize',10,...
            'position',[50 y_lim(2)-5]);
  for i=0:size(sos_Matrix,1)-1                      % alle Teilsysteme suchen und Reihenfolge feststellen
	    suchtext=['H' num2str(i) '(z)'];
	    h_teilsyst= findobj ('string',suchtext);    % Teilsystem mit dem entsprechenden
        	                                        		% String ermitteln
	    kennung = get(h_teilsyst,'userdata');
	    sort_folge(kennung(1,1)+1)= i;  % Position aus UserData ermitteln
  end;
   for Teilsystem=1:size(sos_Matrix,1)	% Jede Zeile der sos-Matrix
	bhilf= sos_Matrix(Teilsystem,1:3);	% b-Koeffizienten des Teilsystems
	ahilf= sos_Matrix(Teilsystem,4:6);	% a-Koeffizienten des Teilsystems
 Teil_str=['H' num2str(sort_folge(Teilsystem)) '(z):'];
 text ('string',Teil_str,...  % Teilsystembezeichnung Hn(z)
                'tag','quant',...
                'clipping','on',...
	'FontSize',10,...
                'color',[0 0 0],...
                'position',[25 y_lim(2)-10-3*2-(Teilsystem-1)*15]);
text ('string','\_',...  % Unterstrich
                'tag','quant',...
                'clipping','on',...
	'FontSize',10,...
                'color',[0 0 0],...
                'position',[25.2 y_lim(2)-10-3*2-(Teilsystem-1)*15]);
 
k_Zeile=['k    =  ' num2str(norm_koeff(Teilsystem))];
            text ('string',k_Zeile,...  % Norm-Koeffizient ausgeben
                'tag','quant',...
                'clipping','on',...
	'FontSize',10,...
                'color',[0 0 0],...
                'position',[35 y_lim(2)-13-(Teilsystem-1)*15]);

     for i=1:3	                % Für jeden einzelnen Koeffizienten des Teilsysrems
        if length(bhilf)>=i
	if (i<11)			% Ausrichtung der Indizes
		leer_str='  ';
	else
		leer_str=' ';
	end;
	if (bhilf(i)<0)		% Ausrichtung der Vorzeichen
		vorzeichen_str=' ';
	else
		vorzeichen_str='  ';
	end;
            b_Zeile=['b' num2str(i-1) leer_str  '= '  vorzeichen_str num2str(bhilf(i))];
            text ('string',b_Zeile,...  % b-Koeffizient ausgeben
                'tag','quant',...
                'clipping','on',...
	'FontSize',10,...
                'color',[0 0 0],...
                'position',[35 y_lim(2)-13-3*i-(Teilsystem-1)*15]);
        end;
        if (strcmp(filter_type,'IIR') & length(ahilf)>=i)
	if (i<11)			% Ausrichtung der Indizes
		leer_str='  ';
	else
		leer_str=' ';
	end;
	if (ahilf(i)<0)		% Ausrichtung der Vorzeichen
		vorzeichen_str=' ';
	else
		vorzeichen_str='  ';
	end;
            a_Zeile=['a' num2str(i-1) leer_str  '= ' vorzeichen_str num2str(ahilf(i))];
            text ('string',a_Zeile,...  % a-Koeffizient ausgeben
	'tag','quant',...
	'clipping','on',...
	'FontSize',10,...
	'color',[0 0 0],...
	'position',[60 y_lim(2)-13-3*i-(Teilsystem-1)*15]);
            end;
     end; % of for-Schleife
  end; % jede Zeile sos-Matrix
  set (h_ueber,'userdata',y_lim(2)-13-3*i-(Teilsystem-1)*15);	% letzte Position merken
end; % normierte Kaskadenstruktur
% ------------ Parallelstruktur -----------------------------
if (Matrix(1,1)==7)		% Parallelstruktur
  sos_Matrix= Matrix(2:size(Matrix,1),2:7);	% sos-Matrix extrahieren
        Ueberschrift= ['Koeffizienten des ' filter_type '-Filters ' num2str(ordnung-1)  '. Ordnung'];
        Ueberschrift=[Ueberschrift ' in Parallelform'];
        h_ueber=text ('string',Ueberschrift,...         % Überschrift ausgeben
            'tag','quant_ueber',...
            'clipping','on',...
            'color',[0 0 0],...
            'horizontalalignment','center',...
            'FontSize',10,...
            'position',[50 y_lim(2)-5]);
 
   for Teilsystem=1:size(sos_Matrix,1)	% Jede Zeile der sos-Matrix
	bhilf= sos_Matrix(Teilsystem,1:3);	% b-Koeffizienten des Teilsystems
	ahilf= sos_Matrix(Teilsystem,4:6);	% a-Koeffizienten des Teilsystems
 Teil_str=['H' num2str(Teilsystem-1) '(z):'];
 text ('string',Teil_str,...  % Teilsystembezeichnung Hn(z)
                'tag','quant',...
                'clipping','on',...
	'FontSize',10,...
                'color',[0 0 0],...
                'position',[25 y_lim(2)-10-3*2-(Teilsystem-1)*12]);
text ('string','\_',...  % Unterstrich
                'tag','quant',...
                'clipping','on',...
	'FontSize',10,...
                'color',[0 0 0],...
                'position',[25.2 y_lim(2)-10-3*2-(Teilsystem-1)*12]);

     for i=1:3	                % Für jeden einzelnen Koeffizienten des Teilsysrems
        if length(bhilf)>=i
	if (i<11)			% Ausrichtung der Indizes
		leer_str='  ';
	else
		leer_str=' ';
	end;
	if (bhilf(i)<0)		% Ausrichtung der Vorzeichen
		vorzeichen_str=' ';
	else
		vorzeichen_str='  ';
	end;
            b_Zeile=['b' num2str(i-1) leer_str  '= '  vorzeichen_str num2str(bhilf(i))];
            text ('string',b_Zeile,...  % b-Koeffizient ausgeben
                'tag','quant',...
                'clipping','on',...
	'FontSize',10,...
                'color',[0 0 0],...
                'position',[35 y_lim(2)-10-3*i-(Teilsystem-1)*12]);
        end;
        if (strcmp(filter_type,'IIR') & length(ahilf)>=i)
	if (i<11)			% Ausrichtung der Indizes
		leer_str='  ';
	else
		leer_str=' ';
	end;
	if (ahilf(i)<0)		% Ausrichtung der Vorzeichen
		vorzeichen_str=' ';
	else
		vorzeichen_str='  ';
	end;
            a_Zeile=['a' num2str(i-1) leer_str  '= ' vorzeichen_str num2str(ahilf(i))];
            text ('string',a_Zeile,...  % a-Koeffizient ausgeben
	'tag','quant',...
	'clipping','on',...
	'FontSize',10,...
	'color',[0 0 0],...
	'position',[60 y_lim(2)-10-3*i-(Teilsystem-1)*12]);
            end;
     end; % of for-Schleife
  end; % jede Zeile sos-Matrix

text ('string','Direktterme:',...  % Direkterme folgen
                'tag','quant',...
                'clipping','on',...
	'FontSize',10,...
                'color',[0 0 0],...
                'position',[24 y_lim(2)-8-6*3-(Teilsystem-1)*12]);

   c_koeff= Matrix(2:size(Matrix,1),1);	% Direktterme
   unterste=y_lim(2)-10-6*3-(Teilsystem-1)*12;
          
   for i=1:size(c_koeff,1)		% jeden Direktterm
	if c_koeff(i) ~=0
		unterste=y_lim(2)-10-6*3-(Teilsystem-1)*12-i*3;
	            	c_Zeile=['c' num2str(i-1)  ' = '  num2str(c_koeff(i))];
	            	text ('string',c_Zeile,...  % Direktterme ausgeben
			'tag','quant',...
			'clipping','on',...
			'FontSize',10,...
			'color',[0 0 0],...
			'position',[35 unterste]);
	end;
   end;
 set (h_ueber,'userdata',unterste);		% letzte gültige Position merken
end; % Parallelstruktur
h_slider=findobj('tag','quant','style','slider');
h_ueber= findobj('tag','quant_ueber');	% Handle auf Tabellenüberschrift
unterste= get(h_ueber,'userdata');		% Position der letzten Zeile
if unterste>0
	set (h_slider,'enable','off');		% Slider nicht nötig, da gesamte Tabelle darstellbar
else
	set (h_slider,'enable','on');		% Slider bedienbar setzen
end;

end                                   % Ende von quant



%-------------tabelle-move--------------------------------------------------
if strcmp(command_str,'tabelle_move')	% Wenn innerhalb der Tabelle Slider betätigt
   h_axes_quant= findobj('tag','axes_quant');	% Handle auf Axes-Objekt
	h_slider= findobj('tag','quant','style','slider');	% Handle auf Slider finden
   h_objects= findobj('parent',h_axes_quant);
  	set(h_objects,'visible','off');
   old_value= get(h_slider,'userdata');		% alte Position
   new_value= get(h_slider,'value');		% neue Position
   set(h_slider,'userdata',new_value);		% neue Position merken
   Differenz=(old_value - new_value);		% Differenz der Sliderpositionen
   y_lim_old= get(h_axes_quant,'ylim');	% y-Begrenzung der Tabelle
   h_ueber= findobj('tag','quant_ueber');	% Handle auf Tabellenüberschrift
   unterste= get(h_ueber,'userdata');		% Position der letzten Zeile
   y_lim_new= y_lim_old - (Differenz * ((-unterste+10)/10)); % neue Begrenzung berechnen
   set(h_axes_quant,'ylim',y_lim_new);	% und setzen
	set(h_objects,'visible','on');
end;


%-------------- close ----- der Koeffizientenanzeige------------------------------------------
if strcmp(command_str,'close')        % Wenn command_str = close
h_pushbutton = findobj('tag','quit'); % Handle auf quit-Button finden
slider_wert= get(h_pushbutton,'userdata');  % alte Slider-Enable-Werte aus UserData
  h_quant = findobj('tag','quant','style','slider');   % Finde Slider in 'quant'
  delete(h_quant);                    % Loesche Slider
h_tabelle = findobj('tag','axes_quant'); % Handle des Tabellenobjekts
delete (h_tabelle);	% Tabelle löschen
h_struktur = findobj ('tag','axes');	%axes-Objekt des Netzwerks
 h_children = findobj('parent',h_struktur);  % handles der Netzwerkkomponenten
set(h_children,'visible','on');	% Netzwerkkomponenten sichtbar setzen
h_axes_h = findobj ('tag','axes_h(z)');   %Objekte der Überschriftsgleichung
set(h_axes_h,'visible','on');		% Überschrift-Objekte sichtbar setzen
h_ueber=findobj('tag','quant_uebernehmen');	% Pushbutton Übernehmen
set (h_ueber,'callback','netzwerk');	% neuer Callback: Netzwerk aktualisieren 
h_skalierung = findobj('tag','Skalierung');	% Handle Checkbox opt. Skalierung
set(h_skalierung,'callback','netzwerk');   	% neuer Callback: Netzwerk aktualisieren

h_quit= findobj('tag','quit');	% Pushbutton quit
set(h_quit,'callback','','enable','off');	% nicht bedienbar setzen, kein Callback
 h_on=findobj('tag','struktur');	% Popup-Menü Struktur
 set (h_on,'enable','on');		% bedienbar setzen
 h_on=findobj('tag','antwort');	% Pushbutton Amplitude/Phase
 set (h_on,'enable','on');		% bedienbar setzen
 h_on=findobj('tag','FFT');		% Popup-Menü FFT-Länge
 set (h_on,'enable','on');		% bedienbar setzen
 h_on=findobj('tag','ende');		% Pushbutton Ende
 set (h_on,'enable','on');		% bedienbar setzen
 h_on=findobj('tag','tauschen');         % Pushbutton Tauschen
 set (h_on,'enable','on');       	%bedienbar setzen
 h_on=findobj('tag','rueckgaengig');  % Pushbutton Rückgängig
set (h_on,'enable','on');		% unbedienbar setzen
 h_on=findobj('tag','filterung');	% Pushbutton Filterung
 set (h_on,'enable','on');		% bedienbar setzen
 h_on=findobj('tag','generator_mat');% Pushbutton Funktionsgenerator
 set (h_on,'enable','on');		% bedienbar setzen
 h_off=findobj('tag','p_n_dia');	% Pushbutton PN-Diagramm
 set (h_off,'enable','on');		% bedienbar setzen
 h_off=findobj('tag','filterbank');	% Pushbutton Filtersysteme
 set (h_off,'enable','on');		% bedienbar setzen
 h_on=findobj('tag','hilfe');		% Pushbutton Hilfe
 set (h_on,'callback','!winhelp struktur\struktur');	% Hilfe aktualisieren
if (slider_wert(1) ~= 0)
	h_slider= findobj('tag','slider');	% waagerechten Slider finden
	set(h_slider,'enable','on','visible','on');  % Slider unsichtbar und unbedienbar
end;
if (slider_wert(2) ~= 0)
	h_slidery= findobj('tag','slidery');	% senkrechten Slider finden
	set(h_slidery,'enable','on','visible','on');  % Slider unsichtbar und unbedienbar
end;
netzwerk;		% aktualisieren der Netzwerkstruktur
end                                   % Ende von close

