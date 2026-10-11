function [num,den]=filtmake(action,s);

%FILTMAKE  Grafisches Filter Entwicklungsprogramm.
%
% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover
%
%	Zum starten "filtmake" eintippen.
%
%	Die berechneten Filterparameter lassen sich zur Laufzeit mit
%	   [b,a] = filtmake('getfilt');
%	auslesen.
%       Beim Programmabschluß mit OK schreibt das Programm
%       die Filterparameter in die globalen Variablen b und a
%       wenn ein Fenster mit 'Tag','hauptfenster' existiert.
%
%       Siehe auch :
%

%       Zur Vermeidung von 'Log of Zero' Meldungen wurde bei der
%       Berechnung stets log10(abs(H)+eps) angewendet !
%
%       Zum korrekten Bildaufbau ist die Schriftgröße anzugeben !

% Nach einer Idee von T. Krauss, 11/15/93

% Possible actions and button callbacks:
%   initialize
%   changemethod
%   changepassband
%   setFreqs
%   setRipples
%   dragRp
%   dragRs
%   dragWp
%   dragWs
%   setord
%   radio
%   design
%   axesredraw
%   info
%   closehelp
%   getfilt


if nargin<1,
    action='initialize';
end;

if strcmp(action,'initialize'),
   % Bildschrimgröße
    scr_size=get(0,'ScreenSize');
    if nargin==0|nargin==1, fontsize=8; else fontsize=s; end

   %=====================================================
   % Berechne 'textHeight' für Fenster "ohne" uimenu !! =
   %=====================================================
    textHeight=fontsize/scr_size(4)*1.67;

    scr_size(3:4)=scr_size(3:4)-2;
    scr_size(4)=scr_size(4)-22;
    figNumber=figure( ...
    	'MenuBar','none', ...
        'Name','IIR Filterentwicklung (Transformation klassischer Analogfilter)', ...
        'NumberTitle','off', ...
        'Position',scr_size, ...
        'Color',[255 255 255]/255, ...
        'InvertHardcopy','off', ...
        'Resize','off');

    %================================
    % main fenster ausschalten
    hdl_main=findobj('Tag','hauptfenster');
    if ~isempty(hdl_main)
      set(hdl_main,'visible','off');
    end

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
        'XTick',[],'YTick',[], ...
        'Box','on');
    set(figNumber,'defaultaxesposition',[0.325 0.11 0.60 0.80])

    set(freqzHnd, ...
        'Units','normalized', ...
        'Position',[0.325 0.11 0.60 0.8], ...
        'XTick',[],'YTick',[], ...
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
    % The CONSOLE frame2
    yPos=frmBottom-frmBorder;
    frmPos=[left+.01 top-7*textHeight+0.01 frmWidth+2*frmBorder-0.02 6*textHeight];
    h=uicontrol( ...
       'Style','frame', ...
       'Units','normalized', ...
       'Position',frmPos, ...
       'Clipping','off', ...
	'Background',my_color);

    %====================================
    % The CONSOLE frame3
    yPos=frmBottom-frmBorder;
    frmPos=[left+.01 top-10.4*textHeight+0.01 frmWidth+2*frmBorder-0.02 3*textHeight];
    h=uicontrol( ...
        'Style','frame', ...
        'Units','normalized', ...
        'Position',frmPos, ...
        'Clipping','off', ...
	'Background',my_color);

    %====================================
    % The CONSOLE frame4
    yPos=frmBottom-frmBorder;
    frmPos=[left+.01 top-15.5*textHeight+0.01 frmWidth+2*frmBorder-0.02 4.5*textHeight];
    h=uicontrol( ...
        'Style','frame', ...
        'Units','normalized', ...
        'Position',frmPos, ...
        'Clipping','off', ...
	'Background',my_color);

    %====================================
    % The Filter Design Passband Selection Menu {fhndlList(15)}
    yPos=1-textHeight*2.25;

    btnPos=[left+frmBorder yPos-btnHt btnWid textHeight];
    labelStr='Tiefpaß|Hochpaß|Bandpaß|Bandsperre';
    callbackStr='filtmake(''changepassband'');';
    passbandHndl=uicontrol( ...
        'Style','popupmenu', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'Interruptible','on', ...
        'Foreground',mtc, ...
        'Background',my_color, ...
        'Callback',callbackStr);

    %====================================
    % The Filter Design Routine Selection Menu {fhndlList(14)}
    % Default : Butterwoth Filter (1)
    yPos=1-textHeight*.5;
    btnPos=[left+frmBorder yPos-btnHt btnWid textHeight];
    labelStr='Butterworth|Tschebyscheff 1|Tschebyscheff 2|Cauer (elliptisch)';
    callbackStr='filtmake(''changemethod'');';
    methodHndl=uicontrol( ...
        'Style','popupmenu', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'Interruptible','on', ...
        'Value',1, ...
        'Background',my_color, ...
        'Foreground',mtc, ...
        'Callback',callbackStr);
    %===================================
    % Sampling frequency label 
    labelBottom=top-textHeight*2;
    labelWidth = .08;
    labelPos = [left+frmBorder labelBottom labelWidth textHeight];

    h = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
	'Position',labelPos, ...
        'Horiz','left', ...
        'String','fa', ...
        'Interruptible','off', ...
        'Background',my_color, ...
        'ForegroundColor','k');

    %===================================
    % Passband edge frequency label 3
    btnNumber=2;
    yPos=menutop-(btnNumber-1)*btnHt+0.04;
    labelBottom=top-textHeight*3;
    labelPos = [left+frmBorder labelBottom labelWidth textHeight];
    h = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',labelPos, ...
        'Horiz','left', ...
        'String','f1', ...
        'Interruptible','off', ...
        'Background',my_color, ...
        'ForegroundColor',mtc);

    %===================================
    % Stopband edge frequency label 2
    labelBottom=top-textHeight*4;
    labelPos = [left+frmBorder labelBottom labelWidth textHeight];
    h = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
		'Position',labelPos, ...
        'Horiz','left', ...
        'String','f2', ...
        'Interruptible','off', ...
        'Background',my_color, ...
        'ForegroundColor',mtc);

    %===================================
    % Stopband edge frequency label 3
    labelBottom=top-textHeight*5;
    labelPos = [left+frmBorder labelBottom labelWidth textHeight];
    h = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
		'Position',labelPos, ...
        'Horiz','left', ...
        'String','f3', ...
        'Interruptible','off', ...
        'Background',my_color, ...
        'ForegroundColor',[.6 .6 .6]);
    %===================================
    % Stopband edge frequency label 4
    labelBottom=top-textHeight*6;
    labelPos = [left+frmBorder labelBottom labelWidth textHeight];
    h = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
		'Position',labelPos, ...
        'Horiz','left', ...
        'String','f4', ...
        'Interruptible','off', ...
        'Background',my_color, ...
        'ForegroundColor',[.6 .6 .6]);

    %====================================
    % frequency Text field / mulitline
    textPos = [left+frmBorder+labelWidth labelBottom textWidth*1.55 5.1*textHeight];
    callbackStr = 'filtmake(''setFreqs'')';
    str = sprintf('1\n0.2\n0.3');
    mat = [1; .2; .3];
    FreqsHndl = uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',textPos, ...
        'Max',2, ... % makes this a multiline edit object
        'Background',my_color+0.1, ...
        'Foreground','black','horiz','left', ...
        'String',str,'Userdata',mat, ...
        'callback',callbackStr);

    %===================================
    % passband ripple label
    labelBottom=top-textHeight*8.5;
    labelLeft = left;
    labelPos = [labelLeft+frmBorder labelBottom labelWidth textHeight];
    h = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
	'Position',labelPos, ...
        'Horiz','left', ...
        'String','Rpass', ...
        'Interruptible','off', ...
        'Background',my_color, ...
        'ForegroundColor',mtc);

    %===================================
    % stopband attenuation label and text field
    labelBottom=top-textHeight*9.5;
    labelPos = [left+frmBorder labelBottom labelWidth textHeight];
    h = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
	'Position',labelPos, ...
        'Horiz','left', ...
        'String','Rstop', ...
        'Interruptible','off', ...
        'Background',my_color, ...
        'ForegroundColor',mtc);

    % ripple Text field
    textPos = [left+frmBorder+labelWidth labelBottom textWidth*1.55 2.1*textHeight];
    callbackStr = 'filtmake(''setRipples'')';
    str = sprintf('3\n60');
    RipplesHndl = uicontrol( ...   % fhndlList(5)
        'Style','edit', ...
        'Units','normalized', ...
        'Position',textPos, ...
        'Max',2, ... % makes this a multiline edit object
        'Horiz','left', ...
        'Background',my_color+.1, ...
        'Foreground','black', ...
        'String',str,'Userdata',[3;60], ...
        'callback',callbackStr);

    %====================================
    % Filter Order text label 
    labelWidth = frmWidth-.01;
    labelBottom=top-textHeight*12;
    labelPos = [left+frmBorder labelBottom labelWidth textHeight];
    h = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
	'Position',labelPos, ...
        'Horiz','center', ...
        'String','Filterordnung', ...
        'Interruptible','off', ...
        'Background',my_color, ...
        'ForegroundColor',mtc);

    %====================================
    % Estimate radio button and text field
    labelBottom=top-textHeight*13.5;
    labelStr='automat.:';
    callbackStr='filtmake(''radio'',1)';
    btnPos=[left+frmBorder labelBottom btnWid*.6 textHeight];
    btn1Hndl=uicontrol( ...
        'Style','radiobutton', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'Background',my_color, ...
        'Foreground',mtc, ...
        'value',1,'Userdata',1, ...
        'Callback',callbackStr);

    textPos=[left+frmBorder+btnWid*.62 labelBottom btnWid*.37 textHeight];
    ord1Hndl = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',textPos, ...
        'Horiz','left', ...
        'Background',my_color, ...
        'String','11','Userdata',[11 -1], ...
        'Foreground',mtc);

    %====================================
    % Specify radio button and text field
    labelBottom=top-textHeight*14.5;
    labelStr='manuell:';
    callbackStr='filtmake(''radio'',2);';
    btnPos=[left+frmBorder labelBottom btnWid*.6 textHeight];
    btn2Hndl=uicontrol( ...
        'Style','radiobutton', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'Background',my_color, ...
        'Foreground',mtc, ...
        'value',0, ...
        'Callback',callbackStr);
    textPos=[left+frmBorder+btnWid*.62 labelBottom-.2*textHeight btnWid*.37 textHeight*1.2];
    callbackStr = 'filtmake(''setord'')';
    ord2Hndl = uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',textPos, ...
        'Horiz','left', ...
        'Background',my_color+0.1, ...
        'Foreground','black', ...
        'String','11','Userdata',11, ...
        'Max',1, ...
        'callback',callbackStr);

    %====================================
    % View Popup - Menu 
    labelStr='Gesamtansicht|Durchlaßbereich|Sperrbereich';
    callbackStr='filtmake(''axesredraw'');';
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
    callbackStr='filtmake(''info'')';
    helpHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[left+frmBorder frmBottom+btnHt+spacing btnWid btnHt], ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %====================================
    % The CLOSE button
    labelStr='Abbruch';
    callbackStr='filtmake(''close'');';
    closeHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[left+frmBorder+btnWid/2 frmBottom btnWid/2 btnHt], ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %====================================
    % The OK button
    labelStr='OK';
    callbackStr='filtmake(''close_ok'');';
    closeHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[left+frmBorder frmBottom btnWid/2 btnHt], ...
        'String',labelStr, ...
        'Callback',callbackStr);

    fhndlList=[freqzHnd 0 0 FreqsHndl RipplesHndl ...
              0 viewHndl btn1Hndl btn2Hndl ord1Hndl ord2Hndl ...
              helpHndl closeHndl methodHndl passbandHndl];
    set(figNumber,'Visible','on','UserData',fhndlList);
    drawnow

    % axes(freqzHnd)
    set(freqzHnd,'Userdata',[])
    filtmake('design')
    return

elseif strcmp(action,'changemethod'),
    v = get(gco,'value'); % 1 = BUTTER, 2 = CHEBY1, 3 = CHEBY2, 4 = ELLIP

    if v==4  % bei Cauer-Entwurf, zu kleine Werte verhindern
      fhndlList = get(gcf,'UserData');
      ripples = get(fhndlList(5),'UserData');
      if ripples(1)>=1 & ripples(2)>150, ripples(2)=150;
      elseif ripples(1)<1 & ripples(2)>120, ripples(2)=120; end
      str=sprintf('%g\n%g',ripples);
      set(fhndlList(5),'UserData',ripples,'String',str);
    end

    filtmake('design')

    return

elseif strcmp(action,'changepassband'),
    passband = get(gco,'value');  % 1 = TP, 2 = HP, 3 = BP, 4 = BS

    fhndlList = get(gcf,'UserData');
    freqs = get(fhndlList(4),'UserData');

    ord1hndl=fhndlList(10);
    ord2hndl=fhndlList(11);

    hndl1=findobj('String','f3');
    hndl2=findobj('String','f4');
    if passband>2 & length(freqs)~=5
      freqs=[1; 0.1; 0.2; 0.3; 0.4];
      str=sprintf('1\n0.1\n0.2\n0.3\n0.4');
      set(fhndlList(4),'UserData',freqs,'String',str)
      set([hndl1,hndl2],'Foreground',[0 0 0]);

    elseif passband<3 & length(freqs)~=3
      freqs=[1; 0.2; 0.3];
      str=sprintf('1\n0.2\n0.3');
      set(fhndlList(4),'UserData',freqs,'String',str)
      set([hndl1,hndl2],'Foreground',[0.6 0.6 0.6]);
    end

    % Die ...ord Funktionen liefern die Tiefpaßordnung.
    % Im Fenster sind aber die richtigen Ordnungen noch anzuzeigen !
    % Dies geschieht für 'automatisch' in 'design'
    % für manuell im folgenden:

    order=get(ord2hndl,'UserData');
    if passband < 3
      set(ord2hndl,'String',num2str(order));
    else
      set(ord2hndl,'String',num2str(order*2));
    end

    filtmake('design')
    return

elseif strcmp(action,'setFreqs'),
    v = get(gco,'Userdata');
    str = get(gco,'String');

    fhndlList=get(gcf,'UserData');
    passband=get(fhndlList(15),'Value');

    % Eingegebene Daten umwandeln

    ind = find(abs(str)<32);
    str(ind) = 32*ones(size(ind));
    str2 = str'; siz = size(str2);
    str_r=ones(siz(1),1)*32;
    str=[];
    for ii=1:siz(2)
      str = [str str2(:,ii) str_r];
    end

    vv = eval(['[' str(:)' ']'],'-1')';

    % prüfen auf Plausibilität

  if vv==-1
    vv = v;
    uiwait(msgbox('Keine Zahl eingegeben !','Eingabefehler','none','Modal'));
  elseif passband < 3
    if length(vv)~=3
        vv=v;
        uiwait(msgbox('Es müssen drei Frequenzen eingegeben werden !',...
          'Eingabefehler','none','modal'));
    elseif any(vv<0) | vv(2)>=vv(3) | vv(3)>=vv(1)/2
        vv = v;
        uiwait(msgbox('Frequenzeingabe fehlerhaft !','Eingabefehler',...
          'none','modal'));
    end
  else
    if length(vv)~=5
        vv=v;
        uiwait(msgbox('Es müssen fünf Frequenzen eingegeben werden !',...
          'Eingabefehler','none','modal'));
    elseif any(vv<0)     |  vv(2)>=vv(3) | vv(3)>=vv(4) | ...
       			    vv(4)>=vv(5) | vv(5)>=vv(1)/2
        vv = v;
        uiwait(msgbox('Frequenzeingabe fehlerhaft !','Eingabefehler',...
          'none','modal'));
    end
  end

    if passband<3
      str = sprintf('%g\n%g\n%g',vv(1),vv(2),vv(3));
    else
      str = sprintf('%g\n%g\n%g\n%g\n%g',vv);
    end
    set(gco,'Userdata',vv,'String',str)
    if any(vv~=v)
        filtmake('design')
    else
        filtmake('axesredraw')
    end
    return

elseif strcmp(action,'setRipples'),
    % Cauer kann Programm zum Absturz bringen
    % daher Parameterauswahl begrenzen !

    v = get(gco,'Userdata');
    str = get(gco,'String');
    fhndlList=get(gcf,'UserData');
    method=get(fhndlList(14),'Value');

    ind = find(abs(str)<32);
    str(ind) = 32*ones(size(ind));
    str2 = str'; siz = size(str2);
    str=[];

    % Endekennungen einfügen
    for ii=1:siz(2)
      str=[str;str2(:,ii);[32;32]];
    end

    vv = eval(['[' str(:)' ']'],'-1')';
    if vv == -1 | length(vv)~=2
      vv = v;
      uiwait(msgbox('Eingabe der Welligkeit fehlerhaft !','Eingabefehler',...
        'none','modal'));
    elseif vv(2) < vv(1) | any(vv<=0)
      vv = v;
      uiwait(msgbox('Eingabe der Welligkeit fehlerhaft !','Eingabefehler',...
        'none','modal'));
     end

    % Bei kleineren Werten vv(1) kann das
    % Programm bei der Berechnung abstürzen
    if vv(1)<1e-3,
      vv(1)=1e-3;
      uiwait(msgbox('minimale Welligkeit = 0.001 dB','Hinweis',...
        'none','modal'));
    end

    if method==4  % Cauer-Entwurf, zu kleine Werte verhindern
      if vv(1)>=1 & vv(2)>150, vv(2)=150;
      elseif vv(1)<1 & vv(2)>120, vv(2)=120; end
    end

    str = sprintf('%g\n%g',vv(1),vv(2));
    set(gco,'Userdata',vv,'String',str)
    if any(vv~=v)
        filtmake('design')
    else
        filtmake('axesredraw')
    end
    return

elseif strcmp(action,'dragRp'),
    % s = 1 ==> down, s = 2 ==> mouse motion, s = 3 ==> mouse up
    if s == 1   % down
        fhndlList=get(gcf,'Userdata');
        passband=get(fhndlList(15),'Value');
        freqs = get(fhndlList(4),'UserData');  
        if passband==1
          Wp = freqs(2);                   % passband frequency
        elseif passband==2
          Wp = freqs(3);
        elseif passband==3
          Wp = freqs(3:4);
        else
          Wp = freqs([2,5]);
        end
        ripples = get(fhndlList(5),'UserData');
        Rp = ripples(1);                 % passband ripple
        pt = get(gca,'currentpoint');
        pt_x = pt(1,1);  pt_y = pt(1,2);
        if pt_y > -Rp/2
            return   % 0dB-Linie nicht ziehen !
        end
        method = get(fhndlList(14),'value');
        hndlList=get(gca,'Userdata');
        the_line = hndlList(2);
        set(the_line,'erasemode','xor')

        % how many pixels wide is the Wp line?
        set(gca,'units','pixels'); 
        pos = get(gca,'position'); 
        set(gca,'units','normalized');
        xl = get(gca,'xlim');
        Wp_in_pixels =  Wp*pos(3)/diff(xl);
        % use right-most 5 pixels, or one fifth of them, which ever is smaller
        width = min(round(Wp_in_pixels/5),5);
        konst = width/pos(3)*diff(xl);
        if passband<3, Wp=[Wp;0]; end
        if (passband==1 & pt_x < Wp(1)-konst) | ...
           (passband==2 & pt_x > Wp(1)+konst) | ...
            (passband==3 & pt_x > Wp(1)+konst & pt_x < Wp(2)-konst) | ...
            (passband==4 & (pt_x < Wp(1)-konst | pt_x > Wp(2)+konst))
            set(gcf,'windowbuttonmotionfcn','filtmake(''dragRp'',2)')
            set(gcf,'windowbuttonupfcn','filtmake(''dragRp'',3)')
        else
            set(gcf,'windowbuttonmotionfcn','filtmake(''dragWp'',2)')
            set(gcf,'windowbuttonupfcn','filtmake(''dragWp'',3)')
        end
    elseif s == 2   % motion
        fhndlList=get(gcf,'Userdata');
        method = get(fhndlList(14),'value');
        passband = get(fhndlList(15),'value');
        hndlList=get(gca,'Userdata');
        the_line = hndlList(2);
        old_ripples = get(fhndlList(5),'UserData');
        pt = get(gca,'currentpoint');
        pt_y = pt(1,2);

        if pt_y > -1e-3, pt_y = -1e-3;
        elseif pt_y < -old_ripples(2), pt_y=-old_ripples(2); end

        % Cauer-Anti-Absturz-Abfrage bei extremen Werten
        if method==4 & pt_y>-1 & old_ripples(2)>120, pt_y=-1; end

        above = 0; below = pt_y;
        if passband~=4
          set(the_line,'Ydata',[above above NaN below below]);
        else   % bandsperre
          set(the_line,'Ydata',[above above NaN below below NaN above above NaN below below]);
        end

        Rp = above - below;

        rips = [Rp; old_ripples(2)];
        str = sprintf('%g\n%g',rips(1),rips(2));
        set(fhndlList(5),'Userdata',rips,'String',str)

        drawnow
    elseif s == 3    % up
        set(gcf,'windowbuttonmotionfcn','')
        set(gcf,'windowbuttonupfcn','')
        filtmake('design')
    end
    return

elseif strcmp(action,'dragRs'),
    % s = 1 ==> down, s = 2 ==> mouse motion, s = 3 ==> mouse up
    if s == 1   % down
        fhndlList=get(gcf,'Userdata');
        passband=get(fhndlList(15),'Value');
        freqs = get(fhndlList(4),'UserData');
        if passband==1
          Wp = freqs(2);                   % passband frequency
          Ws = freqs(3);
        elseif passband==2
          Wp = freqs(3);
          Ws = freqs(2);
        elseif passband==3
          Wp = freqs(3:4);
          Ws = freqs([2,5]);
        elseif passband==4
          Wp = freqs([2,5]);
          Ws = freqs(3:4);
        end
        hndlList=get(gca,'Userdata');
        the_line = hndlList(3);
        set(the_line,'erasemode','xor')
        pt = get(gca,'currentpoint');
        pt_x = pt(1,1);
        % how many pixels wide is the Ws line?
        set(gca,'units','pixels'); 
        pos = get(gca,'position'); 
        set(gca,'units','normalized');
        xl = get(gca,'xlim');
        Ws_in_pixels =  Ws*pos(3)/diff(xl);

        % verwende Randbereich für Frequenzeinstellung
        width = min(round(Ws_in_pixels/5),5);
        konst = width/pos(3)*diff(xl);
        if passband<3, Ws=[Ws;0]; end
        if (pt_x > Ws(1)+konst & passband==1) | ...
           (pt_x < Ws(1)-konst & passband==2) | ...
           ((pt_x < Ws(1)-konst | pt_x > Ws(2)+konst) & passband==3) | ...
           (pt_x > Ws(1)+konst & pt_x < Ws(2)-konst & passband==4)
            set(gcf,'windowbuttonmotionfcn','filtmake(''dragRs'',2)')
            set(gcf,'windowbuttonupfcn','filtmake(''dragRs'',3)')
        else
            set(gcf,'windowbuttonmotionfcn','filtmake(''dragWs'',2)')
            set(gcf,'windowbuttonupfcn','filtmake(''dragWs'',3)')
        end

    elseif s == 2   % motion

        hndlList=get(gca,'Userdata');
        the_line = hndlList(3);
        fhndlList=get(gcf,'Userdata');
        passband=get(fhndlList(15),'value');
        method=get(fhndlList(14),'value');
        pt = get(gca,'currentpoint');
        old_ripples=get(fhndlList(5),'UserData');
        if pt(1,2)> -old_ripples(1), pt(1,2)=-old_ripples(1); end

        % Cauer-Anti-Absturz-Abfrage bei extremen Werten
        if method==4 & old_ripples(1)>=1 & pt(1,2)<-150, pt(1,2)=-150;
        elseif method==4 & old_ripples(1)<1 & pt(1,2)<-120, pt(1,2)=-120; end

        if passband~=3
          set(the_line,'Ydata',[pt(1,2) pt(1,2)])
        else
          set(the_line,'Ydata',[pt(1,2) pt(1,2) NaN pt(1,2) pt(1,2)]);
        end

        % direkte Änderung des Datenfensters
        fhndlList=get(gcf,'Userdata');
        Rs = max(0,-pt(1,2));
        rips = [old_ripples(1); Rs];
        str = sprintf('%g\n%g',rips(1),rips(2));
        set(fhndlList(5),'Userdata',rips,'String',str)

        drawnow
    elseif s == 3    % up
        set(gcf,'windowbuttonmotionfcn','')
        set(gcf,'windowbuttonupfcn','')
        filtmake('design')
    end
    return

elseif strcmp(action,'dragWp'),
    % s = 1 ==> down, s = 2 ==> mouse motion, s = 3 ==> mouse up
    if s == 2   % motion
        fhndlList=get(gcf,'Userdata');
        passband = get(fhndlList(15),'Value');
        freqs = get(fhndlList(4),'UserData');
        Fs = freqs(1);

        if passband==1
          Wp = freqs(2);                   % passband frequency
          Ws = freqs(3);                   % stopband frequency
        elseif passband==2
          Wp = freqs(3);
          Ws = freqs(2);
        elseif passband==3
          Wp = freqs(3:4);
          Ws = freqs([2,5]);
        else
          Wp = freqs([2,5]);
          Ws = freqs(3:4);
        end

        hndlList=get(gca,'Userdata');
        the_line = hndlList(2);
        pt = get(gca,'currentpoint');
        pt_x = pt(1,1);

        if passband==1
          if pt_x > Ws, pt_x = Ws; elseif pt_x < 0, pt_x = 0; end
          set(the_line,'Xdata',[0 pt_x NaN 0 pt_x]);
          freqs = [freqs(1); pt_x; freqs(3)];
        elseif passband==2
          if pt_x < Ws, pt_x = Ws; elseif pt_x > Fs/2, pt_x = Fs/2; end
          set(the_line,'Xdata',[Fs/2 pt_x NaN Fs/2 pt_x]);
          freqs = [freqs(1:2); pt_x];
        elseif passband==3
          if abs(pt_x-Wp(1)) < abs(pt_x-Wp(2))
            if pt_x < Ws(1), pt_x = Ws(1); elseif pt_x > Wp(2), pt_x = Wp(2); end
            set(the_line,'Xdata',[pt_x Wp(2) NaN pt_x Wp(2)]);
            freqs = [freqs(1:2); pt_x; freqs(4:5)];
          else
             if pt_x > Ws(2), pt_x = Ws(2); elseif pt_x < Wp(1), pt_x = Wp(1); end
             set(the_line,'Xdata',[Wp(1) pt_x NaN Wp(1) pt_x]);
             freqs = [freqs(1:3); pt_x; freqs(5)];
          end
        else
          global merker;
          if isempty(merker)
            if abs(pt_x-Wp(1)) < abs(pt_x-Wp(2)), merker=1;
            else merker=2; end
          end
          if merker==1 % abs(pt_x-Wp(1)) < abs(pt_x-Wp(2))
            if pt_x < 0, pt_x=0; elseif pt_x > Ws(1), pt_x = Ws(1); end
            set(the_line,'Xdata',[0 pt_x NaN 0 pt_x NaN Wp(2) Fs/2 NaN Wp(2) Fs/2]);
            freqs = [freqs(1); pt_x; freqs(3:5)];
          else
            if pt_x > Fs/2, pt_x=Fs/2; elseif pt_x < Ws(2), pt_x = Ws(2); end
            set(the_line,'Xdata',[0 Wp(1) NaN 0 Wp(1) NaN pt_x Fs/2 NaN pt_x Fs/2]);
            freqs = [freqs(1:4); pt_x];
          end
        end

        if passband<3
          str = sprintf('%g\n%g\n%g',freqs(1),freqs(2),freqs(3));
        else
          str = sprintf('%g\n%g\n%g\n%g\n%g',freqs);
        end
        set(fhndlList(4),'Userdata',freqs,'String',str);

        drawnow
    elseif s == 3    % up
        clear global merker;
        set(gcf,'windowbuttonmotionfcn','')
        set(gcf,'windowbuttonupfcn','')
        filtmake('design')
    end
    return

elseif strcmp(action,'dragWs'),
    % s = 1 ==> down, s = 2 ==> mouse motion, s = 3 ==> mouse up
    if s == 2   % motion
        fhndlList=get(gcf,'Userdata');
        passband=get(fhndlList(15),'Value');
        freqs = get(fhndlList(4),'UserData');  
        Fs = freqs(1);                   % sampling frequency
        if passband==1
          Wp = freqs(2);                   % passband frequency
          Ws = freqs(3);                   % stopband frequency
        elseif passband==2
          Wp = freqs(3);
          Ws = freqs(2);
        elseif passband==3
          Wp = freqs(3:4);
          Ws = freqs([2,5]);
        else
          Wp = freqs([2,5]);
          Ws = freqs(3:4);
        end

        hndlList=get(gca,'Userdata');
        the_line = hndlList(3);
        pt = get(gca,'currentpoint');
        pt_x = pt(1,1);

        if passband==1
          if pt_x < Wp, pt_x = Wp; elseif pt_x > Fs/2, pt_x = Fs/2; end
          set(the_line,'Xdata',[pt_x Fs/2]);
          freqs = [freqs(1); freqs(2); pt_x];
        elseif passband==2
          if pt_x > Wp, pt_x = Wp; elseif pt_x < 0, pt_x = 0; end
          set(the_line,'Xdata',[0 pt_x]);
          freqs = [freqs(1); pt_x; freqs(3)];
        elseif passband==3
          global merker;
          if isempty(merker)
            if abs(pt_x-Ws(1)) < abs(pt_x-Ws(2)), merker=1;
            else merker=2; end
          end
          if merker==1 % abs(pt_x-Ws(1)) < abs(pt_x-Ws(2))
            if pt_x < 0, pt_x=0; elseif pt_x > Wp(1), pt_x = Wp(1); end
            set(the_line,'Xdata',[0 pt_x NaN Ws(2) Fs/2]);
            freqs = [freqs(1); pt_x; freqs(3:5)];
          else
            if pt_x > Fs/2, pt_x=Fs/2; elseif pt_x < Wp(2), pt_x = Wp(2); end
            set(the_line,'Xdata',[0 Ws(1) NaN pt_x Fs/2]);
            freqs = [freqs(1:4); pt_x];
          end
        else
          if abs(pt_x-Ws(1)) < abs(pt_x-Ws(2))
            if pt_x < Wp(1), pt_x = Wp(1); elseif pt_x > Ws(2), pt_x = Ws(2); end
            set(the_line,'Xdata',[pt_x Ws(2)]);
            freqs = [freqs(1:2); pt_x; freqs(4:5)];
          else
             if pt_x > Wp(2), pt_x = Wp(2); elseif pt_x < Ws(1), pt_x = Ws(1); end
             set(the_line,'Xdata',[Ws(1) pt_x]);
             freqs = [freqs(1:3); pt_x; freqs(5)];
          end

        end

        if passband<3
          str = sprintf('%g\n%g\n%g',freqs(1),freqs(2),freqs(3));
        else
          str = sprintf('%g\n%g\n%g\n%g\n%g',freqs);
        end
        set(fhndlList(4),'Userdata',freqs,'String',str);

        drawnow
    elseif s == 3    % up
        clear global merker;
        set(gcf,'windowbuttonmotionfcn','')
        set(gcf,'windowbuttonupfcn','')
        filtmake('design')
    end
    return

elseif strcmp(action,'setord'),
    hndlList=get(gcf,'Userdata');
    v = get(gco,'Userdata');
    s = get(gco,'String');
    passband=get(hndlList(15),'Value');
    vv = ceil(eval(s,num2str(v(1))));
    if passband > 2
      vv=ceil(vv/2);  % Bandpaß/Bandsperre hat doppelte Filterordnung
    end
    if vv<1, vv = v; end        % vv<3 ?
    if passband < 3 	% Tiefpaß/Hochpaß
      set(gco,'Userdata',vv,'String',num2str(vv))
    else                % Bandpaß/Bandsperre
      set(gco,'Userdata',vv,'String',num2str(vv*2))
    end

    if vv~=v
        set(hndlList(8),'value',0,'userdata',2)  % switch radio buttons
        set(hndlList(9),'value',1)  
        filtmake('design')
    else
        if get(hndlList(8),'userdata') == 1
            set(hndlList(8),'value',0,'userdata',2)  % switch radio buttons
            set(hndlList(9),'value',1) 
            filtmake('design')
        end
    end
    return

elseif strcmp(action,'radio'),
    hndlList=get(gcf,'Userdata');
    for i=8:9,
      set(hndlList(i),'value',0) % Disable all the buttons
    end
    set(hndlList(s+7),'value',1) % Enable selected button
    old_one = get(hndlList(8),'Userdata');
    set(hndlList(8),'Userdata',s) % Remember selected button
    if s~=old_one 
        filtmake('design')
    else
        filtmake('axesredraw')
    end
    return

elseif strcmp(action,'design'), % Design filter
    set(gcf,'Pointer','watch');

    axHndl=gca;
    fhndlList=get(gcf,'Userdata');
    freqzHndl = fhndlList(1);
    FreqsHndl = fhndlList(4);
    RipplesHndl = fhndlList(5);
    viewHndl = fhndlList(7);
    btn1Hndl = fhndlList(8);
    btn2Hndl = fhndlList(9);
    ord1Hndl = fhndlList(10);
    ord2Hndl = fhndlList(11);
    methodHndl = fhndlList(14);
    passbandHndl = fhndlList(15);
    okbuttHndl=findobj(gcf,'String','OK');

% initialize variables
    freqs = get(FreqsHndl,'UserData');
    passband = get(passbandHndl,'Value');

    Fs = freqs(1);                   % sampling frequency
    if passband==1
      Wp = freqs(2);                   % passband frequency
      Ws = freqs(3);                   % stopband frequency
    elseif passband==2
      Wp = freqs(3);
      Ws = freqs(2);
    elseif passband==3 % bandpass
      Wp = freqs(3:4);
      Ws = freqs([2,5]);
    else % bandstop
      Wp = freqs([2,5]);
      Ws = freqs(3:4);
    end
    ripples = get(RipplesHndl,'UserData');
    Rp = ripples(1);                 % passband ripple
    Rs = ripples(2);                 % stopband attenuation

% Estimate order !
    % 1 = BUTTER, 2 = CHEBY1, 3 = CHEBY2, 4 = ELLIP,
    method = get(methodHndl,'value');
    if method == 1
        [n,wn]=buttord(Wp*2/Fs,Ws*2/Fs,Rp,Rs);
        if n<1 | imag(n)~=0, n=1; end
        max_n = 60;  reasonable_n = 30;
    elseif method == 2
        [n,wn]=cheb1ord(Wp*2/Fs,Ws*2/Fs,Rp,Rs);
        if n<1 | imag(n)~=0, n=1; end
        max_n = 30;  reasonable_n = 15;
    elseif method == 3
        [n,wn]=cheb2ord(Wp*2/Fs,Ws*2/Fs,Rp,Rs);
        if n<1 | imag(n)~=0, n=1; end
        max_n = 30;  reasonable_n = 15;
    elseif method == 4
        % Ohne die folgende if-Anweisung tritt intern
        % bei der Berechnung von ellip ein Fehler aufgrund
        % nicht einzuhaltender Randbedingungen auf!
        if Rs>=150 & Rp>=1, Rs=150;
        elseif Rs>120 & Rp<1, Rs=120; end
        [n,wn]=ellipord(Wp*2/Fs,Ws*2/Fs,Rp,Rs);
        if n<1 | imag(n)~=0, n=1; end
        max_n = 25;  reasonable_n = 12;
    end
    % Filterordnung sichern
    if passband < 3
      set(ord1Hndl,'Userdata',[n; wn(:)],'String',num2str(n))
    else
      set(ord1Hndl,'Userdata',[n; wn(:)],'String',num2str(n*2))
    end

% determine which order to use: estimated or specified
    estim = get(btn1Hndl,'UserData');
    order = get(ord1Hndl,'UserData'); % use estimated Filter order
    if passband<3
      wn = order(2);    % use estimated cutoff even for "specified order" case
    else
      wn = order(2:3);
    end
    order = order(1);

    if estim ~= 1
        order = get(ord2Hndl,'UserData'); % use specified Filter order
    elseif (n>max_n)|(isnan(n))|(isinf(n))
        set(ord2Hndl,'UserData',reasonable_n,'string',num2str(reasonable_n))
        set(btn1Hndl,'value',0,'userdata',2)  % switch radio buttons
        set(btn2Hndl,'value',1)
        order = get(ord2Hndl,'UserData'); % use specified Filter order
    end

    drawnow

% Speichere Daten für Protokoll


set(okbuttHndl,'UserData',[passband;freqs;ripples;method;order(1)*round(passband/2)]);

% Design filter
    if method==1, % butterworth
      if passband==1 | passband==3
        [b,a] = butter(order,wn);
      elseif passband==2
        [b,a] = butter(order,wn,'high');
      else % bandstop
        [b,a] = butter(order,wn,'stop'); % 'stop' fehlt noch
      end
      if passband < 3
        title_str = sprintf('Butterworth IIR Filter %g. Ordnung',order);
      else % bandpass/bandstop transformation doubles the filter-order
        title_str = sprintf('Butterworth IIR Filter %g. Ordnung',order*2);
      end
    elseif method==2, % chebyshev type I
      if passband==1 | passband==3
        [b,a] = cheby1(order,Rp,wn);
      elseif passband==2
        [b,a] = cheby1(order,Rp,wn,'high');
      else % bandstop
        [b,a] = cheby1(order,Rp,wn,'stop'); % 'stop' fehlt noch
      end
      if passband < 3
        title_str = sprintf('Tschebysheff Typ I IIR Filter %g. Ordnung',order);
      else
        title_str = sprintf('Tschebysheff Typ I IIR Filter %g. Ordnung',order*2);
      end
    elseif method==3, % chebyshev type II
      if passband==1 | passband==3
        [b,a] = cheby2(order,Rs,wn);
      elseif passband==2
        [b,a] = cheby2(order,Rs,wn,'high');
      else % bandstop
        [b,a] = cheby2(order,Rs,wn,'stop'); %'stop'
      end
      if passband < 3
        title_str = sprintf('Tschebysheff Typ II IIR Filter %g. Ordnung',order);
      else
	title_str = sprintf('Tschebysheff Typ II IIR Filter %g. Ordnung',order*2);
      end
    elseif method==4, % elliptic
      if passband==1 | passband==3
        [b,a] = ellip(order,Rp,Rs,wn);
      elseif passband==2
        [b,a] = ellip(order,Rp,Rs,wn,'high');
      else % bandstop
        [b,a] = ellip(order,Rp,Rs,wn,'stop');
      end
      if passband < 3
        title_str = sprintf('Cauer IIR Filter %g. Ordnung',order);
      else
        title_str = sprintf('Cauer IIR Filter %g. Ordnung',order*2);
      end
    end
    [H,F] = freqz(b,a,max( 2048,nextpow2(5*max(length(b),length(a))) ),Fs);
    H = 20*log10(abs(H+eps));
    axes(freqzHndl)
    axhndlList = get(freqzHndl,'UserData');
    if isempty(axhndlList)   % first time - happens at initialization phase
        % initialize the axes
        above=0;   % Anfangs -
        below=-3;  % initialisierung
        hndl = plot(F,H,[0 Wp NaN 0 Wp],[above above NaN below below], ...
                    [Ws Fs/2],[-Rs -Rs]);
        % set(gcf,'nextplot','new')
        if length(a) > 1
            set(hndl(1),'color','black','userdata',[b; a])  % save filter
            % coefficients in userdata of line
        else
            set(hndl(1),'color','black','userdata',b)
        end
        set(hndl(2:3),'color','red','linewidth',1)
        set(hndl(2),'buttondownfcn','filtmake(''dragRp'',1)')
        set(hndl(3),'buttondownfcn','filtmake(''dragRs'',1)')
        grid on;
        axhndlList = hndl;
        set(freqzHndl,'UserData',axhndlList)
        set(freqzHndl,'xlim',[0 Fs/2],'ylim',[-Rs*(1.5) max(2*Rp,Rs*.1)])
        xlabel('Frequenz (Hz)')
        ylabel('Amplitude (dB)')
        set(gca,'Xcolor','black','Ycolor','black')
        set(get(gca,'title'),'color','black');
    else
        if length(a) > 1
            set(axhndlList(1),'UserData',[b; a])
        else
            set(axhndlList(1),'UserData',[b])
        end 
        filtmake('axesredraw')
    end

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
    FreqsHndl = fhndlList(4);
    RipplesHndl = fhndlList(5);
    viewHndl = fhndlList(7);
    btn1Hndl = fhndlList(8);
    btn2Hndl = fhndlList(9);
    ord1Hndl = fhndlList(10);
    ord2Hndl = fhndlList(11);
    methodHndl = fhndlList(14);
    passbandHndl = fhndlList(15);

    passband = get(fhndlList(15),'Value');
    order = get(ord1Hndl,'UserData'); % estimated Filter order
    wn = order(2);
    order = order(1);
    if get(btn1Hndl,'userdata') ~= 1
        order = get(ord2Hndl,'UserData'); % use specified Filter order
    end
    freqs = get(FreqsHndl,'UserData');  
    Fs = freqs(1);                   % sampling frequency
    W1 = freqs(2);                   % passband or stopband frequency
    W2 = freqs(3);                   % stopband or stopband frequency
    if passband>2
      W3 = freqs(4);
      W4 = freqs(5);
    end
    ripples = get(RipplesHndl,'UserData');
    Rp = ripples(1);                 % passband ripple
    Rs = ripples(2);                 % stopband attenuation
    method = get(methodHndl,'value'); 

    % Create desired frequency response and weight vector
    devs = [ (10^(Rp/20)-1)/(10^(Rp/20)+1)  10^(-Rs/20) ];

    axes(freqzHndl)
    axhndlList = get(freqzHndl,'UserData');
    h = get(axhndlList(1),'userdata');
    if size(h,1) > 1
        b = h(1,:); a = h(2,:);
    else
        b = h; a = 1;
    end
    [H,F] = freqz(b,a,max( 2048,nextpow2(5*max(length(b),length(a))) ),Fs);
    H = 20*log10(abs(H+eps));
    set(axhndlList(1),'Xdata',F,'Ydata',H);
    above = 0; below = -Rp;

    % Anzeigen des Frequenzschemas

    if passband==1 % lowpass
      set(axhndlList(2),'Ydata',[above above NaN below below],...
                      'Xdata',[0 W1 NaN 0 W1],'erasemode','normal')
      set(axhndlList(3),'Ydata',[-Rs -Rs],'XData',[W2 Fs/2],'erasemode','normal')
    elseif passband==2        % highpass
      set(axhndlList(2),'Ydata',[above above NaN below below],...
                      'Xdata',[W2 Fs/2 NaN W2 Fs/2],'erasemode','normal')
      set(axhndlList(3),'Ydata',[-Rs -Rs],'XData',[0 W1],'erasemode','normal')
    elseif passband==3
      set(axhndlList(2),'Ydata',[above above NaN below below ],...
                      'Xdata',[W2 W3 NaN W2 W3 ],'erasemode','normal')
      set(axhndlList(3),'Ydata',[-Rs -Rs NaN -Rs -Rs],'XData',[0 W1 NaN W4 Fs/2],'erasemode','normal')
    else % bandstop
      set(axhndlList(2),'Ydata',[above above NaN below below NaN above above NaN below below],...
                      'Xdata',[W4 Fs/2 NaN W4 Fs/2 NaN 0 W1 NaN 0 W1],'erasemode','normal')
      set(axhndlList(3),'Ydata',[-Rs -Rs],'XData',[W2 W3],'erasemode','normal')
    end

    viewmode = get(viewHndl,'value');  % 1 == full, 2 == passband, 3 == stopband
    if viewmode == 1 % Gesamtansicht
        set(freqzHndl,'xlim',[0 Fs/2],'ylim',...
         [min(22*log10(1-devs(1)),-Rs*(1.5)) max(2*20*log10(1+devs(1)),Rs*.1)])
    elseif viewmode == 2 % Durchlaßbereich
        if passband==1 | passband==4 % lowpass or bandstop
            ymax = max(max(H(find(F<W1)))*1.1,.1*Rp);
            ymin = min(min(H(find(F<W1)))*1.1,-1.1*Rp);
            xmax = min(F(max(find(H>-Rp)))*1.1,Fs/2);
            set(freqzHndl,'xlim',[0 xmax],'ylim',[ymin ymax]);
        elseif passband==2      % highpass
            ymax = max(max(H(find(F>W2)))*1.1,.1*Rp);
            ymin = min(min(H(find(F>W2)))*1.1,-1.1*Rp);
            xmin = max(F(min(find(H>-Rp)))*0.9,0);
            set(freqzHndl,'xlim',[xmin Fs/2],'ylim',[ymin ymax]);
        elseif passband==3      % bandpass
            ymax = max(max(H(find(F>W2&F<W3)))*1.1,.1*Rp);
            ymin = min(min(H(find(F>W2&F<W3)))*1.1,-1.1*Rp);
            xmax = min(F(max(find(H>-Rp)))*1.1,Fs/2);
            xmin = max(F(min(find(H>-Rp)))*0.9,0);
            set(freqzHndl,'xlim',[xmin xmax],'ylim',[ymin ymax]);
        end
    elseif viewmode == 3 % Sperrbereich
      if passband==1 % lowpass
        ymax = max(max(H(find(F>W2)))*.9,-Rs*.9);
        ymin = min(max(H(find(F>W2))), -Rs*1.6);
        xmin = max(F(min(find(H<-Rs)))*0.9,0);
        set(freqzHndl,'xlim',[xmin Fs/2],'ylim',[ymin ymax]);
      elseif passband==2 | passband==3 % highpass
        ymax = max(max(H(find(F<W1)))*.9,-Rs*.9);
        ymin = min(max(H(find(F<W1))), -Rs*1.6);
        xmax = min(F(max(find(H<-Rs)))*1.1,Fs/2);
        set(freqzHndl,'xlim',[0 xmax],'ylim',[ymin ymax]);
      else % bandstop
        ymax = max(max(H(find(F>W2&F<W3)))*0.9,-Rs*0.9);
        ymin = max(min(H(find(F>W2&F<W3))),-Rs*1.6);
        xmax = min(F(max(find(H<-Rs)))*1.1,Fs/2);
        xmin = max(F(min(find(H<-Rs)))*0.9,0);
        set(freqzHndl,'xlim',[xmin xmax],'ylim',[ymin ymax]);
      end
    end
    xlabel('Frequenz (Hz)')
    ylabel('Amplitude (dB)')
    set(gcf,'Pointer','arrow');
    drawnow
    return

elseif strcmp(action,'info'),

    !winhelp filtmake.hlp
    return

elseif strcmp(action,'getfilt')
    fhndlList=get(gcf,'Userdata');
    freqzHndl = fhndlList(1);
    axhndlList = get(freqzHndl,'UserData');
    h = get(axhndlList(1),'userdata');
    if size(h,1) > 1
        num = h(1,:); den = h(2,:);
    else
        num = h; den = 1;
    end

elseif findstr(action,'close') % close und close_ok
    current_figure=gcf;
    hdl_main=findobj('Tag','hauptfenster');
    if strcmp(action,'close_ok')
      [num,den]=filtmake('getfilt');
      if ~isempty(hdl_main),
        global b a; b=num; a=den;
        global filtertyp; filtertyp=6;
        hdl=findobj(gcf,'String','OK');
        makeprot('filtmake',hdl,num,den);
      end
    end
    close(current_figure);
    if ~isempty(hdl_main)
      set(hdl_main,'visible','on');
      if strcmp(action,'close_ok')
        drawmain(num,den,'Filtmake');
      end
    end  
else
  disp(sprintf( ...
     'filtmake: action String ''%s'' nicht bekannt, keine Aktion ausgeführt.',action))
end


