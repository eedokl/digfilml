function h = markerok(action,ax,name,position,ltype,crsrline,hdl_x,hdl_y)

% MARKEROK erzeugt einen Marker, der mit der Maus
% gesteuert werden kann.
% Es sind die folgenden Funktionsaufrufe möglich:
%
% - Erstellen einer Markerlinie
% > markerok('make',ax,'Name','Position','Linientyp',Hdl_l,Hdl_x,Hdl_y)
%    ax = Handle der gewünschten Achse
%    'Name' = Name ist die Bezeichnung der Markerlinie
%    'Position' = Position der Markerlinie innerhalb der Achse
%    'Linientyp' = irgendein MATLAB Linientyp möglich
%    Hdl_l = Handle der Linie, die den Marker erhalten soll
%    Hdl_x = Handle des Ausgabefensters x
%    Hdl_y = Handle des Ausgabefensters y
%
% > markerok('move',ax,'Name')        bewegen einer Markerlinie
% > markerok('del',[],'Name')         löschen einer Markerlinie
% > markerok('location',[],'Name')    Positionswert einer Markerlinie x,y
% > markerok('button_down',[],'Name') interne Funktion (Maustaste gedrückt)
% > markerok('button_up',[],'Name')   interne Funktion (Maustaste losgelassen)
% > markerok('refresh',...)           Markerlinie neu zeichnen
%
% Die Datenausgabe erfolgt in Textfenster deren Handles bei 'make' übergeben
% werden.

% Version 2.0 : Oliver Klein 27-03-97
% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover

%=============================================%
% 	Erstellen einer Markerlinie           %
%=============================================%
if strcmp(action,'make')

  % Achsengröße feststellen
  x = get(ax,'XLim');
  y = get(ax,'YLim');

  % Markerposition außerhalb der Achse ?
  if position(1) < x(1) | position(1) > x(2),
    error('markerok: Markerposition außerhalb der Achse...');
  end;


  % Achse ax wird zur aktuellen Achse (gca), Achsenfarbe auslesen
  old_ax=gca;
  axes(ax);
  % zeichne vertikale Markerlinie
  % im UserData-Property des markers wird das
  % Handle der zu markierenden Linie & Ausgabeobjekt gespeichert
  h = line('LineStyle',ltype,...
  	   'Xdata',[position(1) position(1) NaN x],...
           'Ydata',[y NaN position(2) position(2)],...
     	   'Tag',name,'color','m',...
           'UserData',[crsrline,hdl_x,hdl_y]);
  axes(old_ax);
  set(hdl_x,'String',sprintf('X=%6.4f',position(1)));
  set(hdl_y,'String',sprintf('Y=%6.4f',position(2)));

  % CallBack für Maustastendruck vorbereiten
  str=get(h,'Tag'); % Tag der Markerlinie
  str=['markerok(''button_down'',[],''',str,''')'];

  % ButtonDownFcn-CallBack in Marker und Linie setzen
  set(crsrline,'ButtonDownFcn',str);
  set(h,'ButtonDownFcn',str);
  % set(ax,'ButtonDownFcn',str);

%=============================================%
%         Bewegen einer Markerlinie           %
%=============================================%
%        MARKEROK('move',ax,'NAME',position)  %
%=============================================%
elseif strcmp(action,'move')

  % ermittle Handle der Markerlinie
  hdl = findobj('Tag',name);

  % Achsengröße feststellen
  x = get(ax,'XLim');
  y = get(ax,'YLim');

  % Marker neu setzen
  set(hdl,'XData',[position(1) position(1) NaN x],...
          'YData',[y NaN position(2) position(2)]);

%=============================================%
%         Löschen einer Markerlinie           %
%=============================================%
%     MARKEROK('del',[],'NAME')               %
%=============================================%
elseif strcmp(action,'del')

  % ermittle Handle der Markerlinie
  hdl=findobj('Tag',name);

  % ermittle Handle der markierten Linie
  hdlList=get(hdl,'UserData');
  hdl_line=hdlList(1:length(hdlList)-2);

  % lösche ButtonDownFcn der markierten Linie(n)
  set(hdl_line,'ButtonDownFcn','');

  % handle des Fensters der Markerlinie ermitteln
  fig=get(get(hdl_line(1),'Parent'),'Parent');

  % lösche WindowButtonUpFcn des Fenster der markierten Linie
  set(fig,'WindowButtonUpFcn','');

  % lösche Markerlinie
  delete(hdl);

  % Ausgabeobjekte ausschalten
  set(hdlList(length(hdlList)-1:length(hdlList)),'String','-');

%=============================================%
%      Positionswert einer Markerlinie        %
%=============================================%
%      MARKEROK('location',[],'NAME')         %
%=============================================%
elseif strcmp(action,'location')

  % Handle der Markerlinie ermitteln
  hdl = findobj('Tag',name);

  % Wenn nicht vorhanden, ist Ausgabewert (h) leere Menge
  if isempty(hdl), h = []; return; end;

  % Aktuelle Markerposition
  xx = get(hdl,'XData');
  yy = get(hdl,'YData');

  h = [xx(1) yy(4)];

%=======================================================%
%          Maustaste gedrückt/Marker 'ziehen'           %
%=======================================================%
% MARKEROK('button_down',[],'Tag_der_Markerlinie')      %
%=======================================================%
elseif strcmp(action,'button_down');

  % Handle der Markerlinie
  hdl_marker=findobj('Tag',name);

  % Marker auf 'xor' umschalten und inverse Farbe wählen (nur MATLAB 4)
  if ~strcmp(get(hdl_marker,'EraseMode'),'xor')
    set(hdl_marker,'EraseMode','xor'); %,'Color','g');
  end

  % Handleliste -> markierte Linie & Ausgabefenster (2,3)
  hdlList=get(hdl_marker,'UserData');

  % Handle der zu markierenden Linie
  hdl_line=hdlList(1:length(hdlList)-2);

  % Handles der Ausgabeobjekte
  hdl_win=hdlList(length(hdlList)-1:length(hdlList));

  % Handle der Achse
  axe=get(hdl_line(1),'Parent');

  % Handle des Fensters
  fig=get(axe,'Parent');

  % WindowButtonMotionFcn-CallBack vorbereiten
  str=['''',name,''''];
  str=['markerok(''button_down'',[],',str,')'];

  % WindowButtonUpFcn-CallBack vorbereiten
  str2=['''',name,''''];
  str2=['markerok(''button_up'',[],',str2,')'];

  % WindowButtonUpFcn des Fensters setzen
  set(fig,'WindowButtonUpFcn',str2);

  % WindowButtonMotionFcn des Fensters setzen
  set(fig,'WindowButtonMotionFcn',str);

  % aktuelle Mausposition
  pt=get(axe,'CurrentPoint');

  % ermitteln der zu markierenden Linie und deren Punkt
  merker=1;
  if strcmp(get(hdl_line(1),'LineStyle'),'-')
  % Marker an x-Werten orientieren

    % mehrere zu markierende Linien zulassen
    for k=1:length(hdl_line)
      xw=get(hdl_line(k),'XData');
      wert=(xw-pt(1,1)).^2;

      [dummy,index]=min(wert); index=min(index); dummy=min(dummy);
      if k>1
        if dummy<dummy_old,
          dummy_old=dummy;
          index_old=index; merker=k;
        end
      else
        dummy_old=dummy;
        index_old=index;
      end
    end
  else
  % Marker an x,y-Werten orientieren

    % mehrere zu markierende Linien zulassen
    for k=1:length(hdl_line)
      xw=get(hdl_line(k),'XData');
      yw=get(hdl_line(k),'YData');
      wert=(xw-pt(1,1)).^2+(yw-pt(1,2)).^2;

      [dummy,index]=min(wert); index=min(index); dummy=min(dummy);
      if k>1
        if dummy<dummy_old,
          dummy_old=dummy;
          index_old=index; merker=k;
        end
      else
        dummy_old=dummy;
        index_old=index;
      end
    end
  end
  index=index_old;
  xw=get(hdl_line(merker),'XData');
  yw=get(hdl_line(merker),'YData');

  % Ausgabedaten als Zeichenkette
  x_str=sprintf('X=%6.4f',xw(index));
  y_str=sprintf('Y=%6.4f',yw(index));

  % Marker an neue Position setzen
  markerok('move',axe,name,[xw(index),yw(index)]);

  % Markerpositon ausgeben
  set(hdl_win(1),'String',x_str);
  set(hdl_win(2),'String',y_str);

%=============================================%
%             Maustaste losgelassen           %
%=============================================%
%       MARKEROK('button_up',[],'Name')       %
%=============================================%
elseif strcmp(action,'button_up');

  % Handle der Marker Linie
  hdl_line=findobj('Tag',name);

  % Handle der Achse
  axe=get(hdl_line,'Parent');

  % Handle des Fensters
  fig=get(axe,'Parent');

  % WindowButtonMotionFcn ausschalten
  set(fig,'WindowButtonMotionFcn','');
  set(fig,'WindowButtonUpFcn','');

  % Marker wieder auf 'normal' zurücksetzen
  set(hdl_line,'EraseMode','normal','Color','m');

  % Merker refresh ?? TEST OB PROBLEME ??
  markerok('refresh',[],name);

  refresh(fig);

%==============================================%
% neu zeichnen : MARKEROK('refresh',[],'Name') %
%==============================================%
elseif strcmp(action,'refresh');

  % Handle der Marker Linie
  hdl_line=findobj('Tag',name);

  % wenn vorhanden dann neu setzen
  if isempty(hdl_line), return;
  else
    % aktuelle Position ermitteln
    loc=markerok('location',[],name);

    % aktuelle Achse ermitteln
    ax=get(hdl_line,'Parent');

    % Marker neu zeichnen
    markerok('move',ax,name,loc);
  end

end

