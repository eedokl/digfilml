function [num,den]=meteform(action,s);

%meteform  Iteratives FIR-Filter Entwicklungsprogramm.
%
%       Konvertiert nach MATLAB, 1997 von Oliver Klein
%
%	Zum starten "meteform" eintippen.
%
%	Die berechneten Filterparameter lassen sich zur Laufzeit mit
%	   [b,a] = meteform('getfilt');
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
% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover

% Possible actions and button callbacks:
%   initialize
%   changemethod
%   changepassband
%   setFreqs
%   setRipples
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
      'Name','FIR Filterentwicklung (Lineare Programmierung)', ...
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
      'XTickMode','auto','YTickMode','auto', ...
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
  callbackStr='meteform(''changepassband'');';
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
  labelStr=['Butterworth-Appr.|Tschebyscheff 1-Appr.' ...
            '|Tschebyscheff 2-Appr.|Tschebyscheff-Appr.'];
  ;
  callbackStr='meteform(''changemethod'');';
  methodHndl=uicontrol( ...
      'Style','popupmenu', ...
      'Units','normalized', ...
      'Position',btnPos, ...
      'String',labelStr, ...
      'Interruptible','on', ...
      'Value',4, ...
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
  callbackStr = 'meteform(''setFreqs'')';
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
  callbackStr = 'meteform(''setRipples'')';
  str = sprintf('3\n60');
  RipplesHndl = uicontrol( ...   % fhndlList(5)
      'Style','edit','horiz','left', ...
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
      'String','Filterordnung N', ...
      'Interruptible','off', ...
      'Background',my_color, ...
      'ForegroundColor',mtc);

  %====================================
  % Estimate text&edit field
  labelBottom=top-textHeight*13.5;
  labelStr='untere Grenze:';
  btnPos=[left+frmBorder labelBottom btnWid textHeight];
  textPos=[left+frmBorder+btnWid*.65 labelBottom btnWid*.32 textHeight*1.2];
  uicontrol( ...
      'Style','text', ...
      'Units','normalized', ...
      'Position',btnPos, ...
      'Horiz','left', ...
      'Background',my_color, ...
      'String',labelStr, ...
      'Foreground',mtc);

  ord1Hndl = uicontrol( ...
      'Style','edit', ...
      'Units','normalized', ...
      'Position',textPos, ...
      'Horiz','left', ...
      'Background',my_color+.1, ...
      'String','18','Userdata',[11 -1], ...
      'Foreground',mtc);

  %====================================
  % Specify edit and text field
  labelBottom=top-textHeight*14.5;
  labelStr='obere Grenze:';
  callbackStr='meteform(''radio'',2);';
  btnPos=[left+frmBorder labelBottom btnWid*.6 textHeight];
  textPos=[left+frmBorder+btnWid*.65 labelBottom-textHeight*.2 btnWid*.32 textHeight*1.2];
  uicontrol( ...
      'Style','text', ...
      'Units','normalized', ...
      'Position',btnPos, ...
      'Horiz','left', ...
      'Background',my_color, ...
      'String',labelStr, ...
      'Foreground',mtc);
  ord2Hndl = uicontrol( ...
      'Style','edit', ...
      'Units','normalized', ...
      'Position',textPos, ...
      'Horiz','left', ...
      'Background',my_color+0.1, ...
      'Foreground','black', ...
      'String','20','Userdata',11, ...
      'Max',1);

  %====================================
  % The Filter Design Passband Selection Menu {fhndlList(15)}
  yPos=1-textHeight*20.25;

  btnPos=[left+frmBorder yPos-btnHt btnWid textHeight];
  labelStr='optimiere N|optimiere f1|optimiere f2';
  whattodoHndl=uicontrol( ...
      'Style','popupmenu', ...
      'Units','normalized', ...
      'Position',btnPos, ...
      'String',labelStr, ...
      'Interruptible','on', ...
      'Foreground',mtc, ...
      'Background',my_color);


  %====================================
  % View Popup - Menu
  labelStr='h(n) symmetrisch|h(n) antisymmetrisch';
  viewHndl=uicontrol( ...
      'Style','popupmenu', ...
      'Units','normalized', ...
      'Position',[left+frmBorder yPos-2*btnHt btnWid textHeight], ...
      'String',labelStr, ...
      'Interruptible','on', ...
      'Background',my_color, ...
      'Foreground',mtc);

  %====================================
  % The CALCULATE button
  labelStr='Berechnen';
  callbackStr='meteform(''design'')';
  helpHndl=uicontrol( ...
    'Style','pushbutton', ...
    'Units','normalized', ...
    'Position',...
    [left+frmBorder+btnWid/2 frmBottom+btnHt/2.5+spacing btnWid/2 btnHt/1.5], ...
    'String',labelStr, ...
    'Tag','MeteorForm',...
    'Callback',callbackStr);

  %====================================
  % The INFO button
  labelStr='Hilfe';
  callbackStr='meteform(''info'')';
  helpHndl=uicontrol( ...
    'Style','pushbutton', ...
    'Units','normalized', ...
    'Position',...
    [left+frmBorder frmBottom+btnHt/2.5+spacing btnWid/2 btnHt/1.5],...
    'String',labelStr, ...
    'Callback',callbackStr);

  %====================================
  % The CLOSE button
  labelStr='Abbruch';
  callbackStr='meteform(''close'');';
  closeHndl=uicontrol( ...
    'Style','pushbutton', ...
    'Units','normalized', ...
    'Position',[left+frmBorder+btnWid/2 frmBottom btnWid/2 btnHt/1.5],...
    'String',labelStr, ...
    'Callback',callbackStr);

  %====================================
  % The OK button
  labelStr='OK';
  callbackStr='meteform(''close_ok'');';
  closeHndl=uicontrol( ...
    'Style','pushbutton', ...
    'Units','normalized', ...
    'Position',[left+frmBorder frmBottom btnWid/2 btnHt/1.5], ...
    'String',labelStr, ...
    'Callback',callbackStr);

  fhndlList=[freqzHnd 0 0 FreqsHndl RipplesHndl ...
            0 viewHndl whattodoHndl 0 ord1Hndl ord2Hndl ...
            helpHndl closeHndl methodHndl passbandHndl];
  set(figNumber,'Visible','on','UserData',fhndlList);
  drawnow

  % axes(freqzHnd)
  set(freqzHnd,'Userdata',[])

  set(gca,'xlim',[0 .5],'ylim',[-60*(1.5) max(2*3,60*.1)]);
  xlabel('normierte Frequenz','Color','k');
  ylabel('Amplitude in dB','Color','k');
  grid on;
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

    return

elseif strcmp(action,'changepassband'),
    passband = get(gco,'value');  % 1 = TP, 2 = HP, 3 = BP, 4 = BS

    fhndlList = get(gcf,'UserData');
    freqs = get(fhndlList(4),'UserData');

    ord1hndl=fhndlList(10);
    ord2hndl=fhndlList(11);
    whattodohndl=fhndlList(8);

    hndl1=findobj('String','f3');
    hndl2=findobj('String','f4');
    if passband>2 & length(freqs)~=5
      freqs=[1; 0.1; 0.2; 0.3; 0.4];
      str=sprintf('1\n0.1\n0.2\n0.3\n0.4');
      set(fhndlList(4),'UserData',freqs,'String',str)
      set([hndl1,hndl2],'Foreground',[0 0 0]);
      labelStr=['optimiere N|optimiere f1|optimiere f2|'...
                'optimiere f3|optimiere f4'];
      set(whattodohndl,'String',labelStr);

    elseif passband<3 & length(freqs)~=3
      freqs=[1; 0.2; 0.3];
      str=sprintf('1\n0.2\n0.3');
      set(fhndlList(4),'UserData',freqs,'String',str)
      set([hndl1,hndl2],'Foreground',[0.6 0.6 0.6]);
      labelStr='optimiere N|optimiere f1|optimiere f2';
      set(whattodohndl,'String',labelStr);
    end
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
    uiwait(msgbox('Keine Zahl eingegeben !','Eingabefehler','none','modal'));
  elseif passband < 3
    if length(vv)~=3
        vv=v;
        uiwait(msgbox('Es müssen drei Frequenzen eingegeben werden !',...
          'Eingabefehler',...
          'none','Modal'));
    elseif any(vv<0) | vv(2)>=vv(3) | vv(3)>=vv(1)/2
        vv = v;
        uiwait(msgbox('Frequenzeingabe fehlerhaft !','Eingabefehler',...
          'none','Modal'));
    end
  else
    if length(vv)~=5
        vv=v;
        uiwait(msgbox(...
          'Es müssen fünf Frequenzen eingegeben werden !',...
          'Eingabefehler',...
          'none','Modal'));
    elseif any(vv<0)     |  vv(2)>=vv(3) | vv(3)>=vv(4) | ...
       			    vv(4)>=vv(5) | vv(5)>=vv(1)/2
        vv = v;
        uiwait(msgbox('Frequenzeingabe fehlerhaft !',...
           'Eingabefehler','none','Modal'));
    end
  end

    if passband<3
      str = sprintf('%g\n%g\n%g',vv(1),vv(2),vv(3));
    else
      str = sprintf('%g\n%g\n%g\n%g\n%g',vv);
    end
    set(gco,'Userdata',vv,'String',str)
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
      uiwait(msgbox('Eingabe der Welligkeit fehlerhaft !',...
        'Eingabefehler','none','Modal'));
    elseif vv(2) < vv(1) | any(vv<=0)
      vv = v;
      uiwait(msgbox('Eingabe der Welligkeit fehlerhaft !',...
        'Eingabefehler','none','Modal'));
     end

    % Bei kleineren Werten vv(1) kann das
    % Programm bei der Berechnung abstürzen
    if vv(1)<1e-3,
      vv(1)=1e-3;
      uiwait(msgbox('minimale Welligkeit = 0.001 dB',...
        'Hinweis','none','modal'));
    end
    if method==4  % Cauer-Entwurf, zu kleine Werte verhindern
      if vv(1)>=1 & vv(2)>150, vv(2)=150;
      elseif vv(1)<1 & vv(2)>120, vv(2)=120; end
    end
    str = sprintf('%g\n%g',vv(1),vv(2));
    set(gco,'Userdata',vv,'String',str)
    return

elseif strcmp(action,'design'), % Design filter
    set(gcf,'Pointer','watch');
    axHndl=gca;
    fhndlList=get(gcf,'Userdata');
    freqzHndl = fhndlList(1);
    FreqsHndl = fhndlList(4);
    RipplesHndl = fhndlList(5);
    viewHndl = fhndlList(7);
    whattodoHndl = fhndlList(8);
    btn2Hndl = fhndlList(9);
    ord1Hndl = fhndlList(10);
    ord2Hndl = fhndlList(11);
    methodHndl = fhndlList(14);
    passbandHndl = fhndlList(15);
    okbuttHndl=findobj(gcf,'String','OK');

    % initialize variables & filter information
    freqs = get(FreqsHndl,'UserData');
    passband = get(passbandHndl,'Value');
    method = get(methodHndl,'Value');

    ripples = get(RipplesHndl,'UserData');
    Rp = ripples(1);                 % passband ripple
    Rs = ripples(2);                 % stopband attenuation
    devs = [ (10^(Rp/20)-1)/(10^(Rp/20)+1)  10^(-Rs/20) ];

    % Plausibilitätsprüfungen



    Fs = freqs(1);                   % sampling frequency
    if passband==1
      Wp = freqs(2);                   % passband frequency
      Ws = freqs(3);                   % stopband frequency
      if method==1
        left =[0  0  Ws   Ws   0  Ws  ]/Fs;
        right=[Wp Wp Fs/2 Fs/2 Wp Fs/2]/Fs;
        bound1=[1 10^(-Rp/20)  devs(2) 0 0 0];
        bound2=bound1;
        sense='+-+--+';
        interpolate='aaaax';
        hug='hnnhxx';
        spectype='llllcc';
      elseif method==2
        left =[0  0  Ws   Ws   Ws  ]/Fs;
        right=[Wp Wp Fs/2 Fs/2 Fs/2]/Fs;
        bound1=[1+devs(1) 1-devs(1) devs(2) 0  0];
        bound2=bound1;
        sense='+-+-+';
        interpolate='aaaax';
        hug='nnnhx';
        spectype='llllc';
      elseif method==3
        left =[0  0  Ws   Ws   0 ]/Fs;
        right=[Wp Wp Fs/2 Fs/2 Wp]/Fs;
        bound1=[1 10^(-Rp/20) devs(2) -devs(2) 0];
        bound2=bound1;
        sense='+-+--';
        interpolate='aaaax';
        hug='hnnnx';
        spectype='llllc';
      elseif method==4
        left =[0  0  Ws   Ws  ]/Fs;
        right=[Wp Wp Fs/2 Fs/2]/Fs;
        bound1=[1+devs(1) 1-devs(1) devs(2) -devs(2)];
        bound2=bound1;
        sense='+-+-';
        interpolate='aaaa';
        hug='nnnn';
        spectype='llll';
      end
    elseif passband==2
      Wp = freqs(3);
      Ws = freqs(2);
      if method==1
        left =[0  0  Wp   Wp   0  Wp  ]/Fs;
        right=[Ws Ws Fs/2 Fs/2 Ws Fs/2]/Fs;
        bound1=[devs(2) 0 1 10^(-Rp/20) 0 0];
        bound2=bound1;
        sense='+-+-+-';
        interpolate='aaaaxx';
        hug='nhhnxx';
        spectype='llllcc';
      elseif method==2
        left =[0  0  Wp   Wp   0 ]/Fs;
        right=[Ws Ws Fs/2 Fs/2 Ws]/Fs;
        bound1=[devs(2) 0 1+devs(1) 1-devs(1) 0];
        bound2=bound1;
        sense='+-+-+';
        interpolate='aaaax';
        hug='nhnnx';
        spectype='llllc';
      elseif method==3
        left =[0  0  Wp   Wp   Wp  ]/Fs;
        right=[Ws Ws Fs/2 Fs/2 Fs/2]/Fs;
        bound1=[devs(2) -devs(2) 1 10^(-Rp/20) 0];
        bound2=bound1;
        sense='+-+--';
        interpolate='aaaax';
        hug='nnhnx';
        spectype='llllc';
      elseif method==4
        left =[0  0  Wp   Wp  ]/Fs;
        right=[Ws Ws Fs/2 Fs/2]/Fs;
        bound1=[devs(2) -devs(2) 1+devs(1) 1-devs(1)];
        bound2=bound1;
        sense='+-+-';
        interpolate='aaaa';
        hug='nnnn';
        spectype='llll';
      end
    elseif passband==3 % bandpass
        Wp = freqs(3:4);
        Ws = freqs([2,5]);
      if method==1
        Wm=(Wp(2)+Wp(1))/2;
        left =[0        0     Wp(1) Wp(1)        Wm    Wm          Ws(2)   Ws(2) Wp(1) Wm    0     Ws(2)]/Fs;
        right=[Ws(1)    Ws(1) Wm    Wm           Wp(2) Wp(2)       Fs/2    Fs/2  Wm    Wp(2) Ws(1) Fs/2 ]/Fs;
        bound1=[devs(2) 0     1     10^(-Rp/20)  1     10^(-Rp/20) devs(2) 0     -1   -1     -1   -1    ];
        bound2=bound1;
        sense='+-+-+-+---++';
        interpolate='aaaaaaaaxxxx';
        hug='nhhnhnnhxxxx';
        spectype='llllllllcccc';
      elseif method==2
        left =[0        0     Wp(1)     Wp(1)     Ws(2)   Ws(2) 0     Ws(2)]/Fs;
        right=[Ws(1)    Ws(1) Wp(2)     Wp(2)     Fs/2    Fs/2  Ws(1) Fs/2 ]/Fs;
        bound1=[devs(2) 0     1+devs(1) 1-devs(1) devs(2)  0    -1    -1   ];
        bound2=bound1;
        sense='+-+-+-++';
        interpolate='aaaaaaxx';
        hug='nhnnnhxx';
        spectype='llllllcc';
      elseif method==3
        Wm=(Wp(2)+Wp(1))/2;
        left =[0        0        Wp(1) Wp(1)        Wm    Wm          Ws(2)    Ws(2)   Wp(1) Wm   ]/Fs;
        right=[Ws(1)    Ws(1)    Wm    Wm           Wp(2) Wp(2)       Fs/2     Fs/2    Wm    Wp(2)]/Fs;
        bound1=[devs(2) -devs(2) 1     10^(-Rp/20)  1     10^(-Rp/20) devs(2) -devs(2) -1   -1    ];
        bound2=bound1;
        sense='+-+-+-+---';
        interpolate='aaaaaaaaxx';
        hug='nnhnhnnnxx';
        spectype='llllllllcc';
      elseif method==4
        left =[0     0     Wp(1) Wp(1) Ws(2) Ws(2)]/Fs;
        right=[Ws(1) Ws(1) Wp(2) Wp(2) Fs/2  Fs/2 ]/Fs;
        bound1=[devs(2) -devs(2) 1+devs(1) 1-devs(1) devs(2) -devs(2)];
        bound2=bound1;
        sense='+-+-+-';
        interpolate='aaaaaa';
        hug='nnnnnn';
        spectype='llllll';
      end
    else % bandstop
      Wp = freqs([2,5]);
      Ws = freqs(3:4);
      if method==1
        Wm=(Ws(2)+Ws(1))/2;
        left =[0     0           Ws(1)   Ws(1) Wm      Wm     Wp(2) Wp(2)       Ws(1) Wm    0     Wp(2)]/Fs;
        right=[Wp(1) Wp(1)       Wm      Wm    Ws(2)   Ws(2)  Fs/2  Fs/2        Wm    Ws(2) Wp(1) Fs/2 ]/Fs;
        bound1=[1    10^(-Rp/20) devs(2) 0     devs(2) 0      1     10^(-Rp/20) -1    -1    -1    -1];
        bound2=bound1;
        sense='+-+-+-+-++--';
        interpolate='aaaaaaaaxxxx';
        hug='hnnhnhhnxxxx';
        spectype='llllllllcccc';
      elseif method==2
        Wm=(Ws(2)+Ws(1))/2;
        left =[0          0         Ws(1)   Ws(1) Wm      Wm     Wp(2)     Wp(2)     Ws(1) Wm   ]/Fs;
        right=[Wp(1)      Wp(1)     Wm      Wm    Ws(2)   Ws(2)  Fs/2      Fs/2      Wm    Ws(2)]/Fs;
        bound1=[1+devs(1) 1-devs(1) devs(2) 0     devs(2) 0      1+devs(1) 1-devs(1) -1    -1   ];
        bound2=bound1;
        sense='+-+-+-+-++';
        interpolate='aaaaaaaaxx';
        hug='nnnhnhnnxx';
        spectype='llllllllcc';
      elseif method==3
        left =[0     0           Ws(1)   Ws(1)    Wp(2) Wp(2)       0     Wp(2)]/Fs;
        right=[Wp(1) Wp(1)       Ws(2)   Ws(2)    Fs/2  Fs/2        Wp(1) Fs/2 ]/Fs;
        bound1=[1    10^(-Rp/20) devs(2) -devs(2) 1     10^(-Rp/20) -1    -1   ];
        bound2=bound1;
        sense='+-+-+---';
        interpolate='aaaaaaxx';
        hug='hnnnhnxx';
        spectype='llllllcc';
      elseif method==4
        left =[0     0     Ws(1) Ws(1) Wp(2) Wp(2)]/Fs;
        right=[Wp(1) Wp(1) Ws(2) Ws(2) Fs/2  Fs/2 ]/Fs;
        bound1=[1+devs(1) 1-devs(1) devs(2) -devs(2) 1+devs(1) 1-devs(1)];
        bound2=bound1;
        sense='+-+-+-';
        interpolate='aaaaaa';
        hug='nnnnnn';
        spectype='llllll';
      end
    end
    Lsmallest=eval(get(ord1Hndl,'String'),'1')+1;
    Llargest=eval(get(ord2Hndl,'String'),'121')+1;

    % entweder beide ungerade oder beide gerade
    if rem(Lsmallest,2)~=rem(Llargest,2)
      Llargest=Llargest+1;
      set(ord2Hndl,'String',num2str(Llargest-1));
      drawnow;
    end
    if Lsmallest > Llargest
      Llargest=Lsmallest;
      set(ord2Hndl,'String',num2str(Llargest-1));
      drawnow;
    end

    if get(viewHndl,'Value')==1, symtype='cosine';
    else symtype='sine'; end

    % Plausibel ?
    if strcmp(symtype,'sine') & passband~=3
      uiwait(msgbox('Es lassen sich nur Bandpässe mit antisymmetrischer Impulsantwort realisieren',...
               'Fehler','none','modal'));
      set(gcf,'Pointer','arrow');
      set(0,'PointerLocation',get(0,'PointerLocation'));
      return;
    elseif (passband==2|passband==4) & ~rem(Lsmallest,2)
      uiwait(msgbox('Hochpaß und Bandsperre sind nur mit gerader Filterordnung realisierbar',...
               'Fehler','none','modal'));
      set(gcf,'Pointer','arrow');
      set(0,'PointerLocation',get(0,'PointerLocation'));
      return;
    end

    whattodo=get(whattodoHndl,'Value');
    if get(whattodoHndl,'Value')==1
      whichway=[]; bandpushed=[];
      whattodo='findlen';
    elseif get(whattodoHndl,'Value')==2 % push f1
      whattodo='pushedge';
      whichway='rr';
      if passband==1
        if method==1|method==3, bandpushed=[1 2 5];
        elseif method==2|method==4, bandpushed=[1 2]; end
      elseif passband==2
        if method==1|method==2, bandpushed=[1 2 5];
        elseif method==3|method==4, bandpushed=[1 2]; end
      elseif passband==3
        if method==1, bandpushed=[1 2 11];
        elseif method==2, bandpushed=[1 2 7];
        elseif method==3|method==4, bandpushed=[1 2]; end
      elseif passband==4
        if method==1, bandpushed=[1 2 11];
        elseif method==2|method==4, bandpushed=[1 2];
        elseif method==3, bandpushed=[1 2 7]; end
      end
    elseif get(whattodoHndl,'Value')==3 % push f2
      whattodo='pushedge';
      whichway='ll';
      if passband==1
        if method==1, bandpushed=[3 4 6];
        elseif method==2, bandpushed=[3 4 5];
        elseif method>=3, bandpushed=[3 4]; end
      elseif passband==2
        if method==1, bandpushed=[3 4 6];
        elseif method==2|method==4, bandpushed=[3 4];
        elseif method==3, bandpushed=[3 4 5]; end
      elseif passband==3
        if method==1, bandpushed=[3 4 9];
        elseif method==2|method==4, bandpushed=[3 4];
        elseif method==3, bandpushed=[3 4 9]; end
      elseif passband==4
        if method==1|method==2, bandpushed=[3 4 9];
        elseif method==3|method==4, bandpushed=[3 4]; end
      end
    elseif get(whattodoHndl,'Value')==4 % push f3
      whattodo='pushedge';
      whichway='rr';
      if passband==3
        if method==1|method==3, bandpushed=[5 6 10];
        elseif method==2|method==4, bandpushed=[3 4]; end
      elseif passband==4
        if method==1|method==2, bandpushed=[5 6 10];
        elseif method==3|method==4, bandpushed=[3 4]; end
      end
    elseif get(whattodoHndl,'Value')==5 % push f4
      whattodo='pushedge';
      whichway='ll';
      if passband==3
        if method==1, bandpushed=[7 8 12];
        elseif method==2, bandpushed=[5 6 8];
        elseif method==3, bandpushed=[7 8];
        elseif method==4, bandpushed=[5 6]; end
      elseif passband==4
        if method==1, bandpushed=[7 8 12];
        elseif method==2, bandpushed=[7 8];
        elseif method==3, bandpushed=[5 6 8];
        elseif method==4, bandpushed=[5 6]; end
      end
    end

    anz=201; % kleinere Werte -> keine gleiche Welligkeit

    title('Berechnung läuft !','Color','k');
    drawnow;

    set(findobj('Tag','MeteorForm'),'UserData',[]);
    meteor('extern',Lsmallest,Llargest,symtype,whattodo,spectype,sense,...
      interpolate,hug,anz,left,right,bound1,bound2,whichway,bandpushed);

    coeff=get(findobj('Tag','MeteorForm'),'UserData');
    order=length(coeff)-1;

    if strcmp(whattodo,'pushedge') & order>0
      freqs(get(whattodoHndl,'Value'))=coeff(order+1);
      coeff=coeff(1:order);
      order=order-1;
    end

    set(okbuttHndl,'UserData',[passband;freqs;ripples;method;order(1)]);

    set(gcf,'Pointer','arrow');
    % Die folgende Zeile erzwingt das Neuzeichnen des Mauszeigers.
    % Ohne dies wird der Mauszeiger teilweise erst nach bewegen
    % der Maus auf 'arrow' zurückgesetzt.
    % Dies geschieht bei 'langen' Rechenzeiten zwischen den 'set' Kommandos
    set(0,'PointerLocation',get(0,'PointerLocation'));

    if order>0
      meteform('axesredraw',coeff);
      set(gca,'xlim',[0 .5],'ylim',[-Rs*(1.5) max(2*Rp,Rs*.1)]);
    else
      meteform('axesredraw',coeff);
    end

    return

elseif strcmp(action,'axesredraw'), % redraw axes
    if ~isempty(s), [H,W]=freqz(s,1);
    else H=1; W=2*pi; end
    if isempty(findobj(gcf,'Tag','met_line'))
      hdl=line(W/2/pi,20*log10(abs(H)+eps));
      set(hdl,'Color','k','Tag','met_line');
    else
      set(findobj(gcf,'Tag','met_line'),'YData',20*log10(abs(H)+eps),...
          'XData',W/2/pi);
    end
    xlabel('normierte Frequenz');
    ylabel('Amplitude in dB');

elseif strcmp(action,'info'),

    !winhelp meteform.hlp
    return

elseif strcmp(action,'getfilt')
    num = get(findobj('Tag','MeteorForm'),'userdata');
    den = 1;
    fhndlList=get(gcf,'Userdata');
    hdl=get(gca,'Title');
    str=get(hdl,'String');
%    if get(fhndlList(8),'Value')~=1 & length(num)>1
    if ~isempty(findstr(str,'Eckfrequenz'))
      num=num(1:(length(num)-1));
    end

elseif findstr(action,'close') % close und close_ok
    current_figure=gcf;
    hdl_main=findobj('Tag','hauptfenster');
    if strcmp(action,'close_ok')
      [num,den]=meteform('getfilt');
      if ~isempty(hdl_main) & ~isempty(num),
        global b a; b=num; a=den;
        global filtertyp; filtertyp=8;
        hdl=findobj(gcf,'String','OK');
        makeprot('meteform',hdl,num,den);
      end
    end
    close(current_figure);
    if ~isempty(hdl_main)
      set(hdl_main,'visible','on');
      if strcmp(action,'close_ok') & ~isempty(num)
        drawmain(num,den,'meteform');
        %if findobj('Tag','plotter_Achse1')
        %  filtplot('NewDisplay');
        %end
      end
    end  
else
  disp(sprintf( ...
     'meteform: action String ''%s'' nicht bekannt, keine Aktion ausgeführt.',action))
end

