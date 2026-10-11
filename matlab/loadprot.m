function loadprot(action)
% lade Protokolldatei
% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover
global b a filename

if strcmp(action,'load')
  cd temp
  [fname, pathname]=uigetfile('*.ptk','Koeffizienten einlesen');
  cd ..
  if fname~=0
    fid=fopen([pathname,fname]);
    if fid ~= -1
      filename=[pathname,fname];

      b=[]; a=[];
      gefunden=0;
      while ~feof(fid) & ~gefunden
        str=fgetl(fid);
        if ~isempty(findstr(str,'Filterkoeffizienten'))
          gefunden=1;
        end
      end

      str=fgetl(fid);
      gefunden=0;
      while ~feof(fid) & ~gefunden
        str=fgetl(fid);
        if isempty(findstr(str,'b('))
           gefunden=1;
         else
           str=str(10:length(str)); b=[b,str2num(str)];
         end
      end
      str=fgetl(fid);

      gefunden=0;
      while ~feof(fid) & ~gefunden
        str=fgetl(fid);
        if isempty(findstr(str,'a('))
          gefunden=1;
        else
          str=str(10:length(str)); a=[a,str2num(str)];
        end
      end

      fclose(fid);
    else
      fehler('Fehler beim Laden'); return;
    end
  end
elseif strcmp(action,'save_as')
   cd temp
   [fname, pathname]=uiputfile('*.ptk','Speichern unter');
   cd ..
   if fname~=0
     fid_neu=fopen([pathname,fname],'wt');
     if fid_neu ~= -1
       if isempty(filename)
         fid_alt=-2;
       else
         fid_alt=fopen(filename);
       end
       if fid_alt > -1
         while ~feof(fid_alt);
           str=fgetl(fid_alt);
           if ~feof(fid_alt);
             fprintf(fid_neu,'%s\n',str);
           end
         end
         fclose(fid_alt);
         fclose(fid_neu);
       elseif fid_alt == -1
         fehler('Fehler beim öffnen der aktuellen Datei');
         fclose(fid_neu); eval(['delete ',pathname,fname]);
       else
         fehler('Keine aktuelle Protokolldatei vorhanden !');
         fclose(fid_neu); eval(['delete ',pathname,fname]);
       end
     else
       fehler('Fehler beim Öffnen der neuen Datei');
     end
   end
end
fclose('all');
