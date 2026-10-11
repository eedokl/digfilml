function kaskade(command_str)
% KASKADE
%
% Die Funktion stellt die innere Struktur eines Kaskadenblockes
% in zweiter kanonischer Form normiert oder nicht normiert dar
% Desweiteren besteht die Moeglichkeit zwei Kaskaden in ihrer Reihenfolge  
% zu tauschen.
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



%-------------- Kaskade -----------------------------------------------------
if strcmp(command_str,'kaskade')    % Wenn command_str = kaskade
  h_figure = findobj('tag','netzwerk'); % Finde Figur 'netzwerk'
  h_children = get(h_figure,'children');% Ermittle Nachkommen von 'netzwerk'
  ui_objekte= findobj(h_figure,'type','uicontrol','visible','on');	% alle UiControl-Objekte, die sichtbar sind
  set (ui_objekte,'visible','off'),		% unsichtbar setzen
  h_enable= findobj('tag','ende');	% Objekt zur Speicherung dieser Handle-Liste
  set (h_enable,'userdata',ui_objekte);	% speichern der vorher sichtbaren UiControl-Objekte

  h_slider=findobj('tag','slider'); % Finde waagerechten slider
  set(h_slider, 'visible','off');           % Setze Slider unsichtbar
  h_slidery=findobj('tag','slidery');% Finde senkrechten slider 
  set(h_slidery, 'visible','off');          % Setze Slider 
  h_objekt = gco;                   % Ermittle angeklicktes Objekt
  matrix = get(h_objekt,'userdata');% Lies userdata
  kaskade_nummer = matrix(1,6);     % Kaskadennummer in 1.Reihe, 6.Spalte
  kaskade_position= matrix(1,1);     % Teilsystem-Position
  koeffizienten = matrix((kaskade_position + 2),:);   % Koeffizienten der angewaehlten Kaskade
  b0 = koeffizienten(1);            % b0 = 1.Spalte
  b1 = koeffizienten(2);            % b1 = 2.Spalte
  b2 = koeffizienten(3);            % b2 = 3.Spalte
  a0 = koeffizienten(4);            % a0 = 4.Spalte
  a1 = koeffizienten(5);            % a1 = 5.Spalte
  a2 = koeffizienten(6);            % a2 = 6.Spalte
  string = ['Teilsystem H' num2str(kaskade_nummer) '(z)'];
                                    % Neue Ueberschrift der Figur
  string_old = get(gcf,'name');     % Alte Ueberschrift sichern
  set(gcf,'userdata',string_old);   % in userdata der Figur
  set(gcf,'name',string);           % Neue Ueberschrift setzen
  set(gcf,'windowbuttondownfcn',... % Setze Windowbuttondownfcn aktuelle Fig
        'kaskade(''closed'');');    % Ausfuehrung bei Mausklick in der Figur
  h_axes = findobj('tag','axes');   % Ermittle Handle des Axes-Objektes
  h_children=get(h_axes,'children');% Ermittle Handles der Nachkommen
  set(h_children,'visible','off');	% unsichtbar setzen
  h_axes_h=findobj('tag','axes_h(z)');	% Objekte für Überschrift in Kaskaden- und Parallelform
  set (h_axes_h,'visible','off');		% wenn vorhanden, unsichtbar setzen
  h_uicontrol = findobj('tag','change');% Handles der uicontrol-Objekte
  for handle = h_uicontrol'
    set(handle,'visible','off');    % Alle uicontrol-Objekte unsichtbar
  end  
  x_lim_old = get(h_axes,'xlim');   % Sichere alte Begrenzung x-Achse
  y_lim_old = get(h_axes,'ylim');   % Sichere alte Begrenzung y-Achse
  axes(h_axes);
  set(h_axes,'userdata',[x_lim_old y_lim_old]);
  screensize = get(0,'screensize'); % Ermittle Bildschirmaufloesung
  width = screensize(3);            % Breite des Bildschirms
  height = screensize(4);           % Hoehe des Bildschirms
  x_lim = [-40 40];                 % Festsetzen der waagerechten Grenzwerte
  y_lim = x_lim .*(height/width);   % Anpassen der senkrechten Grenzwerte
  set(h_axes,'ylim',y_lim,'xlim',x_lim);
for n = 0:2
    unten = 30;
    links = 0;
    faktor = (-10);                 
    senkrecht = (n*faktor-7);           % senkrechter Abstand der Bloecke
    waagerecht = 10;                % waagerechter Abstand der Bloecke

% --------------- Zeichne Multiplizierer b(n)--------------------------------
    x = [cos([0:5:360]*(pi/180)) cos([5:5:45]*(pi/180)) cos(225*pi/180)];
    y = [sin([0:5:360]*(pi/180)) sin([5:5:45]*(pi/180)) sin(225*pi/180)];
    x = [x cos([230:5:315]*(pi/180)) cos(135*pi/180)] - waagerecht;
    y = [y sin([230:5:315]*(pi/180)) sin(135*pi/180)] + senkrecht;
    h_line = plot(x+links,y+unten,'-k');        % Beschreibung siehe Netzwerk.m
    set(h_line,'tag','kaskade');
    string = ['b(' num2str(n) ')'];
    h_text= text('string',string,...
      'tag','kaskade',...
      'erasemode','normal',...
      'color',[0 0 0],...
      'position',[(1.5-waagerecht+links) (-1.5+senkrecht+unten)]);

% ----------------- Zeichne Addierer ----------------------------------------
    if(n<=2)
      x = [cos([0:10:360]*(pi/180)) -1];
      y = [sin([0:10:360]*(pi/180)) 0];
      x = [x cos([190:10:270]*(pi/180)) 0];   % - 2*waagerecht;
      y = [y sin([190:10:270]*(pi/180)) 1] + senkrecht;
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');
    end

% ------------ zeichne Verzoegerungsglied -----------------------------------
    if (n>=1)
      x1 = -3;
      x2 = 3;
      y1 = -3.5+senkrecht-faktor;
      y2 = -6.5+senkrecht-faktor;
      x = [x1 x2 x2 x1 x1];
      y = [y1 y1 y2 y2 y1];
      h_verz = plot(x+links,y+unten,'-k');
      set(h_verz,'tag','kaskade');
      string = 'z^-1';
      h_text= text('string',string,...
        'tag','kaskade',...
        'horizontalalignment','center',...
        'color',[0 0 0],...
        'position',[0+links (-5+senkrecht-faktor+unten)]);
    end
% ------------ Zeichne Multiplizierer a(n) ----------------------------------

    if (n >= 1)
      x = [cos([0:5:360]*(pi/180)) cos([5:5:45]*(pi/180)) cos(225*pi/180)];
      y = [sin([0:5:360]*(pi/180)) sin([5:5:45]*(pi/180)) sin(225*pi/180)];
      x = [x cos([230:5:315]*(pi/180)) cos(135*pi/180)] + waagerecht;
      y = [y sin([230:5:315]*(pi/180)) sin(135*pi/180)] + senkrecht;
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');
      string = ['-a(' num2str(n) ')'];
      h_text= text('string',string,...
        'tag','kaskade',...
        'color',[0 0 0],...
        'position',[(1.5+waagerecht+links) (-1.5+senkrecht+unten)]);
    end
% ------------ zeichne Verbindungslinien ------------------------------------
    if (n==0)
      x = [(-3*waagerecht) (-waagerecht-1)];
      x_pfeil = [(-waagerecht-1.6) (-waagerecht-1) (-waagerecht-1.6)];
      x = [x x_pfeil];
      y = [-7 -7 -7.6 -7 -6.3];
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');

      x = [(-waagerecht+1) (-1)];
      x_pfeil = [(-1.6) (-1) (-1.6)];
      x = [x x_pfeil];
      y = [-7 -7 -7.6 -7 -6.3];
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');
      

      x = [(+1) (3*waagerecht)];
      x_pfeil =[(3*waagerecht-0.6) (3*waagerecht) (3*waagerecht-0.6)];
      x = [x x_pfeil];
      y = [-7 -7 -7.6 -7 -6.3];
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');
      
      string = ['Teilsystem H' num2str(kaskade_nummer) '(z) in erster kanonischer Direktform:'];
      h_text= text('string',string,...
        'color',[0 0 0],...
        'tag','kaskade',...
        'position',[(-2*waagerecht-4+links) unten-3]);

      h_text= text('string','X(z)',...
        'color',[0 0 0],...
        'tag','kaskade',...
        'position',[(-3*waagerecht-4+links) -7+unten]);
      h_text= text('string','\_',...
        'color',[0 0 0],...
        'tag','kaskade',...
        'position',[(-3*waagerecht-4+links) -7.2+unten]);
      h_text= text('string','Y(z)',...
        'color',[0 0 0],...
        'tag','kaskade',...
        'position',[(3*waagerecht+3+links) -7+unten]);
      h_text= text('string','\_',...
        'color',[0 0 0],...
        'tag','kaskade',...
        'position',[(3*waagerecht+3+links) -7.2+unten]);
    end       % Ende n==0

      
    if (n>=1)
      x = [(-2*waagerecht) (-2*waagerecht) (-waagerecht-1) (-waagerecht-1.6),...
        (-waagerecht-1) (-waagerecht-1.6)];
     y = [ (senkrecht-faktor) senkrecht senkrecht (senkrecht-0.6),...
         senkrecht (senkrecht+0.6)];
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');

      x = [(-waagerecht+1) (-1) (-1.6) (-1) (-1.6)];
      y = [senkrecht senkrecht (senkrecht-0.6),...
        (senkrecht) (senkrecht+0.6)];
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');
       
       x = [(2*waagerecht) (2*waagerecht) (waagerecht+1) (waagerecht+1.6),...
        (waagerecht+1) (waagerecht+1.6)];
      y = [ (senkrecht-faktor) senkrecht senkrecht (senkrecht-0.6),...
         senkrecht (senkrecht+0.6)];
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');
    

      x = [(waagerecht-1) 1 1.6 1 1.6];
      y = [senkrecht senkrecht (senkrecht-0.6),...
        (senkrecht) (senkrecht+0.6)];
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');

      x = [0 0 -0.6 0 0.6];
      y = [(senkrecht+1) (senkrecht+3.5) (senkrecht+2.9),...
              (senkrecht+3.5) (senkrecht+2.9)];
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');
      
      x = [0 0 -0.6 0 0.6];
      y = [(senkrecht+6.5) (senkrecht-faktor-1) (senkrecht-faktor-1.6),...
              (senkrecht-faktor-1) (senkrecht-faktor-1.6)];
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');
  end   % Ende n <= 1
end     % Ende for n = 0:ordnung

% -------------- Koeffizientenausgabe ---------------------------------------
% Wenn Text 'Hn(z)' angeklickt wird, erfolgt die Ausgabe der Koeffizienten
% von 'Hn(z)'
  links = 0.61;
  unten = 0.1;
  farbe= [0.752 0.752 0.752];	   % Hintergrundfarbe festlegen
  uicontrol('style','frame',...     % Rahmen fuer Koeffizientenausgabe
        'units','normalized',...    % Normalisierte Masseinheit
        'backgroundcolor',farbe,...
        'position',[links unten 0.38 0.188],... % Koordinaten
        'tag','koeffizient');       % Bezeichnung = koeffizient

  uicontrol('style','text',...      % Textobjekt
        'units','normalized',...    % Normalisierte Masseinheit
        'string','a2 =',...         % Auszugebender Text
        'backgroundcolor',farbe,...
        'position',[links + 0.01 unten + 0.005 0.07 0.045],...% Koordinaten
        'tag','koeffizient');       % Bezeichnung = koeffizient
  uicontrol('style','text',...      % Textobjekt
        'units','normalized',...    % Normalisierte Masseinheit
        'string','a1 =',...         % Auszugebender Text
        'backgroundcolor',farbe,...
        'position',[links + 0.01 unten+0.05 0.07 0.045],...  % Koordinaten
        'tag','koeffizient');       % Bezeichnung = koeffizient
  uicontrol('style','text',...      % Textobjekt
        'units','normalized',...    % Normalisierte Masseinheit
        'string','a0 =',...         % Auszugebender Text
        'backgroundcolor',farbe,...
        'position',[links + 0.01 unten+0.095 0.07 0.045],...% Koordinaten
        'tag','koeffizient');       % Bezeichnung = koeffizient
  uicontrol('style','text',...      % Textobjekt
        'units','normalized',...    % Normalisierte Masseinheit
        'string','b2 =',...         % Auszugebender Text
        'backgroundcolor',farbe,...
        'position',[links + 0.19 unten+0.005 0.07 0.045],... % Koordinaten
        'tag','koeffizient');       % Bezeichnung = koeffizient
  uicontrol('style','text',...      % Textobjekt
        'units','normalized',...    % Normalisierte Masseinheit
        'string','b1 =',...         % Auszugebender Text
        'backgroundcolor',farbe,...
        'position',[links + 0.19 unten+0.05 0.07 0.045],...
        'tag','koeffizient');       % Bezeichnung = koeffizient
  uicontrol('style','text',...      % Textobjekt
        'units','normalized',...    % Normalisierte Masseinheit
        'string','b0 =',...         % Auszugebender Text
        'backgroundcolor',farbe,...
        'position',[links + 0.19 unten+0.095 0.07 0.045],...
        'tag','koeffizient');       % Bezeichnung = koeffizient

  string = ['Koeffizienten H' num2str(kaskade_nummer) '(z):'];
                                    % Ueberschrift des Rahmens
  uicontrol('style','text',...      % Text-Objekt fuer Ueberschrift
        'units','normalized',...
        'string',string,...
        'backgroundcolor',farbe,...
        'position',[links + 0.03 unten+0.14 0.28 0.045],...% Position der Ueberschrift
        'tag','koeffizient');
  
  uicontrol('style','edit',...      % Editierbarer Text
        'units','normalized',...
        'string',num2str(a2),...    % Koeffizient a2: Zahl -> String
        'backgroundcolor',farbe,...
        'position',[links + 0.08 unten+0.005 0.11 0.045],...
        'tag','koeffizient');
  uicontrol('style','edit',...
        'units','normalized',...
        'string',num2str(a1),...
        'backgroundcolor',farbe,...
        'position',[links + 0.08 unten+0.05 0.11 0.045],...
        'tag','koeffizient');
  uicontrol('style','edit',...
        'units','normalized',...
        'string',num2str(a0),...
        'backgroundcolor',farbe,...
        'position',[links + 0.08 unten+0.095 0.11 0.045],...
        'tag','koeffizient');
  uicontrol('style','edit',...
        'units','normalized',...
        'string',num2str(b2),...
        'backgroundcolor',farbe,...
        'position',[links + 0.26 unten+0.005 0.11 0.045],...
        'tag','koeffizient');
  uicontrol('style','edit',...
        'units','normalized',...
        'string',num2str(b1),...
        'backgroundcolor',farbe,...
        'position',[links + 0.26 unten+0.05 0.11 0.045],...
        'tag','koeffizient');
  uicontrol('style','edit',...
        'units','normalized',...
        'string',num2str(b0),...
        'backgroundcolor',farbe,...
        'position',[links + 0.26 unten+0.095 0.11 0.045],...
        'tag','koeffizient');


% -------------------- PN-Darstellung ---------------------------------------
  screen = get(0,'screensize');       % Ermittle Bildschirmdaten
  breite = screen(3);                 % Extrahiere Bildschirmbreite
  hoehe = screen(4);                  % Extrahiere Bildschirmhoehe
  hoehe_axes = 0.38;
  breite_axes = hoehe_axes * hoehe / breite;
  y_lim = [-1.5 1.5];                 % Senkrechte Grenzwerte
  x_lim = y_lim;                      % Waagerechte Grenzwerte
  h_axes_pn=axes('position',[0.3 0.1 breite_axes hoehe_axes],...% Position und Ausdehnung
        'xcolor',[0 0 0],...          % Farbe x-Achse = Schwarz
        'ycolor',[0 0 0],...          % Farbe y-Achse = Schwarz
        'xgrid','on',...              % Gitter in x-Richtung an
        'ygrid','on',...              % Gitter in y-Richtung an
        'xlim',x_lim,...
        'ylim',y_lim,...
        'box','on',...
        'tag','kaskade',...
        'drawmode','fast',...
        'color',[1 1 1],...           % Farbe = Weiss
        'nextplot','add');            % Aeltere Plots bleiben erhalten
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
  string = ['PN-Diagramm H' num2str(kaskade_nummer) '(z):'];
  breite = x_lim(1) + (x_lim(2)-x_lim(1))/2;   % Waagerechte Position der Ueberschrift
  text('string',string,...           % Ueberschrift fuer Axes-Objekt
       'erasemode','normal',...
       'color',[0 0 0],...            % Farbe = Schwarz
       'tag','text_real',...
       'verticalalignment','top',...  % Textausrichtung = unten
       'horizontalalignment','center',...% Textausrichtung = zentriert
       'position',[breite y_lim(2)+(y_lim(2)-y_lim(1))/8]);


 % ----------unquantisierte nullstellen plotten --------------------------
    b_hilf = [b0 b1 b2];
    null = roots(b_hilf);                  % Ermittle unquantisierte Polstellen
    laenge_null = length(null);       % Laenge des Polstellenvektors
    old = [];                         % Alte Nullstelle
    hilf = 1;                         % Anzahl der Nullstellen einer Mehrfachnullstelle
    for n = 1:laenge_null             % Mit Nullstellenvektor
      zahl = null(n);                 % Aktuelle Nullstelle
      real_zahl = real(zahl);         % Realteil der Nullstelle
      imag_zahl = imag(zahl);         % Imaginaerteil der Nullstelle
      if ~isempty (old)
      if (zahl == old)                % Wenn Mehrfachnullstelle
        hilf = hilf + 1;              % Erhoehe Anzahl Nullstellen
      end              
      end;
      h_null = plot...                % Plotte Nullstelle
        (real_zahl,imag_zahl,'or');
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
    a_hilf = [a0 a1 a2];
    pol = roots(a_hilf);                   % Ermittle unquantisierte Polstellen
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
      end;
      h_pol = plot...                 % Plotte Polstelle
        (real_zahl,imag_zahl,'xr');
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

end                                 % Ende von Kaskade




%-------------- Kaskadenorm -------------------------------------------------
if strcmp(command_str,'kaskadenorm')% Wenn command_str = kaskadenorm
  h_figure = findobj('tag','netzwerk'); % Finde Figur 'netzwerk'
  h_children = get(h_figure,'children');% Ermittle Nachkommen von 'netzwerk'
  

  ui_objekte= findobj('type','uicontrol','visible','on');	% alle UiControl-Objekte, die sichtbar sind
  set (ui_objekte,'visible','off'),		% unsichtbar setzen
  h_enable= findobj('tag','ende');		% Objekt zur Speicherung dieser Handle-Liste
  set (h_enable,'userdata',ui_objekte);	% speichern der vorher sichtbaren UiControl-Objekte

  h_slider=findobj('tag','slider'); % Finde waagerechten slider
  set(h_slider, 'visible','off');           % Setze Slider 
  h_slidery=findobj('tag','slidery');% Finde senkrechten slider 
  set(h_slidery, 'visible','off');          % Setze Slider 
  h_objekt = gco;                   % Ermittle angeklicktes Objekt
  matrix = get(h_objekt,'userdata');% Lies userdata
  kaskade_nummer = matrix(1,7);     % Kaskadennummer in 1.Reihe, 7.Spalte
  kaskade_position= matrix(1,1);      % Teilsystem_Position
  koeffizienten = matrix((kaskade_position + 2),:);    % Koeffizienten der angewaehlten Kaskade
  norm_faktor = koeffizienten(1);   % norm_faktor = 1.Spalte
  b0 = koeffizienten(2);            % b0 = 2.Spalte
  b1 = koeffizienten(3);            % b1 = 3.Spalte
  b2 = koeffizienten(4);            % b2 = 4.Spalte
  a0 = koeffizienten(5);            % a0 = 5.Spalte
  a1 = koeffizienten(6);            % a1 = 6.Spalte
  a2 = koeffizienten(7);            % a2 = 7.Spalte
  string = ['Teilsystem H' num2str(kaskade_nummer) '(z)'];
                                    % Neue Ueberschrift der Figur
  string_old = get(gcf,'name');     % Alte Ueberschrift sichern
  set(gcf,'userdata',string_old);   % in userdata der Figur
  set(gcf,'name',string);           % Neue Ueberschrift setzen
  set(gcf,'windowbuttondownfcn',... % Setze Windowbuttondownfcn aktuelle Fig
        'kaskade(''closed'');');    % Ausfuehrung bei Mausklick in der Figur
  h_axes = findobj('tag','axes');   % Ermittle Handle des Axes-Objektes
  h_children=get(h_axes,'children');% Ermittle Handles der Nachkommen
  set(h_children,'visible','off');	% unsichtbar setzen
  h_axes_h=findobj('tag','axes_h(z)');	% Objekte für Überschrift in Kaskaden- und Parallelform
  set (h_axes_h,'visible','off');		% wenn vorhanden, unsichtbar setzen
  h_uicontrol = findobj('tag','change');% Handles der uicontrol-Objekte
  for handle = h_uicontrol'
    set(handle,'visible','off');    % Alle uicontrol-Objekte unsichtbar
  end  
  x_lim_old = get(h_axes,'xlim');   % Sichere alte Begrenzung x-Achse
  y_lim_old = get(h_axes,'ylim');   % Sichere alte Begrenzung y-Achse
  axes (h_axes);
  set(h_axes,'userdata',[x_lim_old y_lim_old]);
  screensize = get(0,'screensize'); % Ermittle Bildschirmaufloesung
  width = screensize(3);            % Breite des Bildschirms
  height = screensize(4);           % Hoehe des Bildschirms
  x_lim = [-40 40];                 % Festsetzen der waagerechten Grenzwerte
  y_lim = x_lim .*(height/width);   % Anpassen der senkrechten Grenzwerte
  set(h_axes,'ylim',y_lim,'xlim',x_lim);
for n = 0:2
    unten = 30;
    links = 0;
    faktor = (-10);                 
    senkrecht = (n*faktor-7);           % senkrechter Abstand der Bloecke
    waagerecht = 10;                % waagerechter Abstand der Bloecke

% --------------- Zeichne Multiplizierer b(n)--------------------------------
    x = [cos([0:5:360]*(pi/180)) cos([5:5:45]*(pi/180)) cos(225*pi/180)];
    y = [sin([0:5:360]*(pi/180)) sin([5:5:45]*(pi/180)) sin(225*pi/180)];
    x = [x cos([230:5:315]*(pi/180)) cos(135*pi/180)] - waagerecht;
    y = [y sin([230:5:315]*(pi/180)) sin(135*pi/180)] + senkrecht;
    h_line = plot(x+links,y+unten,'-k');        % Beschreibung siehe Netzwerk.m
    set(h_line,'tag','kaskade');
    string = ['b(' num2str(n) ')'];
    h_text= text('string',string,...
      'tag','kaskade',...
      'erasemode','normal',...
      'color',[0 0 0],...
      'position',[(1.5-waagerecht+links) (-1.5+senkrecht+unten)]);

% ----------------- Zeichne Addierer ----------------------------------------
    if(n<=2)
      x = [cos([0:10:360]*(pi/180)) -1];
      y = [sin([0:10:360]*(pi/180)) 0];
      x = [x cos([190:10:270]*(pi/180)) 0];   % - 2*waagerecht;
      y = [y sin([190:10:270]*(pi/180)) 1] + senkrecht;
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');
    end

% ------------ zeichne Verzoegerungsglied -----------------------------------
    if (n>=1)
      x1 = -3;
      x2 = 3;
      y1 = -3.5+senkrecht-faktor;
      y2 = -6.5+senkrecht-faktor;
      x = [x1 x2 x2 x1 x1];
      y = [y1 y1 y2 y2 y1];
      h_verz = plot(x+links,y+unten,'-k');
      set(h_verz,'tag','kaskade');
      string = 'z^-1';
      h_text= text('string',string,...
        'tag','kaskade',...
        'horizontalalignment','center',...
        'color',[0 0 0],...
        'position',[0+links (-5+senkrecht-faktor+unten)]);
    end
% ------------ Zeichne Multiplizierer a(n) ----------------------------------

    if (n >= 1)
      x = [cos([0:5:360]*(pi/180)) cos([5:5:45]*(pi/180)) cos(225*pi/180)];
      y = [sin([0:5:360]*(pi/180)) sin([5:5:45]*(pi/180)) sin(225*pi/180)];
      x = [x cos([230:5:315]*(pi/180)) cos(135*pi/180)] + waagerecht;
      y = [y sin([230:5:315]*(pi/180)) sin(135*pi/180)] + senkrecht;
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');
      string = ['-a(' num2str(n) ')'];
      h_text= text('string',string,...
        'tag','kaskade',...
        'color',[0 0 0],...
        'position',[(1.5+waagerecht+links) (-1.5+senkrecht+unten)]);
    end
% ------------ zeichne Verbindungslinien ------------------------------------
    if (n==0)
      x = [(-4*waagerecht) (-3*waagerecht-1)];
      x_pfeil = [(-3*waagerecht-1.6) (-3*waagerecht-1) (-3*waagerecht-1.6)];
      x = [x x_pfeil];
      y = [-7 -7 -7.6 -7 -6.4];
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');
              
      x = [(-3*waagerecht+1) (-waagerecht-1)];
      x_pfeil = [(-waagerecht-1.6) (-waagerecht-1) (-waagerecht-1.6)];
      x = [x x_pfeil];
      y = [-7 -7 -7.6 -7 -6.4];
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');

      x = [(-waagerecht+1) (-1)];
      x_pfeil = [(-1.6) (-1) (-1.6)];
      x = [x x_pfeil];
      y = [-7 -7 -7.6 -7 -6.4];
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');
      

      x = [(+1) (3*waagerecht)];
      x_pfeil =[(3*waagerecht-0.6) (3*waagerecht) (3*waagerecht-0.6)];
      x = [x x_pfeil];
      y = [-7 -7 -7.6 -7 -6.4];
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');

      string = ['Teilsystem H' num2str(kaskade_nummer) '(z) in erster kanonischer Direktform:'];
      h_text= text('string',string,...
        'color',[0 0 0],...
        'tag','kaskade',...
        'position',[(-2*waagerecht-4+links) unten-3]);

      h_text= text('string','X(z)',...
        'color',[0 0 0],...
        'tag','kaskade',...
        'position',[(-4*waagerecht-4+links) -7+unten]);
      h_text= text('string','\_',...
        'color',[0 0 0],...
        'tag','kaskade',...
        'position',[(-4*waagerecht-4+links) -7.2+unten]);
      h_text= text('string','Y(z)',...
        'color',[0 0 0],...
        'tag','kaskade',...
        'position',[(3*waagerecht+3+links) -7+unten]);
      h_text= text('string','\_',...
        'color',[0 0 0],...
        'tag','kaskade',...
        'position',[(3*waagerecht+3+links) -7.2+unten]);

% --------------- Zeichne Multiplizierer k(n)--------------------------------
      x = [cos([0:5:360]*(pi/180)) cos([5:5:45]*(pi/180)) cos(225*pi/180)];
      y = [sin([0:5:360]*(pi/180)) sin([5:5:45]*(pi/180)) sin(225*pi/180)];
      x = [x cos([230:5:315]*(pi/180)) cos(135*pi/180)] - 3*waagerecht;
      y = [y sin([230:5:315]*(pi/180)) sin(135*pi/180)] -7;
      h_line = plot(x+links,y+unten,'-k');        % Beschreibung siehe Netzwerk.m
      set(h_line,'tag','kaskade');
      string = 'k';
      h_text= text('string',string,...
      'tag','kaskade',...
      'erasemode','normal',...
      'color',[0 0 0],...
      'position',[(1.5-3*waagerecht+links) (-8.5+unten)]);
    end       % Ende n==0

      
    if (n>=1)
      x = [(-2*waagerecht) (-2*waagerecht) (-waagerecht-1) (-waagerecht-1.6),...
        (-waagerecht-1) (-waagerecht-1.6)];
     y = [ (senkrecht-faktor) senkrecht senkrecht (senkrecht-0.6),...
         senkrecht (senkrecht+0.6)];
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');

      x = [(-waagerecht+1) (-1) (-1.6) (-1) (-1.6)];
      y = [senkrecht senkrecht (senkrecht-0.6),...
        (senkrecht) (senkrecht+0.6)];
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');
       
       x = [(2*waagerecht) (2*waagerecht) (waagerecht+1) (waagerecht+1.6),...
        (waagerecht+1) (waagerecht+1.6)];
      y = [ (senkrecht-faktor) senkrecht senkrecht (senkrecht-0.6),...
         senkrecht (senkrecht+0.6)];
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');
    

      x = [(waagerecht-1) 1 1.6 1 1.6];
      y = [senkrecht senkrecht (senkrecht-0.6),...
        (senkrecht) (senkrecht+0.6)];
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');

      x = [0 0 -0.6 0 0.6];
      y = [(senkrecht+1) (senkrecht+3.5) (senkrecht+2.9),...
              (senkrecht+3.5) (senkrecht+2.9)];
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');
      
      x = [0 0 -0.6 0 0.6];
      y = [(senkrecht+6.5) (senkrecht-faktor-1) (senkrecht-faktor-1.6),...
              (senkrecht-faktor-1) (senkrecht-faktor-1.6)];
      h_line = plot(x+links,y+unten,'-k');
      set(h_line,'tag','kaskade');
  end   % Ende n <= 1
end     % Ende for n = 0:ordnung


% -------------- Koeffizientenausgabe ---------------------------------------
% Wenn Text 'Hn(z)' angeklickt wird, erfolgt die Ausgabe der Koeffizienten
% von 'Hn(z)'
  links = 0.61;
  unten = 0.1;
  farbe = [0.752 0.752 0.752];  % Farbe für Hintergrung definieren
  uicontrol('style','frame',...     % Rahmen fuer Koeffizientenausgabe
        'units','normalized',...    % Normalisierte Masseinheit
        'backgroundcolor',farbe,...
        'position',[links unten 0.38 0.233],... % Koordinaten
        'tag','koeffizient');       % Bezeichnung = koeffizient

  uicontrol('style','text',...      % Textobjekt
        'units','normalized',...    % Normalisierte Masseinheit
        'string','k  =',...         % Auszugebender Text
        'backgroundcolor',farbe,...
        'position',[links+0.01 unten+0.137 0.07 0.045],...% Koordinaten
        'tag','koeffizient');       % Bezeichnung = koeffizient
  uicontrol('style','text',...      % Textobjekt
        'units','normalized',...    % Normalisierte Masseinheit
        'string','a2 =',...         % Auszugebender Text
        'backgroundcolor',farbe,...
        'position',[links+0.01 unten+0.005 0.07 0.045],...% Koordinaten
        'tag','koeffizient');       % Bezeichnung = koeffizient
  uicontrol('style','text',...      % Textobjekt
        'units','normalized',...    % Normalisierte Masseinheit
        'string','a1 =',...         % Auszugebender Text
        'backgroundcolor',farbe,...
        'position',[links+0.01 unten+0.05 0.07 0.045],...  % Koordinaten
        'tag','koeffizient');       % Bezeichnung = koeffizient
  uicontrol('style','text',...      % Textobjekt
        'units','normalized',...    % Normalisierte Masseinheit
        'string','a0 =',...         % Auszugebender Text
        'backgroundcolor',farbe,...
        'position',[links+0.01 unten+0.095 0.07 0.045],...% Koordinaten
        'tag','koeffizient');       % Bezeichnung = koeffizient
  uicontrol('style','text',...      % Textobjekt
        'units','normalized',...    % Normalisierte Masseinheit
        'string','b2 =',...         % Auszugebender Text
        'backgroundcolor',farbe,...
        'position',[links+0.21 unten+0.005 0.07 0.045],... % Koordinaten
        'tag','koeffizient');       % Bezeichnung = koeffizient
  uicontrol('style','text',...      % Textobjekt
        'units','normalized',...    % Normalisierte Masseinheit
        'string','b1 =',...         % Auszugebender Text
        'backgroundcolor',farbe,...
        'position',[links+0.21 unten+0.05 0.07 0.045],...
        'tag','koeffizient');       % Bezeichnung = koeffizient
  uicontrol('style','text',...      % Textobjekt
        'units','normalized',...    % Normalisierte Masseinheit
        'string','b0 =',...         % Auszugebender Text
        'backgroundcolor',farbe,...
        'position',[links+0.21 unten+0.095 0.07 0.045],...
        'tag','koeffizient');       % Bezeichnung = koeffizient

  string = ['Koeffizienten H' num2str(kaskade_nummer) '(z):'];
                                    % Ueberschrift des Rahmens
  uicontrol('style','text',...      % Text-Objekt fuer Ueberschrift
        'units','normalized',...
        'string',string,...
        'backgroundcolor',farbe,...
        'position',[links+0.03 unten+0.182 0.28 0.045],...% Position der Ueberschrift
        'tag','koeffizient');

  uicontrol('style','edit',...      % Editierbarer Text
        'units','normalized',...
        'string',num2str(norm_faktor),...% Koeffizient a2: Zahl -> String
        'backgroundcolor',farbe,...
        'position',[links+0.08 unten+0.137 0.11 0.045],...
        'tag','koeffizient');
  uicontrol('style','edit',...      % Editierbarer Text
        'units','normalized',...
        'string',num2str(a2),...    % Koeffizient a2: Zahl -> String
        'backgroundcolor',farbe,...
        'position',[links+0.08 unten+0.005 0.11 0.045],...
        'tag','koeffizient');
  uicontrol('style','edit',...
        'units','normalized',...
        'string',num2str(a1),...
        'backgroundcolor',farbe,...
        'position',[links+0.08 unten+0.05 0.11 0.045],...
        'tag','koeffizient');
  uicontrol('style','edit',...
        'units','normalized',...
        'string',num2str(a0),...
        'backgroundcolor',farbe,...
        'position',[links+0.08 unten+0.095 0.11 0.045],...
        'tag','koeffizient');
  uicontrol('style','edit',...
        'units','normalized',...
        'string',num2str(b2),...
        'backgroundcolor',farbe,...
        'position',[links+0.26 unten+0.005 0.11 0.045],...
        'tag','koeffizient');
  uicontrol('style','edit',...
        'units','normalized',...
        'string',num2str(b1),...
        'backgroundcolor',farbe,...
        'position',[links+0.26 unten+0.05 0.11 0.045],...
        'tag','koeffizient');
  uicontrol('style','edit',...
        'units','normalized',...
        'string',num2str(b0),...
        'backgroundcolor',farbe,...
        'position',[links+0.26 unten+0.095 0.11 0.045],...
        'tag','koeffizient');

% -------------------- PN-Darstellung ---------------------------------------
  screen = get(0,'screensize');       % Ermittle Bildschirmdaten
  breite = screen(3);                 % Extrahiere Bildschirmbreite
  hoehe = screen(4);                  % Extrahiere Bildschirmhoehe
  hoehe_axes = 0.38;
  breite_axes = hoehe_axes * hoehe / breite;
  y_lim = [-1.5 1.5];                 % Senkrechte Grenzwerte
  x_lim = y_lim;                      % Waagerechte Grenzwerte
  h_axes_pn=axes('position',[0.3 0.1 breite_axes hoehe_axes],...% Position und Ausdehnung
        'xcolor',[0 0 0],...          % Farbe x-Achse = Schwarz
        'ycolor',[0 0 0],...          % Farbe y-Achse = Schwarz
        'xgrid','on',...              % Gitter in x-Richtung an
        'ygrid','on',...              % Gitter in y-Richtung an
        'xlim',x_lim,...
        'ylim',y_lim,...
        'box','on',...
        'tag','kaskade',...
        'drawmode','fast',...
        'color',[1 1 1],...           % Farbe = Weiss
        'nextplot','add');            % Aeltere Plots bleiben erhalten
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
  string = ['PN-Diagramm H' num2str(kaskade_nummer) '(z):'];
  breite = x_lim(1) + (x_lim(2)-x_lim(1))/2;   % Waagerechte Position der Ueberschrift
  text('string',string,...           % Ueberschrift fuer Axes-Objekt
       'erasemode','normal',...
       'color',[0 0 0],...            % Farbe = Schwarz
       'tag','text_real',...
       'verticalalignment','top',...  % Textausrichtung = unten
       'horizontalalignment','center',...% Textausrichtung = zentriert
       'position',[breite y_lim(2)+(y_lim(2)-y_lim(1))/8]);


 % ----------unquantisierte nullstellen plotten --------------------------
    b_hilf = [b0 b1 b2].*norm_faktor;
    null = roots(b_hilf);                  % Ermittle unquantisierte Polstellen
    laenge_null = length(null);       % Laenge des Polstellenvektors
    old = [];                         % Alte Nullstelle
    hilf = 1;                         % Anzahl der Nullstellen einer Mehrfachnullstelle
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
    a_hilf = [a0 a1 a2];
    pol = roots(a_hilf);                   % Ermittle unquantisierte Polstellen
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
      end;
      h_pol = plot...                 % Plotte Polstelle
        (real_zahl,imag_zahl,'xr');
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
end                                 % Ende von Kaskade

% ------------------------ closed -------------------------------------------
if strcmp(command_str,'closed')     % Wenn command_str = closed
  string = get(gcf,'userdata');     % Lies alte Ueberschrift aus userdata
  set(gcf,'name',string);           % Setze alte Ueberschrift
  set(gcf,'windowbuttondownfcn','');% Reset windowbuttondownfcn
  h_axes = findobj('tag','axes');   % Ermittle Handle des Axes-Objektes
  axes(h_axes);                     % h_axes = aktuelles Axes-Objekt
  h_kaskade = findobj('tag','kaskade');% Objekte mit Bezeichnung 'kaskade'
  delete(h_kaskade);                 % Entferne diese Objekte
  h_axes_h=findobj('tag','axes_h(z)');	% Objekte für Überschrift in Kaskaden- und Parallelform
  set (h_axes_h,'visible','on');		% wenn vorhanden, sichtbar setzen
  h_axes_h=findobj('tag','axes_h(z)','type','axes');
  set (h_axes_h,'visible','off');
  h_kaskade = findobj('tag','koeffizient');           % Objekte mit Bezeichnung 'koeffizient'
  delete(h_kaskade);                 % Entferne diese Objekte
  h_children = get(h_axes,'children'); % Handles der Nachkommen von Axes
  set(h_children,'visible','on');     % Setze Nachkommen = sichtbar
  limit = get(h_axes,'userdata');   % Lies alte Achsenbegrenzung
  x_lim = [limit(1) limit(2)];      % Aufteilung nach x und y
  y_lim = [limit(3) limit(4)];
  set(h_axes,'ylim',y_lim,'xlim',x_lim);% Uebernahme der alten Werte
  h_figure = findobj('tag','netzwerk'); % Finde Figur 'netzwerk'

  h_enable= findobj('tag','ende');		% Objekt zur Speicherung dieser Handle-Liste
  ui_objekte = get(h_enable,'userdata');	% laden der vorher sichtbaren UiControl-Objekte
  set (ui_objekte,'visible','on');		% sichtbar setzen

  h_slidery = findobj('tag','slidery'); % Finde senkrechten slider
  set(h_slidery,'visible','off');       % Setze slider unsichtbar
  h_quit = findobj('tag','quit');       % Finde Pushbutton 'quit'
  set(h_quit,'enable','off');           % Setze Pushbutton inaktiv

end                                     % Ende strcmp(command_str,'closed')


%-------------- change ------------------------------------------------------
% Zwei vom Benutzer angegebene Kaskaden werden in ihrer Reihenfolge getauscht
if strcmp(command_str,'change')
  h_data = findobj('type','text',...
    'tag','h(z)');        % finde Objekt, in dem sos-matrix abgespeichert ist
  set(h_data,'buttondownfcn',...      % Wiederherstellen der Buttondownfcn
    'kaskade(''kaskade'');',...
    'color',[0 0 0]);                 % Wiederherstellen der Zeichenfarbe
  h_line = findobj('tag','kaskade3',...% Finde Verbindungslinien zwischen
    'type','line');                   % den Kaskaden
  set(h_line,'buttondownfcn',...      % Wiederherstellen der Buttondownfcn
    'impulant(''kaskade'');');
  h_axes_h=findobj('tag','axes_h(z)');	% Objekte für Überschrift in Kaskaden- und Parallelform
  set (h_axes_h,'buttondownfcn','netzwerk(''quant'');');	% Wiederherstellen der ButtonDownFcn
  h_push_tauschen = findobj...        % Finde Pushbutton 'tauschen'
    ('tag','tauschen');
  data = get(h_push_tauschen,...      % Lies zu tauschende Kaskaden aus
    'userdata');                      % userdata
  kaskade1 = data(1,1);               % Position erste zu tauschende Kaskade
  kaskade2 = data(2,1);               % Position zweite zu tauschende Kaskade
  kas_num1 = data(1,2);               % Nummer erste zu tauschende Kaskade
  kas_num2 = data(2,2);               % Nummer zweite zu tauschende Kaskade
  h_kaskade1 = data(1,3);             % Handle erste zu tauschende Kaskade
  h_kaskade2 = data(2,3);             % Handle zweite zu tauschende Kaskade
  set(h_push_tauschen,...             % Setze Pushbutton 'tauschen' aktiv
    'enable','on');
  h_figure = findobj('tag','netzwerk');% Finde Figur 'netzwerk'
  set(h_figure,'windowbuttonupfcn','');% Reset Windowbuttonupfcn
  matrix = get(h_data(1),'userdata'); % Lies Matrix aus userdata
  matrix_groesse = size(matrix);      % Groesse der Matrix
  reihen = matrix_groesse(1);         % Anzahl der Reihen der Matrix
  spalten = matrix_groesse(2);        % Anzahl der Spalten der Matrix
                                      % Die Koeffizienten beginnen ab Reihe 2
  sos = matrix(2:reihen,:);           % Extrahieren der benoetigten
                                      % Koeffizienten
  reihe1 = kaskade1 + 1;              % Erste zu tauschende Reihe
  reihe2 = kaskade2 + 1;              % Zweite zu tauschende Reihe
  hilf = sos(reihe1,:);               % Hilfsvariable Zwischenspeicher
  sos(reihe1,:) = sos(reihe2,:);      % Reihe2 nach Reihe1
  sos(reihe2,:) = hilf;               % Hilf nach Reihe2
  for handle = h_data'                % Aktualisiere Daten in userdata
    matrix = get(handle,'userdata');  % Lies alte Daten
    matrix(2:reihen,:) = sos;         % Ersetze sos der Matrix
    set(handle,'userdata',matrix);    % Speichern der aktualisierten Matrix
  end
  matrix_k1=get(h_kaskade1,'userdata');% Lies Matrix der ersten Kaskade
  matrix_k1(1,6)=kas_num2;            % Setze neue Kaskadennummer
  set(h_kaskade1,'userdata',matrix_k1);% Speichere aktuelle Matrix
  matrix_k2=get(h_kaskade2,'userdata');% Lies Matrix der zweiten Kaskade
  matrix_k2(1,6)=kas_num1;            % Setze neue Kaskadennummer
  set(h_kaskade2,'userdata',matrix_k2);% Speichere aktuelle Matrix
  h_push_rueck = findobj('tag',...    % Suche Handle des Pushbuttons 
        'rueckgaengig');              % 'rueckgaengig'
  set(h_push_rueck,'userdata',...     % Speichere die getauschten Kaskaden
        data,...                      % in userdata
        'enable','on',...
        'callback','kaskade(''rueckgaengig'');');
  string1 = ['H' num2str(kas_num1) '(z)']; % Tausche Kaskadenbeschriftung
  h_text1 = findobj('type','text','tag','h(z)','string',string1);
  string2 = ['H' num2str(kas_num2) '(z)'];
  h_text2 = findobj('type','text','tag','h(z)','string',string2);
  set(h_text1,'string',string2);
  set(h_text2,'string',string1);
  h_ende=findobj('tag','ende');
  h_enable=get(h_ende,'userdata');
  set (h_enable,'enable','on');

  h_system = findobj...              % Finde Pushbutton 'antwort'
    ('tag','antwort');
  matrix = [4 0 0 0 0 0;sos];
  set(h_system,'userdata',matrix);    % Speichern in userdata Pushbutton 'antwort'
end                                  % Ende von command_str = change

%-------------- Rueckgaengig ------------------------------------------------
% Operation tauschen wird ohne Aenderung abgebrochen
if strcmp(command_str,'rueckgaengig') % Wenn command_str = rueckgaengig
  h_push_rueck = findobj('tag','rueckgaengig');
                                      % Suche Pushbutton 'Rueckgaengig'
  set(h_push_rueck,...                % Setze Pushbutton inaktiv
    'enable','off');
  data = get(h_push_rueck,'userdata'); % zuvor getauschte Kaskaden
  kaskade1 = data(1,1);               % Position erste zu tauschende Kaskade
  kaskade2 = data(2,1);               % Position zweite zu tauschende Kaskade
  kas_num1 = data(1,2);               % Nummer erste zu tauschende Kaskade
  kas_num2 = data(2,2);               % Nummer zweite zu tauschende Kaskade
  h_kaskade1 = data(1,3);             % Handle erste zu tauschende Kaskade
  h_kaskade2 = data(2,3);             % Handle zweite zu tauschende Kaskade
  reihe1 = kaskade1+1;                 
  reihe2 = kaskade2+1;
  h_data = findobj('buttondownfcn',...% Objekt, in dem sos-matrix
        'kaskade(''kaskade'');');     % enthalten ist
  matrix = get(h_data(1),'userdata'); % Lies Matrix aus userdata
  matrix_groesse = size(matrix);      % Groesse der Matrix
  reihen = matrix_groesse(1);         % Anzahl der Reihen der Matrix
  spalten = matrix_groesse(2);        % Anzahl der Spalten der Matrix
                                      % Die Koeffizienten beginnen ab Reihe 2
  sos = matrix(2:reihen,:);           % Extrahieren der benoetigten
                                      % Koeffizienten
  hilf = sos(reihe1,:);               % erste zu tauschende Reihe -> Hilf
  sos(reihe1,:) = sos(reihe2,:);      % Reihe2 -> Reihe1
  sos(reihe2,:) = hilf;               % Hilf -> Reihe2
  for handle = h_data'
    matrix = get(handle,'userdata');  % Alte Matrix lesen
    matrix(2:reihen,:) = sos;         % Matrix aktualisieren
    set(handle,'userdata',matrix);    % Aktualisierte Matrix abspeichern
  end
  matrix_k1=get(h_kaskade1,'userdata');% Lies Matrix der ersten Kaskade


  matrix_k1(1,6)=kas_num1;             % Setze neue Kaskadennummer
  set(h_kaskade1,'userdata',matrix_k1);% Speichere aktuelle Matrix
  matrix_k2=get(h_kaskade2,'userdata');% Lies Matrix der zweiten Kaskade


  matrix_k2(1,6)=kas_num2;             % Setze neue Kaskadennummer
  set(h_kaskade2,'userdata',matrix_k2);% Speichere aktuelle Matrix
  string1 = ['H' num2str(kas_num1) '(z)'];% Text der Kaskaden tauschen
  h_text1 = findobj('type','text',...
        'tag','h(z)','string',string1);
  string2 = ['H' num2str(kas_num2) '(z)'];
  h_text2 = findobj('type','text',...
        'tag','h(z)','string',string2);
  set(h_text1,'string',string2);
  set(h_text2,'string',string1);
  h_system = findobj...              % Finde Pushbutton 'antwort'
    ('tag','antwort');
  matrix = [4 0 0 0 0 0; sos];
  set(h_system,'userdata',matrix);    % Speichern in userdata Pushbutton 'antwort'
end

%-------------- changenorm --------------------------------------------------
% Zwei vom Benutzer angegebene Kaskaden werden in ihrer Reihenfolge getauscht
if strcmp(command_str,'changenorm')
  h_data = findobj('type','text',...
    'tag','h(z)');        % finde Objekt, in dem sos-matrix abgespeichert ist
  set(h_data,'buttondownfcn',...      % Wiederherstellen Buttondownfcn
    'kaskade(''kaskadenorm'');',...
    'color',[0 0 0]);                 % Wiederherstellen Zeichenfarbe
  h_line = findobj('tag','kaskade3',...% Finde Verbindungslinien zwischen
    'type','line');                   % den Kaskaden 
  set(h_line,'buttondownfcn',...      % Wiederherstellen Buttondownfcn
    'impulant(''kaskade_norm'');');
  h_axes_h=findobj('tag','axes_h(z)');	% Objekte für Überschrift in Kaskaden- und Parallelform
  set (h_axes_h,'buttondownfcn','netzwerk(''quant'');');	% Wiederherstellen der ButtonDownFcn
  h_push_tauschen = findobj...        % Finde Pushbutton 'tauschen'
    ('tag','tauschen');
  data = get(h_push_tauschen,...      % Lies zu tauschende Kaskaden aus
    'userdata');                      % userdata
  kaskade1 = data(1,1);               % Position erste zu tauschende Kaskade
  kaskade2 = data(2,1);               % Position zweite zu tauschende Kaskade
  kas_num1 = data(1,2);               % Nummer erste zu tauschende Kaskade
  kas_num2 = data(2,2);               % Nummer zweite zu tauschende Kaskade
  h_kaskade1 = data(1,3);             % Handle erste zu tauschende Kaskade
  h_kaskade2 = data(2,3);             % Handle zweite zu tauschende Kaskade
  set(h_push_tauschen,...             % Setze Pushbutton 'tauschen' aktiv
    'enable','on');
  h_figure = findobj('tag','netzwerk');% Finde Figur 'netzwerk'
  set(h_figure,'windowbuttonupfcn','');% Reset Windowbuttonupfcn
  matrix = get(h_data(1),'userdata'); % Lies Matrix aus userdata
  matrix_groesse = size(matrix);      % Groesse der Matrix
  reihen = matrix_groesse(1);         % Anzahl der Reihen der Matrix
  spalten = matrix_groesse(2);        % Anzahl der Spalten der Matrix
                                      % Die Koeffizienten beginnen ab Reihe 2
  sos = matrix(2:reihen,:);           % Extrahieren der benoetigten
                                      % Koeffizienten
  reihe1 = kaskade1 + 1;              % Erste zu tauschende Reihe
  reihe2 = kaskade2 + 1;              % Zweite zu tauschende Reihe
  hilf = sos(reihe1,:);               % Hilfsvariable Zwischenspeicher
  sos(reihe1,:) = sos(reihe2,:);      % Reihe2 nach Reihe1
  sos(reihe2,:) = hilf;               % Hilf nach Reihe2
  for handle = h_data'                % Aktualisiere Daten in userdata
    matrix = get(handle,'userdata');  % Lies alte Daten
    matrix(2:reihen,:) = sos;         % Ersetze sos der Matrix
    set(handle,'userdata',matrix);    % Speichern der aktualisierten Matrix
  end
  matrix_k1=get(h_kaskade1,'userdata');% Lies Matrix der ersten Kaskade
  matrix_k1(1,7)=kas_num2;             % Setze neue Kaskadennummer
  set(h_kaskade1,'userdata',matrix_k1);% Speichere aktuelle Matrix
  matrix_k2=get(h_kaskade2,'userdata');% Lies Matrix der zweiten Kaskade
  matrix_k2(1,7)=kas_num1;             % Setze neue Kaskadennummer
  set(h_kaskade2,'userdata',matrix_k2);% Speichere aktuelle Matrix
  h_push_rueck = findobj('tag',...    % Suche Handle des Pushbuttons
        'rueckgaengig');              % 'rueckgaengig'
  set(h_push_rueck,'userdata',...     % Speichere die getauschten Kaskaden
        data,...                      % in userdata
        'enable','on',...
        'callback','kaskade(''rueckgaengignorm'');');
  string1 = ['H' num2str(kas_num1) '(z)']; % Tausche Kaskadenbeschriftung
  h_text1 = findobj('type','text','tag','h(z)','string',string1);
  string2 = ['H' num2str(kas_num2) '(z)'];
  h_text2 = findobj('type','text','tag','h(z)','string',string2);
  set(h_text1,'string',string2);
  set(h_text2,'string',string1);
  h_ende=findobj('tag','ende');
  h_enable=get(h_ende,'userdata');
  set (h_enable,'enable','on');
   h_system = findobj...              % Finde Pushbutton 'antwort'
    ('tag','antwort');
  matrix = [5 0 0 0 0 0 0; sos];
  set(h_system,'userdata',matrix);   % Speichern in userdata Pushbutton 'antwort'
end                                  % Ende von command_str = changenorm


%-------------- Rueckgaengignorm --------------------------------------------
% Operation tauschen wird ohne Aenderung abgebrochen
if strcmp(command_str,'rueckgaengignorm') % Wenn command_str = rueckgaengig
  h_push_rueck = findobj('tag','rueckgaengig');
                                      % Suche Pushbutton 'rueckgaengig'
  set(h_push_rueck,...                % Setze Pushbutton inaktiv
    'enable','off');
  data = get(h_push_rueck,'userdata');% zuvor getauschte Kaskaden
  kaskade1 = data(1,1);               % Position erste zu tauschende Kaskade
  kaskade2 = data(2,1);               % Position zweite zu tauschende Kaskade
  kas_num1 = data(1,2);               % Nummer erste zu tauschende Kaskade
  kas_num2 = data(2,2);               % Nummer zweite zu tauschende Kaskade
  h_kaskade1 = data(1,3);             % Handle erste zu tauschende Kaskade
  h_kaskade2 = data(2,3);             % Handle zweite zu tauschende Kaskade
  reihe1 = kaskade1+1;                 
  reihe2 = kaskade2+1;
  h_data = findobj('buttondownfcn',...% Objekt, in dem sos-matrix
        'kaskade(''kaskadenorm'');'); % enthalten ist
  matrix = get(h_data(1),'userdata'); % Lies Matrix aus userdata
  matrix_groesse = size(matrix);      % Groesse der Matrix
  reihen = matrix_groesse(1);         % Anzahl der Reihen der Matrix
  spalten = matrix_groesse(2);        % Anzahl der Spalten der Matrix
                                      % Die Koeffizienten beginnen ab Reihe 2
  sos = matrix(2:reihen,:);           % Extrahieren der benoetigten
                                      % Koeffizienten
  hilf = sos(reihe1,:);               % erste zu tauschende Reihe -> Hilf
  sos(reihe1,:) = sos(reihe2,:);      % Reihe2 -> Reihe1
  sos(reihe2,:) = hilf;               % Hilf -> Reihe2
  for handle = h_data'
    matrix = get(handle,'userdata');  % Alte Matrix lesen
    matrix(2:reihen,:) = sos;         % Matrix aktualisieren
    set(handle,'userdata',matrix);    % Aktualisierte Matrix abspeichern
  end


  matrix_k1=get(h_kaskade1,'userdata');% Lies Matrix der ersten Kaskade
  matrix_k1(1,7)=kas_num1;             % Setze neue Kaskadennummer
  set(h_kaskade1,'userdata',matrix_k1);% Speichere aktuelle Matrix
  matrix_k2=get(h_kaskade2,'userdata');% Lies Matrix der zweiten Kaskade
  matrix_k2(1,7)=kas_num2;             % Setze neue Kaskadennummer



  set(h_kaskade2,'userdata',matrix_k2);% Speichere aktuelle Matrix
  string1 = ['H' num2str(kas_num1) '(z)'];% Text der Kaskaden tauschen
  h_text1 = findobj('type','text',...
        'tag','h(z)','string',string1);
  string2 = ['H' num2str(kas_num2) '(z)'];
  h_text2 = findobj('type','text',...
        'tag','h(z)','string',string2);
  set(h_text1,'string',string2);
  set(h_text2,'string',string1);
  h_system = findobj...              % Finde Pushbutton 'antwort'
    ('tag','antwort');
  matrix = [5 0 0 0 0 0 0; sos];
  set(h_system,'userdata',matrix);   % Speichern in userdata Pushbutton 'antwort'
end

%-------------- tausche -----------------------------------------------------
% Zwei vom Benutzer angegebene Kaskaden werden in ihrer Reihenfolge getauscht
if strcmp(command_str,'tausche')    % Wenn command_str = tausche
  h_push_rueck = findobj('tag','rueckgaengig');
                                      % Suche Pushbutton 'Rueckgaengig'
  set(h_push_rueck,...                % Setze Pushbutton inaktiv
    'enable','off');
  h_push_tauschen = findobj...       % Finde Pushbutton 'tauschen'
     ('tag','tauschen');
   set(h_push_tauschen,...            % Setze Pushbutton inaktiv
     'enable','off',...
     'userdata',[0 0 0; 0 0 0]);     % 1.Kaskade pos,num,handle; 2.Kaskade pos,num,handle
  h_enable=findobj('enable','on');  % aktive UIControl
  set (h_enable,'enable','off');
  h_ende=findobj('tag','ende');
  set(h_ende,'userdata',h_enable);
h_slider= findobj('tag','slider');	% Slider für Strukturdarstellung
set (h_slider,'enable','on');
    h_kaskade = findobj...             % Finde Textobjekte 'h(z)'
     ('type','text',...
      'tag','h(z)');
  set(h_kaskade,...                  % Reset Buttondownfcn
     'buttondownfcn','');
  h_line = findobj...                % Finde Verbindungslinien zwischen
     ('type','line',...               % den Kaskaden
      'tag','kaskade3');
  set(h_line,...                     % Reset Buttondownfcn
     'buttondownfcn','');
  h_axes_h=findobj('tag','axes_h(z)');	% Objekte für Überschrift in Kaskaden- und Parallelform
  set (h_axes_h,'buttondownfcn','');		% Reset ButtonDownFcn
  h_figure = findobj('tag','netzwerk');% Finde Figur 'netzwerk'
  set(h_figure,'windowbuttondownfcn',...% Setze Windowbuttondownfcn
     'kaskade(''waehlen1'');');
  uicontrol('style','text',...        % Text-Objekt fuer Kaskadentausch
        'units','normalized',...
        'string','Erste Kaskade auswaehlen',...
        'position',[0.2 0.05 0.8 0.045],...% Position der Ueberschrift
        'tag','kaskadentausch');
end                                   % Ende von command_str = tausche

%-------------- waehlen1 ----------------------------------------------------
% Zwei vom Benutzer angegebene Kaskaden werden in ihrer Reihenfolge getauscht
if strcmp(command_str,'waehlen1')     % Wenn command_str = waehlen1
  h_objekt = gco;                     % Ermittle aktuelles Objekt
  h_figure = findobj('tag','netzwerk');% Finde Figur 'netzwerk'
  h_text = findobj...
    ('tag','kaskadentausch');         % Finde Textobjekt 'kaskadentausch'
  if strcmp(get(h_objekt,'type'),'text') & strcmp(get(h_objekt,'tag'),'h(z)')  % Wenn aktuelles Objekt = Textobjekt Hn(z)
    matrix = get(h_objekt,'userdata');% Lies userdata
    v_text= get(h_figure,'name');     % Fensternamen lesen
    v_text= v_text(size(v_text,2)-18:size(v_text,2));  % Strukturnamen bestimmen
    if strcmp(v_text,'3. kanonischer Form')  % Wenn 3. kanonische Form
      kaskade_nummer = matrix(1,6);   % Kaskadennummer in 1.Reihe, 6.Spalte
    else                              % Wenn normierte 3. kanonische Form
      kaskade_nummer = matrix(1,7);   % Kaskadennummer in 1.Reihe, 7.Spalte
    end
      kaskade_position = matrix(1,1); % Aktuelle Position der Kaskade
    h_push_tauschen = findobj...      % Finde Pushbutton 'tauschen'
      ('tag','tauschen');
    data = get(h_push_tauschen,...    % Lies zu tauschende Kaskaden aus
      'userdata');                    % userdata
    data(1,1) = kaskade_position;     % Erste Kaskade Position
    data(1,2) = kaskade_nummer;       % Erste Kaskade Nummer
    data(1,3) = h_objekt;             % Erste Kaskade Handle
    set(h_objekt,'color','r');        % Zeichenfarbe der Kaskade = Rot
    set(h_figure,'windowbuttondownfcn',...% Setze Windowbuttondownfcn
      'kaskade(''waehlen2'');');      % fuer zweite Kaskade
    set(h_text,'string',...           % Setze String des Textfeldes
      'Zweite Kaskade auswaehlen');
    set(h_push_tauschen,...           % Schreibe erste zu tauschende Kaskade
      'userdata',data);               % in userdata Pushbutton 'tauschen'
  end
  if ~strcmp(get(h_objekt,'type'),'text') & ~strcmp(get(h_objekt,'tag'),'h(z)')  % Wenn kein Textobjekt Hn(z)
    set(h_text,'string',...           % Setze String des Textfeldes
      'Keine Kaskade, bitte Wahl wiederhohlen');
  end
end                                   % Ende von waehlen1

%-------------- waehlen2 ----------------------------------------------------
% Zwei vom Benutzer angegebene Kaskaden werden in ihrer Reihenfolge getauscht
if strcmp(command_str,'waehlen2')     % Wenn zweites Objekt angewaehlt
  h_objekt = gco;                     % Ermittle aktuelles Objekt
  h_figure = findobj('tag','netzwerk');% Finde Figur 'netzwerk'
  h_text = findobj...                 % Finde Textfeld 'kaskadentausch'
    ('tag','kaskadentausch');
  if strcmp(get(h_objekt,'type'),'text') & strcmp(get(h_objekt,'tag'),'h(z)')  % Wenn aktueles Objekt = Textobjekt Hn(z)
     matrix = get(h_objekt,'userdata');% Lies userdata
    v_text= get(h_figure,'name');     % Fensternamen lesen
    v_text= v_text(size(v_text,2)-18:size(v_text,2));  % Strukturnamen bestimmen
    if strcmp(v_text,'3. kanonischer Form')  % Wenn 3. kanonische Form
      set(h_figure,'windowbuttonupfcn',...% Setze Windowbuttonupfcn fuer
        'kaskade(''change'');');      % Tauschvorgang
      kaskade_nummer = matrix(1,6);   % Kaskadennummer in 1.Reihe, 6.Spalte
    else                              % Wenn normierte 3. kanonische Form
      set(h_figure,'windowbuttonupfcn',... % Setze Windowbuttonupfcn fuer
        'kaskade(''changenorm'');');  % Tauschvorgang
      kaskade_nummer = matrix(1,7);   % Kaskadennummer in 1.Reihe, 7.Spalte
    end
    kaskade_position = matrix(1,1);   % Aktuelle Position
    h_push_tauschen = findobj...      % Finde Pushbutton 'tauschen'
      ('tag','tauschen');
    data = get(h_push_tauschen,...    % Lies zu tauschende Kaskaden aus
      'userdata');                    % userdata
    data(2,1) = kaskade_position;     % Aktuelle Position der zweiten Kaskade
    data(2,2) = kaskade_nummer;       % Nummer der zweiten Kaskade
    data(2,3) = h_objekt;             % Zweite Kaskade Handle
    set(h_objekt,'color','r');        % Zeichenfarbe der Kaskade = Rot
    set(h_figure,...
      'windowbuttondownfcn','');      % Reset Windowbuttondownfcn
    delete(h_text);                   % Entferne Textobjekt 'kaskadentausch'
    set(h_push_tauschen,...           % Schreibe zu tauschende Kaskaden in
      'userdata',data);               % userdata des Pushbuttons 'tauschen'
  end                                 % Ende von Textobjekt
  if ~strcmp(get(h_objekt,'type'),'text') & ~strcmp(get(h_objekt,'tag'),'h(z)')% Wenn kein Textobjekt Hn(z)
    set(h_text,'string',...           % Setze String des Textobjektes
      'Keine Kaskade, bitte Wahl wiederhohlen');
  end
end                                   % Ende waehlen2

