function [num,den]=zmenu(action,num,den)
% Funktionsaufruf : zmenu(action,num,den);
% Die berechneten Filterkoeffizienten werden
% als globale Variablen b und a übergeben.
%
% Nullen in z-Ebene plazieren und Frequenzgang darstellen
% Parameter 'action':   'start','down','up','move','redraw','point','help',
%                       'close','NewDisplay'...
%
% Die Funktion verwendet folgende Unterprogramme :
%
% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover
%
% See also zoomok,...

% Letzte Änderungen :

% ---- Übergabeparameter ----- -> gespeichert in UserData property
% USER_DATA(1)=line,ZEROS
% USER_DATA(2)=axes of ZEROS/POLES = parent von (1) und (6), rechtes Bild
% USER_DATA(3)=Uebergabe von time_line(N/P) Handle = (1) oder (6)
% USER_DATA(4)=freq_line
% USER_DATA(5)=INDEX des zu bewegenden Pol/Nullstelle
% USER_DATA(6)=line,POLES
% USER_DATA(7)=k_gain

%=============================
% Anzahl Eingabewerte prüfen =
%=============================
if nargin<1, action='start';
elseif nargin==2, den=num;num=action;action='start'; end

%==================================================
% Koeffizienten in Pole und Nullstellen umrechnen =
%==================================================
if nargin==2 | nargin ==3
  if length(num)>length(den)
    den=[den,zeros(1,length(num)-length(den))]; % Vektorlängen anpassen
  % elseif length(den)>length(num)
  %  num=[num,zeros(1,length(den)-length(num))]; % Vektorlängen anpassen
  end
  if length(num), [Nullen,Pole,k_gain]=tf2zp(num,den);
  else Nullen=[]; Pole=[]; k_gain=1; end
else
  k_gain=1;
end

%==============================
% Daten und Handles ermitteln =
%==============================
if ~strcmp(action,'start');
  USER_DATA=get(gcf,'userdata');
  %==================================
  % INDEX des zu bewegenden Punktes =
  %==================================
  INDEX=USER_DATA(5);
  ZEROS=get(USER_DATA(1),'XData')+j*get(USER_DATA(1),'YData');
  POLES=get(USER_DATA(6),'XData')+j*get(USER_DATA(6),'YData');
  hdl_edit=findobj('Tag','z_Aufloesung');
  ANZAHL=get(hdl_edit,'UserData');
  plot_auswahl=get(findobj('Tag','z_auswahl'),'Value');
end

if strcmp(action,'start')
  %=================================
  % Informationen für alle Objekte =
  %=================================
  scr_size=get(0,'ScreenSize');
  fontsize=9;
  textHeight=fontsize/scr_size(4)*1.67;
  my_color=[192 192 192 ]/255;
  frmBottom=0.03; frmHeight=0.2; frmTop=0.23;
  if isempty(k_gain), k_gain=1; end

  %=======================
  % Initialisiere Figure =
  %=======================
  scr_size(4)=scr_size(4)-22;
  figNumber=figure( ...
    'NumberTitle','off','Name','Filterentwurf im PN-Diagramm',...
    'units','pixels','menubar','none','position',scr_size,...
    'backingstore','off','Interruptible','off',...
    'resize','off','pointer','watch', ...
    'Color',[1 1 1],'InvertHardcopy','off',...
    'KeyPressFcn','zmenu(''KeyPress'');');
  set(figNumber,'Units','normalized'); 
 %===================
  % Hauptfenster aus =
  %===================
  hdl_main=findobj('Tag','hauptfenster');
  if ~isempty(hdl_main), set(hdl_main,'Visible','off'); end

  %====================================
  % mehrere Rahmen zur Bildaufteilung =
  %====================================
  width=0.01; height=0.26;
  uicontrol( ...
    'Style','Frame','Units','normalized',...
    'Position',[0 0 1 height],...
    'Background',my_color-0.05);
  uicontrol( ...
    'Style','Frame','Units','normalized',...
    'Position',[0 1-width 1 width],...
    'Background',my_color-0.05);
  uicontrol( ...  % linker Balken
    'Style','Frame','Units','normalized',...
    'Position',[0 .259 width 1-height-width+0.003],...
    'Background',my_color-0.05);
  uicontrol( ...  % mitte
    'Style','Frame','Units','normalized',...
    'Position',[.505 .259 width 1-height-width+0.003],...
    'Background',my_color-0.05);
  uicontrol( ... % rechts
    'Style','Frame','Units','normalized',...
    'Position',[1-width .259 1-width 1-height-width+0.003],...
    'Background',my_color-0.05);
  uicontrol( ...
    'Style','Frame','Units','normalized',...
    'Position',[2*width frmBottom .505-width*3 frmHeight],...
    'Background',my_color);
  uicontrol( ...
    'Style','Frame','Units','normalized',...
    'Position',[.505+2*width frmBottom .495-width*4 frmHeight],...
    'Background',my_color);

  %============
  % Button OK =
  %============
  uicontrol( ...
    'Style','PushButton','Units','normalized',...
    'Position',[0.88 frmTop-4*textHeight .08 1.5*textHeight],...
    'String','OK',...
    'Callback','zmenu(''close_ok'');');

  %=================
  % Abbruch Button =
  %=================
  uicontrol( ...
    'Style','PushButton','Units','normalized',...
    'Position',[0.88 frmTop-5.5*textHeight .08 1.5*textHeight],...
    'String','Abbruch',...
    'Callback','zmenu(''close_cancel'');');

  %===============
  % Hilfe Button =
  %===============
  uicontrol( ...
    'Style','PushButton','Units','normalized',...
    'Position',[0.88 frmTop-2.5*textHeight .08 1.5*textHeight],...
    'String','Hilfe',...
    'Callback','zmenu(''help'');');

  %===========================
  % Text & Button Nullstelle =
  %===========================
  uicontrol( ...
    'Style','Text','Units','normalized',...
    'Position',[0.677 frmTop-2*textHeight .122 textHeight],...
    'String','Nullstelle',...
    'Background',my_color,...
    'Callback','zmenu(''Nullstelle'');');
  uicontrol( ...
    'Style','PushButton','Units','normalized',...
    'Position',[0.675 frmTop-3.5*textHeight .125 textHeight*1.5],...
    'String','loeschen',...
    'Interruptible','off',...
    'Callback','zmenu(''DeleteNull'');');

  %=============================
  % Button Nullstelle einfügen =
  %=============================
  uicontrol( ...
    'Style','PushButton','Units','normalized',...
    'Position',[.675+0.125-0.02 frmTop-5*textHeight .02 1.5*textHeight],...
    'String','o',...
    'CallBack','zmenu(''SetNull'');');

  %==========================
  % Text & Button Polstelle =
  %==========================
  uicontrol( ...
    'Style','Text','Units','normalized',...
    'Position',[.552 frmTop-2*textHeight .122 textHeight],...
    'String','Polstelle',...
    'Background',my_color,...
    'Callback','zmenu(''Nullstelle'');');
  uicontrol( ...
    'Style','PushButton','Units','normalized',...
    'Position',[0.55 frmTop-3.5*textHeight .125 textHeight*1.5],...
    'String','loeschen',...
    'Interruptible','off',...
    'Callback','zmenu(''DeletePol'');');

  %============================
  % Button Polstelle einfügen =
  %============================
  uicontrol( ...
    'Style','PushButton','Units','normalized',...
    'Position',[.55 frmTop-5*textHeight .02 1.5*textHeight],...
    'String','x',...
    'CallBack','zmenu(''SetPol'');');

  %================================
  % P/N-Koordinaten - Eingabefeld =
  %================================
  uicontrol( ...
    'Style','edit','Units','normalized',...
    'Position',[0.55+0.025 frmTop-5*textHeight+0.005 .2 textHeight*1.25],...
    'String','0',...
    'UserData',0,'Tag','z_anz_koord',...
    'CallBack','zmenu(''SetKoord'');');

  %===================================
  % Verstärkungsfaktor - Eingabefeld =
  %===================================
  uicontrol( ...
    'Style','text','Units','normalized',...
    'Position',[0.55+0.0025 frmTop-6.5*textHeight+0.005 .125 textHeight*1.25],...
    'String','Faktor:','Background',my_color);

  uicontrol( ...
    'Style','edit','Units','normalized',...
    'Position',[0.65+0.025 frmTop-6.5*textHeight+0.005 .075 textHeight*1.25],...
    'String',num2str(k_gain),...
    'Tag','z_gain','CallBack','zmenu(''SetGain'');');

  %========================
  % Frequenzgangauflösung =
  %========================
  uicontrol( ...
    'Style','text','String','FFT-Länge:','units','normalized',...
    'Background',my_color,...
    'Position',...
    [0.25 frmTop-2.25*textHeight .11 textHeight]);
  uicontrol( ...
    'Style','popupmenu','Units','normalized',...
    'Position',[0.37 frmTop-2.5*textHeight .08 textHeight],...
    'String',...
    '32|64|128|256|512|1024|2048',...
    'Value',4,...
    'Tag','z_Aufloesung','UserData',256,...
    'Callback','zmenu(''GetValue'');');

  %=========================
  % Was wird dargestellt ? =
  %=========================
  uicontrol( ...
    'Style','popupmenu','Tag','z_auswahl','Units','normalized',...
    'Position',[0.04 frmTop-2.5*textHeight .2 textHeight],...
    'String',['Amplitude|Phase|',...
    'Amplitude und Phase|Gruppenlaufzeit|s-Ebene'],...
    'Callback','zmenu(''NewDisplay'');');

  %=================================
  % Amplitude linear/logarithmisch =
  %=================================
  uicontrol( ...
    'Style','popupmenu','Tag','z_scale','Units','normalized',...
    'Position',[0.04 frmTop-4.5*textHeight .2 textHeight],...
    'String', ...
    'lineare Skalierung|logarith. Skalierung',...
    'Callback','zmenu(''NewDisplay'');');

  %================
  % Phase deg/rad =
  %================
  uicontrol( ...
    'Style','popupmenu','Tag','z_deg/rad','Units','normalized',...
    'Position',[0.04 frmTop-6.5*textHeight .2 textHeight],...
    'String', ...
    'Phase in Grad|Phase in Rad',...
    'Callback','zmenu(''NewDisplay'');');

  %============================
  % checkbox für unwrap phase
  uicontrol( ...
    'Style','checkbox','Tag','z_checkbox_wrap','Units','normalized',...
    'Position',[0.25 frmTop-4.5*textHeight .2 textHeight*1.5],...
    'String','unwrap Phase',...
    'Value',1,'Background',my_color, ...
    'Callback','zmenu(''NewDisplay'');');

  %======================
  % Normierung checkbox =
  %======================
  uicontrol( ...
    'Style','checkbox','Tag','z_checkbox_norm','Units','normalized',...
    'Position',[0.25 frmTop-6.5*textHeight .2 textHeight*1.5],...
    'String','normierte Amplitude',...
    'Value',1,'Background',my_color, ...
    'Callback','zmenu(''NewDisplay'');');

  %==================
  % Erstelle Achsen =
  %==================
  if nargin<2,  ZEROS=[]; POLES=[];
  else ZEROS=Nullen; POLES=Pole; end
  ax_time=axes(...
    'Position',[.582 .34 .4 .4/2*3],'XLim',[-1 1],'YLim',[-2 2],...
    'Tag','z_PN','DrawMode','Fast','Interruptible','on','Box','on');
  ax_freq=axes(...
    'Position',[.08 .34 .41 .6],'XLim',[0 .5],'YLim',[0 1.1], ...
    'Tag','z_SP','DrawMode','Fast','Interruptible','on','Box','on');
 %===============
 % Init z-Ebene =
 %===============
  axes(ax_time);

  %=========================
  % berechne Einheitskreis =
  %=========================
  th = 0:pi/50:2*pi;
  xunit = cos(th); yunit = sin(th);

  %===========================================
  % Bildaufbau (Achsen/Pole/Nullstellen/...) =
  %===========================================
%  time_line=plot(xunit,yunit,':k',0,0,'ok',0,0,'xk','EraseMode','xor',...
%     'Interruptible','off');
  time_line=line(xunit,yunit); set(time_line,'LineStyle',':')
  time_line(2)=line(0,0); set(time_line(2),'LineStyle','none','Marker','o')
  time_line(3)=line(0,0); set(time_line(3),'LineStyle','none','Marker','x','MarkerSize',10)
  
  set(time_line,'EraseMode','Normal','ButtonDownFcn','zmenu(''down'');',...
     'Color','k','Interruptible','off');
  time_linep=time_line(3); time_line=time_line(2);
  set(time_linep,'XData',real(POLES),'YData',imag(POLES));
  set(time_line,'XData',real(ZEROS),'YData',imag(ZEROS));
  axis([-1.1 1.1 -1.1 1.1]); grid on;
  xlabel('Real(z)'); ylabel('Imag(z)');
  title('PN-Diagramm','Color','k','FontSize',12);
  Wn=0:0.5/256:0.5; % 256 ist default-Wert

 %====================================
 % Initialisiere Frequenzdarstellung =
 %====================================
  axes(ax_freq);

  %=============
  % Bildaufbau =
  %=============
  
  % freq_line=plot(Wn,ones(size(Wn)),'-k','EraseMode','xor');
  freq_line=line(Wn,ones(size(Wn)));
  set(freq_line,'EraseMode','xor','LineStyle','-','Color','k','Marker','none');
  xlabel('normierte Frequenz','FontSize',12,'Color','k');
  ylabel('Amplitude','FontSize',12,'Color','k');
  axis([0 .5 0 1.1]); grid on;
 %===========================================
 % Speichere wichtige Daten in gcf,UserData =
 %===========================================
  USER_DATA=[time_line; ax_time; 0;freq_line; 0; time_linep; k_gain];
  set(figNumber,'UserData',USER_DATA);

  %========================================
  % Zoomen in Frequenzbereich vorbereiten =
  %========================================
  set(ax_freq,'ButtonDownFcn','zoomok(''down'',[0 0.5]);zmenu(''redraw'');');
  set(get(ax_freq,'children'),'ButtonDownFcn','zoomok(''down'',[0 0.5]);');

  %====================================
  % Achsenbeschriftung,Schrift ändern =
  %====================================
  set([ax_freq,ax_time],'FontSize',10,'Ycolor','k','Xcolor','k',...
      'XMinorTick','on','YMinorTick','on');

  %============================================
  % Mauszeiger zurücksetzen von Uhr auf Pfeil =
  %============================================
  set(gcf,'Pointer','Arrow');

  %============
  % -> redraw =
  %============
  zmenu('redraw');

  return

elseif strcmp(action,'down')
  %===============================
  % linker Mausbutton gedrückt ? =
  %===============================
  if ~strcmp(get(gcf,'SelectionType'),'normal'), return; end

  %==============================
  % Koordinaten des Mauszeigers =
  %==============================
  pt=get(USER_DATA(2),'currentpoint');
  x=pt(1,1); y=pt(1,2);

  %=================================
  % nächste Position zum Mausklick =
  %=================================
  line_x=get(USER_DATA(1),'XData');
  line_y=get(USER_DATA(1),'YData');
  line_v=get(USER_DATA(6),'XData');
  line_w=get(USER_DATA(6),'YData');
  dist=(line_x-x).^2+(line_y-y).^2;
  dis2=(line_v-x).^2+(line_w-y).^2;
  [min_dis2,INDE2]=min(dis2);
  [min_dist,INDEX]=min(dist);
  if isempty(min_dist), min_dist=100; end % Sonderfall keine Nullstelle vorhanden
  if min_dis2<min_dist
    USER_DATA(3)=USER_DATA(6);
    USER_DATA(5)=INDE2;
  else % Sonderfall kein Pol wird durch else abgefangen
    USER_DATA(3)=USER_DATA(1);
    USER_DATA(5)=INDEX;
  end

  %============================================
  % EraseMode xor setzen -> Farben invers bei MATLAB 4 !!! =
  %============================================
  set(USER_DATA(3),'EraseMode','xor','Color','k');
  set(USER_DATA(4),'EraseMode','xor','Color','k');
  if plot_auswahl==5
    set(findobj('Tag','zmenu_line2'),'EraseMode','xor','Color','k');
  end

  %====================
  % USER_DATA sichern =
  %====================
  set(gcf,'userdata',USER_DATA);

  %==============================
  % Maus bewegen oder loslassen =
  %==============================
  set(gcf,'WindowButtonUpFcn','zmenu(''up'');');
  set(gcf,'WindowButtonMotionFcn','zmenu(''move'');');

  %==================================================
  % Erzwinge 'up'-Aufruf -> führt so zu Fehlern !!! =
  %==================================================
%   set(gcf,'Interruptible','on'); % damit ButtonUp auch bei Motion wirksam
   			            % wenn on dann Fehler bei Verarbeitung
   return

elseif strcmp(action,'move')
  %==============================
  % Verstärkungsfaktor auslesen =
  %==============================
  k_gain=USER_DATA(7);

  %=========================
  % Mausposition ermitteln =
  %=========================
  pt=get(USER_DATA(2),'currentpoint');
  xc=pt(1,1); yc=pt(1,2);

  %=====================================
  % Achsenbegrenzungen berücksichtigen =
  %=====================================
  x_lim=get(USER_DATA(2),'XLim'); y_lim=get(USER_DATA(2),'YLim');
  if xc>x_lim(2), xc=x_lim(2);
  elseif xc<x_lim(1), xc=x_lim(1); end
  if yc>y_lim(2), yc=y_lim(2);
  elseif yc<y_lim(1), yc=y_lim(1); end

  %=========================================
  % je nach Auswahl, Pol oder Null - Daten =
  %=========================================
  DATA=get(USER_DATA(3),'XData')+j*get(USER_DATA(3),'YData');

  %====================
  % Bewegen von P/N's =
  %====================
  if yc==0, yc=eps; end  % damit konjugiert komplexe erhalten bleiben
  if abs(yc)>=0 & imag(DATA(INDEX))~=0  	  % komplex -> komplex
    INDEX2=min(find(DATA==conj(DATA(INDEX))));
    DATA(INDEX)=xc+j*yc;
    DATA(INDEX2)=xc-j*yc;
  else % imag(DATA(INDEX))==0  % rell -> reell
    DATA(INDEX)=xc;
  end

  %===============================
  % Aktuelle Koordinate anzeigen =
  %===============================
  hdl_koord=findobj('Tag','z_anz_koord');
  str=num2str(DATA(INDEX)); num=eval(str,'0');
  set(hdl_koord,'String',str,'UserData',num);

  %========================
  % Neue Position sichern =
  %========================
  if USER_DATA(3)==USER_DATA(1), ZEROS=DATA; else POLES=DATA; end
  indizes=find(abs(POLES)==1);

  %==============================================
  % Abfangen von 'log of zero', wenn Pol auf EK =
  %==============================================
  if ~isempty(indizes), POLES(indizes)=POLES(indizes)+0.001; end

  %==========================
  % Koeffizienten berechnen =
  %==========================
  [b,a]=zp2tf(ZEROS.',POLES.',k_gain);

  %==============================================================
  % nicht-kausales Filter zur Darstellung mit freqz vorbereiten =
  %==============================================================
  if length(b)>length(a)
    a=[zeros(1,length(b)-length(a)),a];
  end

 %=================================
 % Berechne Werte für linke Achse =
 %=================================
  plot_auswahl=get(findobj('Tag','z_auswahl'),'Value');

  %====================
  % Amplitude / Phase =
  %====================
  if plot_auswahl<4
    [H,Wn]=freqz(b,a,ANZAHL); Wn=Wn/2/pi;
  end

  %===========================================
  % Amplitude linear/logarithmisch, normiert =
  % oder Amplitude und Phase (rad,deg;wrap)  =
  %===========================================
  if plot_auswahl==1|plot_auswahl==3
    FREQ=abs(H);

    %=============
    % normiert ? =
    %=============
    if get(findobj('Tag','z_checkbox_norm'),'Value')
      maxFREQ=max(FREQ); FREQ=FREQ/maxFREQ;
    end

    %======================
    % Amplitude und Phase =
    %======================
    if plot_auswahl==3
      hdl=findobj('Tag','z_Linie_unten');
      FREQ2=angle(H);
      %=================
      % unwrap Phase ? =
      %=================
      if get(findobj('Tag','z_checkbox_wrap'),'Value')
        FREQ2=unwrap(FREQ2);
      end
      %===================
      % Phase in rad/deg =
      %===================
      if get(findobj('Tag','z_deg/rad'),'Value')==1
        FREQ2=FREQ2/pi*180;
      end
      %=====================================
      % setze Werte für untere linke Achse =
      %=====================================
      set(hdl,'XData',Wn,'YData',FREQ2,'Color','k'); %'w'
    end
    %============================
    % Amplitude logarithmisch ? =
    %============================
    if get(findobj('Tag','z_scale'),'Value')==2
      % indx=find(FREQ~=0); mini=min(FREQ(indx)); % Vermeidung von log(0) !!
      % indx=find(FREQ==0); FREQ(indx)=mini*ones(size(indx));
      FREQ=20*log10(FREQ+eps);
    end
  %============
  % nur Phase =
  %============
  elseif plot_auswahl==2
    FREQ=angle(H);

    %===========
    % unwrap ? =
    %===========
    if get(findobj('Tag','z_checkbox_wrap'),'Value')
      FREQ=unwrap(FREQ);
    end

    %==========
    % deg/rad =
    %==========
    if get(findobj('Tag','z_deg/rad'),'Value')==1
      FREQ=FREQ/pi*180;
    end
  elseif plot_auswahl==4
  %==================
  % Gruppenlaufzeit =
  %==================
    [FREQ,Wn]=grpdelay(b,a,ANZAHL); Wn=Wn/2/pi;
  else % if plot_auswahl==5
  %==========
  % s-Ebene =
  %==========
    [Zs,Ps]=invbilin(ZEROS,POLES);
    FREQ=imag(Zs); Wn=real(Zs);
    set(USER_DATA(4),'LineStyle','none','Marker','o');
    hdl_line2=findobj('Tag','zmenu_line2');
    set(hdl_line2,'XData',real(Ps),'YData',imag(Ps));
    hdl=get(USER_DATA(4),'Parent');
  end

  %===================================
  % setze P/N und linke Achse        =
  % (linke untere wird oben gesetzt) =
  % und unter ->NewDisplay erzeugt   =
  %===================================
  set(USER_DATA(4),'YData',FREQ,'XData',Wn);
  set(USER_DATA(3),'YData',imag(DATA),'XData',real(DATA));

  %====================
  % USER_DATA sichern =
  %====================
  USER_DATA(5)=INDEX;
  set(gcf,'userdata',USER_DATA);

  %===================
  % aktualisiere gcf =
  %===================
  drawnow;

  return

elseif strcmp(action,'up')
  %=================================
  % Mausabfrage wieder ausschalten =
  %=================================
  set(gcf,'WindowButtonMotionFcn','');
  set(gcf,'WindowButtonUpFcn','');

  %=================================
  % Interruptible wieder no (s.o.) =
  %=================================
%   set(gcf,'Interruptible','off');

  zmenu('redraw');
  return

elseif strcmp(action,'redraw')

  %===================
  % ermittle Handles =
  %===================
  hdl_left_ax=get(USER_DATA(4),'Parent');
  hdl_right_ax=get(USER_DATA(1),'Parent');

  %======================
  % rechte Achse -> gca =
  %======================
  axes(hdl_right_ax);

  %============================
  % Warnung, wenn Pole auf EK =
  %============================
  indizes=find(abs(POLES)==1);
  if ~isempty(indizes)
    %==========
    % WARNUNG =
    %==========
    uiwait(msgbox('-> Pol(e) auf dem Einheitskreis !','ACHTUNG','none','modal'));
  else
    %======================
    % Ausgabe vorbereiten =
    %======================
    [b,a]=zp2tf(ZEROS.',POLES.',USER_DATA(7));

    %==============================================================
    % nicht-kausales Filter zur Darstellung mit freqz vorbereiten =
    %==============================================================
    if length(b)>length(a)
      a=[zeros(1,length(b)-length(a)),a];
    end

    if plot_auswahl<4
      %==================
      % Amplitude/Phase =
      %==================
      [H,Wn]=freqz(b,a,ANZAHL); Wn=Wn/2/pi;
    elseif plot_auswahl==4
      %==================
      % Gruppenlaufzeit =
      %==================
      [FREQ,Wn]=grpdelay(b,a,ANZAHL); Wn=Wn/2/pi;
    else % plot_auswahl==5
      %==========
      % s-Ebene =
      %==========
      [Zs,Ps]=invbilin(ZEROS,POLES);
      FREQ=imag(Zs); Wn=real(Zs);
    end
    %=====================
    % linke Achse -> gca =
    %=====================
    axes(hdl_left_ax);

    %===================================
    % P/N-Beschriftung 'links' löschen =
    %===================================
    hdl_t2=findobj(hdl_left_ax,'Tag','z_text2');
    if ~isempty(hdl_t2), delete(hdl_t2); end

    if plot_auswahl==1 | plot_auswahl==3
    %==================
    % Ampltitude/Phase=
    %==================
      FREQ=abs(H); maxFREQ=max(FREQ);

      %=============================
      % Maximum als Titel anzeigen =
      %=============================
      str=['| Hmax(w) | = ' num2str(maxFREQ)];
      set(get(hdl_left_ax,'Title'),'String',str,'FontSize',12,'Color','k');

      %==============
      % Normieren ? =
      %==============
      if get(findobj('Tag','z_checkbox_norm'),'Value')
        FREQ=FREQ/maxFREQ;
      end

      if plot_auswahl==3
        %====================
        % Amplitude & Phase =
        %====================
        %=======================
        % hdls 2.Achse (links) =
        %=======================
        hdl=findobj('Tag','z_Linie_unten');
        hdl_left_ax2=get(hdl,'Parent');

        %=========
        % unwrap =
        %=========
        if get(findobj('Tag','z_checkbox_wrap'),'Value');
          FREQ2=unwrap(angle(H));
        else
          FREQ2=angle(H);
        end

        %==========
        % rad/deg =
        %==========
        if get(findobj('Tag','z_deg/rad'),'Value')==1
          FREQ2=FREQ2/pi*180;
        end

        %=================
        % Werte zuweisen =
        %=================
        set(hdl,'XData',Wn,'YData',FREQ2,'Color','k'); % 'w'

        %=============================
        % 2.Achse setzen/beschriften =
        %=============================
        minF=min(FREQ2);
        maxF=max(FREQ2);
        minF=minF-abs(minF)/10; maxF=maxF+abs(maxF)/10;
        set(hdl_left_ax2,'Ylim',[minF-.1 maxF+.1]);
        axes(hdl_left_ax2);
        if get(findobj('Tag','z_deg/rad'),'Value')==1
          ylabel('Phase (°)','FontSize',12);
        else
          ylabel('Phase (rad)','FontSize',12);
        end
      end
      %==========================
      % obere Achse beschriften =
      %==========================
      axes(hdl_left_ax);
      if get(findobj('Tag','z_scale'),'Value')==1
        ylabel('Amplitude','FontSize',12);
      else
        ylabel('Amplitude in dB','FontSize',12);
      end

    elseif plot_auswahl==2
    %========
    % Phase =
    %========
      %============
      % Titel aus =
      %============
      set(get(hdl_left_ax,'Title'),'String','');

      %==================
      % Phase berechnen =
      %==================
      FREQ=angle(H);

      %=========
      % unwrap =
      %=========
      if get(findobj('Tag','z_checkbox_wrap'),'Value')
        FREQ=unwrap(FREQ);
      end

      %==========
      % rad/deg =
      %==========
      if get(findobj('Tag','z_deg/rad'),'Value')==1
        FREQ=FREQ/pi*180;
        ylabel('Phase (°)','FontSize',12);
      else
        ylabel('Phase (rad)','FontSize',12);
      end
    elseif plot_auswahl==4
    %==================
    % Gruppenlaufzeit =
    %==================
      %====================
      % Achse beschriften = -> Berechnung s.o.
      %====================
      set(get(hdl_left_ax,'Title'),'String','');
      ylabel('Gruppenlaufzeit','FontSize',12);
    else % plot_auswahl==5
    %==========
    % s-Ebene =
    %==========
      %====================
      % Achse beschriften = -> Berechnung s.o.
      %====================
      set(get(hdl_left_ax,'Title'),'String','s-Ebene');
    end

    %===========================================================
    % Je nach Zoomstatus Achse automatisch anpassen oder nicht =
    %===========================================================
    zoomtiefe=get(hdl_left_ax,'UserData');
    if isempty(zoomtiefe), zoomtiefe=1; end
    if (plot_auswahl==1|plot_auswahl==3) & ...
       get(findobj('Tag','z_scale'),'Value')==2
    %============================
    % logarithmische Skalierung =
    %============================
      FREQ=20*log10(FREQ+eps);

      if zoomtiefe(1)==1
      %====================================================
      % Zoomtiefe ist 1 -> automatische Achseneinstellung =
      %====================================================
        minF=min(FREQ); maxF=max(FREQ);
        delta=maxF-minF; if delta<1, delta=1; end
        minF=minF-delta/20-eps; maxF=maxF+delta/20+eps;
        set(hdl_left_ax,'Ylim',[minF maxF]);
      end

      %===================
      % Linientyp setzen =
      %===================
      set(USER_DATA(4),'LineStyle','-','Marker','none');

    elseif plot_auswahl~=5
    %===============================
    % nicht log. und nicht s-Ebene =
    %===============================
      %=======================================
      % Achse einstellen (Extrema begrenzen) =
      %=======================================
      W=find(FREQ<1e6);
      minF=min(FREQ(W)); maxF=max(FREQ(W));
      if maxF==minF & (plot_auswahl==1|plot_auswahl==3)
        minF=0; maxF=1.1;
      else
        delta=maxF-minF; if delta<0.1, delta=0.1; end
        maxF=maxF+delta/20;
        if plot_auswahl==1|plot_auswahl==3, minF=0;
        else, minF=minF-delta/20; end
      end
      %=============================================
      % Wenn kein Zoom -> Achse automatisch setzen =
      %=============================================
      if zoomtiefe(1)==1, set(hdl_left_ax,'Ylim',[minF-eps maxF+eps]); end

      %===================
      % Linientyp setzen =
      %===================
      set(USER_DATA(4),'LineStyle','-','Marker','none');
    else
    %==========
    % s-Ebene =
    %==========
      %===================
      % Achse einstellen =
      %===================
      max_y=max([abs(FREQ)+eps,abs(imag(Ps)),1])*1.1;
      max_x=max([abs(Wn)+eps,abs(real(Ps)),1])*1.1;
      if zoomtiefe(1)==1
        set(hdl_left_ax,'Xlim',[-max_x max_x],'Ylim',[-max_y max_y]);
      end

      %===================
      % Linientyp setzen =
      %===================
      set(USER_DATA(4),'LineStyle','none','Marker','o');

      %==================================
      % 2.Linie (Pole) erstellen/setzen =
      %==================================
      hdl_l2=findobj('Tag','zmenu_line2');
      if isempty(hdl_l2)
        line(real(Ps),imag(Ps),'Color','k','EraseMode','normal',...
             'Tag','zmenu_line2','LineStyle','none','Marker','x','MarkerSize',10);
      else
        set(hdl_l2,...
          'XData',real(Ps),'YData',imag(Ps),...
          'EraseMode','normal','Color','k');
      end

      %====================================
      % P/N Anzahl beschriften in s-Ebene =
      %====================================
      axes(hdl_left_ax);
      zmenu('AnzahlText',Ps,'z_text2');
      zmenu('AnzahlText',Zs,'z_text2\b');

      %======================
      % Zoom links erlauben =
      %======================
      set(get(hdl_left_ax,'Children'),...
        'ButtonDownFcn','zoomok(''down'');');
    end

    %==============================
    % Neue Daten (links) zuweisen =
    %==============================
    set(USER_DATA(4),'YData',FREQ,'XData',Wn,...
        'EraseMode','normal','color','k');
  end

  %======================================
  % rechte Achse (z-Ebene aktualisieren =
  %======================================
  set(USER_DATA(1),'YData',imag(ZEROS),'XData',real(ZEROS),...
      'EraseMode','normal','color','k');
  set(USER_DATA(6),'YData',imag(POLES),'XData',real(POLES),...
      'EraseMode','normal','color','k');

  %===============================
  % Pole/Null beschriften /      =
  % zunächst alte Zahlen löschen =
  %===============================
  hdls=findobj(hdl_right_ax,'Tag','z_ZAHLEN');
  if ~isempty(hdls), delete(hdls); end
  axes(hdl_right_ax)
  zmenu('AnzahlText',POLES,'z_ZAHLEN');
  zmenu('AnzahlText',ZEROS,'z_ZAHLEN\b');

  %====================
  % BtnDownFcn setzen =
  %====================
  set(get(hdl_right_ax,'Children'),...
    'ButtonDownFcn','zmenu(''down'');');

  return

elseif strcmp(action,'AnzahlText')
%===================================================
% Anzahl POLE/Nullen anzeigen / num=was, den = TAG =
%===================================================
  %==========================
  % Farbparameter ermitteln =
  %==========================
  pos=findstr(den,'\');
  if isempty(pos), color='r';
  else, color=den(pos+1); den=den(1:pos-1); end

  %===============================================
  % "Gleichheit" durch Achsenabmessung festlegen =
  %===============================================
  ax_size=axis;
  GRENZE=min(ax_size(2)-ax_size(1),ax_size(4)-ax_size(3))/200;

  %==================================
  % Beschriften / einmal pro Gruppe =
  %==================================
  re=real(num); im=imag(num);
%  indx=max(find(num~=0));
%  re=real(num(1:indx)); im=imag(num(1:indx));
  n=1; zahlen=[];
  while length(re)>n;
    indx=find( (im<=im(n)+GRENZE&im>=im(n)-GRENZE)  & ...
               (re<=re(n)+GRENZE&re>=re(n)-GRENZE)  );
    if length(indx)>1,
      zahlen=[zahlen length(indx)];
      indx=indx(2:length(indx));
      n=n+1;
    end
    re(indx)=[]; im(indx)=[];
  end

  for n=1:length(zahlen)
    text(re(n),im(n),num2str(zahlen(n)),'Color',color,...
         'VerticalAlignment','top','FontWeight','normal',...
         'Fontsize',10,'Fontname','Courier','Tag',den,...
         'Clipping','on');
  end

  return

elseif strcmp(action,'SetKoord')
%==========================
% Koordinatenfeld Eingabe =
%==========================
  hdl=findobj('Tag','z_anz_koord');
  str=get(hdl,'String');
  num=eval(str,'0');
  %=====================
  % Koordinate sichern =
  %=====================
  set(hdl,'String',num2str(num),'UserData',num);

  figure(gcf); % --> Eingabe von return schaltet KeyPressFcn aktiv !

elseif strcmp(action,'SetGain')
%============================
% Verstärkungsfaktor setzen =
%============================
  hdl=findobj('Tag','z_gain');
  str=get(hdl,'String');
  num=eval(str,'0');
  if num~=0
    USER_DATA(7)=num;
    set(gcf,'UserData',USER_DATA);
    zmenu('redraw');
  else
    set(hdl,'String',num2str(USER_DATA(7)));
  end

elseif strcmp(action,'SetPol') | strcmp(action,'SetNull')
%==================
% Pol/Null setzen =
%==================
  %=======================
  % Koordinate ermitteln =
  %=======================
  hdl=findobj('Tag','z_anz_koord');
  koord=get(hdl,'UserData');
  if isempty(koord), return;
  else
    %============
    % PN setzen =
    %============
    if imag(koord)~=0, koord=[koord conj(koord)]; end
    if strcmp(action,'SetPol')
      POLES=[POLES koord];
      set(USER_DATA(6),'XData',real(POLES),'YData',imag(POLES));
    else
      ZEROS=[ZEROS koord];
      set(USER_DATA(1),'XData',real(ZEROS),'YData',imag(ZEROS));
    end
    zmenu('redraw');
    return
  end

elseif strcmp(action,'DeletePol') | strcmp(action,'DeleteNull')
%==============
% P/N löschen =
%==============
  %==================
  % Empfindlichkeit =
  %==================
  GRENZE=0.001;

  %===================================================
  % Vorgang anzeigen vorbereiten/Handle-Index setzen =
  %===================================================
  if strcmp(action,'DeletePol')
    DATA_INDEX=6; str=('Polstelle wählen');
  else
    DATA_INDEX=1; str=('Nullstelle wählen');
  end

  %=====================
  % P/N-Daten auslesen =
  %=====================
  x_data=get(USER_DATA(DATA_INDEX),'XData');
  y_data=get(USER_DATA(DATA_INDEX),'YData');

  if ~isempty(x_data)
    %===================
    % Vorgang anzeigen =
    %===================
    hdl_title=get(USER_DATA(2),'Title');
    set(hdl_title,'String',str);

    %======================
    % warte auf Mausclick =
    %======================
    waitforbuttonpress;

    %=====================
    % Mausclick-Position =
    %=====================
    pt=get(USER_DATA(2),'CurrentPoint');
    x=pt(1,1); y=pt(1,2);

    %=================
    % Abstand zu P/N =
    %=================
    dist=(x_data-x).^2+(y_data-y).^2;
    [min_dist,index]=min(dist);

    %======================================
    % löschen, wenn P/N im GRENZE-Bereich =
    %======================================
    if min_dist<GRENZE
      if y_data(index)==0
      %=====================
      % reelle P/N löschen =
      %=====================
        x_data(index)=[]; y_data(index)=[];
      else
      %=======================
      % komplexe P/N löschen =
      %=======================
        POLES=x_data+j*y_data;
        index2=min(find(POLES==conj(POLES(index))));
        x_data([index,index2])=[]; y_data([index,index2])=[];
      end

      %================================
      % USER_DATA & gcf aktualisieren =
      %================================
      set(USER_DATA(DATA_INDEX),'XData',x_data,'YData',y_data);
      zmenu('redraw');
    end

    %=====================
    % Titel zurücksetzen =
    %=====================
    set(hdl_title,'String','PN-Diagramm');
  end

  return;

elseif strcmp(action,'GetValue')
%============================
% Anzahl Abtastwerte setzen =
%============================
  %=======================
  % Ermittle Einstellung =
  %=======================
  hdl_edit=findobj('Tag','z_Aufloesung');
  potenz=get(hdl_edit,'Value');

  %====================================
  % pot=1 -> 32-Abtatswerte berechnen =
  %====================================
  anzahl=2^(potenz+4);  % pot=1 -> 32er fft

  %=============================================
  % speichere Wert in UserData des popupmenu's =
  %=============================================
  set(hdl_edit,'UserData',anzahl);

  zmenu('redraw');

  return;

elseif findstr(action,'Zoom_')
%========================
% Zoom in/out : z-Ebene =
%========================
  %=================
  % z-Ebene -> gca = ist bereits gesetzt
  %=================
  % axes(get(USER_DATA(1),'Parent'));

  %====================
  % Achseneinstellung =
  %====================
  ax=axis; SCALE=16;
  dx=ax(2)-ax(1); dy=ax(4)-ax(3);

  if findstr(action,'_in')
    %==========
    % Zoom in =
    %==========
    axis([ax(1)+dx/SCALE,ax(2)-dx/SCALE,ax(3)+dy/SCALE,ax(4)-dy/SCALE]);
  elseif findstr(action,'_out')
    %===========
    % Zoom out =
    %===========
    dx=dx/(SCALE-2); dy=dy/(SCALE-2);
    axis([ax(1)-dx,ax(2)+dx,ax(3)-dy,ax(4)+dy]);
  end

elseif strcmp(action,'NewDisplay')
%===============================
% Neue Darstellungsart gewählt =
%===============================
  %============================
  % Daten & Handles ermitteln =
  %============================
  ax_freq=findobj('Tag','z_SP');
  hdl_auswahl=findobj('Tag','z_auswahl');
  plot_auswahl=get(hdl_auswahl,'Value');

  %========================================
  % Defaultwert für Xlim der linken Achse =
  %========================================
  set(ax_freq,'UserData','','Xlim',[0 0.5]);

  if plot_auswahl==3
    %==========================================
    % Amplitude & Phase darstellen (2 Achsen) =
    %==========================================
    if isempty(get(hdl_auswahl,'UserData'))  % Hdl 2.Achse vorhanden?
      %===================
      % 1.Achse anpassen =
      %===================
      axes(ax_freq); xlabel('');
      set(ax_freq,'Position',[0.08 0.64 0.41 0.3]);

      %====================
      % 2.Achse erstellen =
      %====================
      ax2=axes('Position',[0.08 0.34 0.41 0.26],'xcolor','k','ycolor','k',...
        'FontSize',10,'XGrid','on','YGrid','on','Box','on',...
        'Xlim',[0 .5],'Tag','z_SP2','XMinorTick','on','YMinorTick','on');
      axes(ax2); ylabel('Phase','FontSize',12,'Color','k');
      xlabel('normierte Frequenz','FontSize',12,'Color','k');

      %===========================================
      % 2.Linie erstellen/Farbe wegen xor invers =
      %===========================================
      line(0,0,'Tag','z_Linie_unten','EraseMode','xor','Color','k');
      set(hdl_auswahl,'UserData',ax2);  % 2.Achse Handle

      %==================================
      % MausZoom für 2.Achse aktivieren =
      %==================================
      set(ax2,'ButtonDownFcn','zoomok(''down'',[0 .5]);');
      set(get(ax2,'children'),'ButtonDownFcn','zoomok(''down'',[0 .5]);');
    else
      %==============================
      % eventuellen Zoom rücksetzen =
      %==============================
      set(get(hdl_auswahl,'UserData'),'UserData','','Xlim',[0 0.5]);
    end
  else
    %==============================
    % eine Achse darstellen = gca =
    %==============================
    axes(ax_freq);

    %==========================================================
    % wenn 2.Achse vorhanden, dann löschen & 1.Achse anpassen =
    %==========================================================
    ax2=get(hdl_auswahl,'UserData');
    if ~isempty(ax2)
      delete(ax2);
      set(ax_freq,'Position',[0.08 0.34 0.41 0.6]);
      set(hdl_auswahl,'UserData',[]);
    end

    if plot_auswahl==5,
    %==========
    % s-Ebene =
    %==========
      xlabel('Re(s)','FontSize',12);
      ylabel('Im(s)','FontSize',12);
      set(ax_freq,'ButtonDownFcn','zoomok(''down'');');
      set(get(ax_freq,'children'),'ButtonDownFcn','zoomok(''down'');');
    else
      xlabel('normierte Frequenz','FontSize',12);
      set(ax_freq,'ButtonDownFcn','zoomok(''down'',[0 .5]);');
      set(get(ax_freq,'children'),'ButtonDownFcn','zoomok(''down'',[0 .5]);');
    end
  end

  zmenu('redraw');

  return;

elseif strcmp(action,'KeyPress')
%============================
% Tastatureingaben abfragen =
%============================
  %================
  % Eingabe holen =
  %================
  char=get(gcf,'CurrentChar');

  %================
  % z-Ebene = gca =
  %================
  axes(get(USER_DATA(1),'Parent'));

  %=================================
  % z-Ebene mit Zahlenblock ändern =
  %=================================
  ax=axis; SCALE=16;
  dx=ax(2)-ax(1); dy=ax(4)-ax(3);
  if char=='4',      axis([ax(1:2)-dx/SCALE,ax(3:4)]);
  elseif char=='6', axis([ax(1:2)+dx/SCALE,ax(3:4)]);
  elseif char=='8',    axis([ax(1:2),ax(3:4)+dy/SCALE]);
  elseif char=='2',  axis([ax(1:2),ax(3:4)-dy/SCALE]);
  elseif char=='7',  axis([ax(1:2)-dx/SCALE,ax(3:4)+dy/SCALE]);
  elseif char=='9',  axis([ax(1:2)+dx/SCALE,ax(3:4)+dy/SCALE]);
  elseif char=='1',  axis([ax(1:2)-dx/SCALE,ax(3:4)-dy/SCALE]);
  elseif char=='3',  axis([ax(1:2)+dx/SCALE,ax(3:4)-dy/SCALE]);
  elseif char=='5',axis([-1.1 1.1 -1.1 1.1]);
  elseif char=='+', zmenu('Zoom_in');zmenu('redraw');pause(.01);
  elseif char=='-', zmenu('Zoom_out');zmenu('redraw');pause(.01);

  %=HINWEIS=%
  % pause vermeidet einen Stapeüberlauf bei der
  % Programmabarbeitung -> MATLAB-Bug

  %=================
  % Hilfe aufrufen =
  %=================
  elseif char=='h', zmenu('help');

  %=============
  % P/N setzen =
  %=============
  elseif char=='o', zmenu('SetNull');
  elseif char=='x', zmenu('SetPol');

  return

  end

elseif strcmp(action,'help')
%=========================
% Windows-Hilfe aufrufen =
%=========================
  !winhelp zmenu.hlp

elseif findstr(action,'close') % gilt für close_ok und close_cancel
%=============
% OK/Beenden =
%=============
  %=========================
  % einige Handles & Daten =
  %=========================
  current_figure=gcf;
  hdl_main=findobj('Tag','hauptfenster');
  USER_DATA=get(gcf,'UserData');
  k_gain=USER_DATA(7);

  %============
  % OK Button =
  %============
  if strcmp(action,'close_ok')
    %=======================
    % Filter kausal machen =
    %=======================
    if length(POLES)<length(ZEROS)
     anzahl=length(ZEROS)-length(POLES);
     POLES=[POLES,zeros(1,anzahl)];
     str=sprintf('Filter nicht kausal -> %d Pol(e) hinzugefügt !',anzahl);
     uiwait(msgbox(str,'Hinweis','none','modal'));
    end

    [num,den]=zp2tf(ZEROS.',POLES.',k_gain);
    den=den(1:max(find(den~=0)));
    if ~isempty(hdl_main)
      global b a; b=num; a=den;
      global filtertyp; filtertyp=7;
      makeprot('zmenu',[],num,den);
    end
  end

  %===============
  % OK & Beenden =
  %===============
  close(current_figure);

  %====================================
  % Reihenfolge beibehalten, da sonst =
  % Fehler beim Bildaufbau auftreten  =
  % können. (MATLAB-Bug/Windows ?!?)  =
  %====================================
  if ~isempty(hdl_main)
    set(hdl_main,'Visible','on');
    if strcmp(action,'close_ok')
      %======================================================
      % OK Button -> eventuelles Hauptfenster aktualisieren =
      %======================================================
      drawmain(b,a,'ZMENU Ergebnis');
    end
  end
end

