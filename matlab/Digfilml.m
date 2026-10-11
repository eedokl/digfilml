%********************************************************************%
% digfilml.m                                                         %
% Modul gehoert zum Progamm: Digitale Filter unter MATLAB 4.x        %
%                            Version 1.5 : Oliver Klein              %
% Betreuer:                  Prof. Dr.-Ing. D. Stark                 %
%                                                                    % 
% Aufgabe:Programm Digitale Filter unter MATLAB 4.x wird gestartet.  %
%         Aufbau des Hauptfensters mit Menueleiste.In diesem Fenster %
%         werden alle grafischen Ausgaben gemacht.                   %
%                                                                    %
%********************************************************************%

%********************************************************************%
%                     Globale Variablen                              %
%                                                                    %
% b,a:          Koeffizizenten der Übertragungsfunktion H(z)         %
% filename:     Dateiname des aktuellen Datensatzes [String]         %
% filtertyp:    Variable gibt an mit welcher Methode die Filter-     %
%               koeffizienten erzeugt wurden (siehe unten)[Integer]  %
%********************************************************************%
global b a filename filtertyp

% zunächst alle Fenster schließen
close all

format long;                     % Zahlenformat

%cd c:\matlab5\user\digfilml;     % Arbeitsverzeichnis
%                                % entsprechendes Verzeichnis muss
%                                % in matlabrc.m ergaenzt werden

% automatisches Suchen des Arbeitsverzeichnisses digfilml

%p=path; ind1=findstr(p,'\digfilml');
%ind1=ind1(1);
%ind2=findstr(p,':');
%ind2=ind1-ind2; ind2=min(ind2(find(ind2>0)));
%p=p(ind1-ind2-1:ind1+8); eval(['cd ',p]);


[fontsize,intro]=digf_ini;

if intro,digintro; end
clear intro;

scr_size=get(0,'ScreenSize');
%if ~isequal(scr_size,[1 1 800 600])
%	taste= fenster('Verwenden Sie die Bildschirmeinstellung 800x600','Info',2,1);
%	return;
%end;
scr_size(3:4)=scr_size(3:4)-2;
figure('Color',[0 0 0],...
       'Name','DIGFILML - Digitale Filter unter MATLAB 5','Units','pixels',...
       'NumberTitle','off','Resize','off',...    
       'Position',scr_size,...      
       'MenuBar','none','Visible','off',...
       'Interruptible','off',...
       'PaperUnits','normalized',...
       'PaperType','a4letter',...
       'PaperOrientation','portrait',...
       'KeyPressFcn','refresh',...
       'Tag','hauptfenster');
    
% Figure-Position Korrektur (MATLAB-BUG ???)
    scr_size=get(gcf,'Position');
    scr_size(4)=600-scr_size(2)+2;
    scr_size(2)=1;
    set(gcf,'Position',scr_size);
    
clear scr_size p ind1 ind2;

filtertyp=0;                            % Initialisierung

%****filtertyp-Schluessel*******************************************
%filtertyp=1:   FIR-Filter; Koeffizienten eingegeben
%filtertyp=2:   FIR-Filter; Koeffizienten mit Window-Methode
%                           berechnet            
%filtertyp=3:   FIR-Filter; Koeffizienten mit Tschebyscheff-Approx.
%                           berechnet                       
%filtertyp=4:   IIR-Filter; Koeffizienten eingegeben           
%filtertyp=5;   IIR-Filter; Yule-Walker Methode
%filtertyp=6;   IIR-Filter; Transformation klassischer Analogfilter
%filtertyp=7;   IIR-Filter; Entwurf in der z-Ebene
%filtertyp=8;   FIR-Filter; METEOR-Programm von Parks/Steiglitz/u.a
%filtertyp=9;   FIR-Filter; Kaiser/Cheby mit Ordnungsschätzung
%filtertyp=10;  IIR-Filter; ARMA-Modell
%filtertyp=11;  FIR-Filter; Raised cosine Approx.
%******************************************************************* 

%ctrlmenu('menue.txt',gcf);              % Menueleiste wird aufgebaut
                                        % Anweisungen hierzu befinden
                                        % sich in der Datei menue.txt
                
menue2                                        
if ~exist('dspini'),set(findobj('Label','E&chtzeit'),'Enable','off'); end

set(gcf,'Visible','on');                % Fenster wird sichtbar !               

