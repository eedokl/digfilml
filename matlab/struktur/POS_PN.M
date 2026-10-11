function pos_pn
% POS_PN
% Die Funktion Position uebernimmt die Tastaturabfrage bei Zoom- und Marker-
% funktionen innerhalb von pn_darst
%
% ------------------- Funktions Header --------------------------------------
% Autor:               Jörg Rose / Roman Ußkurat
% Erstellungsdatum:    7-10/97
% Version:             MATLAB Version 5 / Student Edition
% 
% Betreuer: Prof. Dr.-Ing. Stark
%

% ------------------------- Globale Variablen -------------------------------

h_fig = findobj('tag','netzwerk');
h_check_zoom = findobj...           % Finde Radiobutton 'zoom_an'
  ('tag','zoom_an');
zoom_on = get(h_check_zoom,...      % Lies Zustand des Radiobuttons
  'value');
char = get(h_fig,'currentcharacter');% Lies aktuelles Zeichen
h_axes_pn = findobj...                % Finde Axes Objekt 'pn_diagramm'
  ('tag','pn_diagramm');
if zoom_on                            % Wenn Zoom an
  h_text_real = findobj...            % Finde Text-Objekt Beschriftung reale Achse
    ('tag','text_real');               
  h_text_im = findobj...              % Finde Text-Objekt Beschriftung imaginaere Achse
    ('tag','text_im');               
  h_text_rech = findobj...            % Finde Text-Objekt Beschriftung reale Achse
    ('tag','rech_text');               
  h_text_quant = findobj...              % Finde Text-Objekt Beschriftung imaginaere Achse
    ('tag','quant_text');               
  x_lim = get(h_axes_pn,'xlim');
  y_lim = get(h_axes_pn,'ylim');
  if strcmp(char,'+')                 % Wenn Taste + betaetigt
    x_lim = x_lim ./ 2;
    y_lim = y_lim ./ 2;
  elseif strcmp(char,'-')
    x_lim = x_lim .* 2;
    y_lim = y_lim .* 2;
  elseif strcmp(char,'2')
    y_lim = y_lim - (abs(y_lim(2)-y_lim(1)))/10;
  elseif strcmp(char,'8')
    y_lim = y_lim + (abs(y_lim(2)-y_lim(1)))/10;
  elseif strcmp(char,'4')
    x_lim = x_lim - (abs(x_lim(2)-x_lim(1)))/10;
  elseif strcmp(char,'6')
    x_lim = x_lim + (abs(x_lim(2)-x_lim(1)))/10;
  end                                 % Ende von Tastenabfrage
  set(h_axes_pn,...                   % Setze Axes-Grenzwerte auf mit rbbox
   'xlim',x_lim,...                   % ausgewaehlten Bereich
   'ylim',y_lim);
  minimum = y_lim(1);             % Minimum senkrechter Grenzwert
  hoehe = minimum - (y_lim(2)-y_lim(1))/10;% Senkrechte Position der Ueberschrift
  breite = x_lim(1) + (x_lim(2)-x_lim(1))/2;   % Waagerechte Position der Ueberschrift
  set(h_text_real,...             % Aktualisiere Position Beschriftung reale Achse
    'position',[breite hoehe]);
  breite = x_lim(1)-(x_lim(2)-x_lim(1))/8;
  hoehe = (y_lim(2)-y_lim(1))/2 + y_lim(1);
  set(h_text_im,...               % Aktualisiere Position Beschriftung imaginaere Achse
    'position',[breite hoehe]);
  hoehe = minimum - 0.2*abs(y_lim(2)-y_lim(1));
  breite = x_lim(1);
  links = breite + 0.3 * abs(x_lim(2)-x_lim(1));
  set(h_text_rech,...             % Aktualisiere Position Beschriftung reale Achse
    'position',[breite hoehe]);
  set(h_text_quant,...             % Aktualisiere Position Beschriftung reale Achse
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
end                                   % Ende von Zoom an
