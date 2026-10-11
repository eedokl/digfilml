function eingaiir(action)

%********************************************************************%
% function eingaiir.m                                                %
% Modul gehört zum Progamm: Digitale Filter unter MATLAB 4.2         %
% Bearbeiter:               Clemens Willenbrink / Oliver Klein       %
% Betreuer:                 Prof. Dr.-Ing. D. Stark                  %
%                                                                    %
% Aufgabe: Aufbau eines Dialogfeldes zur Eingabe von IIR-Koeffizien- %                                                          
%          ten; Erstellung einer Protokolldatei                      %
%                                                                    %
%********************************************************************%

%********************************************************************%
%                   Globale Variablen                                %
%********************************************************************%
global EINGABE_IIR_FIG EINGAIIR_EDIT_TEXT...
       EINGAIIR_EDIT_TEXT2 EINGAIIR_SLIDER EINGAIIR_SLIDER2...
       b_z a_z pos pos2 TT TT2 b a ...
       hilfsgroesse filtertyp iir_filename_edit filename

hilfsgroesse=0;			%**wird bei Fehlern auf eins gesetzt

%********************************************************************%
%  Einlesen der Koeffizienten a,b in das Fenster falls vorhanden     %
%********************************************************************%

if nargin<1,
  action='init';
  b_z=b;               %**Kopie der Koeffizientensätze an b_z,a_z**
  a_z=a;
%  if filtertyp >=4,     %**Erkennungsvariable: IIR-Filter ***
  if length(a)>1         %**Erkennungsvariable: IIR-Filter ***
    if length(b_z)<100,
      for n=[length(b_z)+1:100]
        b_z(n)=0;
      end;
    end;
    if length(a_z)<100,
      for n=[length(a_z)+1:101]
        a_z(n)=0;
      end;
    end;
  else
    b_z=zeros(1,100);
    a_z=zeros(1,105);
    a_z(1)=1;
  end;
end;

%********************************************************************%
%          Überprüfung ob Fenster schon geoeffnet ist                %
%********************************************************************%

if strcmp(action,'init')
  [flag,fig]=figflag('Eingabe der Koeffizienten /IIR-Filter');
  if flag,
    return
  end;

%**************************************************************%
%            Aufbau des Eingabefensters                        %
%**************************************************************%

  EINGABE_IIR_FIG=figure('Color',[1 1 1],'Position',[20 130 600 250],'Name','Eingabe der Koeffizienten /IIR-Filter','NumberTitle','off','Resize','off','MenuBar','none','Visible','off','Interruptible','off','KeyPressFcn','refresh');
  uicontrol('Style','pushbutton','Position',[480 155 100 30],'String','OK','CallBack','eingaiir(''uebernehmen'')','Interruptible','off');
  uicontrol('Style','pushbutton','Position',[480 195 100 30],'String','Abbrechen','CallBack','eingaiir(''abbruch'')','Interruptible','off');
  uicontrol('Style','pushbutton','Position',[480 75 100 30],'String','Hilfe','CallBack','eingaiir(''hilfe'')','Interruptible','off');
  TT(1)=uicontrol('Style','text','Position',[40 200 40 20],'String','b(0)=','BackgroundColor',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  TT(2)=uicontrol('Style','text','Position',[40 180 40 20],'String','b(1)=','BackgroundColor',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  TT(3)=uicontrol('Style','text','Position',[40 160 40 20],'String','b(2)=','BackgroundColor',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  TT(4)=uicontrol('Style','text','Position',[40 140 40 20],'String','b(3)=','BackgroundColor',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  TT(5)=uicontrol('Style','text','Position',[40 120 40 20],'String','b(4)=','BackgroundColor',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  TT(6)=uicontrol('Style','text','Position',[40 100 40 20],'String','b(5)=','BackgroundColor',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  TT(7)=uicontrol('Style','text','Position',[40 80 40 20],'String','b(6)=','BackgroundColor',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  TT(8)=uicontrol('Style','text','Position',[40 60 40 20],'String','b(7)=','BackgroundColor',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  TT(9)=uicontrol('Style','text','Position',[40 40 40 20],'String','b(8)=','BackgroundColor',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  TT(10)=uicontrol('Style','text','Position',[40 20 40 20],'String','b(9)=','BackgroundColor',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  TT2(1)=uicontrol('Style','text','Position',[241 200 40 20],'String','a(1)=','BackgroundColor',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  TT2(2)=uicontrol('Style','text','Position',[241 180 40 20],'String','a(2)=','BackgroundColor',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  TT2(3)=uicontrol('Style','text','Position',[241 160 40 20],'String','a(3)=','BackgroundColor',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  TT2(4)=uicontrol('Style','text','Position',[241 140 40 20],'String','a(4)=','BackgroundColor',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  TT2(5)=uicontrol('Style','text','Position',[241 120 40 20],'String','a(5)=','BackgroundColor',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  TT2(6)=uicontrol('Style','text','Position',[241 100 40 20],'String','a(6)=','BackgroundColor',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  TT2(7)=uicontrol('Style','text','Position',[241 80 40 20],'String','a(7)=','BackgroundColor',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  TT2(8)=uicontrol('Style','text','Position',[241 60 40 20],'String','a(8)=','BackgroundColor',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  TT2(9)=uicontrol('Style','text','Position',[241 40 40 20],'String','a(9)=','BackgroundColor',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  TT2(10)=uicontrol('Style','text','Position',[241 20 40 20],'String','a(10)=','BackgroundColor',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  EINGAIIR_EDIT_TEXT(1)=uicontrol('Style','edit','Position',[80 200 110 20],'String',num2str(b_z(1),13),'Background',[1 1 1],'Foreground',[0 0 0],'Max',1,'Interruptible','off','horiz','left');
  EINGAIIR_EDIT_TEXT(2)=uicontrol('Style','edit','Position',[80 180 110 20],'String',num2str(b_z(2),13),'Background',[1 1 1],'Foreground',[0 0 0],'Max',1,'Interruptible','off','horiz','left');
  EINGAIIR_EDIT_TEXT(3)=uicontrol('Style','edit','Position',[80 160 110 20],'String',num2str(b_z(3),13),'Background',[1 1 1],'Foreground',[0 0 0],'Max',1,'Interruptible','off','horiz','left');
  EINGAIIR_EDIT_TEXT(4)=uicontrol('Style','edit','Position',[80 140 110 20],'String',num2str(b_z(4),13),'Background',[1 1 1],'Foreground',[0 0 0],'Max',1,'Interruptible','off','horiz','left');
  EINGAIIR_EDIT_TEXT(5)=uicontrol('Style','edit','Position',[80 120 110 20],'String',num2str(b_z(5),13),'Background',[1 1 1],'Foreground',[0 0 0],'Max',1,'Interruptible','off','horiz','left');
  EINGAIIR_EDIT_TEXT(6)=uicontrol('Style','edit','Position',[80 100 110 20],'String',num2str(b_z(6),13),'Background',[1 1 1],'Foreground',[0 0 0],'Max',1,'Interruptible','off','horiz','left');
  EINGAIIR_EDIT_TEXT(7)=uicontrol('Style','edit','Position',[80 80 110 20],'String',num2str(b_z(7),13),'Background',[1 1 1],'Foreground',[0 0 0],'Max',1,'Interruptible','off','horiz','left');
  EINGAIIR_EDIT_TEXT(8)=uicontrol('Style','edit','Position',[80 60 110 20],'String',num2str(b_z(8),13),'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],'Max',1,'Interruptible','off','horiz','left');
  EINGAIIR_EDIT_TEXT(9)=uicontrol('Style','edit','Position',[80 40 110 20],'String',num2str(b_z(9),13),'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],'Max',1,'Interruptible','off','horiz','left');
  EINGAIIR_EDIT_TEXT(10)=uicontrol('Style','edit','Position',[80 20 110 20],'String',num2str(b_z(10),13),'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],'Max',1,'Interruptible','off','horiz','left');
  EINGAIIR_EDIT_TEXT2(1)=uicontrol('Style','edit','Position',[281 200 110 20],'String',num2str(a_z(2),13),'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],'Max',1,'Interruptible','off','horiz','left');
  EINGAIIR_EDIT_TEXT2(2)=uicontrol('Style','edit','Position',[281 180 110 20],'String',num2str(a_z(3),13),'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],'Max',1,'Interruptible','off','horiz','left');
  EINGAIIR_EDIT_TEXT2(3)=uicontrol('Style','edit','Position',[281 160 110 20],'String',num2str(a_z(4),13),'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],'Max',1,'Interruptible','off','horiz','left');
  EINGAIIR_EDIT_TEXT2(4)=uicontrol('Style','edit','Position',[281 140 110 20],'String',num2str(a_z(5),13),'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],'Max',1,'Interruptible','off','horiz','left');
  EINGAIIR_EDIT_TEXT2(5)=uicontrol('Style','edit','Position',[281 120 110 20],'String',num2str(a_z(6),13),'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],'Max',1,'Interruptible','off','horiz','left');
  EINGAIIR_EDIT_TEXT2(6)=uicontrol('Style','edit','Position',[281 100 110 20],'String',num2str(a_z(7),13),'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],'Max',1,'Interruptible','off','horiz','left');
  EINGAIIR_EDIT_TEXT2(7)=uicontrol('Style','edit','Position',[281 80 110 20],'String',num2str(a_z(8),13),'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],'Max',1,'Interruptible','off','horiz','left');
  EINGAIIR_EDIT_TEXT2(8)=uicontrol('Style','edit','Position',[281 60 110 20],'String',num2str(a_z(9),13),'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],'Max',1,'Interruptible','off','horiz','left');
  EINGAIIR_EDIT_TEXT2(9)=uicontrol('Style','edit','Position',[281 40 110 20],'String',num2str(a_z(10),13),'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],'Max',1,'Interruptible','off','horiz','left');
  EINGAIIR_EDIT_TEXT2(10)=uicontrol('Style','edit','Position',[281 20 110 20],'String',num2str(a_z(11),13),'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],'Max',1,'Interruptible','off','horiz','left');
  EINGAIIR_SLIDER=uicontrol('Style','slider','Position',[190 18 20 204],'Max',100,'Min',0,'Value',100,'Interruptible','off','Callback','eingaiir(''move1'')');
  uicontrol('Style','frame','Position',[39 19 171 203],'Background',[1 1 1],'Foreground',[0 0 0]);
  uicontrol('Style','text','Position',[39 225 100 20],'String','Koeffizienten:','Background',[1 1 1],'Horiz','left');
  EINGAIIR_SLIDER2=uicontrol('Style','slider','Position',[391 18 20 204],'Max',100,'Min',0,'Value',100,'Interruptible','off','Callback','eingaiir(''move2'')');
  uicontrol('Style','frame','Position',[240 19 171 203],'Background',[1 1 1],'Foreground',[0 0 0]);
  uicontrol('Style','text','Position',[240 225 100 20],'String','Koeffizienten:','Background',[1 1 1],'Horiz','left');

  uicontrol('Style','frame',...
         'Position',[420 19 169 30],...
         'BackgroundColor',[1 1 1],...
         'ForegroundColor',[0 0 0]);

  uicontrol('Style','text',...
  	'Position',[424 22 80 20],...
  	'String','Protokoll:',...
  	'BackgroundColor',[1 1 1],...
  	'ForegroundColor',[0 0 0],...
  	'HorizontalAlignment','left');

  iir_filename_edit=uicontrol('Style','edit',...
	'Position',[480 23 100 19],...
	'String','temp\temp_ptk.ptk',...
	'BackgroundColor',[1 1 225/255],...
	'ForegroundColor',[0 0 0],...
	'Max',1,'horiz','left',...
	'Interruptible','off');

  set(gcf,'Visible','on');     %***Fenster sichtbar machen!***
 
  pos=1;                       %**Initialisierung der Hilfsvariablen
  pos2=1;                      %**pos u. pos2
  if filtertyp==4
     set(iir_filename_edit,'String',filename);
  end;

%********************************************************************%
%               Bewegen des Sliderknopfes 1                          %
%********************************************************************%

elseif strcmp(action,'move1'), 
  for n=[1:10]
    if isempty(str2num(get(EINGAIIR_EDIT_TEXT(n),'String'))),
      fehler('','Hier nur numerische Werte!',...
             'z.B. b(0)=0.062','Fehleingabe wurde gelöscht!');
      set(EINGAIIR_EDIT_TEXT(n),'String','0');
    end;
    b_z(n+pos-1)=str2num(get(EINGAIIR_EDIT_TEXT(n),'String'));
  end;

  pos=get(EINGAIIR_SLIDER,'Value');
  pos=round(pos);
  pos=-(pos-100-1);
  if pos>91
    pos=91;
  end;
  if pos<1
    pos=1;
  end;
  set(EINGAIIR_SLIDER,'Value',-(pos-100-1));
  for n=[1:10]
    set(TT(n),'String',['b(' num2str(n+pos-2) ')=']);
    set(EINGAIIR_EDIT_TEXT(n),'String',num2str(b_z(n+pos-1),13));
  end;

%***************************************************************%
%          Bewegen des Sliderknopfes 2                          %
%***************************************************************%

elseif strcmp(action,'move2'), 
  for n=[1:10]
    if isempty(str2num(get(EINGAIIR_EDIT_TEXT2(n),'String'))),
      fehler('','Hier nur numerische Werte!',...
             'z.B. a(3)=0.062','Fehleingabe wurde gelöscht!');
      set(EINGAIIR_EDIT_TEXT2(n),'String','0');
    else
    end;
    a_z(n+pos2)=str2num(get(EINGAIIR_EDIT_TEXT2(n),'String'));
  end;

  pos2=get(EINGAIIR_SLIDER2,'Value');
  pos2=round(pos2);
  pos2=-(pos2-100-1);
  if pos2>91
    pos2=91;
  end;
  if pos2<1
    pos2=1;
  end;
  set(EINGAIIR_SLIDER2,'Value',-(pos2-100-1));
  for n=[1:10]
    set(TT2(n),'String',['a(' num2str(n+pos2-1) ')=']);
    set(EINGAIIR_EDIT_TEXT2(n),'String',num2str(a_z(n+pos2),13));
  end;

%***************************************************************%
%             Schaltfläche: Übernehmen                          %
%***************************************************************%
elseif strcmp(action,'uebernehmen'),

  %*************Übernahme der b_Koeffizienten*************************

  for n=[1:10]
    if isempty(str2num(get(EINGAIIR_EDIT_TEXT(n),'String'))),
       fehler('','Hier nur numerische Werte!',...
              'z.B. a(3)=0.062','Fehleingabe wurde gelöscht!');
       set(EINGAIIR_EDIT_TEXT(n),'String','0');
       hilfsgroesse=1;
    end;
    b_z(n+pos-1)=str2num(get(EINGAIIR_EDIT_TEXT(n),'String'));
  end;
  b=b_z;
  q=find(b);
  if isempty(q),
    b=[];
  else
    l=max(q);
    b=b(1:l);
  end;

%**************Übernahme der a_Koeffizienten*********

  for n=[1:10]
    if isempty(str2num(get(EINGAIIR_EDIT_TEXT2(n),'String'))),
      fehler('','Hier nur numerische Werte!',...
             'z.B. a(3)=0.062','Fehleingabe wurde gelöscht!');
      set(EINGAIIR_EDIT_TEXT2(n),'String','0');
      hilfsgroesse=1;
    end;
    a_z(n+pos2)=str2num(get(EINGAIIR_EDIT_TEXT2(n),'String'));
  end;
  a=a_z;
  q=find(a);
  l=max(q);
  a=a(1:l);

  if length(a)<2
    fehler('','Keine a-Koeffizienten eingegeben !');
    hilfsgroesse=1;
  end;

%***************************************************************%
%         Überprüfung des Dateinamens                           %
%***************************************************************%

  filename=get(iir_filename_edit,'String');

  pos=max(findstr(filename,'\'));
  if ~isempty(pos), fname=filename(pos+1:length(filename));
  else fname=filename; end

  h=length(fname);
  g=abs(fname); k=findstr(fname,'.');
  g= g<45|g>122|(g>45&g<48&g~=46)|(g>57&g<65)|(g>90&g<95)|g==96;

  if h>12| nnz(g)~=0 | h==0| k>9 | isempty(k) | h-k > 3
                             %Überprüfung ob Dateiname zu lang
                             %Überprüfung auf Sonderzeichen
                             %gültig:Buchstaben,Zahlen,Binde- u.
                             %Unterstrich
    fehler('','DATEINAMENFORMAT:','max. 8 Zeichen',...
           'erlaubt sind: Buchstaben,Zahlen,Binde- u. Unterstrich');
    hilfsgroesse=1; %**Hiermit wird verhindert das das Fenster sich schließt**
  end;

%***************************************************************%
%         Speichern des Koeffizientensatzes                     %
%***************************************************************%

  if hilfsgroesse == 0,   %wenn kein Fehler aufgetreten...
    filtertyp=4;         %Erkennungsvariable: Koeffizienten IIR

%**************************************************************%
%    Erstellen u. Speichern der zugehörigen Protokolldatei     %
%**************************************************************%

    fid=fopen(filename,'wt');
    fprintf(fid,'Protokoll   -Digitale Filter unter MATLAB 4.x-      %s\n\n\n',date);
    fprintf(fid,'Filtertyp: IIR-Filter\n\n');
    fprintf(fid,'eingegebene Filterkoeffizienten:\n\n');

    for n=[0:length(b)-1]
      fprintf(fid,'b(%3.0f) = %+2.16f\n',n,b(n+1));
    end;

    fprintf(fid,' \n\n'); %Leerzeilen erzeugen

    for n=[0:length(a)-1]
      fprintf(fid,'a(%3.0f) = %+2.16f\n',n,a(n+1));
    end;

    fprintf(fid,' \n\n\n'); %Leerzeilen erzeugen

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
    p=roots(a);           %Polstellen berechnen
    if isempty(p),                 %Fall: FIR-Filter!
    p=zeros(size(b,2)-1,1);
    end;
    [mults,idx]=mpoles(p);   %Polstellen nach
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

%*******************************************************************%
%     Fenster schliessen u. nicht mehr nötige Variablen löschen     %
%*******************************************************************%
    close(EINGABE_IIR_FIG);
    clear global EINGABE_IIR_FIG EINGAIIR_EDIT_TEXT...
                 EINGAIIR_EDIT_TEXT2 EINGAIIR_SLIDER EINGAIIR_SLIDER2...
                 b_z a_z pos pos2 TT TT2...
                 hilfsgroesse  iir_filename_edit

%*******************************************************************%
%        Aufruf des jeweiligen Moduls mit neuen Werten              %
%*******************************************************************%
    drawmain(b,a,filename);

  end;

%*******************************************************************%
%            Schaltfläche: Abbruch                                  %
%*******************************************************************%

elseif strcmp(action,'abbruch')
  close(EINGABE_IIR_FIG);
  clear global EINGABE_IIR_FIG EINGAIIR_EDIT_TEXT...
               EINGAIIR_EDIT_TEXT2 EINGAIIR_SLIDER EINGAIIR_SLIDER2...
               b_z a_z pos pos2 TT TT2...
               hilfsgroesse  iir_filename_edit
 
%********************************************************************%
%                    Schaltfläche: Hilfe                             %
%********************************************************************%

elseif strcmp(action,'hilfe')
  !winhelp eingaiir.hlp &

end;