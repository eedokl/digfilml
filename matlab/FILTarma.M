function [num,den]=filtarma(action,s,nume,deno);

%filtarma  Grafisches Filter Entwicklungsprogramm.
%          zur Approximation bekannter Filter
%          durch ARMA-Modelle und zur Umwandlung
%          in Minimum- und Maximumphasensysteme.
%
% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover
%
%	Zum starten "filtarma" eintippen.
%
%	Die berechneten Filterparameter lassen sich zur Laufzeit mit
%	   [b,a] = filtarma('getfilt');
%	auslesen.
%       Beim Programmabschluß mit OK schreibt das Programm
%       die Filterparameter in die globalen Variablen b und a
%       wenn ein Fenster mit 'Tag','hauptfenster' existiert.
%
%       Siehe auch : prony, stmcb, lpc, maxphase, minphase

%       Zum korrekten Bildaufbau ist die Schriftgröße anzugeben !

% Possible actions and button callbacks:
%   initialize
%   design
%   axesredraw
%   info
%   closehelp
%   getfilt

if nargin<1,
    action='initialize';
end;

% prevent uninitialized variable warning !
 aa=1; bb=1;

if strcmp(action,'initialize'),
  if length(nume)<2 & length(deno)<2 & ~strcmp(action,'close')
     fehler('','Darstellung nicht möglich !',...
     'Keine oder nicht genügend Filterkoeffizienten vorhanden.');
     return
  end

   % Bildschrimgröße
    scr_size=get(0,'ScreenSize');
    if nargin==0|nargin==1, fontsize=8; else fontsize=s; end

   %=====================================================
   % Berechne 'textHeight' für Fenster "ohne" uimenu !! =
   %=====================================================
    textHeight=fontsize/scr_size(4)*1.67;

    scr_size(3:4)=scr_size(3:4)-2;
    scr_size(4)=scr_size(4)-22;

    %================================
    % main fenster ausschalten
    hdl_main=findobj('Tag','hauptfenster');
    if ~isempty(hdl_main)
      set(hdl_main,'visible','off');
    end

    figNumber=figure( ...
    	'MenuBar','none', ...
        'Name','ARMA-Filtermodellierung', ...
        'NumberTitle','off', ...
        'Position',scr_size, ...
        'Color',[255 255 255]/255, ...
        'InvertHardcopy','off', ...
        'Resize','off','Visible','off');


    %====================================
    % Information für alle Objekte

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
    spacing=0.019;

    %==================================
    % Set up the frequency response axes
    freqzHnd=axes( ...
        'Units','normalized', ...
        'Position',[0.325 0.11 0.60 0.8], ...
        'Xcolor','black', ...
        'Ycolor','black', ...
        'Box','on');
    set(figNumber,'defaultaxesposition',[0.325 0.11 0.60 0.80])

    set(freqzHnd, ...
        'Units','normalized', ...
        'Position',[0.325 0.11 0.60 0.8], ...
        'Box','on');

    %====================================
    % The CONSOLE frame
    yPos=frmBottom-frmBorder;
    frmPos=[left yPos frmWidth+2*frmBorder frmHeight+2*frmBorder];
    h=uicontrol( ...
        'Style','frame', ...
        'Units','normalized', ...
        'Position',frmPos, ...
        'Clipping','off', ...
	'Background',my_color);

    %==========================
    % Ändere Hintergrundfarbe
    my_color=my_color+0.05;

    %====================================
    % The CONSOLE frame1
    yPos=frmBottom-frmBorder;
    frmPos=[left+.01 top-3.5*textHeight+0.01 frmWidth+2*frmBorder-0.02 4.5*textHeight];
    h=uicontrol( ...
        'Style','frame', ...
        'Units','normalized', ...
        'Position',frmPos, ...
        'Clipping','off', ...
	'Background',my_color);

    %====================================
    % ARMA Design Routine Selection Menu {fhndlList(14)}
    % Default : Original
    yPos=1-textHeight*.5;
    btnPos=[left+frmBorder yPos-btnHt btnWid textHeight*1.25];
    labelStr=['Ausgangs-Filter|ARMA Prony|ARMA Steiglitz-McBride|'...
              'ARMA Shanks|AR Autokorrelation|AR Kovarianz|MA Durbin'];
    callbackStr='filtarma(''design'');';
    methodHndl=uicontrol( ...
        'Style','popupmenu', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'Interruptible','on', ...
        'Value',1,'Max',7, ...
        'Background',my_color, ...
        'Foreground',mtc, ...
        'Callback',callbackStr);

    %====================================
    % Filter Order text label 
    labelWidth = frmWidth-.01;
    labelBottom=top;
    labelPos = [left+frmBorder labelBottom labelWidth textHeight];
    h = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
	'Position',labelPos, ...
        'Horiz','center', ...
        'String','Ordnung', ...
        'Interruptible','off', ...
        'Background',my_color, ...
        'ForegroundColor',mtc);

    %====================================
    % numerator Estimate text&edit field
    labelBottom=top-textHeight*1.5;
    btnPos=[left+frmBorder labelBottom btnWid*.6 textHeight];

    textPos=[left+frmBorder labelBottom btnWid*.37 textHeight];
    uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',textPos, ...
        'Horiz','left', ...
        'Background',my_color, ...
        'String','Zähler:', ...
        'Foreground',mtc);

    textPos=[left+frmBorder+btnWid*.62 labelBottom btnWid*.37 textHeight*1.25];
    ord1Hndl = uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',textPos, ...
        'Horiz','left', ...
        'Background',my_color+0.1, ...
        'String',num2str(length(nume)-1),'Userdata',nume, ...
        'Foreground',mtc,...
        'CallBack','filtarma(''design'');');

    %====================================
    % Specify denominator text&edit
    labelBottom=top-textHeight*2.75;
    btnPos=[left+frmBorder labelBottom btnWid*.6 textHeight];
    textPos=[left+frmBorder labelBottom btnWid*.37 textHeight];
    callbackStr = 'filtarma(''design'');';
    uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',textPos, ...
        'Horiz','left', ...
        'Background',my_color, ...
        'String','Nenner:', ...
        'Foreground',mtc);
    textPos=[left+frmBorder+btnWid*.62 labelBottom btnWid*.37 textHeight*1.25];
    ord2Hndl = uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',textPos, ...
        'Horiz','left', ...
        'Background',my_color+0.1, ...
        'Foreground','black', ...
        'String',num2str(length(deno)-1),'Userdata',deno, ...
        'Max',1, ...
        'callback',callbackStr);

    %====================================
    % View Popup - Menu 
    labelStr='Gesamtansicht|Durchlaßbereich|Sperrbereich';
    callbackStr='filtarma(''axesredraw'');';
    viewHndl=uicontrol( ...
        'Style','popupmenu', ...
        'Units','normalized', ...
        'Position',[left+frmBorder frmBottom+2*(btnHt+spacing) btnWid textHeight], ...
        'String',labelStr, ...
        'Interruptible','on', ...
        'Background',my_color, ...
        'Foreground',mtc, ...
        'Callback',callbackStr);

    %====================================
    % The INFO button
    labelStr='Hilfe';
    callbackStr='filtarma(''info'')';
    helpHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[left+frmBorder frmBottom+btnHt+spacing btnWid btnHt], ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %====================================
    % The CLOSE button
    labelStr='Abbruch';
    callbackStr='filtarma(''close'');';
    closeHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[left+frmBorder+btnWid/2 frmBottom btnWid/2 btnHt], ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %====================================
    % The OK button
    labelStr='OK';
    callbackStr='filtarma(''close_ok'');';
    closeHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[left+frmBorder frmBottom btnWid/2 btnHt], ...
        'String',labelStr, ...
        'Callback',callbackStr);

    FreqsHndl=1;
    RipplesHndl=1;
    btn1Hndl=1;
    btn2Hndl=1;

    fhndlList=[freqzHnd 0 0 FreqsHndl RipplesHndl ...
              0 viewHndl btn1Hndl btn2Hndl ord1Hndl ord2Hndl ...
              helpHndl closeHndl methodHndl ];

    set(figNumber,'Visible','on','UserData',fhndlList);
    drawnow

    % axes(freqzHnd)
    set(freqzHnd,'Userdata',[])
    filtarma('design');
    return

elseif strcmp(action,'design'), % Design filter
  set(gcf,'Pointer','watch');

  axHndl=gca;
  fhndlList=get(gcf,'Userdata');
  freqzHndl = fhndlList(1);
  viewHndl = fhndlList(7);
  ord1Hndl = fhndlList(10);
  ord2Hndl = fhndlList(11);
  methodHndl = fhndlList(14);
  okbuttHndl=findobj(gcf,'String','OK');

% initialize variables
  bb=get(ord1Hndl,'UserData');
  aa=get(ord2Hndl,'UserData');
  hh=filter(bb,aa,[1,zeros(1,255)]);

% read specified orders !
  % gewünschte Filterordnung ermitteln & korrekte Eingabe prüfen
  num=eval(get(ord1Hndl,'String'),'-1');
  den=eval(get(ord2Hndl,'String'),'-1');
  if num<0, num=length(bb)-1;
    uiwait(msgbox('-> Eingabefehler !','FEHLER','none','modal'));
    set(ord1Hndl,'String',num2str(length(bb)-1));
  end
  if den<0, den=length(aa)-1;
    uiwait(msgbox('-> Eingabefehler !','FEHLER','none','modal'));
    set(ord2Hndl,'String',num2str(length(aa)-1));
  end

  method=get(methodHndl,'Value');

% Design filter
  if method==1, % Original
    title_str=sprintf('Original-Modell %d. Ordnung',max(num,den));    %
    set(ord1Hndl,'Visible','on','String',num2str(length(bb)-1));
    set(ord2Hndl,'Visible','on','String',num2str(length(aa)-1));
  elseif method==2, % ARMA Prony
    set(ord1Hndl,'Visible','on');
    set(ord2Hndl,'Visible','on');
    [bb,aa] = prony(hh,num,den);
    title_str=sprintf('ARMA-Modell %g. Ordnung (Prony) ',max(num,den));

    % Das gleiche Ergebnis erhält man mit den Funktionen
    % [H,W]=freqz(bb,aa); [bb,aa]=invfreqz(H,W,num,den);
    % Vorteile liegen in einer mögliche Gewichtung der
    % Frequenzbereiche. Dies ist hier nicht implementiert !

  elseif method==3, % ARMA Steiglitz-McBride
    set(ord1Hndl,'Visible','on');
    set(ord2Hndl,'Visible','on');
    [bb,aa] = stmcb(hh,num,den);
    title_str=sprintf('ARMA-Modell %g. Ordnung (Steiglitz-McBride)',...
                      max(num,den));
  elseif method==4 % ARMA Shanks-Methode
    set(ord1Hndl,'Visible','on');
    set(ord2Hndl,'Visible','on');
    if den==0, den=1;
      set(ord2Hndl,'String',num2str(den));
      uiwait(msgbox('-> Nennerordnung erhöht !','ACHTUNG','none','modal'));
    end
    [bb,aa]=shank(hh,den,num);
    title_str = sprintf('ARMA-Modell %g. Ordnung (MA-Shank,AR-Kovarianz)',...
                        max(num,den));
  elseif method==5, % AR Linear Predictior / Autokorrelation
    set(ord1Hndl,'Visible','off');
    set(ord2Hndl,'Visible','on');
    if den==0, den=1;
      set(ord2Hndl,'String',num2str(den));
      uiwait(msgbox('-> Nennerordnung erhöht !','ACHTUNG','none','modal'));
    end
    [aa,bb] = lpc(hh,den); % num immer 1 -> all-pole
    title_str = sprintf('AR-Modell %g. Ordnung (Autokorrelation)',...
                        max(num,den));
  elseif method==6, % AR Kovarianz-Methode
    set(ord1Hndl,'Visible','off');
    set(ord2Hndl,'Visible','on');
    Hd=toeplitz(hh,[hh(1),zeros(1,den)]);
    INV=Hd.' * Hd;
    aa=pinv(INV)*hh(1:(den+1)).';
    aa=polystab(aa'); aa=aa/aa(1);
    model=filter(1,aa,[1,zeros(1,255)]);
    bb=sqrt(sum(hh.*hh)/sum(model.*model));
    title_str = sprintf('AR-Modell %g. Ordnung (Kovarianz)',...
                        max(num,den));
  elseif method==7, % MA Durbins-Methode
    set(ord1Hndl,'Visible','on');
    set(ord2Hndl,'Visible','off');
    if num==0, num=1;
      set(ord1Hndl,'String',num2str(num));
      uiwait(msgbox('-> Zählerordnung erhöht !','ACHTUNG','none','modal'));
    elseif num>39, num=39;
      uiwait(msgbox('-> Modell-Ordnung zu groß !','ACHTUNG','none','modal'));
      set(ord1Hndl,'String',num2str(num));
    end
    bb=durbin(hh,5*num,num)'; aa=1;
    title_str = sprintf('MA-Modell %g. Ordnung (Durbin)',max(num,den));
  end

  % Sichern der neuen Koeffizienten im OK-Button
  if length(aa)<length(bb)
    aa=[aa,zeros(1,length(bb)-length(aa))];
  elseif length(bb)<length(aa)
    bb=[bb,zeros(1,length(aa)-length(bb))];
  end

  set(okbuttHndl,'UserData',[bb;aa]);

  [H,F] = freqz(bb,aa,max(2048,nextpow2(5*max(length(bb),length(aa))) ),1);
  H = 20*log10(abs(H+eps));
  axes(freqzHndl)
  axhndlList = get(freqzHndl,'UserData');
  if isempty(axhndlList)   % first time - happens at initialization phase
    % initialize the axes
    % set(gcf,'nextplot','new')
    xlabel('Frequenz (Hz)')
    ylabel('Amplitude (dB)')
    set(gca,'Xcolor','k','Ycolor','k')
    set(get(gca,'title'),'color','k');
    hdl=line(F,H,'Color','k'); grid on;
    set(freqzHndl,'UserData',hdl);
  end
  filtarma('axesredraw',[],bb,aa)
  title(title_str)
  set(gcf,'Pointer','arrow');

  % Die folgende Zeile erzwingt das Neuzeichnen des Mauszeigers.
  % Ohne dies wird der Mauszeiger teilweise erst nach bewegen
  % der Maus auf 'arrow' zurückgesetzt.
  % Dies geschieht bei 'langen' Rechenzeiten zwischen den 'set' Kommandos
  set(0,'PointerLocation',get(0,'PointerLocation'));

  drawnow
  return

elseif strcmp(action,'axesredraw'), % redraw axes

    set(gcf,'Pointer','watch');
    axHndl=gca;
    fhndlList=get(gcf,'Userdata');
    freqzHndl = fhndlList(1);

    viewHndl = fhndlList(7);
    ord1Hndl = fhndlList(10);
    ord2Hndl = fhndlList(11);
    methodHndl = fhndlList(14);

    order = get(ord2Hndl,'UserData'); % use specified Filter order

    method = get(methodHndl,'value');

    axes(freqzHndl)
    axhndlList = get(freqzHndl,'UserData');
    [nume,deno]=filtarma('getfilt');
    [H,F] = freqz(nume,deno,max(2048,nextpow2(5*max(length(bb),length(aa))) ),1);
    H = 20*log10(abs(H+eps));
    set(axhndlList(1),'Xdata',F,'Ydata',H);

    viewmode = get(viewHndl,'value');  % 1 == full, 2 == passband, 3 == stopband

    delta=max(H)-min(H); G=abs(H);
    % wo ist der Durchlaßbereich ?
    if G(1)<3 & G(length(H))>3 %TP
      low=1; high=max(find(G<=3-1e-3));
    elseif G(1)>3 & G(length(H))<3 %HP
      low=min(find(G<=3-1e-3)); high=length(H);
    elseif G(1)>3 & G(length(H))>3 %BP
      low=min(find(G<=6-1e-3)); high=max(find(G<=6-1e-3));
    elseif G(1)<3 & G(length(H))<3 %BS
      high=min(find(G>=3+1e-3)); low=1;
    else
      low=1; high=length(H)
    end
    if viewmode == 1 % Gesamtansicht
      set(freqzHndl,'xlim',[0 0.5],'ylim',[min(H)-delta/20-.1 max(H)+delta/20+.1])
    elseif viewmode == 2 % Durchlaßbereich
      ymin=min(H(low:high)); ymax=max(H);
      if isempty(ymin), ymin=min(H); end
      delta=ymax-ymin; ymin=ymin-delta/20; ymax=ymax+delta/20;
      set(freqzHndl,'ylim',[ymin-.01 ymax+.01]);
    elseif viewmode == 3 % Sperrbereich
      ymin=min(H); ymax=-10;
      set(freqzHndl,'ylim',sort([ymin-eps ymax+eps]));
    end
    xlabel('Frequenz (Hz)')
    ylabel('Amplitude (dB)')
    set(gcf,'Pointer','arrow');
    drawnow
    return

elseif strcmp(action,'info'),
    !winhelp filtarma.hlp
    return

elseif strcmp(action,'getfilt')
    hdl=findobj(gcf,'String','OK');
    coeff=get(hdl,'UserData');
    num=coeff(1,:);
    den=coeff(2,:);
    num=num(1:max(find(num~=0)));
    den=den(1:max(find(den~=0)));

elseif findstr(action,'close') % close und close_ok
    current_figure=gcf;
    hdl_main=findobj('Tag','hauptfenster');
    if strcmp(action,'close_ok')
      [num,den]=filtarma('getfilt');
      %if length(num)>length(den)
      %  den=[den,zeros(1,length(num)-length(den))];
      %end
      if ~isempty(hdl_main),
        fhndlList=get(gcf,'Userdata');
        wert=get(fhndlList(14),'Value');
        if wert>1
          global b a filtertyp; 
          makeprot('filtarma',wert,num,den);
          b=num; a=den; filtertyp=10;
        end
      end
    end
    close(current_figure);
    if ~isempty(hdl_main)
      set(hdl_main,'visible','on');
      if strcmp(action,'close_ok')
        drawmain(num,den,'filtarma');
        if findobj('Tag','plotter_Achse1')
          filtplot('NewDisplay');
        end
      end
    end  
else
  disp(sprintf( ...
     'filtarma: action String ''%s'' nicht bekannt, keine Aktion ausgeführt.',action))
end

