function [fontsize,intro]=digf_ini

% Einlesen der Digfil-INI Datei
% fontsize = digf_ini;
%
% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover

fid=fopen('digfilml.ini');
if fid==-1
  disp('digfil.ini not found, setting default values');
  fontsize=8;
else
  gefunden=0;
  while ~feof(fid) & ~gefunden
    str=fgets(fid);
    if ~strcmp(str(1),';')
      gefunden=1;
    end
  end
  eval(str); % -> Parameter FONTSIZE

  gefunden=0;
  while ~feof(fid) & ~gefunden
    str=fgets(fid);
    if ~strcmp(str(1),';')
      gefunden=1;
    end
  end
  eval(str); % -> Parameter INTRO

  fclose(fid);
end




