function str=autotit;
%********************************************************************%
% function autotit.m                                                 %
% Modul gehört zum Progamm: Digitale Filter unter MATLAB 4.x         %
% Bearbeiter:               Oliver Klein                             %
% Betreuer:                 Prof. Dr.-Ing. D. Stark                  %
%                                                                    %
% Aufgabe: aktuelle Protokolldatei (Textdatei mit allen Filterdaten) %                                                          
%          wird geladen um Daten zu entnehmen.                       %                                                        
%********************************************************************%
global filename b a

if ~isempty(filename)
  fid=fopen(filename,'rt');
  if fid ~= -1
      str=[];
      gefunden=0;
      while ~feof(fid)
        dummy=fgetl(fid);
        if ~isempty(findstr(dummy,'Filtertyp')) | ...
           ~isempty(findstr(dummy,'Entwurfsverfahren')) 
           if findstr(dummy,'Filtertyp')
             dummy=dummy(11:length(dummy));         
           elseif findstr(dummy,'Entwurfsverfahren')
             dummy=dummy(19:length(dummy));         
           end          
           str=[str,dummy,';'];
        end
      end       
      N=max(length(a),length(b))-1;
      str=[str,'N=',num2str(N)];
      fclose(fid); 
  else
    str='Protokolldatei nicht gefunden!';
  end;
else
  str='Keine aktuelle Protokolldatei vorhanden !';
end
