function zoomfilt(command_str)
% ZOOMFILT
% Die Funktion Zoomfilt stellt Zoomfunktionen fuer filtant zur Verfuegung
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
  h_check_marker = findobj...         % Finde Checkbox 'marker_an'
    ('tag','marker_an');
  marker_on = get(h_check_marker,...  % Lies Zustand der Checkbox
    'value');
  h_fig = findobj...                  % Finde Figure-Objekt 'netzwerk'
    ('tag','netzwerk');
  h_axes_aus = findobj...             % Finde Axes-Objekt fuer Ausgangsfolge
    ('tag','ausgangsfolge');
  h_axes_ein = findobj...             % Finde Axes-Objekt fuer Eingangsfolge
    ('tag','eingangsfolge');
  if zoom_on                          % Wenn Zoom an
    set(h_fig,...
      'keypressfcn','position;');
    if ~marker_on                     % Wenn Marker aus
      set(h_fig,'windowbuttondownfcn',...% Setze Windowbuttondownfcn
        'zoomfilt(''zoom_bereich'');'); % Ausfuerung wenn Maus betaetigt
    end
    axes(h_axes_aus);
  else                                % Wenn Zoom aus
    if ~marker_on                     % Wenn Marker aus
      set(h_fig,...
        'keypressfcn','');
      set(h_fig,'windowbuttondownfcn','');% Ruecksetzen der Windowbuttondownfcn
    end
    set(h_fig,'windowbuttonupfcn','');% Ruecksetzen der Windowbuttonupfcn
    children_ein = get(h_axes_ein,'children'); % Zur Sicherheit,damit
    set(children_ein,'visible','off');% Objekte innerhalb Axes sichtbar bleiben
    set(children_ein,'visible','on');
    children_aus = get(h_axes_aus,'children');
    set(children_aus,'visible','off');
    set(children_aus,'visible','on');
    axes(h_axes_aus);
  end                                 % Ende von Zoom an oder aus
end                                   % Ende von command_str = zoom_on_off


% ------------------ zoom_bereich -------------------------------------------
if strcmp(command_str,'zoom_bereich') % Wenn command_str = zoom_bereich
  mouse_button = get(gcf,'selectiontype');
  if strcmp(mouse_button,'normal')    % Wenn linke Maustaste
     h_objekt = gca;                   % Ermittle aktuelle Objekt
     h_aktuell_objekt=gco;
     objekt=get(h_objekt,'tag');       % Lies Kennzeichnung des Objektes
     
     if (h_objekt==h_aktuell_objekt | get (gco,'parent')== h_objekt ) 
        %strcmp(objekt,'eingangsfolge')|strcmp(objekt,'ausgangsfolge'))
               % Wenn Objekt = Axes-Objekt 'eingangsfolge' oder 'ausgangsfolge
      h_fig = findobj...
         ('tag','netzwerk');
      koordinate=get(h_objekt,'currentpoint');% Ermittle aktuelle Mausposition innerhalb Axes
      x_pos = koordinate(1,1);        % Extrahiere x-Koordinate
      y_pos = koordinate(1,2);        % Extrahiere y-Koordinate
      axes(h_objekt);                 % Umschalten auf aktuelles Axes-Objekt
      h_axes_aus = findobj...         % Finde Axes-Objekt fuer Ausgangsfolge
        ('tag','ausgangsfolge');
      h_axes_ein = findobj...         % Finde Axes-Objekt fuer Eingangsfolge
        ('tag','eingangsfolge');
      h_text_ein = findobj...         % Finde Text-Objekt Ueberschrift fuer
        ('tag','text_ein');           % Eingangsfolge
      h_text_aus = findobj...         % Finde Text-Objekt Ueberschrift fuer
        ('tag','text_aus');           % Ausgangsfolge
      h_amp_ein = findobj...          % Finde Text-Objekt Ueberschrift fuer
        ('tag','text_amp_ein');       % Eingangsfolge
      h_amp_aus = findobj...          % Finde Text-Objekt Ueberschrift fuer
        ('tag','text_amp_aus');       % Ausgangsfolge
      h_x_aus = findobj...            % Finde Text-Objekt Ueberschrift fuer
        ('tag','text_x_aus');         % Ausgangsfolge
      koord_fig=get(h_fig,'currentpoint');  
      rect = ([koord_fig 0 0]);       % Ursprungs-Rechteck fuer rbbox
      rbbox(rect,koord_fig);          % Ausfuehrung rbbox bis Maustaste losgelassen
      koord_neu = get(h_objekt,'currentpoint');
      x_diff = koord_neu(1,1)-x_pos;
      y_diff = koord_neu(1,2)-y_pos;
      
      if strcmp(objekt,'eingangsfolge')     % Wenn Eingangsfolge
        x_lim_ein = get...                  % Lies senkrechte Grenzwerte der Eingangsfolge
          (h_axes_ein,'xlim');
        y_lim_ein = get...                  % Lies senkrechte Grenzwerte der Eingangsfolge
          (h_axes_ein,'ylim');
        
        x_pos_neu = x_pos + x_diff;
        y_pos_neu = y_pos + y_diff;
      else                                  % Wenn Ausgangsfolge
        x_lim_aus = get...                  % Lies senkrechte Grenzwerte der Ausgangsfolge
          (h_axes_aus,'xlim');
        y_lim_aus = get...                  % Lies senkrechte Grenzwerte der Ausgangsfolge
          (h_axes_aus,'ylim');
        
        % Berechne aktuelle Axes-Koordinaten des Mauszeigers
        x_pos_neu = x_pos + x_diff;
        y_pos_neu = y_pos + y_diff;
      end                                   % Ende von Ein- oder Ausgangsfolge
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
      if (x_pos_neu == x_pos)|(y_pos_neu == y_pos)
        equal = 1;
      else
        equal = 0;
      end
      if ~equal
        if (x_pos < 0)        % Darstellbaren Zeitbereich einschraenken
          x_pos = 0;
        end
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
        if (x_pos_neu > max_zeit)
          x_pos_neu = max_zeit;
        end
        set(h_axes_ein,...              % Setze Axes-Grenzwerte auf mit rbbox
          'xlim',[x_pos x_pos_neu],...   % ausgewaehlten Bereich
          'ylim',[y_pos y_pos_neu]);
        set(h_axes_aus,...
          'xlim',[x_pos x_pos_neu],...
          'ylim',[y_pos y_pos_neu]);
        h_radio_aus = findobj...        % Finde Radiobutton 'filtant_aus'
          ('tag','filtant_aus');
        nur_aus = get...                % value = 1 => nur Ausgangsfolge
          (h_radio_aus,'value');
        maximum = y_pos_neu;            % Maximum der Amplitude
        hoehe = maximum + abs((maximum-y_pos)/100);% Senkrechte Position der Ueberschrift
        breite = (x_pos_neu - x_pos)/2; % Waagerechte Position der Ueberschrift
        breite = breite + x_pos;
        set(h_text_aus,...              % Aktualisiere Position der Ueberschrift
          'position',[breite hoehe]);
        hoehe_amp = (y_pos_neu-y_pos)/2 + y_pos;
        breite_amp = x_pos-(x_pos_neu - x_pos)/8;
        set(h_amp_aus,...                   % Aktualisiere Position der Ueberschrift
          'position',[breite_amp hoehe_amp]);
        if (nur_aus == 0)               % Wenn auch Eingangsfolge
          set(h_text_ein,...            % Aktualisiere Position der Ueberschrift
            'position',[breite hoehe]);
          set(h_amp_ein,...                   % Aktualisiere Position der Ueberschrift
            'position',[breite_amp hoehe_amp]);
          set(h_x_aus,...                     % Aktualisiere Position der Ueberschrift
            'position',[x_pos_neu y_pos-(y_pos_neu-y_pos)/4]);
        elseif (nur_aus == 1)
          set(h_x_aus,...                     % Aktualisiere Position der Ueberschrift
            'position',[x_pos_neu y_pos-(y_pos_neu-y_pos)/8]);
        end                             % Ende von Ein- und Ausgangsfolge
      end                             % Ende von ~equal
    end                               % Ende von h_objekt = Ein- oder Ausgangsfolge
  end                                 % Ende von Maustaste betaetigt
end                                   % Ende von command_str = zoom_bereich




% ------------------ ursprung -----------------------------------------------
if strcmp(command_str,'ursprung')     % Wenn command_str = ursprung
  h_axes_ein = findobj...             % Finde Axes-Objekt 'eingangsfolge'
    ('tag','eingangsfolge');
  h_axes_aus = findobj...             % Finde Axes-Objekt 'ausgangsfolge'
    ('tag','ausgangsfolge');
  h_push_zoom = findobj...            % Finde Radiobutton 'zoom_an'
    ('tag','zoom_ursprung');
  matrix_lim = get...                 % Lies alte Grenzwerte aus userdata
    (h_push_zoom,'userdata');
  x_lim_ein = matrix_lim(1,:);        % Extrahiere waagerechte Grenzwerte Eingangsfolge
  y_lim_ein = matrix_lim(2,:);        % Extrahiere senkrechte Grenzwerte Eingangsfolge
  x_lim_aus = matrix_lim(3,:);        % Extrahiere waagerechte Grenzwerte Ausgangsfolge
  y_lim_aus = matrix_lim(4,:);        % Extrahiere senkrechte Grenzwerte Ausgangsfolge
  set(h_axes_ein,...                  % Aktualisiere Grenzwerte der Eingangsfolge
    'xlim',x_lim_ein,...
    'ylim',y_lim_ein);
  set(h_axes_aus,...                  % Aktualisiere Grenzwerte der Ausgangsfolge
    'xlim',x_lim_aus,...
    'ylim',y_lim_aus);
  h_text_ein = findobj...             % Finde Text-Objekt Ueberschrift Eingangsfolge
    ('tag','text_ein');
  h_text_aus = findobj...             % Finde Text-Objekt Ueberschrift Ausgangsfolge
    ('tag','text_aus');
  h_amp_ein = findobj...              % Finde Text-Objekt Ueberschrift fuer
    ('tag','text_amp_ein');           % Eingangsfolge
  h_amp_aus = findobj...              % Finde Text-Objekt Ueberschrift fuer
    ('tag','text_amp_aus');           % Ausgangsfolge
  h_x_aus = findobj...                % Finde Text-Objekt Ueberschrift fuer
    ('tag','text_x_aus');             % Ausgangsfolge
  maximum = max(y_lim_ein);           % Maximum der Amplitude
  hoehe = maximum + abs(maximum/100); % Senkrechte Position der Ueberschrift
  breite=(x_lim_ein(2)-x_lim_ein(1))/2;% Waagerechte Position der Ueberschrift
  set(h_text_ein,...                  % Aktualisiere Position der Ueberschrift
    'position',[breite hoehe]);
  hoehe_amp = (y_lim_aus(2)-y_lim_aus(1))/2 + y_lim_aus(1);
  breite_amp = x_lim_aus(1)-breite/4;
  set(h_amp_aus,...                   % Aktualisiere Position der Ueberschrift
    'position',[breite_amp hoehe_amp]);
  set(h_x_aus,...                     % Aktualisiere Position der Ueberschrift
    'position',[x_lim_aus(2) y_lim_aus(1)-(y_lim_aus(2)-y_lim_aus(1))/4]);
  hoehe_amp = (y_lim_ein(2)-y_lim_ein(1))/2 + y_lim_ein(1);
  breite_amp = x_lim_ein(1)-breite/4;
  set(h_amp_ein,...                   % Aktualisiere Position der Ueberschrift
    'position',[breite_amp hoehe_amp]);
  maximum = max(y_lim_aus);           % Maximum der Amplitude
  hoehe = maximum + abs(maximum/100); % Senkrechte Position der Ueberschrift
  breite=(x_lim_aus(2)-x_lim_aus(1))/2;% Waagerechte Position der Ueberschrift
  set(h_text_aus,...                  % Aktualisiere Position der Ueberschrift
    'position',[breite hoehe]);
  h_check_marker = findobj...         % Finde Radiobutton 'marker_an'
    ('tag','marker_an');
  marker_on = get(h_check_marker,...  % Lies Zustand der Checkbox
    'value');
  if marker_on == 1                   % Wenn Marker eingeschaltet
    h_line_senkrecht_aus = findobj('tag','marker_senkrecht_aus');
    h_line_waagerecht_aus = findobj('tag','marker_waagerecht_aus');
    h_line_senkrecht_ein = findobj('tag','marker_senkrecht_ein');
    h_line_waagerecht_ein = findobj('tag','marker_waagerecht_ein');
    set(h_line_senkrecht_aus,...      % Aktualisiere y-Koordinate
      'ydata',y_lim_aus);
    set(h_line_waagerecht_aus,...     % Aktualisiere x-Koordinate
      'xdata',x_lim_aus);
    h_radio_aus = findobj...          % Finde Radiobutton 'filtant_aus'
      ('tag','filtant_aus');
    nur_aus = get...                  % value = 1 => nur Ausgangsfolge
      (h_radio_aus,'value');
    if (nur_aus == 0)                 % Wenn Ein- und Ausgangsfolge
      set(h_line_senkrecht_ein,...    % Aktualisiere y-Koordinate
        'ydata',y_lim_ein);
      set(h_line_waagerecht_ein,...   % Aktualisiere x-Koordinate
        'xdata',x_lim_ein);
    end                               % Ende von Ein- und Ausgangsfolge
  end                                 % Ende von Marker an
  axes(h_axes_aus);
end                                   % Ende von zoom_ursprung
