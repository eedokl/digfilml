function eingafir(action)
%********************************************************************%
% function eingafir.m                                                %
% Modul gehört zum Progamm: Digitale Filter unter MATLAB 4.x         %
% Bearbeiter:               Clemens Willenbrink & Oliver Klein       %
%								     %
% - Globale Variablen b,a entfernt von Oliver Klein		     %
% - Übertragungsfunktion mit stext dargestellt			     %
%								     %
% Betreuer:                 Prof. Dr.-Ing. D. Stark                  %
%                                                                    %
% Aufgabe: Aufbau eines Dialogfeldes zur Eingabe von FIR-Koeffizien- %
%          ten; Erstellung einer Protokolldatei                      %
%                                                                    %
%********************************************************************%

%********************************************************************%
%                   Globale Variablen                                %
%********************************************************************%

global EINGABE_FIR_FIG EINGAFIR_EDIT_TEXT...
       EINGAFIR_SLIDER b_z pos T hilfsgroesse b a ...
       filtertyp filename fir_filename_edit 

hilfsgroesse=0;			%**wird bei Fehlern auf eins gesetzt

if nargin<1,
   action='init';
   b_z=b;      			%**Kopie der Koeffizienten an b_z
   % if filtertyp <=3 % alle FIR-Filter zulassen
   if length(a)==1 % alle FIR-Filter zulassen
      if length(b_z)<100,
         for n=[length(b_z)+1:100]
             b_z(n)=0;
         end;
      end;
   else b_z=zeros(1,100); %bei IIR-Filtern Null setzen
   end;
end;

%********************************************************************%
%          Überprüfung ob Fenster schon geoeffnet ist                %
%********************************************************************%

if strcmp(action,'init')
  [flag,fig]=figflag('Eingabe der Koeffizienten');
  if flag,
     return
  end;
%********************************************************************%
%                  Aufbau des Eingabefensters                        %
%********************************************************************%

  EINGABE_FIR_FIG=figure('Color',[1 1 1],'Units','pixels','Position',[20 130 600 250],'Name','Eingabe der Koeffizienten','NumberTitle','off','Resize','off','MenuBar','none','Visible','off','Interruptible','off','KeyPressFcn','refresh');
  uicontrol('Style','pushbutton','Units','pixels','Position',[480 75 100 30],'String','OK','CallBack','eingafir(''uebernehmen'')','Interruptible','off');
  uicontrol('Style','pushbutton','Units','pixels','Position',[480 115 100 30],'String','Abbrechen','CallBack','eingafir(''abbruch'')','Interruptible','off');
  uicontrol('Style','pushbutton','Units','pixels','Position',[480 155 100 30],'String','Hilfe','CallBack','eingafir(''hilfe'')','Interruptible','off');
  T(1)=uicontrol('Style','text','Units','pixels','Position',[40 200 40 20],'String','b(0)=','Background',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  T(2)=uicontrol('Style','text','Units','pixels','Position',[40 180 40 20],'String','b(1)=','Background',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  T(3)=uicontrol('Style','text','Units','pixels','Position',[40 160 40 20],'String','b(2)=','Background',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  T(4)=uicontrol('Style','text','Units','pixels','Position',[40 140 40 20],'String','b(3)=','Background',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  T(5)=uicontrol('Style','text','Units','pixels','Position',[40 120 40 20],'String','b(4)=','Background',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  T(6)=uicontrol('Style','text','Units','pixels','Position',[40 100 40 20],'String','b(5)=','Background',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  T(7)=uicontrol('Style','text','Units','pixels','Position',[40 80 40 20],'String','b(6)=','Background',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  T(8)=uicontrol('Style','text','Units','pixels','Position',[40 60 40 20],'String','b(7)=','Background',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  T(9)=uicontrol('Style','text','Units','pixels','Position',[40 40 40 20],'String','b(8)=','Background',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  T(10)=uicontrol('Style','text','Units','pixels','Position',[40 20 40 20],'String','b(9)=','Background',[1 1 1],'Foreground',[0 0 0],'Horiz','center');
  EINGAFIR_EDIT_TEXT(1)=uicontrol('Style','edit','horiz','left','Position',[80 200 110 20],'String',num2str(b_z(1),13),'Background',[1 1 1],'Foreground',[0 0 0],'Max',1,'Interruptible','off');
  EINGAFIR_EDIT_TEXT(2)=uicontrol('Style','edit','horiz','left','Position',[80 180 110 20],'String',num2str(b_z(2),13),'Background',[1 1 1],'Foreground',[0 0 0],'Max',1,'Interruptible','off');
  EINGAFIR_EDIT_TEXT(3)=uicontrol('Style','edit','horiz','left','Position',[80 160 110 20],'String',num2str(b_z(3),13),'Background',[1 1 1],'Foreground',[0 0 0],'Max',1,'Interruptible','off');
  EINGAFIR_EDIT_TEXT(4)=uicontrol('Style','edit','horiz','left','Position',[80 140 110 20],'String',num2str(b_z(4),13),'Background',[1 1 1],'Foreground',[0 0 0],'Max',1,'Interruptible','off');
  EINGAFIR_EDIT_TEXT(5)=uicontrol('Style','edit','horiz','left','Position',[80 120 110 20],'String',num2str(b_z(5),13),'Background',[1 1 1],'Foreground',[0 0 0],'Max',1,'Interruptible','off');
  EINGAFIR_EDIT_TEXT(6)=uicontrol('Style','edit','horiz','left','Position',[80 100 110 20],'String',num2str(b_z(6),13),'Background',[1 1 1],'Foreground',[0 0 0],'Max',1,'Interruptible','off');
  EINGAFIR_EDIT_TEXT(7)=uicontrol('Style','edit','horiz','left','Position',[80 80 110 20],'String',num2str(b_z(7),13),'Background',[1 1 1],'Foreground',[0 0 0],'Max',1,'Interruptible','off');
  EINGAFIR_EDIT_TEXT(8)=uicontrol('Style','edit','horiz','left','Position',[80 60 110 20],'String',num2str(b_z(8),13),'Background',[1 1 1],'Foreground',[0 0 0],'Max',1,'Interruptible','off');
  EINGAFIR_EDIT_TEXT(9)=uicontrol('Style','edit','horiz','left','Position',[80 40 110 20],'String',num2str(b_z(9),13),'Background',[1 1 1],'Foreground',[0 0 0],'Max',1,'Interruptible','off');
  EINGAFIR_EDIT_TEXT(10)=uicontrol('Style','edit','horiz','left','Position',[80 20 110 20],'String',num2str(b_z(10),13),'Background',[1 1 1],'Foreground',[0 0 0],'Max',1,'Interruptible','off');
  EINGAFIR_SLIDER=uicontrol('Style','slider','Units','pixels','Position',[190 18 20 204],'Max',100,'Min',0,'Value',100,'Interruptible','off','Callback','eingafir(''move'')');
  uicontrol('Style','frame','Units','pixels','Position',[39 19 171 203],'Background',[1 1 1],'Foreground',[0 0 0]);
  uicontrol('Style','text','Units','pixels','Position',[39 225 100 20],'String','Koeffizienten:','Background',[1 1 1],'HorizontalAlignment','left');

  fir_filename_text=uicontrol('Style','text',...
    'Units','pixel',... 
    'Position',[243 21 80 17],...
    'String','Protokoll :',...
    'BackgroundColor',[1 1 1],...
    'ForegroundColor',[0 0 0],...
    'HorizontalAlignment','left');

  fir_filename_edit=uicontrol('Style','edit',...
    'Units','pixel',... 
    'Position',[312 20 185 19],...
    'String','temp\temp_ptk.ptk',...
    'BackgroundColor',[1 1 225/255],...
    'ForegroundColor',[0 0 0],...
    'Max',1,'Horiz','left',...
    'Interruptible','off');

  fir_filename_frame=uicontrol('Style','frame',...
    'Units','pixel',... 
    'Position',[240 19 295 22],...
    'BackgroundColor',[1 1 1],...
    'ForegroundColor',[0 0 0]);

%**************************************************************%
%         Aufbau des Hilfetextes                               %
%**************************************************************%


  axes('Position',[0.36 0.10 0.5 1],'xcolor',[0 0 0],'ycolor',[0 0 0]);
  axis off

  text('units','normalized','Position',[0.06 0.8],...
      'string','Systemfkt. eines kausalen FIR-Filters:',...
      'Color',[0 0 0],...
      'Fontsize',11);
 
    text('units','normalized','Position',[0.1 0.6],...
        'string','H(z)= ',...
        'Color',[0 0 0],...
        'Fontsize',13);
    text('units','normalized','Position',[0.1 0.6],...
        'string','_      ',...
        'Color',[0 0 0],...
        'Fontsize',13);
    text('units','normalized','Position',[0.22 0.6],...
        'string','å',...
        'Fontname','symbol',...
        'Color',[0 0 0],...
        'Fontsize',17);
    text('units','normalized','Position',[0.22 0.52],...
        'string','k=0',...
        'Color',[0 0 0],...
        'Fontsize',11);
    text('units','normalized','Position',[0.22 0.66],...
         'string','N',...
         'Color',[0 0 0],...
         'Fontsize',11);
    text('units','normalized','Position',[0.3 0.6],...
         'string','b  z',...
         'Color',[0 0 0],...
         'Fontsize',15   );
    text('units','normalized','Position',[0.32 0.55],...
         'string','k',...
         'Color',[0 0 0],...
         'Fontsize',11);
    text('units','normalized','Position',[0.39 0.64],...
         'string','-k',...
         'Color',[0 0 0],...
         'Fontsize',11);
    text('units','normalized','Position',[0.2 0.30],...
         'string','b + b z + ... +b   z',...
         'Color',[0 0 0],...
         'Fontsize',15);
    text('units','normalized','Position',[0.2 0.25],...
         'string','  0       1                     N',...
         'Color',[0 0 0],...
         'Fontsize',11);
    text('units','normalized','Position',[0.28 0.34],...
         'string','        -1                       -N',...
         'Color',[0 0 0],...
         'Fontsize',11);
    text('units','normalized','Position',[0.17 0.30],...
          'string','=',...
          'Color',[0 0 0],...
          'Fontsize',11);

  set(gcf,'Visible','on');  %***Fenster sichtbar machen!***
 
  pos=1;     %**Initialisierung der Slider Position


  if filtertyp==1
     set(fir_filename_edit,'String',filename);
  end;

%********************************************************************%
%               Bewegen des Sliderknopfes                            %
%********************************************************************%
elseif strcmp(action,'move'),
  for n=[1:10]
    if isempty(str2num(get(EINGAFIR_EDIT_TEXT(n),'String'))),
      fehler('','Hier nur numerische Werte!',...
             'z.B. a(3)=0.062','Fehleingabe wurde gelöscht!');
      set(EINGAFIR_EDIT_TEXT(n),'String','0');
    else
    end;
    b_z(n+pos-1)=str2num(get(EINGAFIR_EDIT_TEXT(n),'String'));
  end;

  pos=get(EINGAFIR_SLIDER,'Value');
  pos=round(pos);
  pos=-(pos-100-1);
  if pos>91
    pos=91;
  end;
  if pos<1
    pos=1;
  end;
  set(EINGAFIR_SLIDER,'Value',-(pos-100-1));
  for n=[1:10]
    set(T(n),'String',['b(' num2str(n+pos-2) ')=']);
    set(EINGAFIR_EDIT_TEXT(n),'String',num2str(b_z(n+pos-1),13));
  end;

%********************************************************************%
%                  Schaltfläche: Übernehmen                          %
%********************************************************************%

elseif strcmp(action,'uebernehmen'),
  for n=[1:10]
    if isempty(str2num(get(EINGAFIR_EDIT_TEXT(n),'String'))),
      fehler('','Hier nur numerische Werte!','z.B. b(0)=0.053',...
             'Fehleingabe wurde gelöscht!');
      set(EINGAFIR_EDIT_TEXT(n),'String','0');
      hilfsgroesse=1;
    end;
    b_z(n+pos-1)=str2num(get(EINGAFIR_EDIT_TEXT(n),'String'));
  end;
  b=b_z;
  q=find(b);
  if isempty(q),
    b=[];
  else
    l=max(q);
    b=b(1:l);
  end;

%***************************************************************%
%         Überprüfung des Dateinamens                           %
%***************************************************************%

  filename=get(fir_filename_edit,'String');

  pos=max(findstr(filename,'\'));
  if ~isempty(pos), fname=filename(pos+1:length(filename));
  else fname=filename; end

  h=length(fname);
  g=abs(fname); k=findstr(fname,'.');
  g= g<45|g>122|(g>45&g<48&g~=46)|(g>57&g<65)|(g>90&g<95)|g==96;

  if h>12| nnz(g)~=0 | h==0 | k>9 | isempty(k) | h-k > 3
                              %Überprüfung ob Dateiname zu lang
                              %Überprüfung auf Sonderzeichen
                              %gültig:Buchstaben,Zahlen,Binde- u.
                              %Unterstrich.
    fehler('','DATEINAMENFORMAT:','max. 8 Zeichen',...
        'erlaubt sind: Buchstaben,Zahlen,Binde- u. Unterstrich');
    hilfsgroesse=1; 	   %Hiermit wird verhindert, daß
                              %das Fenster sich schließt
  end;
%***************************************************************%
%         Speichern des Koeffizientensatzes                     %
%***************************************************************%

  if hilfsgroesse == 0,   %wenn kein Fehler aufgetreten...
    filtertyp=1;         %Erkennungsvariable: Koeffizienten FIR
    a=1;                 %  a(0)=1 !

%**************************************************************%
%    Erstellen u. Speichern der zugehörigen Protokolldatei     %
%**************************************************************%

    %eval(['fid=fopen(' '''' filename '.txt' '''' ',' '''' 'w' '''' ');']);
    fid=fopen(filename,'wt');
    fprintf(fid,'Protokoll   -Digitale Filter unter MATLAB 4.2-      %s\n\n\n',date);
    fprintf(fid,'Filtertyp: FIR-Filter\n\n');
    fprintf(fid,'eingegebene Filterkoeffizienten:\n\n');
    c=1;
    for n=[0:length(b)-1]
      fprintf(fid,'b(%3.0f) = %+2.16f\n',n,b(n+1));
    end;
    fprintf(fid,'\n\na(  0) = 1.0\n\n\n\n'); %Leerzeilen erzeugen
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

   %***Abfrage nach mehrfach vorkommenenden Nullstellen*********

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
    if isempty(p)                 %Fall: FIR-Filter!
      p=zeros(size(b,2)-1,1);
    end;
    [mults,idx]=mpoles(p);    %Polstellen nach
    p_w=p(idx);               %Größe sortiern.

    real_p=real(p_w);  %Realteil
    imag_p=imag(p_w);  %Imaginärteil
    r=abs(p_w);        %Betrag
    phi=(atan2(imag(p_w),real(p_w)))*360/(2*pi);  %Phase

  % ****Abfrage nach mehrfach vorkommenenden Polstellen*********

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

%*****************************************************************%
%   Fenster schliessen u. nicht mehr nötige Variablen löschen     %
%*****************************************************************%

    close(EINGABE_FIR_FIG);
    clear global EINGABE_FIR_FIG NEU_PUSH_TEXT...
    EINGAFIR_EDIT_TEXT EINGAFIR_SLIDER b_z T pos...
    fir_filename_edit

%***************************************************************%
%    Aufruf des jeweiligen Moduls mit neuen Werten              %
%***************************************************************%
    drawmain(b,a,filename);

  end; % hilfsgroesse=0
%************************%
%  Schaltfläche: Abbruch %
%************************%

elseif strcmp(action,'abbruch')
  close(EINGABE_FIR_FIG);
  clear global EINGABE_FIR_FIG ...
  EINGAFIR_EDIT_TEXT EINGAFIR_SLIDER b_z T pos...
  fir_filename_edit

%***************************************************************%
%               Schaltfläche: Hilfe                             %
%***************************************************************%

elseif strcmp(action,'hilfe')
  !winhelp eingafir.hlp &

end;
