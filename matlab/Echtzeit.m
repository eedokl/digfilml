function fig=echtzeit(action)
%********************************************************************%
% function echtzeit.m                                                %
% Modul gehört zum Progamm: Digitale Filter unter MATLAB 4.2         %
% Bearbeiter:               Clemens Willenbrink / Oliver Klein       %
% Betreuer:                 Prof. Dr.-Ing. D. Stark                  %
%                                                                    %
% Aufgabe: -Aufbau eines Dialogfeldes zur Auswahl von:               %                                                          
%                 > Abtastfrequenz fa                                %                                                        
%                 > Eingangsspannungsbereich d. A/D Umsetzers        %              
%                 > Ausgangsspannungsbvereich d. D/A Umsetzers       %
%          -FIR Filterkoeffizienten werden der DSP-Karte übergeben   %
%          -FIR Echtzeitfilterung wird gestartet                     %
%********************************************************************%

% rtfir, dspini, save, stop auskommentiert
% elftest = 1 gesetzt

%********************************************************************%
%                   Globale Variablen                                %
%********************************************************************%  
global ECHTZEIT_FIG edit_eingang edit_ausgang pushbutton_hilfe...
       pushbutton_abbrechen pushbutton_beenden pushbutton_starten...
       ECHTZEIT_POPUP_TEXT a b filename_text filename...
       meldung 

  if nargin<1, action='init'; end;

dspini;           %Hiermit wird Initialisierungsdatei der DSP-Karte auf-
                  %gerufen (Nur nötig bei Version 3.1!!!!!!!!)

save base base;                         % Elf I/O address
save e3dai e3dai;                       % Elf dai address
%%% elftest=1;

hilfsgroesse=0;
%********************************************************************%
%     Überprüfung ob Systemvoraussetzungen erfüllt und               %
%              DSP-Karte initialisiert ist...                        %
%********************************************************************%  

if ~exist('elftest')
  fehler('','','DSP-Karte nicht vorhanden oder nicht initialisiert!');
  return
end;

if elftest~=1
  fehler('','','DSP-Karte nicht vorhanden oder nicht initialisiert!');
  return
end;



%********************************************************************%
%     Überprüfung ob Filtervoraussetzungen erfüllt sind: Nmax=20     %
%********************************************************************%
if length(a)>60 | (length(a)>1&length(b)>60) | length(b)>100
 fehler('','','Maximale Filterordnung für Echtzeitfilterung überschritten!');
 return
end;

%********************************************************************%
%          Überprüfung ob Dialogfeld schon geoeffnet ist             %
%********************************************************************%  
if strcmp(action,'init')
  [flag,fig]=figflag('Echtzeit - FIR/IIR - Filterung');
  if flag, return; end;

%********************************************************************%  
%                Aufbau des Eingabefensters                          %
%********************************************************************%
  ECHTZEIT_FIG=figure('Color',[1 1 1],'Position',[113 96 400 258],...
    'Name','Echtzeit - FIR/IIR - Filterung',...
    'Units','pixels','NumberTitle','off',...
    'Resize','off','MenuBar','none',...
    'Visible','off','NextPlot','new','Interruptible','no');

  uicontrol('Style','text','Position',[16 172 175 21],...
    'String','Ausgang (26µVss...1.4Vss)',...
    'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],...
    'HorizontalAlignment','left','Units','pixels');
 
  uicontrol('Style','text','Position',[17 199 173 21],...
    'String','Eingang (210mVss ... 2.8Vss)',...
    'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],...
    'HorizontalAlignment','left','Units','pixels');

  uicontrol('Style','text','Position',[273 173 14 20],...
    'String','V','BackgroundColor',[1 1 1],...
    'ForegroundColor',[0 0 0],...
    'HorizontalAlignment','left','Units','pixels');

  uicontrol('Style','text','Position',[273 198 14 20],...
    'String','V','BackgroundColor',[1 1 1],...
    'ForegroundColor',[0 0 0],...
    'HorizontalAlignment','left','Units','pixels');

  uicontrol('Style','frame','Position',[9 163 283 76],...
    'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],...
    'Units','pixels');

  edit_eingang=uicontrol('Style','edit',...
    'Position',[191 203 74 16],'String','1.0',...
    'BackgroundColor',[0 0.502 0.502],'ForegroundColor',[0 0 0],...
    'Max',1,'Interruptible','no','Units','pixels');

  edit_ausgang=uicontrol('Style','edit',...
    'Position',[192 179 74 16],'String','1.0',...
    'BackgroundColor',[0 0.502 0.502],'ForegroundColor',[0 0 0],...
    'Max',1,'Interruptible','no','Units','pixels');

  uicontrol('Style','text','Position',[18 226 210 20],...
    'String','Spannungsbereich AD/DA-Umsetzer:',...
    'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],...
    'HorizontalAlignment','left','Units','pixels');

  uicontrol('Style','text','Position',[9 132 139 20],...
    'String','Abtastfrequenz fa (Hz) :',...
    'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],...
    'HorizontalAlignment','left','Units','pixels');

  pushbutton_hilfe=uicontrol('Style','pushbutton',...
    'Position',[9 9 80 30],'String','Hilfe',...
    'CallBack','echtzeit(''hilfe'')',...
    'Interruptible','no','Units','pixels');

  pushbutton_abbrechen=uicontrol('Style','pushbutton',...
    'Position',[105 8 80 30],'String','Abbrechen',...
    'CallBack','echtzeit(''abbrechen'')',...
    'Interruptible','no','Units','pixels');

  pushbutton_beenden=uicontrol('Style','pushbutton',...
    'Position',[236 11 153 35],...
    'String','Echtzeitfilterung beenden',...
    'CallBack','echtzeit(''stop'')',...
    'Interruptible','no','Units','pixels');

  pushbutton_starten=uicontrol('Style','pushbutton',...
    'Position',[235 53 155 35],...
    'String','Echtzeitfilterung starten',...
    'CallBack','echtzeit(''starten'')',...
    'Interruptible','no','Units','pixels');

  uicontrol('Style','text','Position',[16 70 80 20],...
    'String','Dateiname :','BackgroundColor',[1 1 1],...
    'ForegroundColor',[0 0 0],...
    'HorizontalAlignment','left','Units','pixels');

  filename_text=uicontrol('Style','text','Position',[98 74 80 16],...
    'String','-------------------',...
    'BackgroundColor',[0 0.502 0.502],...
    'ForegroundColor',[0 0 0],...
    'HorizontalAlignment','left','Units','pixels');

  uicontrol('Style','frame','Position',[9 66 185 30],...
    'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],...
    'Units','pixels');

  ECHTZEIT_POPUP_TEXT=uicontrol('Style','popupmenu',...
    'Position',[9 117 135 20],...
    'String','5512.5|6615|8000|9600|11025|16000|18900|22050|27428.57|32000|33075|37800|44100|48000',...
    'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],...
    'Value',1,'Interruptible','no','Value',13,...
    'Units','pixels');

  meldung=uicontrol('Style','text','Position',[10 40 185 20],...
    'String','',...
    'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],...
    'HorizontalAlignment','left','Units','pixels');

  %********************************************************************%
  %               Eingabefenster sichtbar machen                       %
  %********************************************************************%
  set(ECHTZEIT_FIG,'visible','on');

%********************************************************************%
%               Schaltfläche:  Echtzeitfilterung starten             %
%********************************************************************%
elseif strcmp(action,'starten')

%********************************************************************%  
%             Überprüfung der AD/DA-Spannungswerte                   %
%********************************************************************%  
  ad_range=str2num(get(edit_eingang,'string'));
  da_range=str2num(get(edit_ausgang,'string'));

  if isempty(ad_range) | isempty(da_range)
    fehler('','Bitte beachten Sie die gültigen Spannungsbereiche:',...
           'AD-Wandler: 210mVss...2.8Vss',...
           'DA-Wandler:  26µVss...1.4Vss');
    hilfsgroesse=1;   %**Filterung nicht starten

  elseif ad_range<=0.21 | ad_range>=2.8 | da_range<=0.000026 | da_range>=1.4
    fehler('','Bitte beachten Sie die gültigen Spannungsbereiche:',...
           'AD-Wandler: 210mVss...2.8Vss',...
           'DA-Wandler:  26µVss...1.4Vss');
    hilfsgroesse=1;   %**Filterung nicht starten
  end;

%****************************************************************%
%                Überprüfung Koeffizienten/Anzahl                %
%****************************************************************%
if length(a)>1  %% IIR-Filter
  filterart=1; %IIR-Kennung
  if a(1)~=1 | length(b)<1 | (length(a)<3 & length(b)<3)
    fehler('','Kein  gültiger IIR-Koeffizientensatz oder ',...
           'nicht genügend Koeffizienten vorhanden !',...
           'Erforderliche Koeffizientenanzahl größer gleich 3 !');
    hilfsgroesse=1;  %** verhindert Start der Filterung **
  end
else            %% FIR-Filter
  filterart=2; %FIR-Kennung
  if a~=1 | length(b)<3
    fehler('','Kein gültiger FIR-Koeffizientensatz oder nicht genügend',...
           'Koeffizienten vorhanden !',...
           'Erforderliche Koeffizientenanzahl größer gleich 3 !');
    hilfsgroesse=1;  %** verhindert Start der Filterung **
  end;
end

%********************************************************************%  
%                 Übernehmen der Abtastfrequenz fa                   %
%********************************************************************%  
  va=get(ECHTZEIT_POPUP_TEXT,'value');
  if va==1
    fa=5512.5;
  elseif va==2
    fa=6615;
  elseif va==3
    fa=8000;
  elseif va==4
    fa=9600;
  elseif va==5
    fa=11025;
  elseif va==6
    fa=16000;
  elseif va==7
    fa=18900;
  elseif va==8
    fa=22050;
  elseif va==9
    fa=27428.57;
  elseif va==10
    fa=32000;
  elseif va==11
    fa=33075;
  elseif va==12
    fa=37800;
  elseif va==13
    fa=44100;
  elseif va==14
    fa=48000;
  end;


%********************************************************************%  
%            Übergeben der Parameter an die DSP-Karte                %
%********************************************************************%  
  if hilfsgroesse==0     % wenn kein Fehler aufgetreten...

    if filterart==2  % FIR
      rtfir(b,fa,0,0,ad_range,da_range);   % Fkt.aus Toolbox,Firma MEDAV Gmbh
      set(meldung,'string','FIR-Echtzeitfilterung läuft...');
      set(filename_text,'String',filename); %**Dateiname des aktuellen Filters

    elseif filterart==1  % IIR

      % Nenner eventuell mit Nullen auffüllen
      if length(a)<length(b), den=[a,zeros(1,length(b)-length(a))];
      else den=a; end

      % Zähler eventuell mit Nullen auffüllen
      if length(b)<length(a), num=[b,zeros(1,length(a)-length(b))];
      else num=b; end

      % Filterung mit second order sections aktivieren
      sos=tf2sos(num,den);
      rtiir(sos,fa,0,0,ad_range,da_range);

      set(meldung,'string','IIR-Echtzeitfilterung läuft...');
      set(filename_text,'String',filename); %**Dateiname des aktuellen Filters

    end

  end;

%********************************************************************%  
%                    Echtzeitfilterung stoppen                       %
%********************************************************************%
elseif strcmp(action,'stop')
  stop;  %**Alle Funktionen auf der DSP-Karte werden beendet**
  set(filename_text,'String','-------------------'); %**Dateiname löschen
  set(meldung,'string','Echtzeitfilterung abgebrochen...');

%********************************************************************%  
%                   Schaltfläche: Abbrechen                          %
%********************************************************************%  
elseif strcmp(action,'abbrechen')
  stop
  close(ECHTZEIT_FIG);
  clear global ECHTZEIT_FIG edit_eingang edit_ausgang...
        pushbutton_hilfe pushbutton_abbrechen...
        pushbutton_beenden pushbutton_starten ECHTZEIT_POPUP_TEXT

%********************************************************************%  
%                   Schaltfläche: Hilfe                              %
%********************************************************************%  
elseif strcmp(action,'hilfe')
  !winhelp echtzeit.hlp &
end;