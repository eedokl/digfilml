function zoompn(command_str)
% ZOOMPN
% Die Funktion Zoomfilt stellt Zoomfunktionen fuer pn_darst zur Verfuegung
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

% ------------------ zoom_on_off --------------------------------------------
if strcmp(command_str,'zoom_on_off')  % Wenn command_str = zoom_on_off
  h_check_zoom = findobj...           % Finde Checkbox 'zoom_an'
    ('tag','zoom_an');
  zoom_on = get(h_check_zoom,...      % Lies Zustand der Checkbox
    'value');
  h_fig = findobj...                  % Finde Figure-Objekt 'netzwerk'
    ('tag','netzwerk');
  h_axes_pn = findobj...             % Finde Axes-Objekt fuer Ausgangsfolge
    ('tag','pn_diagramm');
  if zoom_on                          % Wenn Zoom an
    set(h_fig,...
      'keypressfcn','pos_pn;');
    set(h_fig,'windowbuttondownfcn',...% Setze Windowbuttondownfcn
      'zoompn(''zoom_bereich'');'); % Ausfuerung wenn Maus betaetigt
    axes(h_axes_pn);
  else                                % Wenn Zoom aus
    h_check_marker = findobj...         % Finde Radiobutton 'marker_an'
      ('tag','marker_an');
    marker_on = get(h_check_marker,...  % Lies Zustand des Radiobuttons
      'value');
    set(h_fig,...
      'keypressfcn','');
    if ~marker_on                     % Wenn Marker aus
      set(h_fig,'windowbuttondownfcn','');% Ruecksetzen der Windowbuttondownfcn
    end
    set(h_fig,'windowbuttonupfcn','');% Ruecksetzen der Windowbuttonupfcn
    children_pn = get(h_axes_pn,'children');
    set(children_pn,'visible','off');
    set(children_pn,'visible','on');
  end                                 % Ende von Zoom an oder aus
end                                   % Ende von command_str = zoom_on_off


% ------------------ zoom_bereich -------------------------------------------
if strcmp(command_str,'zoom_bereich') % Wenn command_str = zoom_bereich
  mouse_button = get(gcf,'selectiontype');
  h_check_zoom = findobj...           % Finde Checkbox 'zoom_an'
    ('tag','zoom_an');
  zoom_on = get(h_check_zoom,...      % Lies Zustand der Checkbox
    'value');
  if strcmp(mouse_button,'normal')& zoom_on % Wenn linke Maustaste
    h_objekt = gco;                   % Ermittle aktuelle Objekt
    objekt=get(h_objekt,'tag');       % Lies Kennzeichnung des Objektes
    if (strcmp(objekt,'pn_diagramm')) % Wenn Objekt = Axes-Objekt 'pn_diagramm'
      h_fig = findobj...
        ('tag','netzwerk');
      koordinate=get(h_objekt,'currentpoint');% Ermittle aktuelle Mausposition innerhalb Axes
      x_pos = koordinate(1,1);        % Extrahiere x-Koordinate
      y_pos = koordinate(1,2);        % Extrahiere y-Koordinate
      axes(h_objekt);                 % Umschalten auf aktuelles Axes-Objekt
      h_axes_pn = findobj...          % Finde Axes-Objekt 'pn_diagramm'
        ('tag','pn_diagramm');
      h_text_real = findobj...        % Finde Text-Objekt Beschrifrung reale Achse
        ('tag','text_real');           
      h_text_im = findobj...          % Finde Text-Objekt Beschriftung imaginaere Achse
        ('tag','text_im');           
      h_text_rech = findobj...        % Finde Text-Objekt Beschrifrung Rechnergenau
        ('tag','rech_text');           
      h_text_quant = findobj...       % Finde Text-Objekt Beschriftung Quantisiert
      ('tag','quant_text');    
      koord_fig = get(h_fig,'currentpoint');
      rect = ([koord_fig 0 0]);   % Ursprungs-Rechteck fuer rbbox
      rbbox(rect,koord_fig);              % Ausfuehrung rbbox bis Maustaste losgelassen
      koord_neu = get(h_objekt,'currentpoint');
      x_diff = koord_neu(1,1)-x_pos;
      y_diff = koord_neu(1,2)-y_pos;

      x_lim = get...                  % Lies senkrechte Grenzwerte der Eingangsfolge
        (h_axes_pn,'xlim');
      y_lim = get...                  % Lies senkrechte Grenzwerte der Eingangsfolge
        (h_axes_pn,'ylim');
      % Berechne aktuelle Axes-Koordinaten des Mauszeigers
      x_pos_neu = x_pos + x_diff;
      y_pos_neu = y_pos + y_diff;
      if x_pos_neu < x_pos            % Pruefe ob neue x-Koordinate kleiner alte
        hilf = x_pos_neu;
        x_pos_neu = x_pos;
        x_pos = hilf;
      end
      if y_pos_neu < y_pos            % Pruefe ob neue y-Koordinate kleiner alte
        hilf = y_pos_neu;
        y_pos_neu = y_pos;
        y_pos = hilf;
      end
      if x_pos == x_pos_neu
        x_pos_neu = x_pos_neu + 0.1;
      end
      if y_pos == y_pos_neu
        y_pos_neu = y_pos_neu + 0.1;
      end
      set(h_axes_pn,...               % Setze Axes-Grenzwerte auf mit rbbox
       'xlim',[x_pos x_pos_neu],...   % ausgewaehlten Bereich
       'ylim',[y_pos y_pos_neu]);
      minimum = y_pos;             % Minimum senkrechter Grenzwert
      hoehe = minimum - (y_pos_neu-y_pos)/10;% Senkrechte Position der Ueberschrift
      breite = x_pos + (x_pos_neu-x_pos)/2;   % Waagerechte Position der Ueberschrift
      set(h_text_real,...             % Aktualisiere Position Beschriftung reale Achse
        'position',[breite hoehe]);
      breite = x_pos-(x_pos_neu-x_pos)/8;
      hoehe = (y_pos_neu-y_pos)/2 + y_pos;
      set(h_text_im,...               % Aktualisiere Position Beschriftung imaginaere Achse
        'position',[breite hoehe]);
      minimum = y_pos;
      hoehe = minimum - 0.2*abs(y_pos_neu - y_pos);
      breite = x_pos;
      links = breite + 0.3*abs(x_pos_neu - x_pos);
      set(h_text_rech,...               % Aktualisiere Position Beschriftung Rechnergenau
        'position',[breite hoehe]);
      set(h_text_quant,...              % Aktualisiere Position Beschriftung Quantisiert
        'position',[links hoehe]);
      % Finde Markerlinien
      h_line_senkrecht_unqu = findobj('tag','marker_senkrecht_unqu');
      h_line_waagerecht_unqu = findobj('tag','marker_waagerecht_unqu');
      h_line_senkrecht_quant = findobj('tag','marker_senkrecht_quant');
      h_line_waagerecht_quant = findobj('tag','marker_waagerecht_quant');
      if ~isempty(h_line_senkrecht_unqu) % Pruefe ob unquantisierte Markerlinie exestiert
        set(h_line_senkrecht_unqu,...
          'ydata',[y_pos y_pos_neu]);
        set(h_line_waagerecht_unqu,...
          'xdata',[x_pos x_pos_neu]);
      end
      if ~isempty(h_line_senkrecht_quant)% Pruefe ob quantisierte Markerlinie exestiert
        set(h_line_senkrecht_quant,...
          'ydata',[y_pos y_pos_neu]);
        set(h_line_waagerecht_quant,...
          'xdata',[x_pos x_pos_neu]);
      end
    end                               % Ende von h_objekt = 'pn_diagramm'
  end                                 % Ende von Maustaste betaetigt
  if strcmp(mouse_button,'alt')       % Wenn rechte Maustaste
    markerpn('set');
  end
end                                   % Ende von command_str = zoom_bereich




% ------------------ ursprung -----------------------------------------------
if strcmp(command_str,'ursprung')     % Wenn command_str = ursprung
  h_axes_pn = findobj...              % Finde Axes-Objekt 'pn_diagramm'
    ('tag','pn_diagramm');
  h_push_zoom = findobj...            % Finde Radiobutton 'zoom_an'
    ('tag','zoom_ursprung');
  matrix_lim = get...                 % Lies alte Grenzwerte aus userdata
    (h_push_zoom,'userdata');
  x_lim = matrix_lim(1,:);            % Extrahiere waagerechte Grenzwerte
  y_lim = matrix_lim(2,:);            % Extrahiere senkrechte Grenzwerte
  set(h_axes_pn,...                   % Aktualisiere Grenzwerte 
    'xlim',x_lim,...
    'ylim',y_lim);
  h_text_real = findobj...            % Finde Text-Objekt Beschriftung reale Achse
    ('tag','text_real');
  h_text_im = findobj...              % Finde Text-Objekt Beschriftung imaginaere Achse
    ('tag','text_im');
  minimum = y_lim(1);             % Minimum senkrechter Grenzwert
  hoehe = minimum - (y_lim(2)-y_lim(1))/10;% Senkrechte Position der Ueberschrift
  breite = x_lim(1) + (x_lim(2)-x_lim(1))/2;   % Waagerechte Position der Ueberschrift
  set(h_text_real,...             % Aktualisiere Position Beschriftung reale Achse
    'position',[breite hoehe]);
  breite = x_lim(1)-(x_lim(2)-x_lim(1))/8;
  hoehe = (y_lim(2)-y_lim(1))/2 + y_lim(1);
  set(h_text_im,...               % Aktualisiere Position Beschriftung imaginaere Achse
    'position',[breite hoehe]);
  h_text_rech = findobj...        % Finde Text-Objekt Beschrifrung Rechnergenau
    ('tag','rech_text');           
  h_text_quant = findobj...       % Finde Text-Objekt Beschriftung Quantisiert
    ('tag','quant_text');           
  minimum = y_lim(1);
  hoehe = minimum - 0.2*abs(y_lim(2) - y_lim(1));
  breite = x_lim(1);
  links = breite + 0.3*abs(x_lim(2) - x_lim(1));
  set(h_text_rech,...               % Aktualisiere Position Beschriftung Rechnergenau
    'position',[breite hoehe]);
  set(h_text_quant,...              % Aktualisiere Position Beschriftung Quantisiert
    'position',[links hoehe]);
  % Finde Markerlinien
  h_line_senkrecht_unqu = findobj('tag','marker_senkrecht_unqu');
  h_line_waagerecht_unqu = findobj('tag','marker_waagerecht_unqu');
  h_line_senkrecht_quant = findobj('tag','marker_senkrecht_quant');
  h_line_waagerecht_quant = findobj('tag','marker_waagerecht_quant');
  if ~isempty(h_line_senkrecht_unqu) % Pruefe ob unquantisierte Markerlinie exestiert
    set(h_line_senkrecht_unqu,...
      'ydata',y_lim);
    set(h_line_waagerecht_unqu,...
      'xdata',x_lim);
  end
  if ~isempty(h_line_senkrecht_quant)% Pruefe ob quantisierte Markerlinie exestiert
    set(h_line_senkrecht_quant,...
      'ydata',y_lim);
    set(h_line_waagerecht_quant,...
      'xdata',x_lim);
  end
  axes(h_axes_pn);
end                                    % Ende von zoom_ursprung
