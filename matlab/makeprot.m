function makeprot(action,hdl,b,a)

% makeprot(action,hdl) erzeugt für
% verschiedene Entwurfsverfahren
% Protokolldateien, die unter
% temp.ptk abgespeichert werden.
%
% action : Entwurfsverfahren
% hdl : z.B. hdl des Objektes mit Daten im UserData-property / ->passbandinfo
%       oder Daten über ARMA-Prozeß
% b,a : Filterkoeffizienten
%
% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover

global filename;
filename='temp\temp_ptk.ptk';

if strcmp(action,'filtmake')
  DATA=get(hdl,'UserData');
  passband=DATA(1);
  if passband<3, offset=0; else, offset=2; end

  freqs=DATA(2:4+offset); freqs=freqs/freqs(1);
  ripples=DATA(5+offset:6+offset);
  filtertyp=DATA(7+offset);
  filterord=DATA(8+offset);

  if passband==1, band='Tiefpaß';
  elseif passband==2, band='Hochpaß';
  elseif passband==3, band='Bandpaß';
  elseif passband==4, band='Bandsperre';
  else, band='FEHLER'; end


%********************************************************************%
%     Erstellen und Speichern der zugehörigen Protokolldatei         %
%********************************************************************%     

  fid=fopen(filename,'wt');
  fprintf(fid,'Protokoll   -Digitale Filter unter MATLAB 4.x-      %s\n\n\n',date);
  fprintf(fid,'Filtertyp: IIR-Filter,%s\r\n\r\n',band);
  if filtertyp==1
     typ='Butterworth';
  elseif filtertyp==2
     typ='Tschebyscheff I';
  elseif filtertyp==3
     typ='Tschebyscheff II';
  elseif filtertyp==4
     typ='Cauer';
  else
     typ='FEHLER';
  end;
  fprintf(fid,'Entwurfsverfahren: %s\n\n',typ);

  fprintf(fid,'Filterordnung N:%3.0f\n\n',filterord);
  if passband < 3
    fprintf(fid,'Band 1: \n');
    fprintf(fid,'\tnormierte untere Bandgrenze: 0.00000\n');
    fprintf(fid,'\tnormierte obere  Bandgrenze: %g\n',freqs(2));
    fprintf(fid,'Band 2: \n');
    fprintf(fid,'\tnormierte untere Bandgrenze: %g\n',freqs(3));
    fprintf(fid,'\tnormierte obere  Bandgrenze: 0.50000\n\n');
  else
    fprintf(fid,'Band 1: \n');
    fprintf(fid,'\tnormierte untere Bandgrenze: 0.00000\n');
    fprintf(fid,'\tnormierte obere  Bandgrenze: %g\n',freqs(2));
    fprintf(fid,'Band 2: \n');
    fprintf(fid,'\tnormierte untere Bandgrenze: %g\n',freqs(3));
    fprintf(fid,'\tnormierte obere  Bandgrenze: %g\n',freqs(4));
    fprintf(fid,'Band 3: \n');
    fprintf(fid,'\tnormierte untere Bandgrenze: %g\n',freqs(5));
    fprintf(fid,'\tnormierte obere  Bandgrenze: 0.50000\n\n');
  end;
  fprintf(fid,'maximale Welligkeit im Durchlaßbereich: %g dB\n',ripples(1));
  fprintf(fid,'maximale Welligkeit im Sperrbereich:    %g dB\n\n',ripples(2));

  fprintf(fid,'berechnete Filterkoeffizienten:\n\n');

elseif strcmp(action,'meteform')
  DATA=get(hdl,'UserData');
  passband=DATA(1);
  if passband<3, offset=0; else, offset=2; end

  freqs=DATA(2:4+offset); freqs=freqs/freqs(1);
  ripples=DATA(5+offset:6+offset);
  filtertyp=DATA(7+offset);
  filterord=DATA(8+offset);


  if passband==1, band='Tiefpaß';
  elseif passband==2, band='Hochpaß';
  elseif passband==3, band='Bandpaß';
  elseif passband==4, band='Bandsperre';
  else, band='FEHLER'; end


%********************************************************************%
%     Erstellen und Speichern der zugehörigen Protokolldatei         %
%********************************************************************%     

  fid=fopen(filename,'wt');
  fprintf(fid,'Protokoll   -Digitale Filter unter MATLAB 4.x-      %s\n\n',date);
  fprintf(fid,'Entwurf durch Lineare Programmierung unter Verwendung\n');
  fprintf(fid,'des Simplex-Algorithmus.\n');
  fprintf(fid,'(Adaption des Programmes METEOR von K.Steiglitz\n');
  fprintf(fid,'IEEE Trans on Signal Proc, Vol.40, No.8, Aug 1992)\n\n');
  fprintf(fid,'Filtertyp: FIR-Filter,%s\r\n\r\n',band);
  if filtertyp==1
     typ='Butterworth - Approximation';
  elseif filtertyp==2
     typ='Tschebyscheff I - Approximation';
  elseif filtertyp==3
     typ='Tschebyscheff II - Approximation';
  elseif filtertyp==4
     typ='Tschebyscheff - Approximation';
  else
     typ='FEHLER';
  end;
  fprintf(fid,'Entwurfsverfahren: %s\n\n',typ);

  fprintf(fid,'Filterordnung N:%3.0f\n\n',filterord);
  if passband < 3
    fprintf(fid,'Band 1: \n');
    fprintf(fid,'\tnormierte untere Bandgrenze: 0.00000\n');
    fprintf(fid,'\tnormierte obere  Bandgrenze: %g\n',freqs(2));
    fprintf(fid,'Band 2: \n');
    fprintf(fid,'\tnormierte untere Bandgrenze: %g\n',freqs(3));
    fprintf(fid,'\tnormierte obere  Bandgrenze: 0.50000\n\n');
  else
    fprintf(fid,'Band 1: \n');
    fprintf(fid,'\tnormierte untere Bandgrenze: 0.00000\n');
    fprintf(fid,'\tnormierte obere  Bandgrenze: %g\n',freqs(2));
    fprintf(fid,'Band 2: \n');
    fprintf(fid,'\tnormierte untere Bandgrenze: %g\n',freqs(3));
    fprintf(fid,'\tnormierte obere  Bandgrenze: %g\n',freqs(4));
    fprintf(fid,'Band 3: \n');
    fprintf(fid,'\tnormierte untere Bandgrenze: %g\n',freqs(5));
    fprintf(fid,'\tnormierte obere  Bandgrenze: 0.50000\n\n');
  end;
  fprintf(fid,'maximale Welligkeit im Durchlaßbereich: %g dB\n',ripples(1));
  fprintf(fid,'maximale Welligkeit im Sperrbereich:    %g dB\n\n',ripples(2));

  fprintf(fid,'berechnete Filterkoeffizienten:\n\n');

elseif strcmp(action,'filtcheb')
  DATA=get(hdl,'UserData');
  passband=DATA(1);
  if passband<3, offset=0; else, offset=2; end

  freqs=DATA(2:4+offset); freqs=freqs/freqs(1);
  ripples=DATA(5+offset:6+offset);
  filtertyp=DATA(7+offset);
  filterord=DATA(8+offset);

  if passband==1, band='Tiefpaß';
  elseif passband==2, band='Hochpaß';
  elseif passband==3, band='Bandpaß';
  elseif passband==4, band='Bandsperre';
  else, band='FEHLER'; end


%********************************************************************%
%     Erstellen und Speichern der zugehörigen Protokolldatei         %
%********************************************************************%     

  fid=fopen(filename,'wt');
  fprintf(fid,'Protokoll   -Digitale Filter unter MATLAB 4.x-      %s\n\n\n',date);
  fprintf(fid,'Filtertyp: FIR-Filter,%s\r\n\r\n',band);
  if filtertyp==1
     typ='Tschebyscheff-Approximation nach Parks-McClellan';
  elseif filtertyp==2
     typ='Fenstermethode mit Kaiserfenster';
  else
     typ='FEHLER';
  end;
  fprintf(fid,'Entwurfsverfahren: %s\n\n',typ);

  fprintf(fid,'Filterordnung N:%3.0f\n\n',filterord);
  if passband < 3
    fprintf(fid,'Band 1: \n');
    fprintf(fid,'\tnormierte untere Bandgrenze: 0.00000\n');
    fprintf(fid,'\tnormierte obere  Bandgrenze: %g\n',freqs(2));
    fprintf(fid,'Band 2: \n');
    fprintf(fid,'\tnormierte untere Bandgrenze: %g\n',freqs(3));
    fprintf(fid,'\tnormierte obere  Bandgrenze: 0.50000\n\n');
  else
    fprintf(fid,'Band 1: \n');
    fprintf(fid,'\tnormierte untere Bandgrenze: 0.00000\n');
    fprintf(fid,'\tnormierte obere  Bandgrenze: %g\n',freqs(2));
    fprintf(fid,'Band 2: \n');
    fprintf(fid,'\tnormierte untere Bandgrenze: %g\n',freqs(3));
    fprintf(fid,'\tnormierte obere  Bandgrenze: %g\n',freqs(4));
    fprintf(fid,'Band 3: \n');
    fprintf(fid,'\tnormierte untere Bandgrenze: %g\n',freqs(5));
    fprintf(fid,'\tnormierte obere  Bandgrenze: 0.50000\n\n');
  end;
  fprintf(fid,'maximale Welligkeit im Durchlaßbereich: %g dB\n',ripples(1));
  fprintf(fid,'maximale Welligkeit im Sperrbereich:    %g dB\n\n',ripples(2));

  fprintf(fid,'berechnete Filterkoeffizienten:\n\n');

elseif strcmp(action,'zmenu')
  fid=fopen(filename,'wt');
  fprintf(fid,'Protokoll   -Digitale Filter unter MATLAB 4.x-      %s\n\n\n',date);
  fprintf(fid,'Entwurfsverfahren: Entwurf im PN-Diagramm\n\n');
  fprintf(fid,'berechnete Filterkoeffizienten:\n\n');

elseif strcmp(action,'mini')
  fid=fopen(filename,'wt');
  fprintf(fid,'Protokoll   -Digitale Filter unter MATLAB 4.x-      %s\n\n\n',date);
  fprintf(fid,'Entwurfsverfahren: Minimum-Phasensystem\n\n');
  fprintf(fid,'berechnete Filterkoeffizienten:\n\n');

elseif strcmp(action,'maxi')
  fid=fopen(filename,'wt');
  fprintf(fid,'Protokoll   -Digitale Filter unter MATLAB 4.x-      %s\n\n\n',date);
  fprintf(fid,'Entwurfsverfahren: Maximum-Phasensystem\n\n');
  fprintf(fid,'berechnete Filterkoeffizienten:\n\n');

elseif strcmp(action,'lin')
  fid=fopen(filename,'wt');
  fprintf(fid,'Protokoll   -Digitale Filter unter MATLAB 4.x-      %s\n\n\n',date);
  fprintf(fid,'Entwurfsverfahren: Rekonstruiertes lineares Phasensystem\n\n');
  fprintf(fid,'berechnete Filterkoeffizienten:\n\n');

elseif strcmp(action,'filtarma')
  fid=fopen(filename,'wt');
  fprintf(fid,'Protokoll   -Digitale Filter unter MATLAB 4.x-      %s\n\n\n',date);
  if hdl==2
    fprintf(fid,['Entwurfsverfahren: Transformation mit ARMA-Modell',...
                 ' nach Prony\n\n']);
  elseif hdl==3
    fprintf(fid,['Entwurfsverfahren: Transformation mit ARMA-Modell',...
                 ' nach Steiglitz-McBride\n\n']);
  elseif hdl==4
    fprintf(fid,['Entwurfsverfahren: Transformation mit ARMA-Modell\n',...
                 ' nach Shanks(MA) und Kovarianzmethode(AR)\n\n']);
  elseif hdl==5
    fprintf(fid,['Entwurfsverfahren: Transformation mit AR-Modell',...
                 ': Autokorrelationsmethode \n\n']);
  elseif hdl==6
    fprintf(fid,['Entwurfsverfahren: Transformation mit AR-Modell',...
                 ': Kovarianzmethode \n\n']);
  elseif hdl==7
    fprintf(fid,['Entwurfsverfahren: Transformation mit MA-Modell',...
                 ' nach Durbin \n\n']);
  end
  fprintf(fid,'berechnete Filterkoeffizienten:\n\n');
end

  for n=[0:length(b)-1]
    fprintf(fid,'b(%3.0f) = %+2.16f\n',n,b(n+1));
  end;
  fprintf(fid,' \n\n'); %Leerzeilen erzeugen

  for n=[0:length(a)-1]
    fprintf(fid,'a(%3.0f) = %+2.16f\n',n,a(n+1));
  end;

  %*** Pol- u. Nullstellen***************************

  fprintf(fid,'\n\nNullstellen: \n\n');
  fprintf(fid,'   Realteil       Imaginärteil         Betrag     Phase    Anz.\n');
  fprintf(fid,'===============================================================\n');
  if length(b)<length(a)
    z=roots([b,zeros(1,length(a)-length(b))]);  %Nullstellen berechnen
  else
    z=roots(b);               %Nullstellen berechnen
  end
  [mults,idx]=mpoles(z);    %Nullstellen nach
  z_w=z(idx);               %Größe sortiern.

  real_z=real(z_w);  %Realteil
  imag_z=imag(z_w);  %Imaginärteil
       r=abs(z_w);   %Betrag
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
       r=abs(p_w);   %Betrag
     phi=(atan2(imag(p_w),real(p_w)))*360/(2*pi);  %Phase

  %****Abfrage nach mehrfach vorkommenenden Polstellen*********

  for i=1:length(p_w)
    if i==1                  %Abfrage 1.Wert
      zaehler=1;
      if length(p_w)==1
         fprintf(fid,'%13.6f  %13.6f    %13.6f  %10.3f  %3.0f\n',real_p(i),imag_p(i),r(i),phi(i),zaehler);
      end
    elseif i==length(p_w) & length(p_w)>1    %Abfrage letzter Wert
      if abs(p_w(i)-p_w(i-1))<0.001
         zaehler=zaehler+1;
         fprintf(fid,'%13.6f  %13.6f    %13.6f  %10.3f  %3.0f\n',real_p(i-1),imag_p(i-1),r(i-1),phi(i-1),zaehler);
      else
         fprintf(fid,'%13.6f  %13.6f    %13.6f  %10.3f  %3.0f\n',real_p(i-1),imag_p(i-1),r(i-1),phi(i-1),zaehler);
         zaehler=1;
         fprintf(fid,'%13.6f  %13.6f    %13.6f  %10.3f  %3.0f\n',real_p(i),imag_p(i),r(i),phi(i),zaehler);
      end
    else
      if abs(p_w(i)-p_w(i-1))<0.001  %toleranz=0.001 !
         zaehler=zaehler+1;
      else
         fprintf(fid,'%13.6f  %13.6f    %13.6f  %10.3f  %3.0f\n',real_p(i-1),imag_p(i-1),r(i-1),phi(i-1),zaehler);
         zaehler=1;     %Zähler zurücksetzen

      end
    end
  end
  
  fclose(fid);

