function position
% POSITION
% Die Funktion Position uebernimmt die Tastaturabfrage bei Zoom- und Marker-
% funktionen innerhalb von filtant
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
h_check_marker = findobj...         % Finde Radiobutton 'marker_an'
  ('tag','marker_an');
marker_on = get(h_check_marker,...  % Lies Zustand des Radiobuttons
  'value');
char = get(h_fig,'currentcharacter');% Lies aktuelles Zeichen
h_radio_lin = findobj...            % Finde Radiobutton 'filtant_lin'
  ('tag','filtant_lin');
radio_lin = get...                  % 0: Amplitude linear
  (h_radio_lin,'value');            % 1: Amplitude in dB
% Finde Markerlinien
h_line_senkrecht_aus = findobj('tag','marker_senkrecht_aus');
h_line_waagerecht_aus = findobj('tag','marker_waagerecht_aus');
h_line_senkrecht_ein = findobj('tag','marker_senkrecht_ein');
h_line_waagerecht_ein = findobj('tag','marker_waagerecht_ein');
h_axes_ein = findobj...             % Finde Axes Objekt 'eingangsfolge'
  ('tag','eingangsfolge');
h_axes_aus = findobj...             % Finde Axes Objekt 'ausgangsfolge'
  ('tag','ausgangsfolge');
h_radio_aus = findobj...            % Finde Radiobutton 'filtant_aus'
  ('tag','filtant_aus');
nur_aus = get...                    % value = 1 => nur Ausgangsfolge
  (h_radio_aus,'value');
h_pop_fft=findobj('tag','fft');     % Finde Popupmenue 'fft'
bereich = get...                    % bereich = 1 => Zeitbereich darstellen
  (h_pop_fft,'value');              % bereich = 2 => Fouriertransformierte
if marker_on                        % Wenn Marker an
  if strcmp(char,'r')|strcmp(char,'l')
    h_check_marker = findobj...         % Finde Radiobutton 'marker_an'
      ('tag','marker_an');
    h_marker_ein_x = findobj...         % Finde Text-Objekt Eingangsfolge x
      ('tag','marker_ein_x');
    h_marker_ein_y = findobj...         % Finde Text-Objekt Eingangsfolge y
      ('tag','marker_ein_y');
    h_marker_aus_y = findobj...         % Finde Text-Objekt Ausgangsfolge y
      ('tag','marker_aus_y');
    marker_position = get...          % Lies aktuelle Markerposition aus userdata
      (h_marker_ein_x,'userdata');
    if strcmp(char,'r')
      marker_position = marker_position + 1;
    end
    if strcmp(char,'l')
      marker_position = marker_position - 1;
    end
    if (marker_position < 0)
      marker_position = 0;
    end
    if bereich == 1                   % Zeitbereich
      matrix = get(h_check_marker,...     % Lies Ein- und Ausgangsfolge aus
        'userdata');                      % userdata
      zeit = matrix(1,:);                 % Extrahiere Zeitachse
      if (marker_position > max(zeit))
        marker_position = max(zeit);
      end
      eingangsfolge = matrix(2,:);        % Extrahiere Eingangsfolge
      ausgangsfolge = matrix(3,:);        % Extrahiere Ausgangsfolge
      marker_wert_ein = eingangsfolge(marker_position+1);
      marker_wert_aus = ausgangsfolge(marker_position+1);
      set(h_marker_ein_x,...
        'string',marker_position,...
        'userdata',marker_position);
      set(h_marker_ein_y,...
        'string',marker_wert_ein);
      set(h_marker_aus_y,...
        'string',marker_wert_aus);
      x_lim_aus = get(h_axes_aus,'xlim');
      y_lim_aus = get(h_axes_aus,'ylim');
      set(h_line_senkrecht_aus,...
        'xdata',[marker_position marker_position]);
      set(h_line_waagerecht_aus,...
        'ydata',[marker_wert_aus marker_wert_aus]);
      if (nur_aus == 0)                   % Wenn Ein- und Ausgangsfolge
        x_lim_ein = get(h_axes_ein,'xlim');
        y_lim_ein = get(h_axes_ein,'ylim');
        set(h_line_senkrecht_ein,...
          'xdata',[marker_position marker_position]);
        set(h_line_waagerecht_ein,...
          'ydata',[marker_wert_ein marker_wert_ein]);
      end                               % Ende von Ein- und Ausgangsfolge  
    elseif bereich == 2               % FFT
      matrix = get(h_marker_ein_y,...     % Lies Spektrum aus userdata
        'userdata');
      ny = matrix(1,:);                   % Extrahiere Frequenz
      eingang_spektrum = matrix(2,:);     % Extrahiere Spektrum des Eingangssignals
      ausgang_spektrum = matrix(3,:);     % Extrahiere Spektrum des Aingangssignals
      eingang_spek_db = matrix(4,:);      % Extrahiere Spektrum des Eingangssignals dB
      ausgang_spek_db = matrix(5,:);      % Extrahiere Spektrum des Aingangssignals dB
      marker_index = marker_position;
      if (marker_index < 0)
        marker_index = 0;
      end
      if (marker_index > (length(ny)-1))
        marker_index = length(ny)-1;
      end
      marker_position = 0.5 / length(ny) * (marker_index);
      if (radio_lin == 1)                 % Amplitude linear
        marker_wert_ein = eingang_spektrum(marker_index+1);
        marker_wert_aus = ausgang_spektrum(marker_index+1);
        string_ein = [num2str(marker_wert_ein)];
        string_aus = [num2str(marker_wert_aus)];
      elseif (radio_lin == 0)             % Amplitude in dB
        marker_wert_ein = eingang_spek_db(marker_index+1);
        marker_wert_aus = ausgang_spek_db(marker_index+1);
        string_ein = [num2str(marker_wert_ein) ' dB'];
        string_aus = [num2str(marker_wert_aus) ' dB'];
      end                                 % Ende von Amplitude linear oder in dB
      set(h_marker_ein_x,...
        'string',marker_position,...
        'userdata',marker_index);
      set(h_marker_ein_y,...
        'string',string_ein);
      set(h_marker_aus_y,...
        'string',string_aus);
      x_lim_aus = get(h_axes_aus,'xlim');
      y_lim_aus = get(h_axes_aus,'ylim');
      set(h_line_senkrecht_aus,...
        'xdata',[marker_position marker_position],...
        'ydata',y_lim_aus)
      set(h_line_waagerecht_aus,...
        'xdata',x_lim_aus,...
        'ydata',[marker_wert_aus marker_wert_aus]);
      if (nur_aus == 0)                   % Wenn Ein- und Ausgangsfolge
        x_lim_ein = get(h_axes_ein,'xlim');
        y_lim_ein = get(h_axes_ein,'ylim');
        set(h_line_senkrecht_ein,...
          'xdata',[marker_position marker_position],...
          'ydata',y_lim_ein)
        set(h_line_waagerecht_ein,...
          'xdata',x_lim_ein,...
          'ydata',[marker_wert_ein marker_wert_ein]);
      end                                 % Ende von Ein- und Ausgangsfolge  
    end                               % Ende von Zeit oder FFT
  end                                 % Ende von 'l' oder 'r'
end                                   % Ende von Marker an
if zoom_on                            % Wenn Zoom an
h_filterantwort = findobj...        % Finde Pushbutton 'filterung'
    ('tag','filterung');
  sys_data = get...                   % Ermittle Systemdaten aus userdata
    (h_filterantwort,'userdata');     % Aenderung der Systemdaten durch Funktiongenerator
  x = sys_data(1,:);                  % Eingangsfolge aus Systemdaten
  fft_laenge = sys_data(2,1);     % FFT-Laenge = 2.Reihe, 1.Spalte
  h_pop_fft=findobj('tag','fft');     % Finde Popupmenue 'fft'
  bereich = get...                    % bereich = 1 => Zeitbereich darstellen
    (h_pop_fft,'value');              % bereich = 2 => Fouriertransformierte
  if (bereich == 1)
    max_zeit = fft_laenge;
  else
    max_zeit = 0.5;
  end
  h_text_ein = findobj...             % Finde Text-Objekt Ueberschrift fuer
    ('tag','text_ein');               % Eingangsfolge
  h_text_aus = findobj...             % Finde Text-Objekt Ueberschrift fuer
    ('tag','text_aus');               % Ausgangsfolge
  h_amp_ein = findobj...              % Finde Text-Objekt Ueberschrift fuer
    ('tag','text_amp_ein');           % Eingangsfolge
  h_amp_aus = findobj...              % Finde Text-Objekt Ueberschrift fuer
    ('tag','text_amp_aus');           % Ausgangsfolge
  h_x_aus = findobj...                % Finde Text-Objekt Ueberschrift fuer
    ('tag','text_x_aus');             % Ausgangsfolge
  x_lim_aus = get(h_axes_aus,'xlim');
  y_lim_aus = get(h_axes_aus,'ylim');
  x_lim_ein = get(h_axes_ein,'xlim');
  y_lim_ein = get(h_axes_ein,'ylim');
  if strcmp(char,'+')                 % Wenn Taste + betaetigt
    x_lim_aus = x_lim_aus ./ 2;
    y_lim_aus = y_lim_aus ./ 2;
    x_lim_ein = x_lim_ein ./ 2;
    y_lim_ein = y_lim_ein ./ 2;
  elseif strcmp(char,'-')
    x_lim_aus = x_lim_aus .* 2;
    y_lim_aus = y_lim_aus .* 2;
    x_lim_ein = x_lim_ein .* 2;
    y_lim_ein = y_lim_ein .* 2;
if (x_lim_aus(2) > max_zeit)
      x_lim_aus(2) = x_lim_aus(2) - (x_lim_aus(2) - max_zeit);
      x_lim_ein(2) = x_lim_ein(2) - (x_lim_ein(2) - max_zeit);
    end
    if (x_lim_aus(1) < 0)
      x_lim_aus(1) = x_lim_aus(1) - x_lim_aus(1);
      x_lim_ein(1) = x_lim_ein(1) - x_lim_ein(1);
    end
  elseif strcmp(char,'2')
    y_lim_aus = y_lim_aus - (abs(y_lim_aus(2)-y_lim_aus(1)))/10;
    y_lim_ein = y_lim_ein - (abs(y_lim_ein(2)-y_lim_ein(1)))/10;
  elseif strcmp(char,'8')
    y_lim_aus = y_lim_aus + (abs(y_lim_aus(2)-y_lim_aus(1)))/10;
    y_lim_ein = y_lim_ein + (abs(y_lim_ein(2)-y_lim_ein(1)))/10;
  elseif strcmp(char,'4')
    x_lim_aus = x_lim_aus - (abs(x_lim_aus(2)-x_lim_aus(1)))/10;
    x_lim_ein = x_lim_ein - (abs(x_lim_ein(2)-x_lim_ein(1)))/10;
    if (x_lim_aus(1) < 0)
      x_lim_aus = x_lim_aus - x_lim_aus(1);
      x_lim_ein = x_lim_ein - x_lim_ein(1);
    end
  elseif strcmp(char,'6')
    x_lim_aus = x_lim_aus + (abs(x_lim_aus(2)-x_lim_aus(1)))/10;
    x_lim_ein = x_lim_ein + (abs(x_lim_ein(2)-x_lim_ein(1)))/10;
    if (x_lim_aus(2) > max_zeit)
      x_lim_aus = x_lim_aus - (x_lim_aus(2) - max_zeit);
      x_lim_ein = x_lim_ein - (x_lim_ein(2) - max_zeit);
    end
  end                                 % Ende von Tastenabfrage
set(h_axes_ein,...                  % Setze Axes-Grenzwerte auf mit rbbox
   'xlim',x_lim_ein,...               % ausgewaehlten Bereich
   'ylim',y_lim_ein);
  set(h_axes_aus,...
   'xlim',x_lim_aus,...
   'ylim',y_lim_aus);
  maximum = max(y_lim_aus);           % Maximum der Amplitude
  hoehe = maximum + abs(maximum/100); % Senkrechte Position der Ueberschrift
  breite = abs((x_lim_aus(2) - x_lim_aus(1))/2); % Waagerechte Position der Ueberschrift
  breite = breite + x_lim_aus(1);
  set(h_text_aus,...                  % Aktualisiere Position der Ueberschrift
    'position',[breite hoehe]);
  hoehe = (y_lim_aus(2)-y_lim_aus(1))/2 + y_lim_aus(1);
  breite = x_lim_aus(1)-(x_lim_aus(2) - x_lim_aus(1))/8;
  set(h_amp_aus,...                   % Aktualisiere Position der Ueberschrift
    'position',[breite hoehe]);
  if marker_on                        % Wenn Marker an
    set(h_line_senkrecht_aus,...      % Aktualisiere y-Koordinate
      'ydata',y_lim_aus);
    set(h_line_waagerecht_aus,...     % Aktualisiere x-Koordinate
      'xdata',x_lim_aus);
  end                                 % Ende von Marker an
  if (nur_aus == 0)                   % Wenn auch Eingangsfolge
    maximum = max(y_lim_ein);         % Maximum der Amplitude
    hoehe = maximum + abs(maximum/100);% Senkrechte Position der Ueberschrift
    breite = abs((x_lim_ein(2) - x_lim_ein(1))/2); % Waagerechte Position der Ueberschrift
    breite = breite + x_lim_ein(1);
    set(h_text_ein,...                % Aktualisiere Position der Ueberschrift
      'position',[breite hoehe]);
    set(h_x_aus,...                     % Aktualisiere Position der Ueberschrift
      'position',[x_lim_aus(2) y_lim_aus(1)-(y_lim_aus(2)-y_lim_aus(1))/4]);
    hoehe = (y_lim_ein(2)-y_lim_ein(1))/2 + y_lim_ein(1);
    breite = x_lim_aus(1)-(x_lim_aus(2) - x_lim_aus(1))/8;
    set(h_amp_ein,...                 % Aktualisiere Position der Ueberschrift
      'position',[breite hoehe]);
    if marker_on                      % Wenn Marker an
      set(h_line_senkrecht_ein,...    % Aktualisiere y-Koordinate
        'ydata',y_lim_ein);
      set(h_line_waagerecht_ein,...   % Aktualisiere x-Koordinate
        'xdata',x_lim_ein);
    end                               % Ende von Marker an
  elseif (nur_aus == 1)
    set(h_x_aus,...                     % Aktualisiere Position der Ueberschrift
      'position',[x_lim_aus(2) y_lim_aus(1)-(y_lim_aus(2)-y_lim_aus(1))/8]);
  end                                 % Ende von Ein- und Ausgangsfolge
end                                   % Ende von Zoom an
