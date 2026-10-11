function filttime(action,s);

% Die Funktion filttime ist ein Programm zur
% Filteranalyse im Zeitbereich.
% Es verwendet die Koeffizienten der
% Übertragungsfunktion H(z), die global
% als b und a vorliegen müssen !
%
% Aufruf : FILTTIME('initialize',fontsize);
%
% Die berechneten Daten werden im aktuellen
% Fenster dargestellt.
%
% Version 1.0 / Mar-97 / O.Klein / FH Hannover
%
% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover
%

% verwendete Objekt-Tags :
%
% time_abtastwerte   popupmenu   : Anzahl Abtastwerte
% time_Achse1                    : Achse1 ({oben})
% time_Achse2                    : Achse2 (unten/mitte)
% time_Achse3                    : Achse3 (unten)
% time_area_auswahl  popupmenu   : Zeit/Frequenzbereich
% time_check_marker              : Marker ein/{aus}
% time_check_norm                : Normierung ein/{aus} ->NICHT IMPLEMENTIERT
% time_fft                       : FFT
% time_interpol                  : Interpolation
% time_Linie1                    : Linie in Achse1
% time_Linie2                    : Linie in Achse2
% time_Linie3                    : Linie in Achse3
% time_plot3d                    : 3d plot/z_Ebene
% time_plot_input    popupmenu   : Eingangssignal
% time_plot_output   popupmenu   : Darstellungsart
% time_quant_check               : quantisieren ein/{aus}
% time_quant_slider              : Bit-Anzahl
% time_scale         popupmenu   : lin/log  ->NICHT IMPLEMENTIERT
% time_text_x        text        : Marker-Ausgabe Achse1
% time_text_x2       text        : Marker-Ausgabe Achse2
% time_text_x3       text        : Marker-Ausgabe Achse3
% time_text_y        text        : Marker-Ausgabe Achse1
% time_text_y2       text        : Marker-Ausgabe Achse2
% time_text_y3       text        : Marker-Ausgabe Achse3
% time_title_edit    edit        : Titeleingabefenster
% time_user          edit        : Formeleingabefenster
% Ver                            : Markerlinie Achse1
% Ver2                           : Markerlinie Achse2
% Ver3                           : Markerlinie Achse3
%

% HINWEISE :
%
% keine YMinorTicks verwenden, da sonst 'gca'-Probleme !!!
%

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
  if scr_size(3)<645, yscale=0.03;
  elseif scr_size(3)<805, yscale=0.015;
  else yscale=-0.0225; end

  %====================================================
  % Berechne 'textHeight' für Fenster "mit" uimenu !! =
  %====================================================
  textHeight=fontsize/scr_size(4)*1.72;
  scr_size(3:4)=scr_size(3:4)-2;
  set(gcf,'Color','w','InvertHardcopy','off');
  figNumber=gcf;

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
    'Box','on','Tag','time_Achse1');
  xlabel('n','Color','k'); ylabel('','Color','k');

  %=================
  % Rahmen für GUI =
  %=================
  yPos=frmBottom-frmBorder;
  frmPos=[left yPos frmWidth+2*frmBorder frmHeight+2*frmBorder];
  h=uicontrol( ...
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
  frmPos=[left+.01 top-7.5*textHeight+0.01,...
          frmWidth+2*frmBorder-0.02 6.5*textHeight];
  h=uicontrol( ...
    'Style','frame', ...
    'Units','normalized', ...
    'Position',frmPos, ...
    'Clipping','off', ...
    'Background',my_color);

  %====================
  % Rahmen2 im Rahmen =
  %====================
  yPos=frmBottom-frmBorder;
  frmPos=[left+.01 top-13*textHeight+0.01 ...
          frmWidth+2*frmBorder-0.02 5*textHeight];
  h=uicontrol( ...
    'Style','frame', ...
    'Units','normalized', ...
    'Position',frmPos, ...
    'Clipping','off', ...
    'Background',my_color);

  %====================
  % Rahmen3 im Rahmen =
  %====================
  yPos=frmBottom-frmBorder;
  frmPos=[left+.01 top-25.75*textHeight+0.01,...
          frmWidth+2*frmBorder-0.02 12.25*textHeight];
  h=uicontrol( ...
    'Style','frame', ...
    'Units','normalized', ...
    'Position',frmPos, ...
    'Clipping','off', ...
    'Background',my_color);

  %=====================================
  % The Time Analysis Selection Menu 1 =
  % Hier wird 'fontsize' gespeichert   =
  %=====================================
  yPos=1-textHeight*.5;
  btnPos=[left+frmBorder yPos-btnHt btnWid textHeight];
  methodHndl=uicontrol( ...
    'Style','popupmenu', ...
    'Units','normalized', ...
    'Position',btnPos, ...
    'String','Frequenzbereich|Zeitbereich', ...
    'Interruptible','on', ...
    'Value',2, ...
    'Background',my_color, ...
    'Foreground',mtc, ...
    'Tag','time_area_auswahl', ...
    'UserData',fontsize, ...
    'Callback','filttime(''Other'');');

  %=====================================
  % The Time Analysis Selection Menu 2 =
  %=====================================
  yPos=1-textHeight*2.5;
  btnPos=[left+frmBorder yPos-btnHt btnWid textHeight*1.25];
  outputHndl=uicontrol( ...
    'Style','popupmenu', ...
    'Units','normalized', ...
    'Position',btnPos, ...
    'String','x(n)|h(n)|y(n)|x(n),y(n)|x(n),h(n),y(n)', ...
    'Interruptible','on', ...
    'Value',3, ...
    'Background',my_color, ...
    'Foreground',mtc, ...
    'Tag','time_plot_output', ...
    'Callback','filttime(''NewDisplay'');');

  %======================
  % Eingangssignal TEXT =
  %======================
  uicontrol( ...
    'Style','Text','Units','normalized',...
    'Position',[left+frmBorder 1-textHeight*7+yscale btnWid textHeight],...
    'String', ...
    'Eingangssignal:',...
    'Background',my_color');

  %=================
  % Eingangssignal =
  %=================
  uicontrol( ...
    'Style','popupmenu','Tag','time_plot_input','Units','normalized',...
    'Position',[left+frmBorder 1-textHeight*8.75+yscale*2 btnWid textHeight],...
    'String', ...
    ['Einheitsimpuls|Einheitssprungfolge|Rechteckfolge|',...
     'Dreieckfolge|Zufallsfolge|benutzerdefiniert'],...
    'Background',my_color, ...
    'UserData',randn('seed'),...
    'Callback','filttime(''NewDisplay'');');

  %===================
  % Abtastwerte TEXT =
  %===================
  uicontrol( ...
    'Style','Text','Units','normalized',...
    'Position',[left+frmBorder 1-10*textHeight+yscale btnWid textHeight],...
    'String', ...
    'Abtastwerte:','Value',1, ...
    'Background',my_color');

  %=======================
  % Abtastwert popupmenu =
  %=======================
  uicontrol('Style','popupmenu','Tag','time_abtastwerte',...
    'Units','normalized','Position',...
    [left+frmBorder 1-11.75*textHeight+yscale btnWid textHeight*1.5],...
    'String', ...
    '8|16|32|64|128|256|512','Value',3, ...
    'Background',my_color, ...
    'Callback','filttime(''NewDisplay'');');

  %==================
  % Marker checkbox =
  %==================
  uicontrol('Style','checkbox','Tag','time_check_marker',...
    'Units','normalized','Position',...
    [left+frmBorder 1-14.5*textHeight+yscale btnWid textHeight*1.25],...
    'String', ...
    'Marker','Value',0, ...
    'Background',my_color, ...
    'Callback','filttime(''Marker'');');

  %================
  % Marker text_x =
  %================
  uicontrol('Style','text', ...
    'Units','normalized','Position',...
    [left+frmBorder 1-15.5*textHeight+yscale btnWid/2 textHeight],...
    'String','-', ...
    'Background',my_color, ...
    'HorizontalAlignment','left',...
    'Tag','time_text_x');

  %================
  % Marker text_y =
  %================
  uicontrol('Style','text', ...
    'Units','normalized','Position',...
    [left+frmBorder+btnWid/2 1-15.5*textHeight+yscale ...
     btnWid/2 textHeight],...
    'String','-', ...
    'Background',my_color, ...
    'HorizontalAlignment','left',...
    'Tag','time_text_y');

  %=================
  % Marker text_x2 =
  %=================
  uicontrol('Style','text', ...
    'Units','normalized','Position',...
    [left+frmBorder 1-16.5*textHeight+yscale btnWid/2 textHeight],...
    'String','-', ...
    'Background',my_color, ...
    'HorizontalAlignment','left',...
    'Tag','time_text_x2');

  %=================
  % Marker text_y2 =
  %=================
  uicontrol('Style','text', ...
    'Units','normalized','Position',...
    [left+frmBorder+btnWid/2 1-16.5*textHeight+yscale ...
     btnWid/2 textHeight],...
    'String','-', ...
    'Background',my_color, ...
    'HorizontalAlignment','left',...
    'Tag','time_text_y2');

  %=================
  % Marker text_x3 =
  %=================
  uicontrol('Style','text', ...
    'Units','normalized','Position',...
    [left+frmBorder 1-17.5*textHeight+yscale btnWid/2 textHeight],...
    'String','-', ...
    'Background',my_color, ...
    'HorizontalAlignment','left',...
    'Tag','time_text_x3');

  %=================
  % Marker text_y3 =
  %=================
  uicontrol('Style','text', ...
    'Units','normalized','Position',...
    [left+frmBorder+btnWid/2 1-17.5*textHeight+yscale ...
     btnWid/2 textHeight],...
    'String','-', ...
    'Background',my_color, ...
    'HorizontalAlignment','left',...
    'Tag','time_text_y3');

  %=========================
  % Interpolation checkbox =
  %=========================
  uicontrol('Style','checkbox','Tag','time_interpol','Units','normalized',...
    'Position',[left+frmBorder 1-19.75*textHeight+yscale btnWid textHeight],...
    'String', ...
    'Interpolation','Value',0, ...
    'Background',my_color, ...
    'HorizontalAlignment','left',...
    'Callback','filttime(''NewDisplay'');');

  %===============
  % FFT checkbox =
  %===============
  uicontrol('Style','checkbox','Tag','time_fft',...
    'Units','normalized','Position',...
    [left+frmBorder 1-21*textHeight+yscale btnWid textHeight],...
    'String','FFT','Value',0, ...
    'Background',my_color,'HorizontalAlignment','left',...
    'CallBack','filttime(''NewDisplay'');');

  %========================
  % Quantisierer checkbox =
  %========================
  uicontrol('Style','checkbox','Tag','time_quant_check','Units','normalized',...
    'Position',[left+frmBorder 1-22.25*textHeight+yscale btnWid textHeight],...
    'String', ...
    'Koeff. quantisieren','Value',0, ...
    'Background',my_color, ...
    'Callback','filttime(''NewDisplay'');');

  %======================
  % Quantisierer slider =
  %======================
  uicontrol('Style','slider','Tag','time_quant_slider',...
    'Units','normalized', ...
    'Position',[left+frmBorder 1-23.25*textHeight+yscale btnWid textHeight],...
    'Value',64,'Min',2,'Max',64, ...
    'Background',my_color,'UserData',1, ...
    'Callback','filttime(''NewDisplay'');');

  %====================
  % lin/log popupmenu =
  %====================
  uicontrol('Style','popupmenu','Tag','time_scale',...
    'Units','normalized', ...
    'Position',[left+frmBorder 1-25*textHeight+yscale btnWid textHeight*1.25],...
    'Value',1,...
    'String','lineare Amplitude|logarith. Amplitude', ...
    'Background',my_color, ...
    'Callback','filttime(''NewDisplay'');');

  %=============
  % Titel Text =
  %=============
  uicontrol('Style','text','Units','normalized', ...
   'Position',[left+frmBorder,1-26.5*textHeight+yscale,btnWid,textHeight],...
   'String','Titel-Eingabe:','Horiz','left', ...
   'Background',my_color,'Max',1);

  %===============
  % Titel Button =
  %===============
  uicontrol('Style','pushbutton','Units','normalized', ...
    'Position',...
    [left+frmBorder+.1,1-26.5*textHeight+yscale,btnWid-.1,textHeight],...
    'String','Auto-Titel', ...
    'Background',my_color,'Max',1,'CallBack','filttime(''AutoTitel'');');

  %=============
  % Titel Edit =
  %=============
  uicontrol('Style','edit','Units','normalized', ...
   'Position',[left+frmBorder,1-27.75*textHeight+yscale,btnWid,textHeight*1.25],...
   'String','','Background',my_color-0.05,...
   'Max',1,'Tag','time_title_edit', ...
   'CallBack','filttime(''TitleEdit'');');

  %==============
  % Formel Text =
  %==============
  uicontrol('Style','text','Units','normalized', ...
   'Position',[left+frmBorder,1-29*textHeight+yscale,btnWid,textHeight],...
   'String','Folgeneingabe:', ...
   'Background',my_color,'Max',1);

  %=================
  % Formel editbox =
  %=================
  uicontrol('Style','edit','Tag','time_USER',...
    'Units','normalized', ...
    'Position',[left+frmBorder 1-30.25*textHeight+yscale btnWid textHeight*1.25],...
    'String','sin(2*pi*0.25*nT)',...
    'Background',my_color-0.05,'CallBack','filttime(''NewDisplay'');');

  %===================
  % Der Hilfe button =
  %===================
  uicontrol( ...
    'Style','pushbutton', ...
    'Units','normalized', ...
    'Position',[left+frmBorder frmBottom+btnHt*3/4 btnWid btnHt*3/4], ...
    'String','Hilfe', ...
    'Callback','filttime(''hilfe'')');

  %=====================
  % Der Beenden button =
  %=====================
  uicontrol( ...
    'Style','pushbutton', ...
    'Units','normalized', ...
    'Position',[left+frmBorder frmBottom btnWid/2 btnHt*3/4], ...
    'String','Beenden', ...
    'Callback','filttime(''close_ok'');');

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
  hdl_line=line(0,0,'Tag','time_Linie1','Color','k',...
                'Linestyle','none','Marker','o','Linewidth',3,'MarkerSize',4);
  %==================
  % Analyse starten =
  %==================
  filttime('NewDisplay');
  return

elseif strcmp(action,'NewDisplay'),

  %=====================================
  % Handles & Objektzustände ermitteln =
  %=====================================
  hdl_ax1=findobj('Tag','time_Achse1');
  hdl_ax2=findobj('Tag','time_Achse2');
  hdl_ax3=findobj('Tag','time_Achse3');
  hdl_line1=findobj('Tag','time_Linie1');
  hdl_line2=findobj('Tag','time_Linie2');
  hdl_line3=findobj('Tag','time_Linie3');
  hdl_auswahl=findobj('Tag','time_plot_input');
  hdl_output=findobj('Tag','time_plot_output');
  hdl_fft=findobj('Tag','time_fft');
  hdl_interpol=findobj('Tag','time_interpol');
  hdl_quant=findobj('Tag','time_quant_check');
  hdl_slide=findobj('Tag','time_quant_slider');

  input_auswahl=get(hdl_auswahl,'Value');
  output_auswahl=get(hdl_output,'Value');
  anz_werte=2.^(get(findobj('Tag','time_abtastwerte'),'Value')+2);
  fft_anz=1024;

  %=============================
  % Koeffizienten quantisieren =
  %=============================
  if get(hdl_quant,'Value')
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
    num=quantdig(num,bits);
    den=quantdig(den,bits); den(1)=1;
    set(hdl_quant,'String',['quantisiere mit ',num2str(bits),' bit']);
    set(hdl_slide,'Visible','on');
  else
    set(hdl_slide,'Visible','off');
    set(hdl_quant,'String','Koeff. quantisieren');
  end

  %======================================
  % Berechnen der Einheitsimpulsantwort =
  %======================================
  h_n=filter(num,den,[1 zeros(1,fft_anz-1)]);

  %==================================
  % Berechnung des Eingangssignales =
  %==================================
  if input_auswahl==1
    %=================
    % Einheitsimpuls =
    %=================
    x_n=[1 zeros(1,fft_anz-1)];
  elseif input_auswahl==2
    %=================
    % Einheitssprung =
    %=================
    x_n=[ones(1,fft_anz)];
  elseif input_auswahl==3
    %=================
    % Rechteck       =
    %=================
    x_n=[ones(1,anz_werte/8) zeros(1,anz_werte*7/8)];
  elseif input_auswahl==4
    %=================
    % Dreieck        =
    %=================
    x_n=bartlett(anz_werte/4+1).'; x_n(anz_werte)=0;
  elseif input_auswahl==5
    %=============================================
    % Rauschen / normalverteilt                  =
    % wird bei Aufruf von filttime initialisiert =
    %=============================================
    randn('seed',get(hdl_auswahl,'UserData'));
    x_n=sqrt(1*1)*(randn(1,fft_anz/2));
  elseif input_auswahl==6
    %==================
    % Benutzereingabe =
    %==================
    hdl=findobj('Tag','time_USER');
    str=get(hdl,'String'); nT=0:fft_anz/2-1;
    x_n=eval(str,'99');
    if x_n(1)==99 & length(x_n)==1
      messageb('Fehler','Fehler in Matlabausdruck','ok','!',1,'task');
      x_n=0;
    end
    x_n=x_n(:).';
    if length(x_n)<anz_werte, x_n(anz_werte)=0; end
  end

  %=============
  % Marker aus =
  %=============
  if findobj('Tag','Ver')
    markmerk=markerok('location',[],'Ver');
    markmerk=markmerk(1);
    hdl=findobj('Tag','time_check_marker');
    set(hdl,'Value',0);
    markerok('del',[],'Ver');
    if findobj('Tag','Ver2')
      markerok('del',[],'Ver2');
    end
    if findobj('Tag','Ver3')
      markerok('del',[],'Ver3');
    end
  else
    markmerk=[];
  end

  %=======================
  % Achsen positionieren =
  %=======================
  if output_auswahl==4 & (isempty(hdl_ax2)|~isempty(hdl_ax3))
    delete(hdl_ax3); hdl_ax3=[]; hdl_line3=[];
    set(hdl_ax1,'Position',[0.36 0.56 0.56 0.38]);
    set(get(hdl_ax1,'XLabel'),'String','','Color','k');
    if isempty(hdl_ax2)
      hdl_ax2=axes(...
        'Position',[0.36 0.1 0.56 0.38],'xcolor','k','ycolor','k',...
        'XGrid','on','YGrid','on','Box','on','Tag','time_Achse2');
    else
      set(hdl_ax2,'Position',[0.36 0.1 0.56 0.38]);
    end
  elseif output_auswahl==5 & isempty(hdl_ax3)
    set(hdl_ax1,'Position',[0.36 0.70 0.56 0.24]);
    set(get(hdl_ax1,'XLabel'),'String','','Color','k');
    if isempty(hdl_ax2)
      hdl_ax2=axes(...
        'Position',[0.36 0.4 0.56 0.24],'xcolor','k','ycolor','k',...
        'XGrid','on','YGrid','on','Box','on','Tag','time_Achse2');
    else
      set(hdl_ax2,'Position',[0.36 0.4 0.56 0.24]);
    end
    set(get(hdl_ax2,'XLabel'),'String','');
    hdl_ax3=axes(...
      'Position',[0.36 0.1 0.56 0.24],'xcolor','k','ycolor','k',...
      'XGrid','on','YGrid','on','Box','on','Tag','time_Achse3');
  elseif output_auswahl<4
    set(hdl_ax1,'Position',[0.36 0.1 0.56 0.84]);
    delete(hdl_ax2); delete(hdl_ax3); hdl_ax2=[]; hdl_ax3=[];
    hdl_line2=[]; hdl_line3=[];
  end

  %============================================
  % Alle Objekte mit Tag 'time_Linie' löschen =
  %============================================
  hdl=findobj('Tag','time_Linie');
  if ~isempty(hdl), rette=get(hdl(1),'ButtonDownFcn'); else, rette=''; end
  delete(hdl);

  if ~get(hdl_fft,'Value')  % ZEITBEREICH
    %===============================================
    % Aufbereitung der Werte zur graf. Darstellung =
    %===============================================
    t_n=[0:anz_werte-1]; x_n=x_n(1:anz_werte); h_n=h_n(1:anz_werte);

    %====================================
    % Berechnung der Systemantwort y(n) =
    %====================================
    y_n=filter(num,den,x_n);

    %==================
    % Interpolation ? =
    %==================
    if get(hdl_interpol,'Value')
      tt_n=min(t_n):max(t_n)/4/max(t_n):max(t_n);
      if output_auswahl==1|output_auswahl==4|output_auswahl==5
        x_n=spline(t_n,x_n,tt_n);
        min_x=min(x_n); if min_x>0, min_x=0; end
        delta=max(x_n)-min_x;
        min_x=min_x-delta/50-eps; max_x=max(x_n)+delta/50+eps;
      end
      if output_auswahl==2|output_auswahl==5
        h_n=spline(t_n,h_n,tt_n);
        min_h=min(h_n); if min_h>0, min_h=0; end
        delta=max(h_n)-min_h;
        min_h=min_h-delta/50-eps; max_h=max(h_n)+delta/50+eps;
      end
      if output_auswahl==3|output_auswahl==4|output_auswahl==5
        y_n=spline(t_n,y_n,tt_n);
        min_y=min(y_n); if min_y>0, min_y=0; end
        delta=max(y_n)-min_y;
        min_y=min_y-delta/50-eps; max_y=max(y_n)+delta/50+eps;
      end
      old_t_n=tt_n; t_n=tt_n;
      set([hdl_line1,hdl_line2,hdl_line3],...
          'LineStyle','-','LineWidth',1,'Visible','on','Marker','none');
      LineStyle='-'; Marker='none'; LineWidth=1; Visible='on';
    else
      tt_n=[t_n;t_n;nan*ones(size(t_n))]; tt_n=tt_n(:);
      old_t_n=t_n;
      xx_n=[zeros(1,anz_werte);x_n;nan*ones(size(x_n))]; xx_n=xx_n(:);
      hh_n=[zeros(1,anz_werte);h_n;nan*ones(size(h_n))]; hh_n=hh_n(:);
      yy_n=[zeros(1,anz_werte);y_n;nan*ones(size(y_n))]; yy_n=yy_n(:);

      min_x=min(x_n); if min_x>0, min_x=0; end
      delta=max(x_n)-min_x;
      min_x=min_x-delta/20-eps; max_x=max(x_n)+delta/20+eps;

      min_h=min(h_n); if min_h>0, min_h=0; end
      delta=max(h_n)-min_h;
      min_h=min_h-delta/20-eps; max_h=max(h_n)+delta/20+eps;

      min_y=min(y_n); if min_y>0, min_y=0; end
      delta=max(y_n)-min_y;
      min_y=min_y-delta/20-eps; max_y=max(y_n)+delta/20+eps;
      if anz_werte <= 64
        set([hdl_line1,hdl_line2,hdl_line3],'LineStyle','none','Marker','o',...
            'LineWidth',3,'Visible','on');
        Visible='on';
      else
        set([hdl_line1,hdl_line2,hdl_line3],'Visible','off');
        Visible='off';
      end
      LineStyle='none'; LineWidth=3; Marker='o';
    end

    %===============
    % NaN abfangen =
    %===============
    if isnan(min_x),min_x=-realmax; end
    if isnan(min_h),min_h=-realmax; end
    if isnan(min_y),min_y=-realmax; end
    if isnan(max_x),max_x= realmax; end
    if isnan(max_h),max_h= realmax; end
    if isnan(max_y),max_y= realmax; end

    %=======================
    % XTick manuell setzen =
    %=======================
    index=0:anz_werte/8:anz_werte-1;
    if anz_werte~=8, index(length(index)+1)=anz_werte-1; end
    %==========
    % Ausgabe =
    %==========
    if ~isempty(hdl_ax3)
      set(hdl_ax1,'XLim',[0 anz_werte-1],'YLim',[min_x max_x]);
      set(hdl_ax2,'XLim',[0 anz_werte-1],'YLim',[min_h max_h]);
      set(hdl_ax3,'XLim',[0 anz_werte-1],'YLim',[min_y max_y]);
      set([hdl_ax1,hdl_ax2,hdl_ax3],'XTick',index,'XTickLabel',index);

      set(hdl_line1,'XData',t_n,'YData',x_n);
      axes(hdl_ax1); ylabel('x(n)','Color','k');
      if ~get(hdl_interpol,'Value')
          line(tt_n(:),xx_n(:),'Color','k',...
               'Tag','time_Linie','ButtonDownFcn',rette);
      end

      axes(hdl_ax2); ylabel('h(n)','Color','k');
      if ~isempty(hdl_line2)
        set(hdl_line2,'XData',t_n,'YData',h_n);
      else
        hdl_line2=line(t_n,h_n,'Tag','time_Linie2');
      end
      if ~get(hdl_interpol,'Value')
          line(tt_n(:),hh_n(:),'Color','k',...
            'Tag','time_Linie','ButtonDownFcn',rette);
      end

      axes(hdl_ax3); ylabel('y(n)','Color','k'); xlabel('n','Color','k');
      if ~isempty(hdl_line3)
        set(hdl_line3,'XData',t_n,'YData',y_n);
      else
        hdl_line3=line(t_n,y_n,'Tag','time_Linie3');
      end
      if ~get(hdl_interpol,'Value')
          line(tt_n(:),yy_n(:),'Color','k','Linewidth',1,...
               'Tag','time_Linie','ButtonDownFcn',rette);
      end

    elseif ~isempty(hdl_ax2)

      set(hdl_ax1,'XLim',[0 anz_werte-1],'YLim',[min_x max_x]);
      set(hdl_ax2,'XLim',[0 anz_werte-1],'YLim',[min_y max_y]);
      set([hdl_ax1,hdl_ax2],'XTick',index,'XTickLabel',index);
      set(hdl_line1,'XData',t_n,'YData',x_n);

      axes(hdl_ax1); ylabel('x(n)','Color','k');
      if ~get(hdl_interpol,'Value')
        line(tt_n(:),xx_n(:),'Color','k','Linewidth',1,...
             'Tag','time_Linie','ButtonDownFcn',rette);
      end

      axes(hdl_ax2); ylabel('y(n)','Color','k'); xlabel('n','Color','k');
      if ~isempty(hdl_line2)
        set(hdl_line2,'XData',t_n,'YData',y_n);
      else
        hdl_line2=line(t_n,y_n,'Tag','time_Linie2');
      end
      if ~get(hdl_interpol,'Value')
          line(tt_n(:),yy_n(:),'Color','k','Linewidth',1,...
               'Tag','time_Linie','ButtonDownFcn',rette);
      end
    else
      axes(hdl_ax1);
      if output_auswahl==1
        ylabel('x(n)','Color','k');
        set(hdl_line1,'XData',t_n,'YData',x_n);
        set(hdl_ax1,'XLim',[0 anz_werte-1],'YLim',[min_x max_x]);
        if ~get(hdl_interpol,'Value')
          line(tt_n(:),xx_n(:),'Color','k','Linewidth',1,...
               'Tag','time_Linie','ButtonDownFcn',rette);
        end
      elseif output_auswahl==2
        ylabel('h(n)','Color','k');
        set(hdl_line1,'XData',t_n,'YData',h_n);
        set(hdl_ax1,'XLim',[0 anz_werte-1],'YLim',[min_h max_h]);
        if ~get(hdl_interpol,'Value')
          line(tt_n(:),hh_n(:),'Color','k','Linewidth',1,...
               'Tag','time_Linie','ButtonDownFcn',rette);
        end
      elseif output_auswahl==3
        ylabel('y(n)','Color','k');
        set(hdl_line1,'XData',t_n,'YData',y_n);
        set(hdl_ax1,'XLim',[0 anz_werte-1],'YLim',[min_y max_y]);
        if ~get(hdl_interpol,'Value')
          line(tt_n(:),yy_n(:),'Color','k','Linewidth',1,...
               'Tag','time_Linie','ButtonDownFcn',rette);
        end
      end
      xlabel('n');
      set(hdl_ax1,'XTick',index,'XTickLabel',index);
    end
    set([hdl_line1,hdl_line2,hdl_line3],'LineWidth',LineWidth,...
      'MarkerSize',4,'Visible',Visible,'LineStyle',LineStyle,'Color','k','Marker',Marker);

    %==============================
    % Marker eventuell neu setzen =
    %==============================
    if ~isempty(markmerk)
      pos=min(find(old_t_n==markmerk));
      hdl=findobj('Tag','time_check_marker');
      if isempty(pos), pos=1; end
      set(hdl,'Value',1);
      filttime('Marker',pos);
    end

  else % FREQUENZBEREICH

    fft_anz=1024;
    %=================
    % Frequenzvektor =
    %=================
    W=(0:fft_anz/2-1)/fft_anz;

    %=====================
    % lösche 2. Linie(n) =
    %=====================
    delete(findobj('Tag','time_Linie'));

    %===========
    % X=FFT(x) =
    %===========
    X_W=abs(fft(x_n,fft_anz)); X_W=X_W(1:fft_anz/2);

    %=============================================
    % X(W) normieren, so daß FFT(delta(n))==1(W) =
    %=============================================
    index=max(find(x_n~=0));
    index=index-(min(find(x_n~=0))-1);
    if index>0, X_W=X_W/index; end

    %===========
    % H=FFT(h) =
    %===========
    H_W=abs(fft(h_n,fft_anz)); H_W=H_W(1:fft_anz/2);
    % Normierung : H_W=H_W/1;

    %=========
    % Y=H.*X =
    %=========
    Y_W=X_W.*H_W;

    %===================================
    % linear / logarithmische Skaliert =
    %===================================
    if get(findobj('Tag','time_scale'),'Value')==2
      X_W=20*log10(X_W+eps); min_X=min(X_W); max_X=max(X_W);
      H_W=20*log10(H_W+eps); min_H=min(H_W); max_H=max(H_W);
      Y_W=20*log10(Y_W+eps); min_Y=min(Y_W); max_Y=max(Y_W);
      delta=(max_X-min_X)/20; if delta<0.1, delta=0.1; end
      max_X=max_X+delta; min_X=min_X-delta;
      if min_X<-150, min_X=-150; end
      delta=(max_H-min_H)/20; if delta<0.1, delta=0.1; end
      max_H=max_H+delta; min_H=min_H-delta;
      if min_H<-150, min_H=-150; end
      delta=(max_Y-min_Y)/20; if delta<0.1, delta=0.1; end
      max_Y=max_Y+delta; min_Y=min_Y-delta;
      if min_Y<-150, min_Y=-150; end
      str=' in dB';
      if isnan(min_X),min_X=-realmax; end
      if isnan(min_H),min_H=-realmax; end
      if isnan(min_Y),min_Y=-realmax; end
      if isnan(max_X),max_X=realmax; end
      if isnan(max_H),max_H=realmax; end
      if isnan(max_Y),max_Y=realmax; end 
    else
      min_X=0; max_X=max(X_W)*1.02+eps; if isnan(max_X),max_X=realmax; end
      min_H=0; max_H=max(H_W)*1.02+eps; if isnan(max_H),max_H=realmax; end
      min_Y=0; max_Y=max(Y_W)*1.02+eps; if isnan(max_Y),max_Y=realmax; end
      str='';
    end

    %==========
    % Ausgabe =
    %==========
    if ~isempty(hdl_ax3)
      set(hdl_ax1,'XLim',[0 .5],'YLim',[min_X max_X]);
      set(hdl_ax2,'XLim',[0 .5],'YLim',[min_H max_H]);
      set(hdl_ax3,'XLim',[0 .5],'YLim',[min_Y max(max_X,max_Y)]);
      set([hdl_ax1,hdl_ax2,hdl_ax3],'XTickMode','auto',...
          'XTickLabelMode','auto');
      set(hdl_line1,'XData',W,'YData',X_W);
      set(get(hdl_ax1,'ylabel'),'String',['|X(F)|/M',str]);
      axes(hdl_ax2);
      ylabel(['|H(F)|',str],'Color','k');
      if ~isempty(hdl_line2)
        set(hdl_line2,'XData',W,'YData',H_W);
      else
        hdl_line2=line(W,H_W,'Color','k','Tag','time_Linie2');
      end

      axes(hdl_ax3);
      ylabel(['|Y(F)|/M',str],'Color','k'); xlabel('F','Color','k');
      if ~isempty(hdl_line3)
        set(hdl_line3,'XData',W,'YData',Y_W);
      else
        hdl_line3=line(W,Y_W,'Color','k','Tag','time_Linie3');
      end

    elseif ~isempty(hdl_ax2)

      set(hdl_ax1,'XLim',[0 .5],'YLim',[min_X max_X]);
      set(hdl_ax2,'XLim',[0 .5],'YLim',[min_Y max(max_X,max_Y)]);
      set([hdl_ax1,hdl_ax2],'XTickMode','auto',...
          'XTickLabelMode','auto');
      set(hdl_line1,'XData',W,'YData',X_W);
      set(get(hdl_ax1,'ylabel'),'String',['|X(F)|/M',str],'Color','k');

      axes(hdl_ax2);
      ylabel(['|Y(F)|/M',str],'Color','k'); xlabel('F','Color','k');
      if ~isempty(hdl_line2)
        set(hdl_line2,'XData',W,'YData',Y_W);
      else
        hdl_line2=line(W,Y_W,'Color','k','Tag','time_Linie2');
      end
    else
      axes(hdl_ax1);
      if output_auswahl==1
        ylabel(['|X(F)|/M',str],'Color','k');
        set(hdl_line1,'XData',W,'YData',X_W);
        set(hdl_ax1,'XLim',[0 .5],'YLim',[min_X max_X]);
      elseif output_auswahl==2
        ylabel(['|H(F)|',str],'Color','k');
        set(hdl_line1,'XData',W,'YData',H_W);
        set(hdl_ax1,'XLim',[0 .5],'YLim',[min_H max_H]);
      elseif output_auswahl==3
        ylabel(['|Y(F)|/M',str],'Color','k');
        set(hdl_line1,'XData',W,'YData',Y_W);
        set(hdl_ax1,'XLim',[0 .5],'YLim',[min_Y max_Y]);
      end
      xlabel('F','Color','k');
      set(hdl_ax1,'XTickMode','auto','XTickLabelMode','auto');
    end
    set([hdl_line1,hdl_line2,hdl_line3],'LineStyle','-',...
        'LineWidth',1,'Visible','on','Marker','none');

    %==============================
    % Marker eventuell neu setzen =
    %==============================
    if ~isempty(markmerk)
      pos=min(find(W==markmerk));
      hdl=findobj('Tag','time_check_marker');
      if isempty(pos), pos=1; end
      set(hdl,'Value',1);
      filttime('Marker',pos);
    end

  end

  return

elseif strcmp(action,'Marker')
%===================
% Marker /diskret/ =
%===================
  marker_wert=get(findobj('Tag','time_check_marker'),'Value');
  output_auswahl=get(findobj('Tag','time_plot_output'),'Value');

  if marker_wert==1
  %===============================================================
  %       Handles ermitteln und Marker initialisieren            =
  %===============================================================
    hdl_line=findobj('Tag','time_Linie1');
    hdl_ax=get(hdl_line,'Parent');
    hdl_x=findobj('Tag','time_text_x');
    hdl_y=findobj('Tag','time_text_y');
    if nargin==1, pos=1; else, pos=s; end
    x=get(hdl_line,'XData'); y=get(hdl_line,'YData');
    hdl_lines=findobj(hdl_ax,'Tag','time_Linie');

    markerok('make',hdl_ax,'Ver',[x(pos) y(pos)],'-',...
             [hdl_line,hdl_lines],hdl_x,hdl_y);

    if output_auswahl==4 | output_auswahl==5
      hdl_line2=findobj('Tag','time_Linie2');
      hdl_ax2=get(hdl_line2,'Parent');
      hdl_lines=findobj(hdl_ax2,'Tag','time_Linie');
      hdl_x=findobj('Tag','time_text_x2');
      hdl_y=findobj('Tag','time_text_y2');
      y2=get(hdl_line2,'YData');
      markerok('make',hdl_ax2,'Ver2',[x(pos) y2(pos)],...
               '-',[hdl_line2,hdl_lines],hdl_x,hdl_y);
    end
    if output_auswahl==5
      hdl_line3=findobj('Tag','time_Linie3');
      hdl_ax3=get(hdl_line3,'Parent');
      hdl_lines=findobj(hdl_ax3,'Tag','time_Linie');
      hdl_x=findobj('Tag','time_text_x3');
      hdl_y=findobj('Tag','time_text_y3');
      y3=get(hdl_line3,'YData');
      markerok('make',hdl_ax3,'Ver3',[x(pos) y3(pos)],...
               '-',[hdl_line3,hdl_lines],hdl_x,hdl_y);
    end

  else
  %===============================================================
  %                             Marker löschen                   =
  %===============================================================
    markerok('del',[],'Ver');
    if findobj('Tag','Ver2')
      markerok('del',[],'Ver2');
    end
    if findobj('Tag','Ver3')
      markerok('del',[],'Ver3');
    end

  end

elseif strcmp(action,'hilfe')
%=====================================
%      Windows-Hilfe aufrufen        =
% NUR MICROSOFT WINDOWS-KOMPATIBEL ! =
%=====================================
  !winhelp filttime.hlp

elseif strcmp(action,'Other')
  hdl=findobj('Tag','time_area_auswahl');
  if get(hdl,'Value')==1
    fontsize=get(hdl,'UserData');   
    filttime('close');
    filtplot('initialize',fontsize);
  end
  return

elseif strcmp(action,'TitleEdit')
  %=======================
  % Eingabe eines Titels =
  %=======================
  hdl_edit=findobj('Tag','time_title_edit');
  hdl_ax=findobj('Tag','time_Achse1');
  hdl_ti=get(hdl_ax,'Title');
  set(hdl_ti,'String',get(hdl_edit,'String'),'Color','k');

elseif strcmp(action,'AutoTitel')
  %=======================
  % Automatischer Titel  =
  %=======================
  hdl_edit=findobj('Tag','time_title_edit');
  hdl_ax=findobj('Tag','time_Achse1');
  hdl_ti=get(hdl_ax,'Title');
  str=autotit;
  set(hdl_ti,'String',str,'Color','k');
  set(hdl_edit,'String',str);

elseif findstr(action,'close') % close und close_ok
%========================
% Filteranalyse beenden =
%========================
   %======================================
   % vorhandene Achsen & Objekte löschen =
   %======================================
    hdl=findobj('Tag','time_Achse1');
    delete(hdl);
    hdl=findobj('Tag','time_Achse2');
    if ~isempty(hdl), delete(hdl); end
    hdl=findobj('Tag','time_Achse3');
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
