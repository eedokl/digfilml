function fir_wind(action)
%********************************************************************%
% function fir_wind.m                                                %
% Modul gehört zum Progamm: Digitale Filter unter MATLAB 4.x         %
% Bearbeiter:               Clemens Willenbrink / Oliver Klein       %
% Betreuer:                 Prof. Dr.-Ing. D. Stark                  %
%                                                                    %
% Aufgabe: -Aufbau eines Dialogfeldes zur Eingabe von Filterpara-    %                                                          
%           metern. Berechnung des entsprechenden FIR-Filters(Filter-%                                                        
%           koeffizienten) nach der Window-Methode                   %              
%          -Erstellung einer Protokolldatei                          %
%********************************************************************%

%********************************************************************%
%                   Globale Variablen                                %
%********************************************************************%  

global b a window_methode_fig window_tiefpass...
       window_hochpass window_bandpass window_bandsperre...
       window_N_edit window_fg_edit window_fg_text...
       window_hinweis_text window_fg_frame...
       window_fgo_frame window_fg_edit_1...
       window_fg_edit_2 window_fgu_text window_fgo_text...
       window_push_button_ok window_push_button_abbrechen...
       window_push_button_hilfe...
       window_pop_up_text window_filename_edit...
       Ftype n wn wind filename filtertyp val FT_wm...
       fg_wm fg_1_wm fg_2_wm window_kaiser_frame window_kaiser_text...
       window_kaiser_edit alpha

hilfsgroesse=0;  % wird bei Fehlern auf 1 gesetzt,damit Fenster nicht
		 % geschlossen wird.

if nargin<1,     % Initialisierung 
   action='init';
end;

%********************************************************************%
%          Überprüfung ob Fenster schon geoeffnet ist                %
%********************************************************************%

if strcmp(action,'init')
  [flag,fig]=figflag('Filterdesign:  FIR-Filter /Window - Methode');
  if flag,   %**wenn Fenster vorhanden nicht nochmal erzeugen!**
    return
  end;
%********************************************************************%
%                    Aufbau des Dialogfeldes                         %
%********************************************************************%


  window_methode_fig=figure('Color',[1 1 1],...
   'Units','pixels',...
   'Position',[45 100 535 292],...
        'Name','Filterdesign:  FIR-Filter /Window - Methode',...
		  'NumberTitle','off',...
		  'Resize','off',...
		  'MenuBar','none',...
		  'Visible','off',...
		  'KeyPressFcn','refresh',...
		  'Interruptible','off');

  uicontrol('Style','frame',...
  'units','pixels',...   
  'Position',[19 118 101 145],...
		  'BackgroundColor',[1 1 1],...
		  'ForegroundColor',[0 0 0]);

  window_tiefpass=uicontrol('Style','radiobutton',...
  'units','pixels',...   
		  'Position',[25 230 80 20],...
		  'String','Tiefpass',...
		  'BackgroundColor',[1 1 1],...
		  'ForegroundColor',[0 0 0],...
		  'Value',1,...
		  'Interruptible','off',...
		  'Callback','fir_wind(''tiefpass'')');
		 
	       
  window_hochpass=uicontrol('Style','radiobutton',...
  'units','pixels',...   
		 'Position',[25 200 80 20],...
		 'String','Hochpass',...
		 'BackgroundColor',[1 1 1],...
		 'ForegroundColor',[0 0 0],...
		 'Value',0,...
		 'Interruptible','off',...
		 'Callback','fir_wind(''hochpass'')');

  window_bandpass=uicontrol('Style','radiobutton',...
  'units','pixels',...   
		 'Position',[25 170 80 20],...
		 'String','Bandpass',...
		 'BackgroundColor',[1 1 1],...
		 'ForegroundColor',[0 0 0],...
		 'Value',0,...
		 'Interruptible','off',...
		 'Callback','fir_wind(''bandpass'')');

  window_bandsperre=uicontrol('Style','radiobutton',...
  'units','pixels',...   
		 'Position',[25 140 84 20],...
		 'String','Bandsperre',...
		 'BackgroundColor',[1 1 1],...
		 'ForegroundColor',[0 0 0],...
		 'Value',0,...
		 'Interruptible','off',...
		 'Callback','fir_wind(''bandsperre'')');

  uicontrol('Style','text',...
  'units','pixels',...   
		 'Position',[24 251 53 20],...
		 'String','Filtertyp:',...
		 'BackgroundColor',[1 1 1],...
		 'ForegroundColor',[0 0 0],...
		 'HorizontalAlignment','left');

  uicontrol('Style','frame',...
  'units','pixels',...   
		 'Position',[139 117 122 24],...
		 'BackgroundColor',[1 1 1],...
		 'ForegroundColor',[0 0 0]);

  window_N_edit=uicontrol('Style','edit',...
  'units','pixels',...   
		 'Position',[223 119 25 19],...
		 'String','14',...
		 'BackgroundColor',[255 255 225]/255,...
		 'ForegroundColor',[0 0 0],...
		 'Max',1,'horiz','left',...
		 'Interruptible','off');

  window_fg_edit=uicontrol('Style','edit',...
  'units','pixels',...   
		 'Position',[308 239 56 19],...
		 'String','0.25',...
		 'BackgroundColor',[255 255 225]/255,...
		 'ForegroundColor',[0 0 0],...
		 'Max',1,'horiz','left',...
		 'Interruptible','off');

  window_hinweis_text=uicontrol('Style','text',...
  'units','pixels',...   
		 'Position',[364 237 80 20],...
		 'String','(0 < fg < 0.5)',...
		 'BackgroundColor',[1 1 1],...
		 'ForegroundColor',[0 0 0],...
		 'HorizontalAlignment','center');

  window_fg_text=uicontrol('Style','text',...
  'units','pixels',...   
		 'Position',[143 237 165 20],...
		 'String','normierte Grenzfrequenz fg =',...
		 'BackgroundColor',[1 1 1],...
		 'ForegroundColor',[0 0 0],...
		 'HorizontalAlignment','left');

  window_fg_frame=uicontrol('Style','frame',...
  'units','pixels',...   
		 'Position',[139 233 317 30],...
		 'BackgroundColor',[1 1 1],...
		 'ForegroundColor',[0 0 0]);

  window_fgo_frame=uicontrol('Style','frame',...
  'units','pixels',...   
		 'Position',[139 161 290 60],...
		 'BackgroundColor',[1 1 1],...
		 'ForegroundColor',[0 0 0],...
		 'Visible','off');

  window_fg_edit_1=uicontrol('Style','edit',...
  'units','pixels',...   
		 'Position',[361 197 56 19],...
		 'String','0.15',...
		 'BackgroundColor',[255 255 225]/255,...
		 'ForegroundColor',[0 0 0],...
		 'Max',1,'horiz','left',...
		 'Interruptible','off',...
		 'Visible','off');

  window_fg_edit_2=uicontrol('Style','edit',...
  'units','pixels',...   
		 'Position',[361 172 56 19],...
		 'String','0.35',...
		 'BackgroundColor',[255 255 225]/255,...
		 'ForegroundColor',[0 0 0],...
		 'Max',1,'horiz','left',...
		 'Interruptible','off',...
		 'Visible','off');

  window_fgu_text=uicontrol('Style','text',...
  'units','pixels',...   
		 'Position',[145 195 215 20],...
		 'String','normierte untere Grenzfrequenz fgu =',...
		 'BackgroundColor',[1 1 1],...
		 'ForegroundColor',[0 0 0],...
		 'HorizontalAlignment','left',...
		 'Visible','off');

  window_fgo_text=uicontrol('Style','text',...
  'units','pixels',...   
		 'Position',[145 169 215 20],...
		 'String','normierte obere  Grenzfrequenz fgo =',...
		 'BackgroundColor',[1 1 1],...
		 'ForegroundColor',[0 0 0],...
		 'HorizontalAlignment','left',...
		 'Visible','off');

  uicontrol('Style','text',...
  'units','pixels',...   
		'Position',[141 118 80 20],...
		'String','Filterordnung:',...
		'BackgroundColor',[1 1 1],...
		'ForegroundColor',[0 0 0],...
		'HorizontalAlignment','left');

  uicontrol('Style','text',...
  'units','pixels',...   
		'Position',[23 38 80 20],...
		'String','Protokoll:',...
		'BackgroundColor',[1 1 1],...
		'ForegroundColor',[0 0 0],...
		'HorizontalAlignment','left');

  window_push_button_ok=uicontrol('Style','pushbutton',...
  'units','pixels',...   
		'Position',[427 48 100 25],...
		'String','OK',...
		'CallBack','fir_wind(''ok'')',...
		'Interruptible','off');
	
  window_push_button_abbrechen=uicontrol('Style','pushbutton',...
  'units','pixels',...   
		'Position',[427 83 100 25],...
		'String','Abbrechen',...
		'CallBack','fir_wind(''abbrechen'')',...
		'Interruptible','off');

  window_push_button_hilfe=uicontrol('Style','pushbutton',...
  'units','pixels',...   
		'Position',[427 118 100 25],...
		'String','Hilfe',...
		'CallBack','fir_wind(''Hilfe'')',...
		'Interruptible','off');


  uicontrol('Style','text',...
  'units','pixels',...   
		'Position',[298 136 97 20],...
		'String','Fensterfunktion:',...
		'BackgroundColor',[1 1 1],...
		'ForegroundColor',[0 0 0],...
		'HorizontalAlignment','left');

  window_pop_up_text=uicontrol('Style','popupmenu',...
  'units','pixels',...   
		'Position',[298 118 118 20],...
		'String','Rechteck|Bartlett|Blackman|Hamming|Hanning|Kaiser',...
		'BackgroundColor',[1 1 1],...
		'ForegroundColor',[0 0 0],...
		'Value',1,...
		'Interruptible','off',...
		'Callback','fir_wind(''window'')');

  window_kaiser_frame=uicontrol('Style','frame',...
  'units','pixels',...   
		 'Position',[298 80 118 30],...
		 'BackgroundColor',[1 1 1],...
		 'ForegroundColor',[0 0 0],...
		 'Visible','off');

  window_kaiser_text=uicontrol('Style','text',...
  'units','pixels',...   
		 'Position',[299 83 100 20],...
		 'String',' A(dB) =',...
		 'BackgroundColor',[1 1 1],...
		 'ForegroundColor',[0 0 0],...
		 'HorizontalAlignment','left',...
		 'Visible','off');

  window_kaiser_edit=uicontrol('Style','edit',...
  'units','pixels',...   
		 'Position',[350 86 56 19],...
		 'String','50.0',...
		 'BackgroundColor',[255 255 225]/255,...
		 'ForegroundColor',[0 0 0],...
		 'Max',1,'horiz','left',...
		 'Interruptible','off',...
		 'Visible','off');

  window_filename_edit=uicontrol('Style','edit',...
  'units','pixels',...   
		'Position',[90 39 200 19],...
		'String','temp\temp_ptk.ptk',...
		'BackgroundColor',[255 255 225]/255,...
		'ForegroundColor',[0 0 0],...
		'Max',1,'horiz','left',...
		'Interruptible','off');

  uicontrol('Style','frame',...
  'units','pixels',...   
	       'Position',[19 35 300 30],...
	       'BackgroundColor',[1 1 1],...
	       'ForegroundColor',[0 0 0]);

  uicontrol('Style','text',...
  'units','pixels',...   
		'Position',[19 10 400 18],...
		'String','Die Grenzfrequenzen sind normiert auf die Abtastfrequenz (0<f/fa<0.5)',...
		'BackgroundColor',[1 1 1],...
		'ForegroundColor',[0 0 0],...
		'HorizontalAlignment','left');

%********************************************************************%
%      Einlesen von evtl. vorhandenen Werte aus dem Arbeitsbereich   %
%********************************************************************%

  if filtertyp==2,
    set(window_N_edit,'String',n);              %Filterordnung
    set(window_filename_edit,'String',filename);  %filename
    set(window_pop_up_text,'value',val)           %Fenstertyp
    if val==6,
      set(window_kaiser_frame,'visible','on');   %Zusatz fuer
      set(window_kaiser_text,'visible','on');    %Kaiserfenster
      set(window_kaiser_edit,'visible','on');
      set(window_kaiser_edit,'string',alpha);
    end;

    if FT_wm == 'TP'                              %wenn Tiefpass...
      set(window_tiefpass,'Value',1);
      set(window_fg_edit,'String',fg_wm);
      set(window_tiefpass,'value',1);
      set(window_hochpass,'value',0);
      set(window_bandpass,'value',0);
      set(window_bandsperre,'value',0);
      set(window_fgo_frame,'visible','off');
      set(window_fgu_text,'visible','off');
      set(window_fgo_text,'visible','off');
      set(window_fg_edit_1,'visible','off');
      set(window_fg_edit_2,'visible','off');
      set(window_fg_text,'visible','on');
      set(window_fg_frame,'visible','on');
      set(window_fg_edit,'visible','on');
      set(window_hinweis_text,'visible','on');

    elseif FT_wm == 'HP'                          %wenn Hochpass...
      set(window_hochpass,'Value',1);
      set(window_fg_edit,'String',fg_wm);
      set(window_hochpass,'value',1);
      set(window_tiefpass,'value',0);
      set(window_bandpass,'value',0);
      set(window_bandsperre,'value',0);
      set(window_fgo_frame,'visible','off');
      set(window_fgu_text,'visible','off');
      set(window_fgo_text,'visible','off');
      set(window_fg_edit_1,'visible','off');
      set(window_fg_edit_2,'visible','off');
      set(window_fg_text,'visible','on');
      set(window_fg_frame,'visible','on');
      set(window_fg_edit,'visible','on');
      set(window_hinweis_text,'visible','on');

    elseif FT_wm == 'BP'                          %wenn Bandpass...
      set(window_bandpass,'Value',1);
      set(window_fg_edit_1,'String',fg_1_wm);
      set(window_fg_edit_2,'String',fg_2_wm);
      set(window_bandpass,'value',1);
      set(window_tiefpass,'value',0);
      set(window_hochpass,'value',0);
      set(window_bandsperre,'value',0);
      set(window_fgo_frame,'visible','on');
      set(window_fgu_text,'visible','on');
      set(window_fgo_text,'visible','on');
      set(window_fg_edit_1,'visible','on');
      set(window_fg_edit_2,'visible','on');
      set(window_fg_text,'visible','off');
      set(window_fg_frame,'visible','off');
      set(window_fg_edit,'visible','off');
      set(window_hinweis_text,'visible','off');

    elseif FT_wm == 'BS'                          %wenn Bandsperre...
      set(window_bandsperre,'Value',1);
      set(window_fg_edit_1,'String',fg_1_wm);
      set(window_fg_edit_2,'String',fg_2_wm);
      set(window_bandsperre,'value',1);
      set(window_tiefpass,'value',0);
      set(window_hochpass,'value',0);
      set(window_bandpass,'value',0);
      set(window_fgo_frame,'visible','on');
      set(window_fgu_text,'visible','on');
      set(window_fgo_text,'visible','on');
      set(window_fg_edit_1,'visible','on');
      set(window_fg_edit_2,'visible','on');
      set(window_fg_text,'visible','off');
      set(window_fg_frame,'visible','off');
      set(window_fg_edit,'visible','off');
      set(window_hinweis_text,'visible','off');
    end;
  end; % von filtertyp==2

  set(window_methode_fig,'visible','on'); %**Fenster sichtbar machen***

%********************************************************************%
%                    Schaltfläche: Abbrechen                         %
%********************************************************************%

elseif strcmp(action,'abbrechen')
  close(window_methode_fig);
  clear global window_methode_fig window_tiefpass...
  window_hochpass window_bandpass window_bandsperre...
  window_N_edit window_fg_edit window_fg_text window_fg_frame...
  window_fgo_frame window_fg_edit_1 window_fg_edit_2...
  window_fgu_text window_fgo_text window_push_button_ok...
  window_push_button_abbrechen window_pop_up_text...
  window_filename_edit window_push_button_hilfe

%********************************************************************%
%                    Schaltfläche: Hilfe                             %
%********************************************************************%

elseif strcmp(action,'Hilfe')
  !winhelp fir_wind.hlp &

%********************************************************************%
%                       Radiobutton Tiefpass                         %
%********************************************************************%                      
elseif strcmp(action,'tiefpass')                 
  set(window_tiefpass,'value',1);
  set(window_hochpass,'value',0);
  set(window_bandpass,'value',0);
  set(window_bandsperre,'value',0);
  set(window_fgo_frame,'visible','off');
  set(window_fgu_text,'visible','off');
  set(window_fgo_text,'visible','off');
  set(window_fg_edit_1,'visible','off');
  set(window_fg_edit_2,'visible','off');
  set(window_fg_text,'visible','on');
  set(window_fg_frame,'visible','on');
  set(window_fg_edit,'visible','on');
  set(window_hinweis_text,'visible','on');
  Ftype=[];

%********************************************************************%
%                       Radiobutton Hochpass                         %
%********************************************************************%
elseif strcmp(action,'hochpass')                 
  set(window_hochpass,'value',1);
  set(window_tiefpass,'value',0);
  set(window_bandpass,'value',0);
  set(window_bandsperre,'value',0);
  Ftype='high';
  set(window_fgo_frame,'visible','off');
  set(window_fgu_text,'visible','off');
  set(window_fgo_text,'visible','off');
  set(window_fg_edit_1,'visible','off');
  set(window_fg_edit_2,'visible','off');
  set(window_fg_text,'visible','on');
  set(window_fg_frame,'visible','on');
  set(window_fg_edit,'visible','on');
  set(window_hinweis_text,'visible','on');

%********************************************************************%
%                       Radiobutton Bandpass                         %
%********************************************************************%

elseif strcmp(action,'bandpass')                 
  set(window_bandpass,'value',1);
  set(window_tiefpass,'value',0);
  set(window_hochpass,'value',0);
  set(window_bandsperre,'value',0);
  set(window_fgo_frame,'visible','on');
  set(window_fgu_text,'visible','on');
  set(window_fgo_text,'visible','on');
  set(window_fg_edit_1,'visible','on');
  set(window_fg_edit_2,'visible','on');
  set(window_fg_text,'visible','off');
  set(window_fg_frame,'visible','off');
  set(window_fg_edit,'visible','off');
  set(window_hinweis_text,'visible','off');
  Ftype=[];

%********************************************************************%
%                       Radiobutton Bandsperre                       %
%********************************************************************%
elseif strcmp(action,'bandsperre')               
  set(window_bandsperre,'value',1);
  set(window_tiefpass,'value',0);
  set(window_hochpass,'value',0);
  set(window_bandpass,'value',0);
  set(window_fgo_frame,'visible','on');
  set(window_fgu_text,'visible','on');
  set(window_fgo_text,'visible','on');
  set(window_fg_edit_1,'visible','on');
  set(window_fg_edit_2,'visible','on');
  set(window_fg_text,'visible','off');
  set(window_fg_frame,'visible','off');
  set(window_fg_edit,'visible','off');
  set(window_hinweis_text,'visible','off');
  Ftype='stop';

%********************************************************************%
%Setzen oder löschen eines zusätz. Eingabebereichs / Kaiserfenster   %                    %
%********************************************************************%

elseif strcmp(action,'window') 
  if get(window_pop_up_text,'Value')==6,
    set(window_kaiser_frame,'visible','on');
    set(window_kaiser_text,'visible','on');
    set(window_kaiser_edit,'visible','on');
  else
    set(window_kaiser_frame,'visible','off');
    set(window_kaiser_text,'visible','off');
    set(window_kaiser_edit,'visible','off');
  end;

%********************************************************************%
%                       Schaltfläche: OK                             %
%********************************************************************%       

elseif strcmp(action,'ok')                   

  n=(str2num(get(window_N_edit,'String')));  %Filterordnung

  %********************************************************************%
  %                       Abfangen von Fehleingaben                    %
  %********************************************************************%

  if isempty(n)
    fehler('','Filterordnung N ganzzahlig im Bereich:  3...99 !');
    hilfsgroesse=1;  % Hiermit wird verhindert, daß das Fenster sich schließt.
  elseif n<3 | n>99
	fehler('','Filterordnung N ganzzahlig im Bereich:  3...99 !');
	hilfsgroesse=1;
  elseif (n-fix(n)) ~=0
     fehler('','Filterordnung N ganzzahlig im Bereich:  3...99 !');
     hilfsgroesse=1;
  elseif rem(n,2) & get(window_hochpass,'value')==1
     fehler('','Bei Hochpaß und Bandsperre muß die Filterordnung N',...
            'geradzahlig gewählt werden !');
     hilfsgroesse=1;
  elseif rem(n,2) & get(window_bandsperre,'value')==1
     fehler('','Bei Hochpaß und Bandsperre muß die Filterordnung N',...
            'geradzahlig gewählt werden !');
     hilfsgroesse=1;
  else     %Zeile GANZ_WEIT_UNTEN
    %********************************************************************%
    %       Fenstertyp wird entsprechend dem Pop-Up Menü übernommen      %
    %********************************************************************%
    val=get(window_pop_up_text,'value');
    if val==1
      wind=boxcar(n+1);
    elseif val==2
      wind=bartlett(n+1);
    elseif val==3
      wind=blackman(n+1);
    elseif val==4
      wind=hamming(n+1);
    elseif val==5
      wind=hanning(n+1);
    elseif val==6
      alpha=str2num(get(window_kaiser_edit,'string'));
      if alpha>=50
         beta=0.1102*(alpha-8.7);
      elseif alpha>21 & alpha<50
         beta=0.5842*(alpha-21)^0.4+0.07866*(alpha-21);
      elseif alpha<=21
         beta=0;
      end;
      wind=kaiser(n+1,beta);
    end;



%********************************************************************%
%    Übernehmen der Filterart u. den entspr. Grenzfrequenzen         %
%********************************************************************%

    if get(window_tiefpass,'value')==1
      FT_wm='TP';
      fg_wm=get(window_fg_edit,'String');
      Ftype=[];
      wn=str2num(get(window_fg_edit,'String'))*2; %Grenzfrequenz***
    elseif get(window_hochpass,'value')==1
      FT_wm='HP';
      fg_wm=get(window_fg_edit,'String');
      Ftype='high';
      wn=str2num(get(window_fg_edit,'String'))*2; %Grenzfrequenz***

    elseif get(window_bandpass,'value')==1
      FT_wm='BP';
      fg_1_wm=get(window_fg_edit_1,'String');
      fg_2_wm=get(window_fg_edit_2,'String');
      Ftype=[];
      wn=[str2num(get(window_fg_edit_1,'String'))*2 str2num(get(window_fg_edit_2,'String'))*2];
    elseif get(window_bandsperre,'value')==1
      FT_wm='BS';
      fg_1_wm=get(window_fg_edit_1,'String');
      fg_2_wm=get(window_fg_edit_2,'String');
      Ftype='stop';
      wn=[str2num(get(window_fg_edit_1,'String'))*2 str2num(get(window_fg_edit_2,'String'))*2];

    end;

%********************************************************************%
%                 Dateiname übernehmen                               %
%********************************************************************%

    filename=get(window_filename_edit,'String');

%********************************************************************%
%    Berechnung der Filterkoeffizienten m. Hilfe der Fkt. fir1.m     %
%********************************************************************%
    if FT_wm=='TP' | FT_wm=='HP'
      f=str2num(get(window_fg_edit,'String'));
      if f>0 & f<0.5 &  hilfsgroesse==0;
        [b,a]=fir1(n,wn,Ftype,wind); %*Koeffizienten berechnen
        % folgende Zeile beseitigt Nullstellen im Unendlichen
        indx=find(abs(b)<1e-4);  % quick & dirty
        b(indx)=b(indx)*0;
      else
        fehler('','Normierte Grenzfrequenz im Bereich:  0<fg<0.5 !');
        hilfsgroesse=1;
      end;
    elseif FT_wm=='BP' | FT_wm=='BS'
      g=str2num(get(window_fg_edit_1,'String'));
      h=str2num(get(window_fg_edit_2,'String'));
      if g>0 & g<0.5 & h>0 & h<0.5 & h>g &  hilfsgroesse==0;
        [b,a]=fir1(n,wn,Ftype,wind); %*Koeffizienten berechnen

        % folgende Zeile beseitigt Nullstellen im Unendlichen
        % if ~rem(n,2), b([1:n/2+1]*2-1)=zeros(1,n/2+1); end
        indx=find(abs(b)<1e-4);  % quick & dirty
        b(indx)=b(indx)*0;
      else
        fehler('','Normierte Grenzfrequenzen im Bereich:  0<fg<0.5 !',...
               'Grenzfrequenzen dürfen sich nicht überschneiden.');
        hilfsgroesse=1;
      end;
    end;
    filtertyp=2;         %*Erkennungsvariable für Window_Methode**

    %=============================
    % Überprüfung des Dateinamen =
    %=============================

    pos=max(findstr(filename,'\'));
    if ~isempty(pos), fname=filename(pos+1:length(filename));
    else fname=filename; end

    h=length(fname);
    g=abs(fname);
    k=findstr(fname,'.');
    g= g<45|g>122|(g>45&g<48&g~=46)|(g>57&g<65)|(g>90&g<95)|g==96;

    if h>12| nnz(g)~=0 | h==0 | k>9 | isempty(k) | h-k > 3

      %Überprüfung ob Dateiname zu lang******
      %Überprüfung auf Sonderzeichen*********
      %gültig:Buchstaben,Zahlen,Binde- u.****
      %Unterstrich.**************************
      fehler('','DATEINAMENFORMAT:','max. 8 Zeichen',...
             'erlaubt sind: Buchstaben,Zahlen,Binde- u. Unterstrich');
      hilfsgroesse=1;
    end;

    %****************************%
    % Speichern des Datensatzes  %
    %  Verzeichnis:...\fir_wind  %
    %****************************%
   
    if hilfsgroesse==0     % wenn kein Fehler aufgetreten...

    %********************************************************%
    % Erstellen und Speichern der zugehörigen Protokolldatei %
    %********************************************************%

      fid=fopen(filename,'wt');
      fprintf(fid,'Protokoll   -Digitale Filter unter MATLAB 4.x-      %s\n\n\n',date);
      fprintf(fid,'Filtertyp: FIR-Filter,%s\n\n',FT_wm);
      fprintf(fid,'Entwurfsverfahren: Window-Methode\n\n');
      if val==1
        fenster='Rechteck';
      elseif val==2
        fenster='Bartlett';
      elseif val==3
        fenster='Blackman';
      elseif val==4
        fenster='Hamming';
      elseif val==5
        fenster='Hanning';
      elseif val==6
        fenster=['Kaiser,A=',get(window_kaiser_edit,'string'),'dB'];
      end;
      fprintf(fid,'Fensterfunktion: %s\n\n',fenster);
      fprintf(fid,'Filterordnung N: %3.0f\n\n',n);
      if FT_wm=='HP' |FT_wm=='TP'
        fprintf(fid,'normierte Grenzfrequenz fg: %s\n\n',fg_wm);
      else
        fprintf(fid,'normierte untere Grenzfrequenz fgu: %s\n',fg_1_wm);
        fprintf(fid,'normierte obere  Grenzfrequenz fgo: %s\n\n',fg_2_wm);
      end;
      fprintf(fid,'berechnete Filterkoeffizienten:\n\n');
      for n=[0:length(b)-1]
        fprintf(fid,'b(%3.0f) = %+2.16f\n',n,b(n+1));
      end;

      fprintf(fid,' \n\na(  0) = 1.0\n\n\n\n'); %Leerzeilen erzeugen

      %*** Pol- u. Nullstellen***************************

      fprintf(fid,'Nullstellen: \n\n');
      fprintf(fid,'   Realteil       Imaginärteil         Betrag     Phase    Anz.\n');
      fprintf(fid,'===============================================================\n');
      z=roots(b);               %Nullstellen berechnen
      [mults,idx]=mpoles(z);    %Nullstellen nach
      z_w=z(idx);               %Größe sortiern.

      real_z=real(z_w);  %Realteil
      imag_z=imag(z_w);  %Imaginärteil
      r=abs(z_w);        %Betrag
      phi=(atan2(imag(z_w),real(z_w)))*360/(2*pi);  %Phase

      %****Abfrage nach mehrfach vorkommenenden Nullstellen*********
      for i=1:length(z_w)
        if i==1                  %Abfrage 1.Wert
          zaehler=1;
          if length(z_w)==1
            fprintf(fid,'%13.6f  %13.6f    %13.6f  %10.3f  %3.0f\n',real_z(i),imag_z(i),r(i),phi(i),zaehler);
          end;
        elseif i==length(z_w) & length(z_w)>1    %Abfrage letzter Wert
          if abs(z_w(i)-z_w(i-1))<0.001
            zaehler=zaehler+1;
            fprintf(fid,'%13.6f  %13.6f    %13.6f  %10.3f  %3.0f\n',real_z(i-1),imag_z(i-1),r(i-1),phi(i-1),zaehler);
          else
            fprintf(fid,'%13.6f  %13.6f    %13.6f  %10.3f  %3.0f\n',real_z(i-1),imag_z(i-1),r(i-1),phi(i-1),zaehler);
            zaehler=1;
            fprintf(fid,'%13.6f  %13.6f    %13.6f  %10.3f  %3.0f\n',real_z(i),imag_z(i),r(i),phi(i),zaehler);
          end;
        else
          if abs(z_w(i)-z_w(i-1))<0.001  %toleranz=0.001 !
            zaehler=zaehler+1;
          else
            fprintf(fid,'%13.6f  %13.6f    %13.6f  %10.3f  %3.0f\n',real_z(i-1),imag_z(i-1),r(i-1),phi(i-1),zaehler);
            zaehler=1;     %Zähler zurücksetzen
          end;
        end;
      end;

      fprintf(fid,' \n\n'); %Leerzeilen erzeugen
      fprintf(fid,'Polstellen: \n\n');
      fprintf(fid,'   Realteil       Imaginärteil         Betrag     Phase    Anz.\n');
      fprintf(fid,'===============================================================\n');
      p=roots(a);               %Polstellen berechnen
      if isempty(p),                 %Fall: FIR-Filter!
        p=zeros(size(b,2)-1,1);
      end;
      [mults,idx]=mpoles(p);    %Polstellen nach
      p_w=p(idx);               %Größe sortiern.

      real_p=real(p_w);  %Realteil
      imag_p=imag(p_w);  %Imaginärteil
      r=abs(p_w);        %Betrag
      phi=(atan2(imag(p_w),real(p_w)))*360/(2*pi);  %Phase

      %****Abfrage nach mehrfach vorkommenenden Polstellen*********

      for i=1:length(p_w)
        if i==1                  %Abfrage 1.Wert
          zaehler=1;
          if length(p_w)==1
            fprintf(fid,'%13.6f  %13.6f    %13.6f  %10.3f  %3.0f\n',real_p(i),imag_p(i),r(i),phi(i),zaehler);
          end;
        elseif i==length(p_w) & length(p_w)>1    %Abfrage letzter Wert
          if abs(p_w(i)-p_w(i-1))<0.001
            zaehler=zaehler+1;
            fprintf(fid,'%13.6f  %13.6f    %13.6f  %10.3f  %3.0f\n',real_p(i-1),imag_p(i-1),r(i-1),phi(i-1),zaehler);
          else
            fprintf(fid,'%13.6f  %13.6f    %13.6f  %10.3f  %3.0f\n',real_p(i-1),imag_p(i-1),r(i-1),phi(i-1),zaehler);
            zaehler=1;
            fprintf(fid,'%13.6f  %13.6f    %13.6f  %10.3f  %3.0f\n',real_p(i),imag_p(i),r(i),phi(i),zaehler);
          end;
        else
          if abs(p_w(i)-p_w(i-1))<0.001  %toleranz=0.001 !
            zaehler=zaehler+1;
          else
            fprintf(fid,'%13.6f  %13.6f    %13.6f  %10.3f  %3.0f\n',real_p(i-1),imag_p(i-1),r(i-1),phi(i-1),zaehler);
            zaehler=1;     %Zähler zurücksetzen
          end;
        end;
      end;
      fclose(fid);

      %***************************************************************%
      % Dialogfeld schliessen und nicht mehr nötige Variablen löschen %
      %***************************************************************%

      close(window_methode_fig);
      clear global window_methode_fig ...
      window_tiefpass window_hochpass window_bandpass...
      window_bandsperre window_N_edit window_fg_edit...
      window_fg_text window_fg_frame window_fgo_frame ...
      window_fg_edit_1 window_fg_edit_2 window_fgu_text...
      window_fgo_text window_push_button_ok...
      window_push_button_abbrechen window_pop_up_text...
      window_filename_edit window_push_button_hilfe

      %***********************************************%
      % Aufruf des jeweiligen Moduls mit neuen Werten %
      %***********************************************%
      drawmain(b,a,filename);

    end;
 
  end;     %schließt else-Zweig GANZ_WEIT_UNTEN

end; % strcmp


