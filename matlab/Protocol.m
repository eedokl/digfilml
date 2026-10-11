function protocol
%********************************************************************%
% function protocol.m                                                %
% Modul gehört zum Progamm: Digitale Filter unter MATLAB 4.x         %
% Bearbeiter:               Oliver Klein                             %
% Betreuer:                 Prof. Dr.-Ing. D. Stark                  %
%                                                                    %
% Aufgabe: aktuelle Protokolldatei (Textdatei mit allen Filterdaten) %                                                          
%          wird zur Ansicht in ein Editorfenster geladen.            %                                                        
%          Aufruf erfogt durch den Menüpunkt Aktuelle Protokoll-     %              
%          datei im Menü Datei.                                      %
%********************************************************************%
global filename

if ~isempty(filename)
  fid=fopen(filename,'rt');
  if fid ~= -1
     eval(['!notepad ',filename]);
     % FILENAME will never be closed (in MATLAB)
     % so use close all to correct it
     % This is quick & dirty, because other files can be affected
     fclose('all');
  else
    fehler('','','Protokolldatei nicht gefunden!');
  end;
else
  fehler('','','Keine aktuelle Protokolldatei vorhanden !');
end