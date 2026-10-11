function  fehler_fig=fehler(textstr1,textstr2,textstr3,textstr4)
%********************************************************************%
% function fehler(textstr1,textstr2,textstr3,textstr4)               %
% Modul gehört zum Progamm: Digitale Filter unter MATLAB 4.2         %
% Bearbeiter:               Clemens Willenbrink / Oliver Klein       %
% Betreuer:                 Prof. Dr.-Ing. D. Stark                  %
%                                                                    %
% Aufgabe: Aufbau eines Fehlerfensters;                              %                                                          
%          Einlesen des entspr. Fehlertextes (textstr1-4);           %                                                        
%                                                                    %              
%                                                                    %
%********************************************************************%

%********************************************************************%
%                      Schaltfläche: OK                              %
%********************************************************************% 


if strcmp(textstr1,'ok')
	close(gcf);
	return
end;

%********************************************************************%
%        Überprüfung ob Fenster schon geöffnet ist                   %
%********************************************************************%

[flag,fig]=figflag('Fehler',0);
           if flag,
              return
           end;

%********************************************************************%
%                Abfrage wieviele Textstrings                        %
%********************************************************************% 


if nargin ==1
   textstr4='';
   textstr3='';
   textstr2='';
elseif nargin == 2
   textstr4='';
   textstr3='';
elseif nargin == 3
   textstr4='';
end;

%********************************************************************%
%                     Aufbau des Fensters                            %
%********************************************************************%

  fehler_fig=figure('Color',[1 1 1],'Position',[124 142 368 163],...
             'Name','Fehler','NumberTitle','off',...
             'Resize','off','MenuBar','none','Visible','off',...
             'KeyPressFcn','refresh',...
             'Interruptible','off');

	uicontrol('Style','text','Position',[10 105 350 20],...
                  'String',textstr2,'BackgroundColor',[1 1 1],...
                  'ForegroundColor',[0 0 0],...
                  'HorizontalAlignment','center');

	uicontrol('Style','text','Position',[10 75 350 20],...
                  'String',textstr3,'BackgroundColor',[1 1 1],...
                  'ForegroundColor',[0 0 0],...
                  'HorizontalAlignment','center');

	uicontrol('Style','text','Position',[10 45 350 20],...
                  'String',textstr4,'BackgroundColor',[1 1 1],...
                  'ForegroundColor',[0 0 0],...
                  'HorizontalAlignment','center');

	fehler_pushbutton=uicontrol('Style','pushbutton',...
                  'Position',[295 10 60 20],'String','OK',...
                  'CallBack','fehler(''ok'')','Interruptible','off');

	uicontrol('Style','text','Position',[10 135 350 20],...
                  'String',textstr1,'BackgroundColor',[1 1 1],...
                  'ForegroundColor',[0 0 0],...
                  'HorizontalAlignment','center');

%********************************************************************%
%                Fenster sichtbar machen                             %
%********************************************************************%
       set(gcf,'visible','on');