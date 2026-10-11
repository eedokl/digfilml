function markerpn(command_str)
% MARKERPN
% Die Funktion Markerfi stellt Markerfunktionen fuer pn_darst zur Verfuegung
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
  h_check_marker = findobj...         % Finde Radiobutton 'marker_an'
    ('tag','marker_an');
  marker_on = get(h_check_marker,...  % Lies Zustand des Radiobuttons
    'value');
  h_marker = findobj...               % Finde Markerspezifische Objekte
    ('tag','marker');
  h_axes_pn  = findobj...             % Finde Axes Objekt 'pn_diagramm'
    ('tag','pn_diagramm');
  h_radio_unqu = findobj...           % Finde Radiobutton 'pn_unquantisiert'
    ('tag','pn_unquantisiert');
  unquantisiert = get...              % Lies Zustand des Radiobuttons
    (h_radio_unqu,'value');
  anzahl = get...                     % Anzahl Pole bzw. Nullstellen aus
    (h_radio_unqu,'userdata');        % Userdata
  h_radio_quant = findobj...          % Finde Radiobutton 'pn_quantisiert'
    ('tag','pn_quantisiert');            
  quantisiert = get...                % Lies Zustand des Radiobuttons
    (h_radio_quant,'value');
  set(h_check_marker,'userdata',...   % Markerobjekt
    'nullstelle');
  if marker_on                        % Wenn Marker an
    axes(h_axes_pn);                  % Setze aktuelles Axes-Objekt
    pause(1);                         % Pause zum Umschalten auf Axes-Objekt
    set(h_radio_quant,...             % Sichere Markerposition in Userdata
      'userdata',1);
    set(h_fig,'windowbuttondownfcn',...% Setze Windowbuttondownfcn
      'zoompn(''zoom_bereich'');');   % Ausfuerung wenn Maus betaetigt
    x_lim = get(h_axes_pn,'xlim');    % x-Grenzwerte Ausgangsfolge
    y_lim = get(h_axes_pn,'ylim');    % y-Grenzwerte Ausgangsfolge
    if unquantisiert                  % Wenn unquantisiert
      h_null = findobj...             % Finde erste Nullstelle
        ('tag','nullstelle',...
         'userdata',1);
      if ~isempty(h_null)             % Wenn unquantisierte Nullstelle vorhanden
        x_data = get(h_null,'xdata'); % Lies x-Koordinate der Nullstelle
        y_data = get(h_null,'ydata'); % Lies y-Koordinate der Nullstelle
        line('xdata',[x_data x_data],...
          'ydata',y_lim,...           % Senkrechte Markerlinie der Ausgangsfolge
          'erasemode','normal',...
          'color','r',...             % Farbe Rot
          'tag','marker_senkrecht_unqu');% Kennzeichnung der Markerlinie
        line('xdata',x_lim,...
          'ydata',[y_data y_data],...
          'erasemode','normal',...    % Waagerechte Markerlinie der Ausgangsfolge
          'color','r',...
          'tag','marker_waagerecht_unqu');
      end                             % Ende von ~isempty(h_null)
    end                               % Ende von Unquantisiert
    if quantisiert                    % Wenn quantisierte Darstellung
      h_null = findobj...             % Finde erste quantisierte Nullstelle
        ('tag','nullstelle_quant',...
         'userdata',1);
      if ~isempty(h_null)             % Wenn quantisierte Nullstelle vorhanden
        x_data = get(h_null,'xdata'); % Lies x-Koordinate der Nullstelle
        y_data = get(h_null,'ydata'); % Lies y-Koordinate der Nullstelle
        line('xdata',[x_data x_data],...
          'ydata',y_lim,...           % Senkrechte Markerlinie der Ausgangsfolge
          'erasemode','normal',...
          'color','b',...             % Farbe Blau
          'buttondownfcn','',...
          'tag','marker_senkrecht_quant');
        line('xdata',x_lim,...
          'ydata',[y_data y_data],...
          'erasemode','normal',...    % Waagerechte Markerlinie der Ausgangsfolge
          'color','b',...
          'tag','marker_waagerecht_quant');
      end                             % Ende von ~isempty(h_null)
    end                               % Ende von Unquantisiert
    children_pn = get(h_axes_pn,'children');% Eingefuegt um Sichtbarkeit
    set(children_pn,'visible','off'); % noch vorhandener Objekte zu gewaehrleisten
    set(children_pn,'visible','on');
    command_str = 'ausgabe';          % Setze command_str = 'ausgabe'
  else                                % Wenn Marker aus
    if ~zoom_on                       % Wenn Zoom ausgeschaltet
      set(h_fig,'windowbuttondownfcn','');% Ruecksetzen Windowbuttondownfcn
      set(h_fig,...                   % Ruecksetzen keypressfunction
        'keypressfcn','');
    end                               % Ende von Zoom aus
    % Finde und entferne Markerlinien
    h_line = findobj('tag','marker_senkrecht_unqu');
    delete(h_line);
    h_line = findobj('tag','marker_waagerecht_unqu');
    delete(h_line);
    h_line = findobj('tag','marker_senkrecht_quant');
    delete(h_line);
    h_line = findobj('tag','marker_waagerecht_quant');
    delete(h_line);
    children_pn = get...
      (h_axes_pn,'children');         % Eingefuegt um Sichtbarkeit
    set(children_pn,'visible','off'); % noch vorhandener Objekte zu gewaehrleisten
    set(children_pn,'visible','on');
    h_marker_objekt = findobj...      % Finde Marker Objekte
      ('tag','marker_objekt');
    set(h_marker_objekt,...           % Ruecksetzen String
      'string','');
    h_quant_real = findobj...         % Finde Text-Objekt 'marker_quant_real'
      ('tag','marker_quant_real');
    set(h_quant_real,...              % Ruecksetzen String
      'string','');
    h_unqu_real = findobj...          % Finde Text-Objekt 'marker_unqu_real'
      ('tag','marker_unqu_real');
    set(h_unqu_real,...               % Ruecksetzen String
      'string','');
    h_quant_imag = findobj...         % Finde Text-Objekt 'marker_quant_imag'
      ('tag','marker_quant_imag');
    set(h_quant_imag,...              % Ruecksetzen String
      'string','');
    h_unqu_imag = findobj...          % Finde Text-Objekt 'marker_unqu_imag'
      ('tag','marker_unqu_imag');
    set(h_unqu_imag,...               % Ruecksetzen String
      'string','');
    axes(h_axes_pn);                  % Setze aktuelle Axes-Objekt
  end                                 % Ende von Marker an oder aus
end                                   % Ende von command_str = marker_on_off


% ------------------ moved --------------------------------------------------
if strcmp(command_str,'moved')        % Wenn Pushbutton betaetigt
  h_check_marker = findobj('tag','marker_an');
  marker_on = get(h_check_marker,'value');
  if (marker_on)
    h_objekt = gco;                     % Aktuelles Objekt
    % Finde Markerlinien
    h_line_senkrecht_unqu = findobj('tag','marker_senkrecht_unqu');
    h_line_waagerecht_unqu = findobj('tag','marker_waagerecht_unqu');
    h_line_senkrecht_quant = findobj('tag','marker_senkrecht_quant');
    h_line_waagerecht_quant = findobj('tag','marker_waagerecht_quant');
    h_axes_pn = findobj...              % Finde Axes Objekt 'pn_diagramm'
      ('tag','pn_diagramm');
    x_lim = get(h_axes_pn,'xlim');      % Lies x-Grenzwerte
    y_lim = get(h_axes_pn,'ylim');      % Lies y-Grenzwerte
    h_radio_unqu = findobj...           % Finde Radiobutton 'pn_unquantisiert'
      ('tag','pn_unquantisiert');
    unquantisiert = get...              % Lies Zustand des Radiobuttons
      (h_radio_unqu,'value');
    anzahl = get...                     % Anzahl Pole bzw. Nullstellen aus
      (h_radio_unqu,'userdata');        % Userdata
    h_radio_quant = findobj...          % Finde Radiobutton 'pn_quantisiert'
      ('tag','pn_quantisiert');            
    quantisiert = get...                % Lies Zustand des Radiobuttons
      (h_radio_quant,'value');
    position = get...                   % Lies alte Markerposition aus
      (h_radio_quant,'userdata');       % Userdata
    if strcmp(get(h_objekt,'string'),'>')% Wenn Pushbutton '>' betaetigt
      position = position + 1;          % Inkrementiere Position
      if (position > anzahl)            % Wenn Position > Anzahl Pol-/Nullstellen
        position = 1;                   % Position = 1
      end
    elseif strcmp(get(h_objekt,'string'),'<')% Wenn Pushbutton '<' betaetigt
      position = position - 1;          % Dekrementiere Position
      if (position < 1)                 % Wenn Position < 1
        position = anzahl;              % Position = letzte Pol-/Nullstelle
      end
    end                                 % Ende von < oder > betaetigt
    objekt = get(h_check_marker,...     % Pruefe ob Pol- oder Nullstelle
      'userdata');
    if unquantisiert                    % Wenn unquantisierte Darstellung
      if strcmp(get(h_objekt,'string'),'P')% Wenn Pushbutton 'P' betaetigt
        h_pol = findobj...              % Finde erste Polstelle
          ('tag','polstelle',...
           'userdata',1);
        if ~isempty(h_pol)              % Wenn Polstelle vorhanden
          x_data = get(h_pol,'xdata');  % Lies x-Koordinate
          y_data = get(h_pol,'ydata');  % Lies y-Koordinate
          set(h_line_senkrecht_unqu,... % Aktualisiere unquantisierte
            'xdata',[x_data x_data],... % Markerposition
            'ydata',y_lim);
          set(h_line_waagerecht_unqu,...
            'xdata',x_lim,...
            'ydata',[y_data y_data]);
          position = 1;                 % Setze Position = 1
          set(h_check_marker,...        % Setze Markerobjekt = Polstelle
            'userdata','polstelle');
        end                             % Ende von ~isempty(h_pol)
      elseif strcmp(get(h_objekt,'string'),'N')% Wenn Pushbutton 'N' betaetigt
        h_null = findobj...             % Finde erste Nullstelle
          ('tag','nullstelle',...
           'userdata',1);
        if ~isempty(h_null)             % Wenn Nullstelle vorhanden
          x_data = get(h_null,'xdata'); % Lies x-Koordinate der Nullstelle
          y_data = get(h_null,'ydata'); % Lies y-Koordinate der Nullstelle
          set(h_line_senkrecht_unqu,... % Aktualisiere unquantisierte
            'xdata',[x_data x_data],... % Markerposition
            'ydata',y_lim);
          set(h_line_waagerecht_unqu,...
            'xdata',x_lim,...
            'ydata',[y_data y_data]);
          position = 1;                 % Setze Position = 1
          set(h_check_marker,...        % Setze Markerobjekt = Nullstelle
            'userdata','nullstelle');
        end                             % Ende von ~isempty(h_null)
      elseif strcmp(get(h_objekt,'string'),'>') | strcmp(get(h_objekt,'string'),'<')
        h_marker_objekt = findobj...    % Ermittle Handle des naechsten Markerobjektes
          ('tag',objekt,...
           'userdata',position);
        if ~isempty(h_marker_objekt)    % Wenn Markerobjekt vorhanden
          x_data = get(h_marker_objekt,'xdata');% Lies x-Koordinate des Markerobjektes
          y_data = get(h_marker_objekt,'ydata');% Lies y-Koordinate des Markerobjektes
          set(h_line_senkrecht_unqu,... % Aktualisiere unquantisierte Markerposition
            'xdata',[x_data x_data],...
            'ydata',y_lim);
          set(h_line_waagerecht_unqu,...
            'xdata',x_lim,...
            'ydata',[y_data y_data]);
        end                             % Ende von ~isempty(h_marker_objekt)
      end                               % Ende von Tastenabfrage
    end                                 % Ende von Unquantisiert
    if quantisiert                      % Wenn Quantisierte Darstellung
      if strcmp(get(h_objekt,'string'),'P')% Wenn Pushbutton 'P' betaetigt
        h_pol = findobj...              % Finde erste quantisierte Polstelle
          ('tag','polstelle_quant',...
           'userdata',1);
        if ~isempty(h_pol)              % Pruefe ob Pol vorhanden
          x_data = get(h_pol,'xdata');  % Lies x-Koordinate der Polstelle
          y_data = get(h_pol,'ydata');  % Lies y-Koordinate der Polstelle
          set(h_line_senkrecht_quant,...% Aktualisiere quantisierte
            'xdata',[x_data x_data],... % Markerposition
            'ydata',y_lim);
          set(h_line_waagerecht_quant,...
            'xdata',x_lim,...
            'ydata',[y_data y_data]);
          position = 1;                 % Setze Position = 1
          set(h_check_marker,...        % Setze Markerobjekt = Polstelle
            'userdata','polstelle');
        end                             % Ende von ~isempty(h_pol)
      elseif strcmp(get(h_objekt,'string'),'N')% Wenn Pushbutton 'N' betaetigt
        h_null = findobj...             % Finde erste Nullstelle
          ('tag','nullstelle_quant',...
           'userdata',1);
        if ~isempty(h_null)             % Pruefe ob Nullstelle vorhanden
          x_data = get(h_null,'xdata'); % Lies x-Koordinate der Nullstelle
          y_data = get(h_null,'ydata'); % Lies y-Koordinate der Nullstelle
          set(h_line_senkrecht_quant,...% Aktualisiere quantisierte
            'xdata',[x_data x_data],... % Markerposition
            'ydata',y_lim);
          set(h_line_waagerecht_quant,...
            'xdata',x_lim,...
            'ydata',[y_data y_data]);
          position = 1;                 % Position = 1
          set(h_check_marker,...        % Setze Markerobjekt = Nullstelle
            'userdata','nullstelle');
        end                             % Ende von ~isempty(h_null)
      elseif strcmp(get(h_objekt,'string'),'>') | strcmp(get(h_objekt,'string'),'<')
        string = [objekt '_quant'];     % Ermittle Markerobjekt Pol oder Nullstelle
        h_marker_objekt = findobj...    % Ermittle Handle des Markerobjektes
          ('tag',string,...
           'userdata',position);
        if ~isempty(h_marker_objekt)    % Wenn Markerobjekt vorhanden
          x_data = get(h_marker_objekt,'xdata');% Lies x-Koordinate des Markerobjektes
          y_data = get(h_marker_objekt,'ydata');% Lies y-Koordinate des Markerobjektes
          set(h_line_senkrecht_quant,...% Aktualisiere quantisierte
            'xdata',[x_data x_data],... % Markerposition
            'ydata',y_lim);
          set(h_line_waagerecht_quant,...
            'xdata',x_lim,...
            'ydata',[y_data y_data]);
        end                             % Ende von ~isempty(h_marker_objekt)
      end                               % Ende von Tastenabfrage
    end                                 % Ende von Quantisiert
    set(h_radio_quant,...               % Sichere aktuelle Markerposition in
      'userdata',position);             % Userdata
    command_str = 'ausgabe';            % Setze command_str = 'ausgabe'
  end                                   % Ende von marker_on
end                                     % Ende von moved


% ------------------ set ----------------------------------------------------
if strcmp(command_str,'set')          % Wenn rechte Maustaste betaetigt
  h_objekt = gco;
  h_check_marker = findobj...         % Finde Radiobutton 'marker_an'
    ('tag','marker_an');
  marker_on = get(h_check_marker,...  % Lies Zustand des Radiobuttons
    'value');
  if marker_on                        % Wenn Marker an
    % Finde Markerlinien
    h_line_senkrecht_unqu = findobj('tag','marker_senkrecht_unqu');
    h_line_waagerecht_unqu = findobj('tag','marker_waagerecht_unqu');
    h_line_senkrecht_quant = findobj('tag','marker_senkrecht_quant');
    h_line_waagerecht_quant = findobj('tag','marker_waagerecht_quant');
    h_axes_pn = findobj...            % Finde Axes Objekt 'pn_diagramm'
      ('tag','pn_diagramm');
    x_lim = get(h_axes_pn,'xlim');    % Lies x-Grenzwerte
    y_lim = get(h_axes_pn,'ylim');    % Lies y-Grenzwerte
    h_radio_unqu = findobj...         % Finde Radiobutton 'pn_unquantisiert'
      ('tag','pn_unquantisiert');
    unquantisiert = get...            % Lies Zustand des Radiobuttons
      (h_radio_unqu,'value');
    h_radio_quant = findobj...        % Finde Radiobutton 'pn_quantisiert'
      ('tag','pn_quantisiert');            
    quantisiert = get...              % Lies Zustand des Radiobuttons
      (h_radio_quant,'value');
    string = get...                   % Lies Kennzeichnung des Objektes
      (h_objekt,'tag');
    if strcmp(string,'polstelle')|strcmp(string,'polstelle_quant')...
      |strcmp(string,'nullstelle')|strcmp(string,'nullstelle_quant')
      position = get...               % Lies Markerposition aus
        (h_objekt,'userdata');        % Userdata        
      if strcmp(string,'polstelle')|strcmp(string,'polstelle_quant')
        objekt = 'polstelle';
      elseif strcmp(string,'nullstelle')|strcmp(string,'nullstelle_quant')
        objekt = 'nullstelle';
      end
      if (quantisiert == 1)           % Wenn quantisierte Darstellung
        string = [objekt '_quant'];   % Markerobjekt = Pol-/Nullstelle _quant
        h_marker_objekt = findobj...  % Ermittle Handle des Markerobjektes
          ('tag',string,...
           'userdata',position);
        if ~isempty(h_marker_objekt)  % Wenn Markerobjekt vorhanden
          x_data = get(h_marker_objekt,'xdata');% Lies x-Koordinate des Markerobjektes
          y_data = get(h_marker_objekt,'ydata');% Lies y-Koordinate des Markerobjektes
          set(h_line_senkrecht_quant,...% Aktualisiere senkrechte Markerposition
            'xdata',[x_data x_data],...
            'ydata',y_lim);
          set(h_line_waagerecht_quant,...
            'xdata',x_lim,...
            'ydata',[y_data y_data]);
        end                           % Ende von ~isempty(h_marker_objekt)
      end                             % Ende von Quantisiert
      if (unquantisiert == 1)         % Wenn unquantisierte Darstellung
        h_marker_objekt = findobj...  % Ermittle Handle des Markerobjektes
          ('tag',objekt,...
           'userdata',position);
        if ~isempty(h_marker_objekt)  % Wenn Markerobjekt vorhanden
          x_data = get(h_marker_objekt,'xdata');% Lies x-Koordinate
          y_data = get(h_marker_objekt,'ydata');% Lies y-Koordinate
          set(h_line_senkrecht_unqu,...% Aktualisiere unquantisierte
            'xdata',[x_data x_data],...% Markerposition
            'ydata',y_lim);
          set(h_line_waagerecht_unqu,...
            'xdata',x_lim,...
            'ydata',[y_data y_data]);
        end                           % Ende von ~isempty(h_marker_objekt)
      end                             % Ende von unquantisiert
      set(h_radio_quant,...           % Sichere aktuelle Markerposition in
        'userdata',position);         % Userdata
      set(h_check_marker,...          % Sichere Markerobjekt in Userdata
        'userdata',objekt);
    end                               % Ende von Objekt = Pol- oder Nullstelle
  end                                 % Ende von Marker an
  command_str = 'ausgabe';            % Setze command_str = 'ausgabe'
end                                   % Ende von command_str = set


% ------------------ ausgabe ------------------------------------------------
if strcmp(command_str,'ausgabe')      % Wenn command_str = ausgabe
  h_axes_pn = findobj...              % Finde Axes Objekt 'pn_diagramm'
    ('tag','pn_diagramm');
  h_radio_unqu = findobj...           % Finde Radiobutton 'pn_unquantisiert'
    ('tag','pn_unquantisiert');
  unquantisiert = get...              % Lies Zustand des Radiobuttons
    (h_radio_unqu,'value');
  h_radio_quant = findobj...          % Finde Radiobutton 'pn_quantisiert'
    ('tag','pn_quantisiert');            
  quantisiert = get...                % Lies Zustand des Radiobuttons
    (h_radio_quant,'value');
  position = get...                   % Lies alte Markerposition aus
    (h_radio_quant,'userdata');       % Userdata
  h_check_marker = findobj...         % Finde Radiobutton 'marker_an'
    ('tag','marker_an');
  objekt = get(h_check_marker,...     % Pruefe ob Pol- oder Nullstelle
    'userdata');
  h_marker_objekt = findobj...        % Finde Marker Objekte
    ('tag','marker_objekt');
  h_quant_real = findobj...           % Finde Marker Objekte
    ('tag','marker_quant_real');
  h_unqu_real = findobj...            % Finde Marker Objekte
    ('tag','marker_unqu_real');
  h_quant_imag = findobj...           % Finde Marker Objekte
    ('tag','marker_quant_imag');
  h_unqu_imag = findobj...            % Finde Marker Objekte
    ('tag','marker_unqu_imag');
  if strcmp(objekt,'polstelle')       % Wenn Markerobjekt = Polstelle
    set(h_marker_objekt,...
      'string','Polstelle');
  elseif strcmp(objekt,'nullstelle')  % Wenn Markerobjekt = Nullstelle
    set(h_marker_objekt,...
      'string','Nullstelle');
  end                                 % Ende von Objekt = Pol- oder Nullstelle
  if (quantisiert == 1)               % Wenn quantisierte Darstellung
    string = [objekt '_quant'];       % Markerobjekt = Pol-/Nullstelle _quant
    h_marker_objekt = findobj...      % Ermittle Handle des Markerobjektes
      ('tag',string,...
       'userdata',position);
    if ~isempty(h_marker_objekt)      % Wenn Markerobjekt vorhanden
      x_data = get(h_marker_objekt,'xdata');% Lies x-Koordinate des Markerobjektes
      y_data = get(h_marker_objekt,'ydata');% Lies y-Koordinate des Markerobjektes
      string = num2str(x_data);       % Quantisierter Realteil
      set(h_quant_real,...            % Setze String des Textobjektes
        'string',string);
      string = [num2str(y_data) 'i']; % Quantisierter Imaginaerteil
      set(h_quant_imag,...            % Setze String des Textobjektes
        'string',string);
    elseif isempty(h_marker_objekt)   % Wenn Markerobjekt nicht vorhanden
      string = '';                     
      set(h_quant_real,...            % Setze String des Textobjektes
        'string',string);
      set(h_quant_imag,...            % Setze String des Textobjektes
        'string',string);
    end                               % Ende von Markerobjekt
  end                                 % Ende von quantisierter Darstellung
  if (quantisiert == 0)               % Wenn keine quantisierte Darstellung
    string = '';                      % 
    set(h_quant_real,...              % Setze String des Textobjektes
      'string',string);
    set(h_quant_imag,...              % Setze String des Textobjektes
      'string',string);
  end                                 % Ende von keine quantisierte Darstellung
  if (unquantisiert == 1)             % Wenn unquantisierte Darstellung
    string = [objekt];                % Markerobjekt = Pol-/Nullstelle 
    h_marker_objekt = findobj...      % Ermittle Handle des Markerobjektes
      ('tag',string,...
       'userdata',position);
    if ~isempty(h_marker_objekt)      % Wenn Markerobjekt vorhanden
      x_data = get(h_marker_objekt,'xdata');% Lies x-Koordinate des Markerobjektes
      y_data = get(h_marker_objekt,'ydata');% Lies y-Koordinate des Markerobjektes
      string = num2str(x_data);       % Quantisierter Realteil
      set(h_unqu_real,...             % Setze String des Textobjektes
        'string',string);
      string = [num2str(y_data) 'i']; % Quantisierter Imaginaerteil
      set(h_unqu_imag,...             % Setze String des Textobjektes
        'string',string);
    elseif isempty(h_marker_objekt)   % Wenn Markerobjekt nicht vorhanden
      string = '';                       
      set(h_unqu_real,...             % Setze String des Textobjektes
        'string',string);
      set(h_unqu_imag,...             % Setze String des Textobjektes
        'string',string);
    end                               % Ende von Markerobjekt
  end                                 % Ende von unquantisierter Darstellung
  if (unquantisiert == 0)             % Wenn keine unquantisierte Darstellung
    string = '';                       
    set(h_unqu_real,...               % Setze String des Textobjektes
      'string',string);
    set(h_unqu_imag,...               % Setze String des Textobjektes
      'string',string);
  end                                 % Ende von keine quantisierte Darstellung
  axes(h_axes_pn);                    % Aktuelles Axes-Objekt
end                                   % Ende von Ausgabe
