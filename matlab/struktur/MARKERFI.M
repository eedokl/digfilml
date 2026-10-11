function markerfi(command_str)
% MARKERFI
% Die Funktion Markerfi stellt Markerfunktionen fuer filtant zur Verfuegung
%
% ------------------- Funktions Header --------------------------------------
% Autor:               Jörg Rose / Roman Ußkurat
% Erstellungsdatum:    7-10/97
% Version:             MATLAB Version 5 / Student Edition
% 
% Betreuer: Prof. Dr.-Ing. Stark
%

% ------------------ marker_on_off --------------------------------------------
if strcmp(command_str,'marker_on_off')% Wenn command_str = marker_on_off
  h_fig = findobj('tag','netzwerk');
  h_check_zoom = findobj...           % Finde Radiobutton 'zoom_an'
    ('tag','zoom_an');
  zoom_on = get(h_check_zoom,...      % Lies Zustand des Radiobuttons
    'value');
  h_radio_lin = findobj...            % Finde Radiobutton 'filtant_lin'
    ('tag','filtant_lin');
  radio_lin = get...                  % 0: Amplitude linear
    (h_radio_lin,'value');            % 1: Amplitude in dB
  h_check_marker = findobj...         % Finde Radiobutton 'marker_an'
    ('tag','marker_an');
  marker_on = get(h_check_marker,...  % Lies Zustand des Radiobuttons
    'value');
  h_marker = findobj...               % Finde Markerspezifische Objekte
    ('tag','marker');
  h_marker_ein_x = findobj...         % Finde Text-Objekt Eingangsfolge x
    ('tag','marker_ein_x');
  h_marker_ein_y = findobj...         % Finde Text-Objekt Eingangsfolge y
    ('tag','marker_ein_y');
  h_marker_aus_y = findobj...         % Finde Text-Objekt Ausgangsfolge y
    ('tag','marker_aus_y');
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
    set(h_marker,...                  % Setze Marker-Objekte sichtbar
      'visible','on');
    set(h_marker_ein_x,...            % Setze Text-Objekt sichtbar
      'visible','on');
    set(h_marker_ein_y,...            % Setze Text-Objekt sichtbar
      'visible','on');
    set(h_marker_aus_y,...            % Setze Text-Objekt sichtbar
      'visible','on');
    set(h_fig,'windowbuttondownfcn',...
      'markerfi(''set'');');          % Setzen Windowbuttondownfcn
    marker_position = get...          % Lies aktuelle Markerposition aus userdata
      (h_marker_ein_x,'userdata');
    set(h_fig,...                     % Setze keypressfcn = position
      'keypressfcn','position;');     % Ausfuehrung bei Tastendruck
    if (bereich == 1)                 % Zeitbereich darstellen
      matrix = get(h_check_marker,... % Lies Ein- und Ausgangsfolge aus
        'userdata');                  % userdata
      zeit = matrix(1,:);             % Extrahiere Zeitachse
      eingangsfolge = matrix(2,:);    % Extrahiere Eingangsfolge
      ausgangsfolge = matrix(3,:);    % Extrahiere Ausgangsfolge
      marker_wert_ein = eingangsfolge(marker_position+1);
      marker_wert_aus = ausgangsfolge(marker_position+1);
      axes(h_axes_aus);               % Setze aktuelles Axes-Objekt
      pause(0.1);
      x_lim_aus = get(h_axes_aus,'xlim'); % x-Grenzwerte Ausgangsfolge
      y_lim_aus = get(h_axes_aus,'ylim'); % y-Grenzwerte Ausgangsfolge
      line('xdata',[marker_position marker_position],...
        'ydata',y_lim_aus,...         % Senkrechte Markerlinie der Ausgangsfolge
        'erasemode','xor',...
        'color','b',...               % Farbe Blau
        'tag','marker_senkrecht_aus');
      line('xdata',x_lim_aus,...
        'ydata',[marker_wert_aus marker_wert_aus],...
        'erasemode','xor',...         % Waagerechte Markerlinie der Ausgangsfolge
        'color','b',...
        'tag','marker_waagerecht_aus');
      set(h_marker_aus_y,...          % Ausgabe des Wertes der aktuellen
        'string',marker_wert_aus);    % Markerposition
      set(h_marker_ein_x,...
        'string',marker_position);
      set(h_marker_ein_y,...          % Ausgabe des Markerwertes der aktuellen Position
        'string',marker_wert_ein);
      if (nur_aus == 0)               % Ein- und Ausgangsfolge
        axes(h_axes_ein);             % Setze aktuelles Axes-Objekt
        pause(0.1);
        x_lim_ein = get(h_axes_ein,'xlim');% Lies x-Grenzwerte Eingangsfolge
        y_lim_ein = get(h_axes_ein,'ylim');% Lies y-Grenzwerte Eingangsfolge
        line('xdata',[marker_position marker_position],...
          'ydata',y_lim_ein,...       % Senkrechte Markerlinie der Eingangsfolge
          'erasemode','xor',...
          'color','b',...
          'tag','marker_senkrecht_ein');
        line('xdata',x_lim_ein,...
          'ydata',[marker_wert_ein marker_wert_ein],...
          'erasemode','xor',...       % Waagerechte Markerlinie der Eingangsfolge
          'color','b',...
          'tag','marker_waagerecht_ein');
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
      marker_index = marker_position; % Zuweisung Position des Markers = Index
      marker_position = 0.5 / length(ny) *  marker_position; % Zugehoerige Markerpsition aus Index berechnen
      marker_wert_ein = eingang_spektrum(marker_index+1);
      marker_wert_aus = ausgang_spektrum(marker_index+1);
      marker_wert_ein_db = eingang_spek_db(marker_index+1);
      marker_wert_aus_db = ausgang_spek_db(marker_index+1);
      axes(h_axes_aus);               % Setze aktuelles Axes-Objekt
      pause(0.1);                       % Pause zum Wechseln des aktuellen Axes-Objektes
      x_lim_aus = get(h_axes_aus,'xlim');% Lies x-Grenzwerte der Ausgangsfolge
      y_lim_aus = get(h_axes_aus,'ylim');% Lies y-Grenzwerte der Ausgangsfolge
      set(h_marker_ein_x,...          % Ausgabe der Markerposition
        'string',marker_position);
      line('xdata',[marker_position marker_position],...
        'ydata',y_lim_aus,...         % Senkrecht Markerlinie der Ausgangsfolge
        'erasemode','xor',...
        'color','b',...
        'buttondownfcn','',... %'markerfi(''catch_fft'');'
        'tag','marker_senkrecht_aus');
      if (radio_lin == 1)             % Amplitude linear
        line('xdata',x_lim_aus,...
          'ydata',[marker_wert_aus marker_wert_aus],...
          'erasemode','xor',...       % Waagerechte Linie der Ausgangsfolge
          'color','b',...
          'tag','marker_waagerecht_aus');
        string_aus = [num2str(marker_wert_aus)];
        string_ein = [num2str(marker_wert_ein)];
      elseif (radio_lin == 0)         % Amplitude in dB
        line('xdata',x_lim_aus,...
          'ydata',[marker_wert_aus_db marker_wert_aus_db],...
          'erasemode','xor',...       % Waagerechte Linie der Ausgangsfolge
          'color','b',...
          'tag','marker_waagerecht_aus');
        string_aus = [num2str(marker_wert_aus_db) ' dB'];
        string_ein = [num2str(marker_wert_ein_db) ' dB'];
      end                             % Ende von Amplitude linear oder in dB
      set(h_marker_aus_y,...          % Ausgabe des Markerwertes der aktuellen Position
        'string',string_aus);
      set(h_marker_ein_y,...          % Ausgabe des Markerwertes an der aktuellen Position
        'string',string_ein);
      if (nur_aus == 0)               % Ein- und Ausgangsfolge
        axes(h_axes_ein);             % Setze aktuelles Axes-Objekt
        pause(0.1);                     % Pause zum Wechseln des aktuellen Axes-Objektes
        x_lim_ein = get(h_axes_ein,'xlim');% Lies x-Grenzwerte der Eingangsfolge
        y_lim_ein = get(h_axes_ein,'ylim');% Lies y-Grenzwerte der Eingangsfolge
        line('xdata',[marker_position marker_position],...
          'ydata',y_lim_ein,...       % Senkrechte Markerlinie der Eingangsfolge
          'erasemode','xor',...
          'color','b',...
          'tag','marker_senkrecht_ein');
        if (radio_lin == 1)             % Amplitude linear
          line('xdata',x_lim_ein,...
            'ydata',[marker_wert_ein marker_wert_ein],...
            'erasemode','xor',...       % Waagerechte Markerlinie der Eingangsfolge
            'color','b',...
            'tag','marker_waagerecht_ein');
        elseif (radio_lin == 0)         % Amplitude in dB
          line('xdata',x_lim_ein,...
            'ydata',[marker_wert_ein_db marker_wert_ein_db],...
            'erasemode','xor',...       % Waagerechte Markerlinie der Eingangsfolge
            'color','b',...
            'tag','marker_waagerecht_ein');
        end                             % Ende von Amplitude linear oder in dB
      end                             % Ende von Ein- und Ausgangsfolge
    end                               % Ende von Bereich = 2
    children_ein = get(h_axes_ein,'children');% Eingefuegt um Sichtbarkeit
    set(children_ein,'visible','off');% noch vorhandener Objekte zu gewaehrleisten
    set(children_ein,'visible','on');
    children_aus = get(h_axes_aus,'children');
    set(children_aus,'visible','off');
    set(children_aus,'visible','on');
  else                                % Wenn Marker aus
    set(h_marker_ein_x,...            % Setze Text-Objekt unsichtbar
      'userdata',0,...                % Ruecksetzen der Markerposition
      'visible','off');
    set(h_marker_ein_y,...            % Setze Text-Objekt unsichtbar
      'visible','off');
    set(h_marker_aus_y,...            % Setze Text-Objekt unsichtbar
      'visible','off');
    set(h_marker,...                  % Setze Marker-Objekte unsichtbar
      'visible','off');
    h_marker_frame = findobj...
      ('tag','marker',...
       'style','frame');
    set(h_marker_frame,...            % Setze Frame-Objekt sichtbar
      'visible','on');
    if zoom_on                        % Wenn Zoom eingeschaltet
      set(h_fig,'windowbuttondownfcn','zoomfilt(''zoom_bereich'');');
    end                               % Ende von Zoom ein
    if ~zoom_on                       % Wenn Zoom aus
      set(h_fig,...
        'keypressfcn','');
      set(h_fig,'windowbuttondownfcn','');
    end
    % Finde und entferne Markerlinien
    h_line = findobj('tag','marker_senkrecht_aus');
    delete(h_line);
    h_line = findobj('tag','marker_waagerecht_aus');
    delete(h_line);
    h_line = findobj('tag','marker_senkrecht_ein');
    delete(h_line);
    h_line = findobj('tag','marker_waagerecht_ein');
    delete(h_line);
    children_ein = get(h_axes_ein,'children');% Eingefuegt um Sichtbarkeit
    set(children_ein,'visible','off');% noch vorhandener Objekte zu gewaehrleisten
    set(children_ein,'visible','on');
    children_aus = get(h_axes_aus,'children');
    set(children_aus,'visible','off');
    set(children_aus,'visible','on');
    axes(h_axes_aus);
  end                                 % Ende von Marker an oder aus
end                                   % Ende von command_str = marker_on_off


% ------------------ set ----------------------------------------------------
if strcmp(command_str,'set')            % Wenn Maus betaetigt
  mouse_button = get(gcf,'selectiontype');
  if strcmp(mouse_button,'alt')      % Wenn rechte Maustaste
    h_pop_fft=findobj('tag','fft');     % Finde Popupmenue 'fft'
    bereich = get...                    % bereich = 1 => Zeitbereich darstellen
      (h_pop_fft,'value');              % bereich = 2 => Fouriertransformierte
    h_radio_aus = findobj...            % Finde Radiobutton 'filtant_aus'
      ('tag','filtant_aus');
    nur_aus = get...                    % value = 1 => nur Ausgangsfolge
      (h_radio_aus,'value');
    h_radio_lin = findobj...            % Finde Radiobutton 'filtant_lin'
      ('tag','filtant_lin');
    radio_lin = get...                  % 0: Amplitude linear
      (h_radio_lin,'value');            % 1: Amplitude in dB
    h_axes_ein = findobj...             % Finde Axes Objekt 'eingangsfolge'
      ('tag','eingangsfolge');
    h_axes_aus = findobj...             % Finde Axes Objekt 'ausgangsfolge'
      ('tag','ausgangsfolge');
    h_check_marker = findobj...         % Finde Radiobutton 'marker_an'
      ('tag','marker_an');
    h_marker_ein_x = findobj...         % Finde Text-Objekt Eingangsfolge x
      ('tag','marker_ein_x');
    h_marker_ein_y = findobj...         % Finde Text-Objekt Eingangsfolge y
      ('tag','marker_ein_y');
    h_marker_aus_y = findobj...         % Finde Text-Objekt Ausgangsfolge y
      ('tag','marker_aus_y');
    h_fig = findobj('tag','netzwerk');  % Finde Figure-Objekt 'netzwerk'
      % Finde Markerlinien
    h_line_senkrecht_aus = findobj('tag','marker_senkrecht_aus');
    h_line_waagerecht_aus = findobj('tag','marker_waagerecht_aus');
    h_line_senkrecht_ein = findobj('tag','marker_senkrecht_ein');
    h_line_waagerecht_ein = findobj('tag','marker_waagerecht_ein');
    koordinate = get(gca,'currentpoint');% Ermittle aktuelle Axes-Koordinate
    marker_position = koordinate(1,1);   % Extrahiere x-Koordinate = Markerposition
    if bereich == 1                   % Zeitbereich
      marker_position = round(marker_position);% Anpassen an Matrixindex
      if (marker_position < 0)            % Pruefe ob Position kleiner Index
        marker_position = 0;
      end
      matrix = get(h_check_marker,...     % Lies Ein- und Ausgangsfolge aus
        'userdata');                      % userdata
      zeit = matrix(1,:);                 % Extrahiere Zeitachse
      if (marker_position > max(zeit))    % Pruefe ob Position groesser Index
        marker_position = max(zeit);
      end
      eingangsfolge = matrix(2,:);        % Extrahiere Eingangsfolge
      ausgangsfolge = matrix(3,:);        % Extrahiere Ausgangsfolge
      marker_wert_ein = eingangsfolge(marker_position+1);% Lies Markerwert der aktuellen Position
      marker_wert_aus = ausgangsfolge(marker_position+1);% Lies Markerwert der aktuellen Position
      string_ein = [num2str(marker_wert_ein)];
      string_aus = [num2str(marker_wert_aus)];
      set(h_marker_ein_x,...
        'string',marker_position,...      % Ausgabe aktuelle Markerposition
        'userdata',marker_position);      % Sichere aktuelle Markerposition
    elseif bereich == 2               % FFT
      matrix = get(h_marker_ein_y,...     % Lies Spektrum aus userdata
        'userdata');
      ny = matrix(1,:);                   % Extrahiere Frequenz
      eingang_spektrum = matrix(2,:);     % Extrahiere Spektrum des Eingangssignals
      ausgang_spektrum = matrix(3,:);     % Extrahiere Spektrum des Aingangssignals
      eingang_spek_db = matrix(4,:);      % Extrahiere Spektrum des Eingangssignals dB
      ausgang_spek_db = matrix(5,:);      % Extrahiere Spektrum des Aingangssignals dB
      marker_index = round(marker_position * 2 * (length(ny)-1));
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
    end                               % Ende von Zeit oder FFT 
    set(h_marker_ein_y,...
      'string',string_ein);        % Ausgabe Markerwert Eingangsfolge
    set(h_marker_aus_y,...
      'string',string_aus);        % Ausgabe Markerwert Ausgangsfolge
    x_lim_aus = get(h_axes_aus,'xlim'); % Lies x-Grenzwerte Ausgangsfolge
    y_lim_aus = get(h_axes_aus,'ylim'); % Lies y-Grenzwerte Ausgangsfolge
    set(h_line_senkrecht_aus,...        % Aktualisiere x-Koordinaten
      'xdata',[marker_position marker_position]);
    set(h_line_waagerecht_aus,...       % Aktualisiere y-Koordinaten
      'ydata',[marker_wert_aus marker_wert_aus]);
    if (nur_aus == 0)                   % Wenn Ein- und Ausgangsfolge
      x_lim_ein = get(h_axes_ein,'xlim');% Lies x-Grenzwerte Eingangsfolge
      y_lim_ein = get(h_axes_ein,'ylim');% Lies y-Grenzwerte Eingangsfolge
      set(h_line_senkrecht_ein,...
        'xdata',[marker_position marker_position]);% Aktualisiere x-Koordinaten
      set(h_line_waagerecht_ein,...
        'ydata',[marker_wert_ein marker_wert_ein]);% Aktualisiere y-Koordinaten
    end                                 % Ende von Ein- und Ausgangsfolge  
  elseif strcmp(mouse_button,'normal')% Wenn rechte Maustaste
    h_check_zoom = findobj...         % Finde Radiobutton 'zoom_an'
      ('tag','zoom_an');
    zoom_on = get(h_check_zoom,...    % Lies Zustand des Radiobuttons
      'value');
    if zoom_on                        % Wenn Zoom eingeschaltet
      zoomfilt('zoom_bereich');       % Zoomfunktion aufrufen
    end
  end                                 % Ende von Maustaste
end                                   % Ende von set


% ------------------ moved --------------------------------------------------
if strcmp(command_str,'moved') % Wenn Pushbutton betaetigt
  h_objekt = gco;
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
  differenz = get(h_objekt,'userdata');
  marker_position = marker_position + differenz;
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
end                                   % Ende von moved



