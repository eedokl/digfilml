function paralle(command_str)
% PARALLE
%
% Die Funktion stellt die innere Struktur eines Kaskadenblockes
% in erster kanonischer Form dar
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
a=a';b=b';


%-------------- Kaskade -----------------------------------------------------
if strcmp(command_str,'kaskade')    % Wenn command_str = kaskade
  h_figure = findobj('tag','netzwerk'); % Finde Figur 'netzwerk'
  h_children = get(h_figure,'children');% Ermittle Nachkommen von 'netzwerk'

 ui_objekte= findobj(h_figure,'type','uicontrol','visible','on');	% alle UiControl-Objekte, die sichtbar sind
  set (ui_objekte,'visible','off'),		% unsichtbar setzen
  h_enable= findobj('tag','ende');		% Objekt zur Speicherung dieser Handle-Liste
  set (h_enable,'userdata',ui_objekte);	% speichern der vorher sichtbaren UiControl-Objekte

  h_slider=findobj('tag','slider'); % Finde waagerechten slider
  set(h_slider,'visible','off');    % Setze Slider unsichtbar
  h_slidery=findobj('tag','slidery');% Finde senkrechten slider 
  set(h_slidery,'visible','off');  % Setze Slider unsichtbar 
  h_objekt = gco;                   % Ermittle angeklicktes Objekt
  matrix = get(h_objekt,'userdata');% Lies userdata
  kaskade_nummer = matrix(1,6);     % Kaskadennummer in 1.Reihe, 6.Spalte
  koeffizienten = matrix((kaskade_nummer + 2),:);
                                    % Koeffizienten der angewaehlten Kaskade
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
        'paralle(''closed'');');   % Ausfuehrung bei Mausklick in der Figur
  h_axes = findobj('tag','axes');   % Ermittle Handle des Axes-Objektes
  h_children=get(h_axes,'children');% Ermittle Handles der Nachkommen
  set(h_children,'visible','off');  % Setze saemtliche Nachkommen unsichtbar
  h_axes_h=findobj('tag','axes_h(z)');	% Objekte für Überschrift in Kaskaden- und Parallelform
  set (h_axes_h,'visible','off');	% wenn vorhanden, unsichtbar setzen
  h_uicontrol = findobj('tag','change');% Handles der uicontrol-Objekte
  for handle = h_uicontrol'
    set(handle,'visible','off');    % Alle uicontrol-Objekte unsichtbar
  end  
  x_lim_old = get(h_axes,'xlim');   % Sichere alte Begrenzung x-Achse
  y_lim_old = get(h_axes,'ylim');   % Sichere alte Begrenzung y-Achse
  set(h_axes,'userdata',[x_lim_old y_lim_old]);
  screensize = get(0,'screensize'); % Ermittle Bildschirmaufloesung
  width = screensize(3);            % Breite des Bildschirms
  height = screensize(4);           % Hoehe des Bildschirms
  x_lim = [-40 40];                 % Festsetzen der waagerechten Grenzwerte
  y_lim = x_lim .*(height/width);   % Anpassen der senkrechten Grenzwerte
  set(h_axes,'ylim',y_lim,'xlim',x_lim);
  axes(h_axes);
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
  end     % Ende for n = 0:2

% -------------- Koeffizientenausgabe ---------------------------------------
% Wenn Text 'Hn(z)' angeklickt wird, erfolgt die Ausgabe der Koeffizienten
% von 'Hn(z)'
  farbe = [0.752 0.752 0.752];  % Hintergrundfarbe definieren
  uicontrol('style','frame',...     % Rahmen fuer Koeffizientenausgabe
        'units','normalized',...    % Normalisierte Masseinheit
        'backgroundcolor',farbe,...
        'position',[0.41 0.05 0.38 0.188],... % Koordinaten
        'tag','koeffizient');       % Bezeichnung = koeffizient

  uicontrol('style','text',...      % Textobjekt
        'units','normalized',...    % Normalisierte Masseinheit
        'string','a2 =',...         % Auszugebender Text
        'backgroundcolor',farbe,...
        'position',[0.42 0.055 0.07 0.045],...% Koordinaten
        'tag','koeffizient');       % Bezeichnung = koeffizient
  uicontrol('style','text',...      % Textobjekt
        'units','normalized',...    % Normalisierte Masseinheit
        'string','a1 =',...         % Auszugebender Text
        'backgroundcolor',farbe,...
        'position',[0.42 0.1 0.07 0.045],...  % Koordinaten
        'tag','koeffizient');       % Bezeichnung = koeffizient
  uicontrol('style','text',...      % Textobjekt
        'units','normalized',...    % Normalisierte Masseinheit
        'string','a0 =',...         % Auszugebender Text
        'backgroundcolor',farbe,...
        'position',[0.42 0.145 0.07 0.045],...% Koordinaten
        'tag','koeffizient');       % Bezeichnung = koeffizient
  uicontrol('style','text',...      % Textobjekt
        'units','normalized',...    % Normalisierte Masseinheit
        'string','b2 =',...         % Auszugebender Text
        'backgroundcolor',farbe,...
        'position',[0.6 0.055 0.07 0.045],... % Koordinaten
        'tag','koeffizient');       % Bezeichnung = koeffizient
  uicontrol('style','text',...      % Textobjekt
        'units','normalized',...    % Normalisierte Masseinheit
        'string','b1 =',...         % Auszugebender Text
        'backgroundcolor',farbe,...
        'position',[0.6 0.1 0.07 0.045],...
        'tag','koeffizient');       % Bezeichnung = koeffizient
  uicontrol('style','text',...      % Textobjekt
        'units','normalized',...    % Normalisierte Masseinheit
        'string','b0 =',...         % Auszugebender Text
        'backgroundcolor',farbe,...
        'position',[0.6 0.145 0.07 0.045],...
        'tag','koeffizient');       % Bezeichnung = koeffizient

  string = ['Koeffizienten H' num2str(kaskade_nummer) '(z):'];
                                    % Ueberschrift des Rahmens
  uicontrol('style','text',...      % Text-Objekt fuer Ueberschrift
        'units','normalized',...
        'string',string,...
        'backgroundcolor',farbe,...
        'position',[0.44 0.19 0.28 0.045],...% Position der Ueberschrift
        'tag','koeffizient');

  uicontrol('style','edit',...      % Editierbarer Text
        'units','normalized',...
        'string',num2str(a2),...    % Koeffizient a2: Zahl -> String
        'backgroundcolor',farbe,...
        'position',[0.47 0.055 0.11 0.045],...
        'tag','koeffizient');
  uicontrol('style','edit',...
        'units','normalized',...
        'string',num2str(a1),...
        'backgroundcolor',farbe,...
        'position',[0.47 0.1 0.11 0.045],...
        'tag','koeffizient');
  uicontrol('style','edit',...
        'units','normalized',...
        'string',num2str(a0),...
        'backgroundcolor',farbe,...
        'position',[0.47 0.145 0.11 0.045],...
        'tag','koeffizient');
  uicontrol('style','edit',...
        'units','normalized',...
        'string',num2str(b2),...
        'backgroundcolor',farbe,...
        'position',[0.67 0.055 0.11 0.045],...
        'tag','koeffizient');
  uicontrol('style','edit',...
        'units','normalized',...
        'string',num2str(b1),...
        'backgroundcolor',farbe,...
        'position',[0.67 0.1 0.11 0.045],...
        'tag','koeffizient');
  uicontrol('style','edit',...
        'units','normalized',...
        'string',num2str(b0),...
        'backgroundcolor',farbe,...
        'position',[0.67 0.145 0.11 0.045],...
        'tag','koeffizient');
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
  h_kaskade = findobj('tag','koeffizient'); % Objekte mit Bezeichnung 'koeffizient'
  delete(h_kaskade);                 % Entferne diese Objekte
  h_children = get(gca,'children'); % Handles der Nachkommen von Axes
  set(h_children,'visible','on');     % Setze Nachkommen = sichtbar
  h_axes_h=findobj('tag','axes_h(z)');	% Objekte für Überschrift in Kaskaden- und Parallelform
  set (h_axes_h,'visible','on');		% wenn vorhanden, sichtbar setzen
h_axes_h=findobj('tag','axes_h(z)','type','axes');	% Axes-Objekte für Überschrift 
  set (h_axes_h,'visible','off');		% wenn vorhanden, sichtbar setzen
  limit = get(h_axes,'userdata');   % Lies alte Achsenbegrenzung
  x_lim = [limit(1) limit(2)];      % Aufteilung nach x und y
  y_lim = [limit(3) limit(4)];
  set(h_axes,'ylim',y_lim,'xlim',x_lim);% Uebernahme der alten Werte
  h_figure = findobj('tag','netzwerk'); % Finde Figur 'netzwerk'
  h_enable= findobj('tag','ende');	% Objekt zur Speicherung dieser Handle-Liste
  ui_objekte = get(h_enable,'userdata');	% laden der vorher sichtbaren UiControl-Objekte
  set (ui_objekte,'visible','on');		% sichtbar setzen
  h_slidery = findobj('tag','slidery'); % Finde senkrechten slider
  set(h_slidery,'visible','off');       % Setze slider unsichtbar
  h_quit = findobj('tag','quit');       % Finde Pushbutton 'quit'
  set(h_quit,'enable','off');           % Setze Pushbutton inaktiv
  
end                                     % Ende strcmp(command_str,'closed')
