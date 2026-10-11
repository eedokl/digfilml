function filtplot(action,s);

% Die Funktion FILTPLOT ist ein Programm zur
% Filteranalyse im Frequenzbereich.
% Es verwendet die Koeffizienten der
% Übertragungsfunktion H(z), die global
% als b und a vorliegen müssen !
%
% Die berechneten Daten werden im aktuellen
% Fenster dargestellt.
%
% Aufruf : FILTPLOT(action,{param})
%          action : 'initialize'
%          param  : Schriftgröße (default=8)
%
% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover
%

% verwendete Objekt-Tags ({}=default) :
%
% plotter_Achse1                    : Achse1 ({oben})
% plotter_Achse2                    : Achse2 (unten)
% plotter_area_auswahl  popupmenu   : Zeit/Frequenzbereich
% plotter_axis          edit-Objekt : Achseneinstellung
% plotter_check_ideal               : Ideales Filter
% plotter_check_marker              : Marker ein/{aus}
% plotter_check_norm                : Normierung ein/{aus}
% plotter_check_wrap                : unwrap Phase {ein}/aus
% plotter_deg/rad                   : Phase in {deg}/rad
% plotter_Linie1                    : Linie in Achse1
% plotter_Linie2                    : Linie in Achse2
% plotter_plot3d                    : 3d plot/z_Ebene
% plotter_plot_auswahl  popupmenu   : Darstellungsart
% plotter_quant_check               : quantisieren ein/{aus}
% plotter_quant_slider              : Bit-Anzahl
% plotter_scale         popupmenu   : lin/log
% plotter_text_x        text        : Marker-Ausgabe Achse1
% plotter_text_x2       text        : Marker-Ausgabe Achse1
% plotter_text_y        text        : Marker-Ausgabe Achse2
% plotter_text_y2       text        : Marker-Ausgabe Achse2
% plotter_title_edit    edit        : Titeleingabefenster
% plotter_z                         : Zahlen in z/s-Ebene
% plotter_z1                        : Kreis in z-Ebene
% Ver                               : Markerlinie Achse1
% Ver2                              : Markerlinie Achse2

      % HINWEIS : YMINORTICK
      % UNBEDINGT AUSSCHALTEN, DA SONST FEHLER IN GCA-HANDLING
      % WELCHES ZU EINEM MARKERPROBLEM FÜHRT

%===============================
% verwendete globale Variablen =
%===============================
  global b a;
  num=b; den=a;

if length(num)<2 & length(den)<2 & ~strcmp(action,'close')
   fehler('','Darstellung nicht möglich !',...
     'Keine oder nicht genügend Filterkoeffizienten vorhanden.');
   return
else
   hdl=findobj('Label','&Filteranalyse');
   if ~isempty(hdl), set(hdl,'Enable','off'); end
end;

%============================
% wenn kein Aufrufparameter =
%============================
if nargin<1,
    action='initialize';
end;

if strcmp(action,'initialize')
%=====================
% GUI initialisieren =
%=====================
  %================================
  % Bildschirmauflösung ermitteln =
  %================================
  scr_size=get(0,'ScreenSize');
  if nargin==0|nargin==1, fontsize=8; else fontsize=s; end

  %===========================================
  % GUI muß trotz normierter Position-Angabe =
  % etwas nachskaliert werden                =
  %===========================================
  if scr_size(3)<645, yscale=0.039;
  elseif scr_size(3)<805, yscale=0.015;
  else yscale=-0.0225; end

  %====================================================
  % Berechne 'textHeight' für Fenster "mit" uimenu !! =
  %====================================================
  textHeight=fontsize/scr_size(4)*1.72;
  scr_size(3:4)=scr_size(3:4)-2;
  set(gcf,'Color','w','InvertHardcopy','off');

  %=================================
  % Informationen für alle Objekte =
  %=================================
  menutop=0.95;
  btnTop = 0.6;
  left=0.03;
  frmBorder=0.019;
  frmBottom=0.05;
  frmHeight = 0.92;
  frmWidth = 0.175;
  top=0.88;
  my_color=[192 192 192 ]/255;
  mtc='black';
  btnWid=0.175;
  btnHt=0.06;
  textWidth = 0.06;

  %===================
  % Achse1 erstellen =
  %===================
  axes( ...
    'Units','normalized', ...
    'Position',[0.36 0.1 0.56 0.84], ...
    'Xcolor','black', ...
    'Ycolor','black', ...
    'XGrid','on','YGrid','on',...
    'XLim',[0 0.5], ...
    'ButtonDownFcn','filtplot(''ax_click'');',...
    'Box','on','Tag','plotter_Achse1');
  xlabel('','Color','k'); ylabel('','Color','k');
  title('','Color','k');

  %=================
  % Rahmen für GUI =
  %=================
  yPos=frmBottom-frmBorder;
  frmPos=[left yPos frmWidth+2*frmBorder frmHeight+2*frmBorder];
  uicontrol( ...
    'Style','frame', ...
    'Units','normalized', ...
    'Position',frmPos, ...
    'Clipping','off', ...
    'Background',my_color);

  %===============
  % Farbe heller =
  %===============
  my_color=my_color+0.05;

  %====================
  % Rahmen1 im Rahmen =
  %====================
  yPos=frmBottom-frmBorder;
  frmPos=[left+.01 top-11.5*textHeight+0.01 ...
          frmWidth+2*frmBorder-0.02 10.5*textHeight];
  uicontrol( ...
    'Style','frame', ...
    'Units','normalized', ...
    'Position',frmPos, ...
    'Clipping','off', ...
    'Background',my_color);

  %====================
  % Rahmen2 im Rahmen =
  %====================
  yPos=frmBottom-frmBorder;
  frmPos=[left+.01 top-16.75*textHeight+0.01 ...
          frmWidth+2*frmBorder-0.02 4.5*textHeight];
  uicontrol( ...
    'Style','frame',...
    'Units','normalized', ...
    'Position',frmPos, ...
    'Clipping','off', ...
    'Background',my_color);

  %====================
  % Rahmen3 im Rahmen =
  %====================
  yPos=frmBottom-frmBorder;
  frmPos=[left+.01 top-25.75*textHeight+0.01 ...
          frmWidth+2*frmBorder-0.02 8.25*textHeight];
  uicontrol( ...
    'Style','frame', ...
    'Units','normalized', ...
    'Position',frmPos, ...
    'Clipping','off', ...
    'Background',my_color);

  %=======================================
  % The Filter Analysis Selection Menu 1 =
  % Hier wird 'fontsize' gespeichert !   =
  %=======================================
  yPos=1-textHeight*.5;
  btnPos=[left+frmBorder yPos-btnHt btnWid textHeight];
  uicontrol( ...
    'Style','popupmenu', ...
    'Units','normalized', ...
    'Position',btnPos, ...
    'String','Frequenzbereich|Zeitbereich', ...
    'Interruptible','on', ...
    'Value',1, ...
    'Background',my_color, ...
    'Foreground',mtc, ...
    'Tag','plotter_area_auswahl', ...
    'UserData',fontsize, ...
    'Callback','filtplot(''Other'');');

  %=======================================
  % The Filter Analysis Selection Menu 2 =
  %=======================================
  yPos=1-textHeight*2.25;
  btnPos=[left+frmBorder yPos-btnHt btnWid textHeight];
  labelStr=['Amplitude|Phase|Amplitude und Phase|Gruppenlaufzeit',...
            '|PN-Verteilung (z)|PN-Verteilung (s)|z-Ebene (3D)'];
  uicontrol( ...
    'Style','popupmenu', ...
    'Units','normalized', ...
    'Position',btnPos, ...
    'String',labelStr, ...
    'Interruptible','on', ...
    'Foreground',mtc, ...
    'Background',my_color, ...
    'Tag','plotter_plot_auswahl', ...
    'Callback','filtplot(''NewDisplay'');');

  %=================================
  % Amplitude linear/logarithmisch =
  %=================================
  uicontrol('Style','popupmenu','Tag','plotter_scale',...
    'Units','normalized',...
    'Position',[left+frmBorder 1-8*textHeight+yscale*2 btnWid textHeight],...
    'String','lineare Amplitude|logarith. Amplitude',...
    'Background',my_color, ...
    'Callback','filtplot(''NewDisplay'');');

  %================
  % Phase deg/rad =
  %================
  uicontrol('Style','popupmenu','Tag','plotter_deg/rad',...
    'Units','normalized',...
    'Position',[left+frmBorder 1-textHeight*9.75+yscale*2 btnWid textHeight],...
    'String','Phase in Grad|Phase in Rad',...
    'Background',my_color, ...
    'Callback','filtplot(''NewDisplay'');');

  %============================
  % checkbox für unwrap phase =
  %============================
  uicontrol('Style','checkbox','Tag','plotter_check_wrap',...
    'Units','normalized','Position',...
    [left+frmBorder 1-11.25*textHeight+yscale btnWid textHeight*1.25],...
    'String', ...
    'unwrap Phase','Value',1, ...
    'Background',my_color, ...
    'Callback','filtplot(''NewDisplay'');');

  %======================
  % Normierung checkbox =
  %======================
  uicontrol('Style','checkbox','Tag','plotter_check_norm',...
    'Units','normalized','Position',...
    [left+frmBorder 1-12.5*textHeight+yscale btnWid textHeight*1.25],...
    'String', ...
    'normierte Amplitude','Value',0, ...
    'Background',my_color, ...
    'Callback','filtplot(''NewDisplay'');');

  %==========================
  % Idealer Filter checkbox =
  %==========================
  uicontrol('Style','checkbox','Tag','plotter_check_ideal',...
    'Units','normalized','Position',...
    [left+frmBorder 1-13.75*textHeight+yscale btnWid textHeight*1.25],...
    'String', ...
    'Idealfilter anzeigen','Value',0, ...
    'Background',my_color, ...
    'Callback','filtplot(''NewDisplay'');');

  %========================
  % Quantisierer checkbox =
  %========================
  uicontrol('Style','checkbox','Tag','plotter_quant_check',...
    'Units','normalized','Position',...
    [left+frmBorder 1-15*textHeight+yscale btnWid textHeight],...
    'String','Koeff. quantisieren','Value',0, ...
    'Background',my_color, ...
    'Callback','filtplot(''NewDisplay'');');

  %======================
  % Quantisierer slider =
  %======================
  uicontrol('Style','slider','Tag','plotter_quant_slider',...
    'Units','normalized','Position',...
    [left+frmBorder 1-16*textHeight+yscale btnWid textHeight],...
    'Visible','off', ...
    'Value',64,'Min',2,'Max',64, ...
    'Background',my_color,'UserData',1, ...
    'Callback','filtplot(''NewDisplay'');');

  %==================
  % Marker checkbox =
  %==================
  uicontrol('Style','checkbox','Tag','plotter_check_marker',...
    'Units','normalized','Position',...
    [left+frmBorder 1-19*textHeight+yscale btnWid textHeight*1.5],...
    'String', ...
    'Marker','Value',0, ...
    'Background',my_color, ...
    'Callback','filtplot(''Marker'');');

  %=================
  % Marker text_x1 =
  %=================
  uicontrol('Style','text', ...
    'Units','normalized','Position',...
    [left+frmBorder 1-20*textHeight+yscale btnWid/2 textHeight],...
    'String','-', ...
    'Background',my_color, ...
    'HorizontalAlignment','left',...
    'Tag','plotter_text_x');

  %=================
  % Marker text_y1 =
  %=================
  uicontrol('Style','text', ...
    'Units','normalized','Position',...
    [left+frmBorder+btnWid/2 1-20*textHeight+yscale btnWid/2 textHeight],...
    'String','-', ...
    'HorizontalAlignment','left',...
    'Background',my_color, ...
    'Tag','plotter_text_y');

  %=================
  % Marker text_x2 =
  %=================
  uicontrol('Style','text', ...
    'Units','normalized','Position',...
    [left+frmBorder 1-21*textHeight+yscale btnWid/2 textHeight],...
    'String','-', ...
    'Background',my_color, ...
    'HorizontalAlignment','left',...
    'Tag','plotter_text_x2');

  %=================
  % Marker text_y2 =
  %=================
  uicontrol('Style','text','Units','normalized','Position',...
    [left+frmBorder+btnWid/2 1-21*textHeight+yscale btnWid/2 textHeight],...
    'String','-', ...
    'HorizontalAlignment','left',...
    'Background',my_color, ...
    'Tag','plotter_text_y2');

  %============
  % Xmin text =
  %============
  uicontrol('Style','text','Units','normalized','Position',...
    [left+frmBorder 1-24.5*textHeight+yscale btnWid/3 textHeight],...
    'String','Xmin:', ...
    'Background',my_color, ...
    'HorizontalAlignment','left');

  %============
  % Xmax text =
  %============
  uicontrol('Style','text','Units','normalized','Position',...
    [left+frmBorder 1-25.5*textHeight+yscale btnWid/3 textHeight],...
    'String','Xmax:', ...
    'Background',my_color, ...
    'HorizontalAlignment','left');

  %============
  % Ymin text =
  %============
  uicontrol('Style','text','Units','normalized','Position',...
    [left+frmBorder 1-26.5*textHeight+yscale btnWid/3 textHeight],...
    'String','Ymin:', ...
    'Background',my_color, ...
    'HorizontalAlignment','left');

  %============
  % Ymax text =
  %============
  uicontrol('Style','text','Units','normalized','Position',...
    [left+frmBorder 1-27.5*textHeight+yscale btnWid/3 textHeight],...
    'String','Ymax:', ...
    'Background',my_color, ...
    'HorizontalAlignment','left');

  %=======================
  % Achsenparameter text =
  %=======================
  uicontrol('Style','text','Units','normalized','Position',...
    [left+frmBorder 1-23.5*textHeight+yscale btnWid textHeight],...
    'String','Achsenbegrenzung', ...
    'Background',my_color, ...
    'HorizontalAlignment','center');

  %=======================
  % Achsenparameter Edit =
  %=======================
  uicontrol('Style','edit','Units','normalized', ...
    'Position',...
    [left+frmBorder+btnWid/3,1-27.5*textHeight+yscale,...
     2*btnWid/3,textHeight*4],...
    'String',sprintf('0\n0.5\n0\n1.1'), ...
    'Background',my_color,'Max',2, ...
    'HorizontalAlignment','left',...
    'Tag','plotter_axis','UserData',[0 .5 0 1.1 gca], ...
    'CallBack','filtplot(''ChangeAxis'');');

  %=============
  % Titel Text =
  %=============
  uicontrol('Style','text','Units','normalized', ...
    'Position',...
    [left+frmBorder,1-29*textHeight+yscale,btnWid,textHeight],...
    'String','Titel-Eingabe:','Horiz','left', ...
    'Background',my_color,'Max',1);

  %===============
  % Titel Button =
  %===============
  uicontrol('Style','pushbutton','Units','normalized', ...
    'Position',...
    [left+frmBorder+.1,1-29*textHeight+yscale,btnWid-.1,textHeight],...
    'String','Auto-Titel', ...
    'Background',my_color,'Max',1,'CallBack','filtplot(''AutoTitel'');');

  %=============
  % Titel Edit =
  %=============
  uicontrol('Style','edit','Units','normalized', ...
    'Position',[left+frmBorder,1-30.25*textHeight+yscale,btnWid,textHeight*1.25],...
    'String','', ...
    'Background',my_color-0.05,...
    'Tag','plotter_title_edit', ...
    'CallBack','filtplot(''TitleEdit'');');

  %===================
  % Der Hilfe button =
  %===================
  uicontrol( ...
    'Style','pushbutton', ...
    'Units','normalized', ...
    'Position',[left+frmBorder frmBottom+btnHt*3/4 btnWid btnHt*3/4], ...
    'String','Hilfe', ...
    'Callback','filtplot(''hilfe'')');

  %=====================
  % Der Beenden button =
  %=====================
  uicontrol( ...
    'Style','pushbutton', ...
    'Units','normalized', ...
    'Position',[left+frmBorder frmBottom btnWid/2 btnHt*3/4], ...
    'String','Beenden', ...
    'Callback','filtplot(''close_ok'');');

  %=======================
  % Der Protokoll button =
  %=======================
  uicontrol( ...
    'Style','pushbutton', ...
    'Units','normalized', ...
    'Position',[left+frmBorder+btnWid/2 frmBottom btnWid/2 btnHt*3/4], ...
    'String','Protokoll', ...
    'Callback','protocol');

  %=======================
  % Linie initialisieren =
  %=======================
  line(0,0,'Tag','plotter_Linie1','Color','k');

  %==================
  % Analyse starten =
  %==================
  filtplot('NewDisplay');

  return

elseif strcmp(action,'NewDisplay'),

  %=====================================
  % Handles & Objektzustände ermitteln
  %=====================================
  hdl_ax1=findobj('Tag','plotter_Achse1');
  hdl_ax2=findobj('Tag','plotter_Achse2');
  hdl_line1=findobj('Tag','plotter_Linie1');
  hdl_auswahl=findobj('Tag','plotter_plot_auswahl');
  hdl_axis=findobj('Tag','plotter_axis');
  hdl_quant=findobj('Tag','plotter_quant_check');
  hdl_slide=findobj('Tag','plotter_quant_slider');
  plot_auswahl=get(hdl_auswahl,'Value');
  hdl_title=get(hdl_ax1,'Title');

  % Titel löschen / Eingabefeld beibehalten
  set(hdl_title,'String','');

  %================================
  % eventuell Idealfilter löschen =
  %================================
  hdl_ideal=findobj('Tag','plotter_Pass3dB');
  if ~isempty(hdl_ideal), delete(hdl_ideal); end

  % 3D Verwaltung

  hdl=findobj('Tag','plot3d');
  if ~isempty(hdl),
    %=================
    % Lösche 3d-plot =
    %=================
    delete(hdl);

    %======================================
    % 2d-plot Parameter wieder herstellen =
    %======================================
    % delete(plot(1));
    pos_3d=axis; pos_3d=pos_3d(1:4); axis(pos_3d);
    set(gca,'XColor','k','YColor','k',...
     'ButtonDownFcn','filtplot(''ax_click'')','Box','on');  
    ylabel('','Color','k'); xlabel('','Color','k')
    filtplot('TitleEdit'); grid on;
    hdl_line1=line(0,0,'Tag','plotter_Linie1','Color','k');
  end

  %=============================
  % Koeffizienten quantisieren =
  %=============================
  if get(hdl_quant,'Value')
    %================
    % slider setzen =
    %================
    bits=get(hdl_slide,'Value');
    old=get(hdl_slide,'UserData');
    if bits>old & bits<=get(hdl_slide,'Max')
      bits=round(bits); if bits==old, bits=bits+1; end
    elseif bits<old & bits>=get(hdl_slide,'Min')
      bits=round(bits); if bits==old, bits=bits-1; end
    else
      bits=old;
    end
    set(hdl_slide,'UserData',bits,'Value',bits);
    set(hdl_quant,'String',['quantisiere mit ',num2str(bits),' bit']);
    set(hdl_slide,'Visible','on');

    %===============
    % quantisieren =
    %===============
    num=quantdig(num,bits);
    den=quantdig(den,bits); den(1)=1;
  else
    set(hdl_slide,'Visible','off');
    set(hdl_quant,'String','Koeff. quantisieren');
  end

  %=========================================
  % Marker ausschalten, merken wenn an war =
  %=========================================
  if findobj('Tag','Ver')
    marker_pos=markerok('location',[],'Ver');
    hdl=findobj('Tag','plotter_check_marker');
    set(hdl,'Value',0);
    markerok('del',[],'Ver');
    if findobj('Tag','Ver2')
      markerok('del',[],'Ver2');
    end
  else, marker_pos=[]; end

  %====================================================
  % eventuell vorhandene z-Ebenen Objekte/Style löschen
  %====================================================
  hdls=findobj('Tag','plotter_z');
  if ~isempty(hdls), delete(hdls); end
  hdls=findobj('Tag','plotter_z1');
  if ~isempty(hdls), delete(hdls); set(hdl_line1,'LineStyle','-','Marker','none'); end

  %=======================================================
  % Bei Darstellung Amplitude und Phase 2.Achse erzeugen =
  %=======================================================
  if plot_auswahl==3

    %====================================
    % Hdl der 2.Achse schon vorhanden ? =
    %====================================
    if isempty(hdl_ax2)

      %===============================================
      % Ja : 2.Achse erzeugen & Achsen positionieren =
      %===============================================

      set(hdl_ax1,'Position',[0.36 0.56 0.56 0.38]);
      hdl_ax2=axes(...
        'Position',[0.36 0.1 0.56 0.38],'xcolor','k','ycolor','k',...
        'XGrid','on','YGrid','on','Box','on',...
        'ButtonDownFcn','filtplot(''ax_click'');',...
        'Xlim',[0 0.5],'Tag','plotter_Achse2');
      set(get(hdl_ax2,'XLabel'),'String','','Color','k');
      set(get(hdl_ax2,'YLabel'),'String','','Color','k');

      %===================
      % 2.Linie erzeugen =
      %===================
      axes(hdl_ax2);
      hdl_line2=line(0,0,'Tag','plotter_Linie2','Color','k');
      axes(hdl_ax1);
    else
      hdl_line2=findobj('Tag','plotter_Linie2');
    end
  else
  %=====================================
  % Darstellung erfolgt in einer Achse =
  %=====================================
    %============================
    % eventuell 2.Achse löschen =
    %============================
    if ~isempty(hdl_ax2)
      if findobj('Tag','Ver2')
        markerok('del',[],'Ver2');
      end
      delete(hdl_ax2);
      pos=get(hdl_auswahl,'UserData');
      %===========================
      % Achse1 wieder vergrößern =
      %===========================
      set(hdl_ax1,'Position',[0.36 0.1 0.56 0.84]);
    end
  end

  %================================
  % berechne darzustellende Daten =
  %================================
  if plot_auswahl<4
    [H,Wn]=freqz(num,den,2048); Wn=Wn/2/pi;
    H_betrag=abs(H);
    H_phase=angle(H);
    Hmax=max(H_betrag);

    str_betrag='Amplitude';
    str_phase='Phase (rad)';

    %=============================
    % Betrag eventuell normieren =
    %=============================
    if get(findobj('Tag','plotter_check_norm'),'Value')
      H_betrag=H_betrag/Hmax;
    end

    %=========================
    % Betrag eventuell in dB =
    %=========================
    if get(findobj('Tag','plotter_scale'),'Value')==2
      H_betrag=20*log10(H_betrag+eps);   % +eps vermeidet log of zero
      str_betrag='Amplitude in dB';
    end

    %============================
    % Phase eventuell unwrapped =
    %============================
    if get(findobj('Tag','plotter_check_wrap'),'Value')
      H_phase=unwrap(H_phase);
    end

    %==========================
    % Phase eventuell in Grad =
    %==========================
    if get(findobj('Tag','plotter_deg/rad'),'Value')==1
      H_phase=H_phase/pi*180;
      str_phase='Phase (°)';
    end

  elseif plot_auswahl==4
    [H_gruppe,Wn]=grpdelay(num,den,2048); Wn=Wn/2/pi;

  elseif plot_auswahl==5|plot_auswahl==6
    %========================================
    % Vektorlängen von num und den anpassen =
    %========================================
    if length(num)>length(den),den=[den,zeros(1,length(num)-length(den))];
    elseif length(den)>length(num),num=[num,zeros(1,length(den)-length(num))];end
    if length(num), [ZERO,POLE,GAIN]=tf2zp(num,den);
    else ZERO=[];POLE=[];GAIN=1; end

    %==============================
    % Werte für s-Ebene berechnen =
    %==============================
    if plot_auswahl==6, [zs,ps]=invbilin(ZERO,POLE); end
  end

  %==============================================================
  % Daten zur Darstellung aufbereiten & Achsengrenzen berechnen =
  %==============================================================
  if plot_auswahl<4
    indx=find(isnan(H_betrag)); H_betrag(indx)=zeros(size(indx));
    min_betrag=min(H_betrag)-eps; max_betrag=max(H_betrag)+eps;
    if min_betrag>0, min_betrag=0; end
    delta=max_betrag-min_betrag;
    min_betrag=min_betrag-delta/50; max_betrag=max_betrag+delta/50;

    indx=find(isnan(H_phase)); H_phase(indx)=zeros(size(indx));
    min_phase=min(H_phase)-1e-3; max_phase=max(H_phase)+1e-3;
    delta=max_phase-min_phase;
    min_phase=min_phase-delta/50; max_phase=max_phase+delta/50;
  elseif plot_auswahl==4
    indx=find(isnan(H_gruppe)); H_gruppe(indx)=zeros(size(indx));
    min_gruppe=min(H_gruppe)-eps; max_gruppe=max(H_gruppe)+eps;

    % Vermeide zu große 'peaks'
    if abs(max_gruppe)>500, max_gruppe=500; end
    if abs(min_gruppe)>500, min_gruppe=-500; end

    delta=max_gruppe-min_gruppe; if delta<0.1, delta=0.1; end
    min_gruppe=min_gruppe-delta/50; max_gruppe=max_gruppe+delta/50;
  elseif plot_auswahl==5
    min_z=abs(min( min(real(ZERO)), min(imag(ZERO)) )-eps);
    min_p=abs(min( min(real(POLE)), min(imag(POLE)) )-eps);
    max_z=abs(max( max(real(ZERO)), max(imag(ZERO)) ))+eps;
    max_p=abs(max( max(real(POLE)), max(imag(POLE)) ))+eps;
    max_z=max([min_z,max_z,min_p,max_p])*1.1;
    max_z=max(max_z,1.1);
  elseif plot_auswahl==6
    min_y=abs(min( [imag(zs),imag(ps)] ));
    max_y=abs(max( [imag(zs),imag(ps)] ));
    max_y=max(min_y,max_y)*1.1+eps;
    min_x=abs(min( [real(zs),real(ps)] ));
    max_x=abs(max( [real(zs),real(ps)] ));
    max_x=max(min_x,max_x)*1.1+eps;
  end

  %============================
  % Daten geeignet darstellen =
  %============================

    %==================================
    % Default-Einstellung für x-Achse =
    %==================================
    set(hdl_ax1,'Xlim',[0 0.5]); % Default

  if plot_auswahl==1
  %============
  % Amplitude =
  %============
    set(hdl_line1,'XData',Wn,'YData',H_betrag);
    xlabel('normierte Frequenz'); ylabel(str_betrag);
    set(hdl_ax1,'Ylim',[min_betrag max_betrag]);

    str=sprintf('%g\n%g\n%g\n%g\n',[0,0.5,min_betrag,max_betrag]);
    set(hdl_axis,'UserData',[0,0.5,min_betrag,max_betrag,hdl_ax1],...
        'String',str);
    filtplot('DetectPassband',H_betrag);

  elseif plot_auswahl==2
  %========
  % Phase =
  %========
    set(hdl_line1,'XData',Wn,'YData',H_phase);
    xlabel('normierte Frequenz'); ylabel(str_phase);
    set(hdl_ax1,'Ylim',[min_phase max_phase]);

    str=sprintf('%g\n%g\n%g\n%g\n',[0,0.5,min_phase,max_phase]);
    set(hdl_axis,'UserData',[0,0.5,min_phase,max_phase,hdl_ax1],'String',str);
  elseif plot_auswahl==3
  %======================
  % Amplitude und Phase =
  %======================
    set(hdl_line1,'XData',Wn,'YData',H_betrag);
    set(hdl_line2,'XData',Wn,'YData',H_phase);
    set(get(hdl_ax1,'XLabel'),'String','');
    set(get(hdl_ax1,'YLabel'),'String',str_betrag);
    set(hdl_ax1,'Ylim',[min_betrag max_betrag]);
    set(get(hdl_ax2,'XLabel'),'String','normierte Frequenz');
    set(get(hdl_ax2,'YLabel'),'String',str_phase);
    set(hdl_ax2,'Ylim',[min_phase max_phase]);
    str=sprintf('%g\n%g\n%g\n%g\n',[0,0.5,min_betrag,max_betrag]);
    set(hdl_axis,'UserData',[0,.5,min_betrag,max_betrag,hdl_ax1],...
        'String',str);
    filtplot('DetectPassband',H_betrag);
  elseif plot_auswahl==4
  %==================
  % Gruppenlaufzeit =
  %==================
    set(hdl_line1,'XData',Wn,'YData',H_gruppe);
    xlabel('normierte Frequenz'); ylabel('Gruppenlaufzeit');
    set(hdl_ax1,'Ylim',[min_gruppe max_gruppe]);
    str=sprintf('%g\n%g\n%g\n%g\n',[0,0.5,min_gruppe,max_gruppe]);
    set(hdl_axis,'UserData',[0,0.5,min_gruppe,max_gruppe,hdl_ax1],...
        'String',str);

  elseif plot_auswahl==5
  %=========================
  % z-Ebene (2dimensional) =
  %=========================
    %=========================================
    % Einheitskreis berechnen und darstellen =
    %=========================================
    th = 0:pi/50:2*pi;
    line(cos(th),sin(th),'Color','k','LineStyle',':','Tag','plotter_z1');
%    set(hdl_line1,'YData',imag(ZERO),'XData',real(ZERO),'LineStyle','o');
    set(hdl_line1,'YData',imag(ZERO),'XData',real(ZERO),'Marker','o','LineStyle','none');
    line(real(POLE),imag(POLE),'Color','k','LineStyle','none','Marker','x',...
         'Tag','plotter_z1');
    axis([-max_z max_z -max_z max_z]);
    xlabel('Re(z)'); ylabel('Im(z)');

    str=sprintf('%g\n%g\n%g\n%g\n',[-max_z,max_z,-max_z,max_z]);
    set(hdl_axis,'UserData',[-max_z,max_z,-max_z,max_z,hdl_ax1],'String',str);
    %===================================
    % POLE/ZERO mit Anzahl beschriften =
    %===================================
    % zunächst alte Anzahlen löschen   =
    %===================================
    hdls=findobj('Tag','plotter_z');
    if ~isempty(hdls), delete(hdls); end

    %======================
    % Auflösung ermitteln =
    %======================
    ax_size=axis;
    GRENZE=min(ax_size(2)-ax_size(1),ax_size(4)-ax_size(3))/200;

    %===========================
    % mehrfache Pole ermitteln =
    %===========================
    re=real(POLE); im=imag(POLE);
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
      text(re(n),im(n),num2str(zahlen(n)),'Color','r',...
           'VerticalAlignment','top','FontWeight','normal',...
           'Fontsize',10,'Fontname','Courier','Tag','plotter_z');
    end

    %==================================
    % mehrfache Nullstellen ermitteln =
    %==================================
    re=real(ZERO); im=imag(ZERO);
    n=1; zahlen=[];
    while length(re)>=n;
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
      text(re(n),im(n),num2str(zahlen(n)),'Color','b',...
           'VerticalAlignment','top','FontWeight','normal',...
           'Fontsize',10,'Fontname','Courier','Tag','plotter_z');

    end
  elseif plot_auswahl==6
    set(hdl_line1,'XData',real(zs),'YData',imag(zs),'Marker','o','LineStyle','none');
    xlabel('Re(s)'); ylabel('Im(s)');
    set(hdl_ax1,'Ylim',[-max_y max_y],'Xlim',[-max_x max_x]);
    hdl_line2=line(real(ps),imag(ps),'Marker','x','LineStyle','none','Color','k',...
                   'Tag','plotter_z1');
    str=sprintf('%g\n%g\n%g\n%g\n',[-max_x,max_x,-max_y,max_y]);
    set(hdl_axis,'UserData',[-max_x,max_x,-max_y,max_y,hdl_ax1],'String',str);
    %===============================
    % zs/ps mit Anzahl beschriften =
    %===================================
    % zunächst alte Anzahlen löschen   =
    %===================================
    hdls=findobj('Tag','plotter_z');
    if ~isempty(hdls), delete(hdls); end

    %======================
    % Auflösung ermitteln =
    %======================
    ax_size=axis;
    GRENZE=min(ax_size(2)-ax_size(1),ax_size(4)-ax_size(3))/200;

    %===========================
    % mehrfache Pole ermitteln =
    %===========================
    re=real(ps); im=imag(ps);
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
      text(re(n),im(n),num2str(zahlen(n)),'Color','r',...
           'VerticalAlignment','top','FontWeight','normal',...
           'Fontsize',10,'Fontname','Courier','Tag','plotter_z');
    end

    %==================================
    % mehrfache Nullstellen ermitteln =
    %==================================
    re=real(zs); im=imag(zs);
    n=1; zahlen=[];
    while length(re)>=n;
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
      text(re(n),im(n),num2str(zahlen(n)),'Color','b',...
           'VerticalAlignment','top','FontWeight','normal',...
           'Fontsize',10,'Fontname','Courier','Tag','plotter_z');
    end

  end % von plot_auswahl==6

  %======================================
  % Marker eventuell wieder einschalten =
  % Ausnahme : 3d-plot                  =
  %======================================
  if ~isempty(marker_pos) & plot_auswahl~=7
    marker_pos=min(find(Wn==marker_pos(1)));
    if isempty(marker_pos), marker_pos=1; end
    set(hdl,'Value',1);
    filtplot('Marker',marker_pos);
  end

  %====================
  % 3d plot erstellen =
  %====================
  if plot_auswahl==7
    [hdl,hdl2]=zplane3d(num,den);
    set([hdl,hdl2],'Tag','plot3d');
    filtplot('TitleEdit');
    set(gca,'Tag','plotter_Achse1');
  end

  return

elseif strcmp(action,'Marker')
%=========
% Marker =
%=========
  hdl_auswahl=findobj('Tag','plotter_plot_auswahl');
  plot_auswahl=get(hdl_auswahl,'Value');
  if plot_auswahl==7
    set(findobj('Tag','plotter_check_marker'),'Value',0);
    return;
  end
  marker_wert=get(findobj('Tag','plotter_check_marker'),'Value');
  lim_axis=axis; xmin=lim_axis(1);
  hdl_line1=findobj('Tag','plotter_Linie1');
  xdata=get(hdl_line1,'XData');
  pos=min(find(xdata>=xmin));
  if ~isempty(pos)
    if marker_wert==1
      %==============================================
      % Handles ermitteln und Marker initialisieren =
      %==============================================
      hdl_line=findobj('Tag','plotter_Linie1');
      hdl_ax=get(hdl_line,'Parent');
      hdl_x=findobj('Tag','plotter_text_x');
      hdl_y=findobj('Tag','plotter_text_y');
      hdlx=findobj('Tag','plotter_text_x2');
      hdly=findobj('Tag','plotter_text_y2');

      if nargin==1, pos=pos; else, pos=s; end

      x=get(hdl_line,'XData'); y=get(hdl_line,'YData');
      if plot_auswahl==5|plot_auswahl==6
        hdl_line2=findobj(gca,'Marker','x','LineStyle','none');
        hdl_line=[hdl_line,hdl_line2];
      end
      markerok('make',hdl_ax,'Ver',[x(pos) y(pos)],'-',hdl_line,hdl_x,hdl_y);
      if plot_auswahl==3 % ~=3 -> löschen erfolgt schon oben
        hdl_line2=findobj('Tag','plotter_Linie2');
        hdl_ax2=get(hdl_line2,'Parent');
        y2=get(hdl_line2,'YData');
        markerok('make',hdl_ax2,'Ver2',[x(pos) y2(pos)],...
                 '-',hdl_line2,hdlx,hdly);
      end
    else
      %=================
      % Marker löschen =
      %=================
      markerok('del',[],'Ver');
      if findobj('Tag','Ver2')
        markerok('del',[],'Ver2');
      end
    end
  else
    set(findobj('Tag','plotter_check_marker'),'Value',0);
  end

elseif strcmp(action,'ChangeAxis')

  % Bei 3d-Achse nichts einstellen !
  if findobj('Tag','plot3d'), return; end

    v = get(gco,'Userdata'); ax=v(5); v=v(1:4);
  str = get(gco,'String');
  plot_auswahl=get(findobj('Tag','plotter_plot_auswahl'),'Value');

  %====================================
  % Textfeld-Text in Zahlen umwandeln =
  %====================================
  ind = find(abs(str)<32);
  str(ind) = 32*ones(size(ind));
  str2 = str'; siz = size(str2);
  str_r=ones(siz(1),1)*32;
  str=[];
  for ii=1:siz(2)
    str = [str str2(:,ii) str_r];
  end
  vv = eval(['[' str(:)' ']'],'-1');

  %===========================
  % Prüfen auf Plausibilität =
  %===========================
  if vv==-1 | length(vv)~=4
    vv = v;
    messageb('Fehler','Fehlerhafte Eingabe','ok','!',1,'task');
  elseif vv(1)>=vv(2) | vv(3)>=vv(4)
    vv = v;
    messageb('Fehler','Fehlerhafte Eingabe','ok','!',1,'task');
  elseif plot_auswahl<5 & ( vv(1)<0 | vv(2)>0.5 )
    vv = v;
    messageb('Fehler','Fehlerhafte Eingabe','ok','!',1,'task');
  end

  %===============
  % Achse setzen =
  %===============
  str = sprintf('%g\n%g\n%g\n%g',vv);
  set(gco,'UserData',[vv,ax],'String',str);
  set(ax,'XLim',vv(1:2),'YLim',vv(3:4));

  %======================================
  % Marker an neue Achsengröße anpassen =
  %======================================
  markerok('refresh',[],'Ver');
  markerok('refresh',[],'Ver2');

  return

elseif strcmp(action,'ax_click')
%=============================
% Achseneinstellung anzeigen =
%=============================
  hdl_edit_ax=findobj('Tag','plotter_axis');
  str=sprintf('%g\n%g\n%g\n%g',axis);

  %======================================================
  % sichern von akt. Achseneinstellung und Achsenhandle =
  %======================================================
  set(hdl_edit_ax,'UserData',[axis,gca],'String',str);

  return

elseif strcmp(action,'TitleEdit')
  %=======================
  % Eingabe eines Titels =
  %=======================
  hdl_edit=findobj('Tag','plotter_title_edit');
  hdl_ax=findobj('Tag','plotter_Achse1');
  hdl_ti=get(hdl_ax,'Title');
  set(hdl_ti,'String',get(hdl_edit,'String'),'Color','k');

elseif findstr(action,'AutoTitel')
  %=======================
  % Automatischer Titel  =
  %=======================
  hdl_edit=findobj('Tag','plotter_title_edit');
  hdl_ax=findobj('Tag','plotter_Achse1');
  hdl_ti=get(hdl_ax,'Title');
  str=autotit;
  set(hdl_ti,'String',str,'Color','k');
  set(hdl_edit,'String',str);

elseif strcmp(action,'hilfe')
%=====================================
%      Windows-Hilfe aufrufen        =
% NUR MICROSOFT WINDOWS-KOMPATIBEL ! =
%=====================================
  !winhelp filtplot.hlp

elseif strcmp(action,'Other')
%================================
% -> zur Analyse im Zeitbereich =
%================================
  hdl=findobj('Tag','plotter_area_auswahl');
  if get(hdl,'Value')==2
    fontsize=get(hdl,'UserData');
    filtplot('close');
    filttime('initialize',fontsize);
  end
  return

elseif strcmp(action,'DetectPassband')
%=====================================
% Idealfilter ermitteln und anzeigen =
%=====================================
  if get(findobj('Tag','plotter_check_ideal'),'Value')
    old_ax=gca; hdl_ax1=findobj('Tag','plotter_Achse1');
    axes(hdl_ax1); absH=s;

    if get(findobj('Tag','plotter_scale'),'Value')==2
      dB3=-10*log10(2); mini=-realmax; maxi=0;
    else
      dB3=1/sqrt(2); mini=0; maxi=1;
    end
    first=absH(1); last=absH(length(absH));
    hdl=findobj('Tag','plotter_Linie1');
    xdat=get(hdl,'XData');

    if first>dB3 & last<dB3 %TP
      W3dB=max(find(absH>=dB3-1e-3));
      if ~isempty(W3dB)
        line([0 xdat(W3dB) xdat(W3dB) 0.5],[maxi maxi mini mini],...
             'LineStyle','-',...
             'Color','b','Tag','plotter_Pass3dB');
      end
    elseif first<dB3 & last>dB3 %HP
      W3dB=min(find(absH>=dB3-1e-3));
      if ~isempty(W3dB)
        line([0 xdat(W3dB) xdat(W3dB) 0.5],[mini mini maxi maxi],...
             'LineStyle','-',...
             'Color','b','Tag','plotter_Pass3dB');
      end
    elseif first<dB3 & last<dB3 %BP
      low=min(find(absH>=dB3-1e-3));
      high=max(find(absH>=dB3-1e-3));
      if ~isempty(low) & ~isempty(high)
        line([0 xdat(low) xdat(low) xdat(high) xdat(high) 0.5],...
              [mini mini maxi maxi mini mini],'LineStyle','-',...
             'Color','b','Tag','plotter_Pass3dB');
      end
    elseif first>dB3 & last>dB3 %BS
      low=min(find(absH<=dB3+1e-3));
      high=max(find(absH<=dB3+1e-3));
      if ~isempty(low) & ~isempty(high)
        line([0 xdat(low) xdat(low) xdat(high) xdat(high) 0.5],...
             [maxi maxi mini mini maxi maxi],'LineStyle','-',...
             'Color','b','Tag','plotter_Pass3dB');
      end
    end
    axes(old_ax);
  end

elseif findstr(action,'close') % close und close_ok
%========================
% Filteranalyse beenden =
%========================
   %======================================
   % vorhandene Achsen & Objekte löschen =
   %======================================
    hdl=findobj('Tag','plotter_Achse1');
    delete(hdl);
    hdl=findobj('Tag','plotter_Achse2');
    if ~isempty(hdl), delete(hdl); end
    hdl=findobj(gcf,'Type','uicontrol');
    delete(hdl);
    hdl=findobj('Label','&Filteranalyse');
    if ~isempty(hdl), set(hdl,'Enable','on'); end

   %====================================
   % Hauptfenster auf schwarz schalten =
   %====================================
    set(gcf,'Color','k','InvertHardcopy','on');

end
