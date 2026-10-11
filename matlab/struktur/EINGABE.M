function eingabe(command_str)
% EINGABE
%
% Die Funktion überprüft die Eingaben in Editierfelder auf 
% Richtigkeit. Sie wird nur innerhalb eines Callback der jeweiligen
% Editierfelder ausgeführt.
%
% ------------------- Funktions Header --------------------------------------
% Autor:               Jörg Rose / Roman Ußkurat
% Erstellungsdatum:    7-10/97
% Version:             MATLAB Version 5 / Student Edition
% 
% Betreuer: Prof. Dr.-Ing. Stark
%
if nargin ==0
	error('Kein Prüfmerkmal des Editierfeldes');
end;

% ------ Festkommaquantisierung: Einheitsimpulseditierfeld -------------
if strcmp(command_str,'Einheitsimpuls')	% Eingabefeld Einheitsimpuls
	h_obj=findobj('tag','festkomma','userdata',1);	% Handle auf Editierfeld
	wert_str=get(h_obj,'string');		% Wert lesen
   wert = str2num(wert_str);		% in Zahl umwandeln
   h_vorgabewerte= findobj('tag','arithmetik');	% Handle auf popup-Menü Arithmetik
	vorgabewerte= get(h_vorgabewerte,'userdata');	% Vorgabewerte lesen
   if isempty(wert)
      wert=vorgabewerte(1);
   end;
   wert=wert(1,1);
	wert = abs(real(wert));			% in positive reelle Zahl wandeln
	if wert>1				% Einheitsimpuls maximal 1
		wert=1;
   end;
   if wert == 0
      wert=1;
   end;
   	vorgabewerte(1)=wert;		% neuen Wert merken
		set (h_vorgabewerte,'userdata',vorgabewerte);	% in UserData zurückschreiben
		set (h_obj,'string',num2str(wert));	% gültige Wert in Editierfeld zurückschreiben
end;
% ------ Festkommaquantisierung: Einheitsimpulseditierfeld_Filtersysteme -------------
if strcmp(command_str,'Einheitsimpuls_Filtsys')	% Eingabefeld Einheitsimpuls
	h_obj=findobj('tag','filtsys','userdata','einheits');	% Handle auf Editierfeld
   wert_str=get(h_obj,'string');		% Wert lesen
   wert = str2num(wert_str);		% in Zahl umwandeln
   
   if isempty(wert)
      wert=1;
   end;
   wert=wert(1,1);
	wert = abs(real(wert));			% in positive reelle Zahl wandeln
	if wert>1				% Einheitsimpuls maximal 1
		wert=1;
   end;
      if wert == 0
      wert=1;
   end;
  	set (h_obj,'string',num2str(wert));	% gültige Wert in Editierfeld zurückschreiben
end;
% ------ Festkommaquantisierung: Editierfeld für Anzahl der Bits im Rechenwerk -------------
if strcmp(command_str,'BitALU')	% Eingabefeld Anzahl Bits in Rechenwerk
	h_obj=findobj('tag','festkomma','userdata',2);	% Handle auf Editierfeld
	wert_str=get(h_obj,'string');		% Wert lesen
   wert = str2num(wert_str);		% in Zahl umwandeln
   h_vorgabewerte= findobj('tag','arithmetik');	% Handle auf popup-Menü Arithmetik
	vorgabewerte= get(h_vorgabewerte,'userdata');	% Vorgabewerte lesen
   if isempty(wert)
      wert = vorgabewert(2);
   end;
   wert=wert(1,1);
	wert = ceil(abs(real(wert)));		% in ganze positive reelle Zahl wandeln
	if (wert > 53)				% Begrenzung
		wert = 53;
	end;
	if (wert < 2)				% Begrenzung, 1 Vorzeichen-, ein Werte-Bit
		wert = 2;
	end;
		vorgabewerte(2)=wert;		% neuen Wert merken
		set (h_vorgabewerte,'userdata',vorgabewerte);	% in UserData zurückschreiben
		set (h_obj,'string',num2str(wert));	% gültige Wert in Editierfeld zurückschreiben
end;
% ------ Festkommaquantisierung: Editierfeld für Anzahl der Bits im Speicher -------------
if strcmp(command_str,'BitSpeicher')	% Eingabefeld Anzahl Bits im Speicher
	h_obj=findobj('tag','festkomma','userdata',5);	% Handle auf Editierfeld
	wert_str=get(h_obj,'string');		% Wert lesen
   wert = str2num(wert_str);		% in Zahl umwandeln
   h_vorgabewerte= findobj('tag','arithmetik');	% Handle auf popup-Menü Arithmetik
	vorgabewerte= get(h_vorgabewerte,'userdata');	% Vorgabewerte lesen
   if isempty(wert)
      wert = vorgabewert(3);
   end;
   wert=wert(1,1);
	wert = ceil(abs(real(wert)));		% in ganze positive reelle Zahl wandeln
	if (wert > 53)				% Begrenzung
		wert = 53;
	end;
	if (wert < 2)				% Begrenzung, 1 Vorzeichen-, ein Werte-Bit
		wert = 2;
	end;
   	vorgabewerte(3)=wert;		% neuen Wert merken
		set (h_vorgabewerte,'userdata',vorgabewerte);	% in UserData zurückschreiben
		set (h_obj,'string',num2str(wert));	% gültige Wert in Editierfeld zurückschreiben
end;
% ------ Gleitkommaquantisierung: Editierfeld für Anzahl der Mantisse-Bits im Rechenwerk -------------
if strcmp(command_str,'MantisseALU')	% Eingabefeld Anzahl Bits 
	h_obj=findobj('tag','gleitkomma','userdata',1);	% Handle auf Editierfeld
	wert_str=get(h_obj,'string');		% Wert lesen
   wert = str2num(wert_str);		% in Zahl umwandeln
   h_vorgabewerte= findobj('tag','arithmetik');	% Handle auf popup-Menü Arithmetik
	vorgabewerte= get(h_vorgabewerte,'userdata');	% Vorgabewerte lesen
   if isempty(wert)
      wert = vorgabewerte(4);
   end;
   wert=wert(1,1);
	wert = ceil(abs(real(wert)));		% in ganze positive reelle Zahl wandeln
	if (wert > 53)				% Begrenzung
		wert = 53;
	end;
	if (wert < 2)				% Begrenzung, 1 Vorzeichen-, ein Werte-Bit
		wert = 2;
	end;
		vorgabewerte(4)=wert;		% neuen Wert merken
		set (h_vorgabewerte,'userdata',vorgabewerte);	% in UserData zurückschreiben
		set (h_obj,'string',num2str(wert));	% gültige Wert in Editierfeld zurückschreiben
end;
% ------ Gleitkommaquantisierung: Editierfeld für Anzahl der Mantisse-Bits im Speicher -------------
if strcmp(command_str,'MantisseSpeicher')	% Eingabefeld Anzahl Bits 
	h_obj=findobj('tag','gleitkomma','userdata',3);	% Handle auf Editierfeld
	wert_str=get(h_obj,'string');		% Wert lesen
   wert = str2num(wert_str);		% in Zahl umwandeln
   h_vorgabewerte= findobj('tag','arithmetik');	% Handle auf popup-Menü Arithmetik
	vorgabewerte= get(h_vorgabewerte,'userdata');	% Vorgabewerte lesen
   if isempty(wert)
		wert = vorgabewerte(5);		% wert ist ungültig
   end;
   wert=wert(1,1);
	wert = ceil(abs(real(wert)));		% in ganze positive reelle Zahl wandeln
	if (wert > 53)				% Begrenzung
		wert = 53;
	end;
	if (wert < 2)				% Begrenzung, 1 Vorzeichen-, ein Werte-Bit
		wert = 2;
	end;
		vorgabewerte(5)=wert;		% neuen Wert merken
		set (h_vorgabewerte,'userdata',vorgabewerte);	% in UserData zurückschreiben
		set (h_obj,'string',num2str(wert));	% gültige Wert in Editierfeld zurückschreiben
end;
% ------ Gleitkommaquantisierung: Editierfeld für Anzahl der Exponent-Bits im Rechenwerk -------------
if strcmp(command_str,'ExponentALU')	% Eingabefeld Anzahl Bits des Exponenten
	h_obj=findobj('tag','gleitkomma','userdata',2);	% Handle auf Editierfeld
	wert_str=get(h_obj,'string');		% Wert lesen
   wert = str2num(wert_str);		% in Zahl umwandeln
   h_vorgabewerte= findobj('tag','arithmetik');	% Handle auf popup-Menü Arithmetik
	vorgabewerte= get(h_vorgabewerte,'userdata');	% Vorgabewerte lesen
   if isempty(wert)
		wert = vorgabewerte(6);		% wert ist ungültig
   end;
   wert=wert(1,1);
	wert = ceil(abs(real(wert)));		% in ganze positive reelle Zahl wandeln
	if (wert > 8)				% Begrenzung
		wert = 8;
	end;
	if (wert < 2)				% Begrenzung, 1 Vorzeichen-, ein Werte-Bit
		wert = 2;
	end;
		vorgabewerte(6)=wert;		% neuen Wert merken
		set (h_vorgabewerte,'userdata',vorgabewerte);	% in UserData zurückschreiben
		set (h_obj,'string',num2str(wert));	% gültige Wert in Editierfeld zurückschreiben
end;
% ------ Gleitkommaquantisierung: Editierfeld für Anzahl der Exponent-Bits im Speicher -------------
if strcmp(command_str,'ExponentSpeicher')	% Eingabefeld Anzahl Bits des Exponenten 
	h_obj=findobj('tag','gleitkomma','userdata',4);	% Handle auf Editierfeld
	wert_str=get(h_obj,'string');		% Wert lesen
   wert = str2num(wert_str);		% in Zahl umwandeln
   h_vorgabewerte= findobj('tag','arithmetik');	% Handle auf popup-Menü Arithmetik
	vorgabewerte= get(h_vorgabewerte,'userdata');	% Vorgabewerte lesen
   if isempty(wert)
		wert = vorgabewerte(7);		% wert ist ungültig
   end
   wert=wert(1,1);
  	wert = ceil(abs(real(wert)));		% in ganze positive reelle Zahl wandeln
	if (wert > 8)				% Begrenzung
		wert = 8;
	end;
	if (wert < 2)				% Begrenzung, 1 Vorzeichen-, ein Werte-Bit
		wert = 2;
	end;
		vorgabewerte(7)=wert;		% neuen Wert merken
		set (h_vorgabewerte,'userdata',vorgabewerte);	% in UserData zurückschreiben
		set (h_obj,'string',num2str(wert));	% gültige Wert in Editierfeld zurückschreiben
end;


% ------ Quantisierung Funktionsgenerator ----------------------------------
if strcmp(command_str,'quant')      % Eingabefeld Anzahl Bits fuer Quantisierung 
  h_edit_bit = findobj...            % Finde Editierobjekt 'generat_quant'
      ('tag','generat_quant',...
       'style','edit');
  h_sys_filterung = findobj...      % Finde Pushbutton 'filterung'
    ('tag','filterung');
  sys_data = get...                 % Lies Systemdaten aus userdata
    (h_sys_filterung,'userdata');
  bit_old = sys_data(2,18);           % Alte Anzahl Bits
  bit = str2num(get(h_edit_bit,'string'));
  if isempty(bit) % Z.B.: Buchstabe
    bit = bit_old;
  end
  bit = bit(1,1);
  if (bit < 1)|(bit >53)
    bit = bit_old;
  end
  set (h_edit_bit,'string',num2str(bit));
end


% ------ Frequenz Sinus Funktionsgenerator ----------------------------------
if strcmp(command_str,'frequenz')       % Eingabefeld Frequenz der Sinusfunktion 
  h_edit_ny = findobj...            % Finde Editierobjekt 'frequenz'
      ('tag','frequenz',...
       'style','edit');
  h_sys_filterung = findobj...      % Finde Pushbutton 'filterung'
    ('tag','filterung');
  sys_data = get...                 % Lies Systemdaten aus userdata
    (h_sys_filterung,'userdata');
  ny_old = sys_data(2,4);           % Alte normierte Frequenz
  ny = str2num(get(h_edit_ny,'string'));
  if isempty(ny) % Z.B.: Buchstabe
    ny = ny_old;
  end
  ny = ny(1,1);
  if (ny < 0)|(ny >= 0.5)
    ny = ny_old;
  end
  set (h_edit_ny,'string',num2str(ny,12));
end


% ------ Frequenzschrittweite Sinus Funktionsgenerator ----------------------------------
if strcmp(command_str,'step_freq')  % Eingabefeld Frequenzschrittweite der Sinusfunktion 
  h_edit_step = findobj...          % Finde Editierobjekt 'frequenz_step'
      ('tag','frequenz_step',...
       'style','edit');
  step_old = get(h_edit_step,'userdata');% Schrittweite aus userdata
  step = str2num(get(h_edit_step,'string'));
  if isempty(step)
    step = step_old;
  end
  step = step(1,1); 
  if (step > 0.5)|(step < 0.0001)
    step = step_old;
  end
  set(h_edit_step,...               % Ausgabe der Schrittweite
    'string',step,...
    'userdata',step);               % Sichern der Schrittweite
end  % Ende von step_freq


% ------ Phase Sinus Funktionsgenerator ----------------------------------
if strcmp(command_str,'phase')      % Eingabefeld Phase der Sinusfunktion 
  h_edit_phase = findobj...         % Finde Editierobjekt 'phase'
      ('tag','phase',...
       'style','edit');
  h_sys_filterung = findobj...      % Finde Pushbutton 'filterung'
    ('tag','filterung');
  sys_data = get...                 % Lies Systemdaten aus userdata
    (h_sys_filterung,'userdata');
  phase_old = sys_data(2,5);        % Alter Phasenwert
  phase = str2num(get(h_edit_phase,'string'));
  if isempty(phase)
    phase = phase_old;
  end
  phase = phase(1,1);
  if (phase < -360)|(phase > 360)
    phase = phase_old;
 end
   set(h_edit_phase,'string',num2str(phase,10));
end


% ------ Phasenschrittweite Sinus Funktionsgenerator ----------------------------------
if strcmp(command_str,'step_phase')  % Eingabefeld Phasenzschrittweite der Sinusfunktion 
  h_edit_step = findobj...          % Finde Editierobjekt 'phase_step'
      ('tag','phase_step',...
       'style','edit');
  step_old = get(h_edit_step,'userdata');% Schrittweite aus userdata
  step = str2num(get(h_edit_step,'string'));
  if isempty(step)
    step = step_old;
  end
  step = step(1,1);
  if (step < -180)|(step > 180)
    step = step_old;
  end
  set(h_edit_step,...               % Ausgabe der Schrittweite
    'string',step);
end


% ------ Tastverhaeltnis Rechteck Funktionsgenerator ----------------------------------
if strcmp(command_str,'tast_recht')  % Eingabefeld Phasenzschrittweite der Sinusfunktion 
  tast_max = 1;
  tast_min = 0;
  h_edit_tast = findobj...          % Finde Editierobjekt 'rechteck_tast'
      ('tag','rechteck_tast',...
       'style','edit');
  h_sys_filterung = findobj...      % Finde Pushbutton 'filterung'
    ('tag','filterung');
  sys_data = get...                 % Lies Systemdaten aus userdata
    (h_sys_filterung,'userdata');
  tast_old = sys_data(2,15);           % Altes Tastverhältnis
  tast_new = str2num(get(h_edit_tast,'string')); % Neues Tastverhältnis aus Editierobjekt
  if isempty(tast_new)
    tast_new = tast_old;
  end
  tast_new = tast_new(1,1);
  if (tast_new < tast_min)|(tast_new > tast_max)
    tast_new = tast_old;
  end
  set(h_edit_tast,'string',tast_new);
end   % Ende von tast_recht


% ------ Perioden Rechteck Funktionsgenerator ----------------------------------
if strcmp(command_str,'periode_recht')  % Eingabefeld Phasenzschrittweite der Sinusfunktion 
  h_edit_periode = findobj...          % Finde Editierobjekt 'rechteck_periode'
      ('tag','rechteck_periode',...
       'style','edit');
  h_sys_filterung = findobj...      % Finde Pushbutton 'filterung'
    ('tag','filterung');
  sys_data = get...                 % Lies Systemdaten aus userdata
    (h_sys_filterung,'userdata');
  fft_laenge = sys_data(2,1);
  periode_min = 1;
  periode_max = round(fft_laenge/2);
  periode_old = sys_data(2,16);           % Alte Periodenanzahl
  periode_new = str2num(get(h_edit_periode,'string')); % Neue Periodenanzahl aus Editierobjekt
  if isempty(periode_new)
    periode_new = periode_old;
  end
  periode_new = periode_new(1,1);
  if (periode_new < periode_min)|(periode_new > periode_max)
    periode_new = periode_old;
  end
  set(h_edit_periode,'string',periode_new);
end % Ende von periode_recht


% ------ Fouriersynthese Funktionsgenerator ---------------------------------
if strcmp(command_str,'fourier')  % Eingabefelder Fouriersynthese der Sinusfunktion 
  h_sys_filterung = findobj...      % Finde Pushbutton 'filterung'
    ('tag','filterung');
  sys_data = get...                 % Lies Systemdaten aus userdata
    (h_sys_filterung,'userdata');
  h_push_gen = findobj...
    ('tag','generator_mat');
  matrix_fourier = get...
    (h_push_gen,'userdata');
  for i=1:10
    h_amp = findobj...
      ('tag','fourier_amp',...
       'userdata',i);
    amp = str2num(get(h_amp,'string'));
      if (isempty(amp)) % Wenn statt Zahlen Buchstaben eingegeben wurden
        amp = matrix_fourier(i,1);
      end
      amp = amp(1,1);
      if (amp < 0)|(amp > 10)
        amp = matrix_fourier(i,1);
      end
    set(h_amp,'string',amp); 
    h_freq = findobj...
      ('tag','fourier_freq',...
      'userdata',i);
   freq = str2num(get(h_freq,'string'));
    if (isempty(freq))
      freq = matrix_fourier(i,2);
    end
    freq = freq(1,1);
    if (freq < 0)|(freq >= 0.5)
      freq = matrix_fourier(i,2);
    end
    set(h_freq,'string',num2str(freq,12));
    h_phase = findobj...
      ('tag','fourier_phase',...
       'userdata',i);
    phase = str2num(get(h_phase,'string')); 
    if isempty(phase)
      phase = matrix_fourier(i,3);
    end
    phase = phase(1,1);
    if (phase < -360)|(phase > 360)
      phase = matrix_fourier(i,3);
      set(h_phase,'string',phase);
    end
    set(h_phase,'string',phase);
  end
end    % Ende von Fouriersynthese
