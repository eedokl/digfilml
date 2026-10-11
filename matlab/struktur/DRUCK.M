function druck (command_str)
% DRUCK 	führt eine Abfrage durch, ob der aktuelle Fensterinhalt gedruckt werden soll (Hardcopy)
%		oder ein Textfile mit den aktuellen Koeffizienten erstellt werden soll.
%
% ------------------- Funktions Header --------------------------------------
% Autor:               Jörg Rose / Roman Ußkurat
% Erstellungsdatum:    7-10/97
% Version:             MATLAB Version 5 / Student Edition
% 
% Betreuer: Prof. Dr.-Ing. Stark
%
global a b

if nargin ==0		% Erstaufruf
        command_str='init';
end;
if strcmp(command_str,'init')	% Initialisierung
	fig_str='Drucken';
	[flag,fig] = figflag(fig_str,0);	% Existiert Fenster für Druckabfrage
	if flag
		return;		% Wenn ja, druck verlassen
	end;
	% ------ Struktur-Fenster unbedienbar setzen ---------
	h_obj= findobj('type','uicontrol','enable','on');	% alle aktiven UIControl-Objekte
	h_ende=findobj('tag','ende');		% Ende-Pushbutton
	set (h_ende,'userdata',h_obj);		% aktive Objekte merken
	set (h_obj,'enable','off');		% inaktiv setzen

	farbe=[0.6275 0.6275 0.6275];	% Farbwert für Hintergründe
	h_fig=figure('units','normalized',...% Einheit normalisiert
        	'menubar','none',...        % Menueleiste ausblenden
	        'position',[0.2 0.4 0.6 0.3],...
	        'color',farbe,...
                'ShareColors','on',...
	        'numbertitle','off',...     % Figurnummer ausblenden
		'name','Drucken',...
		'resize','off',...
		'tag','druck_abfrage');
	Text_str=['Mit ''Hardcopy'' wird ein Ausdruck des aktuellen Diagramms vorgenommen,'];
	uicontrol(h_fig,...		% Erklärender Text für die Auswahl
        	'style','Text',...
	        'units','normalized',...
		'backgroundcolor',farbe,...   % Hintergrundfarbe
	        'string',Text_str,...       % Auszugebender Text
		'HorizontalAlignment','left',...
	        'position',[0.1 0.7 0.7 0.2]);
	Text_str=['mit ''Textfile'' werden die aktuellen Koefizienten in einem Text-File ausgegeben.'];
	uicontrol(h_fig,...		% Erklärender Text für die Auswahl
        	'style','Text',...
	        'units','normalized',...
		'backgroundcolor',farbe,...   % Hintergrundfarbe
	        'string',Text_str,...       % Auszugebender Text
		'HorizontalAlignment','left',...
	        'position',[0.1 0.5 0.7 0.2]);
	uicontrol(gcf,...                   % Pushbutton Hardcopy
        	'style','pushbutton',...      % 
	        'string','Hardcopy',...       % Beschriftung des Pushbuttons
        	'units','normalized',...
                'callback','druck(''hardcopy'');',...% Bei Betätigung
	        'position',[0.115 0.1 0.175 0.15]);
	uicontrol(gcf,...                   % Pushbutton Textfile
        	'style','pushbutton',...      % 
	        'string','Textfile',...       % Beschriftung des Pushbuttons
        	'units','normalized',...
	        'callback','druck(''textfile'');',...% Bei Betätigung
	        'position',[0.315 0.1 0.175 0.15]);
	uicontrol(gcf,...                   % Pushbutton Hilfe
        	'style','pushbutton',...      % 
	        'string','Hilfe',...       % Beschriftung des Pushbuttons
        	'units','normalized',...
	        'callback','!winhelp struktur\druck',...% Bei Betätigung
	        'position',[0.515 0.1 0.175 0.15]);
	uicontrol(gcf,...                   % Pushbutton Abbrechen
        	'style','pushbutton',...      % 
	        'string','Abbrechen',...       % Beschriftung des Pushbuttons
        	'units','normalized',...
	        'callback','druck(''abbrechen'');',...% Bei Betätigung
	        'position',[0.715 0.1 0.175 0.15]);

end; % init

% ------ Hardcopy -------------
if strcmp (command_str,'hardcopy')
        h_fig=findobj('name','Drucken');	% Druckauswahl-Fenster
	delete (h_fig);				% schließen
	h_exist=findobj('tag','quant_ueber');	% Tabellenüberschrift
	if isempty(h_exist)			% Keine Tabelle in Anzeige => Überschrift zusätzlich ausgeben
		h_axes_text=axes('position',[0.35 0.95 0.6 0.1],...% Position und Ausdehnung
        		'ylim',[0 0.9],...            % Zuweissung waagerechte Grenzwerte
		        'xlim',[0 0.2],...            % Zuweisung senkrechte Grenzwerte
		        'visible','off',...         % Begrenzung und Koordinaten unsichtbar
			'tag','Beschriftungs-Axes',...
		        'drawmode','fast',...
		        'color',[1 1 1],...         % Farbe = Weiss
		        'nextplot','add');          % Ältere Plots bleiben erhalten
		h_fig=findobj('tag','netzwerk');	% Figure für Struktur
		name_str= get(h_fig,'name');		% Fenstertitel als Überschrift
		h_text=text(0.0,0.3,name_str);		% Überschrift ausgeben
		set(h_text,'color','k');
	end;
   h_uicontrol= findobj('type','uicontrol','visible','on');
   set (h_uicontrol,'visible','off');
   h_axes=findobj('tag','axes');   % Axes-Objekt für Struktur
   x_lim_old=get(h_axes,'XLim');
   y_lim_old=get(h_axes,'YLim');
   old_position=get(h_axes,'position');
   y_lim=y_lim_old*0.8;
   x_lim=x_lim_old;
   set (h_axes,'YLim',y_lim);
   set (h_axes,'position',[0 0 1 1]);
   h_teil= findobj('tag','ansicht');
   h_teil_value= get(h_teil,'value');
   flag_erkennung=0;
   if (h_teil_value == 1)
      h_popup=findobj('tag','struktur');
      if (get(h_popup,'value')==6)         % Wenn Lattice-Ladder
        flag_erkennung=1;
        h_min = findobj('userdata','min');
        pos_min = min(get(h_min,'xdata'));
        h_max = findobj('userdata','max');
        pos_max = max(get(h_max,'xdata'));
        pos_breite = pos_max - pos_min;
        pos_breite = pos_breite * 1.05;
        x_lim_breite = x_lim(2) - x_lim(1);
        zoom_faktor = x_lim_breite/pos_breite;
        x_lim_new = x_lim/zoom_faktor;
        middle_new = (x_lim_new(1) + x_lim_new(2))/2;
        h_middle = findobj('userdata','middle');
        x_data_middle = get(h_middle,'xdata');
        middle_old = x_data_middle(1);
        waagerecht = middle_old - middle_new;
        x_lim_new = x_lim_new + waagerecht;
        y_lim=y_lim./zoom_faktor;
        y_lim = y_lim + 40;
        set (h_axes,'YLim',y_lim);
        set (h_axes,'XLim',x_lim_new);
        h_fig=findobj('tag','netzwerk');
        old_pos=get(h_fig,'PaperPosition');
        set (h_fig,'PaperPosition',[1 1.5 25 20]);
        set (h_axes_text,'position',[0.35 0.855 0.6 0.1]);
      end;
   end;
   
   drawnow;      % vor Druckaufruf Bildschirmumbau abwarten 
   pause(3);
   print;             % Druckaufruf MATLAB
   set (h_axes,'YLim',y_lim_old);
   set (h_axes,'XLim',x_lim_old);
   set (h_axes,'position',old_position);
   if flag_erkennung==1
      set (h_fig,'PaperPosition',old_pos);
   end;
   set (h_uicontrol,'visible','on');
	if isempty(h_exist)	% Wenn Überschrift ausgegeben
		delete(h_axes_text);		% Text-Axes-Objekt schließen
	end;
   command_str='abbrechen';	% Nach Ausdruck beenden
   drawnow;
end;	% Hardcopy

% ------ Textfile -------------
if strcmp(command_str,'textfile')
	[filename,pathname] = uiputfile ('*.txt','Speichern unter');
    if filename ~= 0	
		fid= fopen ([pathname filename],'wt');
		h_matrix=findobj('tag','antwort');	% Pushbutton Amplitude/Phase
		Matrix = get (h_matrix,'userdata');	% Matrix in UserData des Pushbuttons
		if any(a(2:size(a,2)))			% FIR/IIR-Filter?
			filter_type='IIR';
		else
			filter_type='FIR';
		end;
		ordnung=max(size(b,2),size(a,2));	% Anzahl der Koeffizienten

	% ---------- Direktform, 1. oder 2. kanonische Form -------------
	if (Matrix(1,1)==1 | Matrix(1,1)==2 | Matrix(1,1)==3)   % eine der Direktstrukturen
		bhilf=Matrix(2:size(Matrix,1),1);   % b-Koeffizienten
		ahilf=Matrix(2:size(Matrix,1),2);   % a-Koeffizienten
		Ueberschrift= ['Koeffizienten des ' filter_type '-Filters ' num2str(ordnung-1)  '. Ordnung'];
		if (Matrix(1,1) ==1)
			Ueberschrift=[Ueberschrift ' in Direktform'];
		end;
		if (Matrix(1,1) ==2)
			Ueberschrift=[Ueberschrift ' in 1. kanonischer Form'];
		end;
		if (Matrix(1,1) ==3)
			Ueberschrift=[Ueberschrift ' in 2. kanonischer Form'];
		end;
		fprintf(fid,'%s\n\n',Ueberschrift);	% Überschrift ausdrucken
		for i=1:ordnung                % Für jeden einzelnen Koeffizienten
			if (i<11)	% Ausrichtung der Indizes
				leer_str='  ';
			else
				leer_str=' ';
			end;
			if length(bhilf)>=i		% Koeffizientensätze formatiert ausdrucken
				fprintf(fid,'b%1.0f%s=%11.8f',i-1,leer_str,bhilf(i));
			end;
			if (strcmp(filter_type,'IIR') & length(ahilf)>=i)
				fprintf(fid,'\ta%1.0f%s=%11.8f\n',i-1,leer_str,ahilf(i));
			else
				fprintf(fid,'\n');
			end;
		end; % of for-Schleife
	end; % eine der Direktstrukturen
	% ------------- Lattice-Ladder-Struktur ---------------
	if (Matrix(1,1) ==6)        % Lattice-Ladder-Struktur
		khilf=Matrix(2:size(Matrix,1)-1,1); % k-Koeffizienten
		chilf=Matrix(2:size(Matrix,1),2);   % c-Koeffizienten
		Ueberschrift= ['Koeffizienten des ' filter_type '-Filters ' num2str(ordnung-1)  '. Ordnung'];
		Ueberschrift=[Ueberschrift ' in Lattice-Ladder-Struktur'];
		fprintf(fid,'%s\n\n',Ueberschrift);	% Überschrift ausdrucken
		for i=1:length(chilf)              % Für jeden einzelnen Koeffizienten
			if (i<11)			% Ausrichtung der Indizes
				leer_str='  ';
			else
				leer_str=' ';
			end;
			if length(khilf)>=i		% Lattice-Ladder-Koeffizienten ausdrucken
				fprintf(fid,'k%1.0f%s=%11.8f',i-1,leer_str,khilf(i));	% k-koeffizienten
			else
				fprintf(fid,'\t\t');
			end;
			if length(chilf)>=i
				fprintf(fid,'\tc%1.0f%s=%11.8f\n',i-1,leer_str,chilf(i)); % c-Koeffizienten
 			end;
		end; % of for-Schleife
	end; % Lattice-Ladder-Struktur
	% ------------ Kaskade -----------------------------
	if (Matrix(1,1)==4)		% Kaskadenstruktur
		sos_Matrix= Matrix(2:size(Matrix,1),:);	% sos-Matrix extrahieren
		Ueberschrift= ['Koeffizienten des ' filter_type '-Filters ' num2str(ordnung-1)  '. Ordnung'];
		Ueberschrift=[Ueberschrift ' in Kaskaden-Struktur'];
		fprintf(fid,'%s\n\n',Ueberschrift);	% Überschrift ausdrucken
		for i=0:size(sos_Matrix,1)-1                      % alle Teilsysteme suchen und Reihenfolge feststellen
		    suchtext=['H' num2str(i) '(z)'];
		    h_teilsyst= findobj ('string',suchtext);    % Teilsystem mit dem entsprechenden
		        	                                        		% String ermitteln
		    kennung = get(h_teilsyst,'userdata');
		    sort_folge(kennung(1,1)+1)= i;  % Position aus UserData ermitteln
		end;
		for Teilsystem=1:size(sos_Matrix,1)	% Jede Zeile der sos-Matrix
			bhilf= sos_Matrix(Teilsystem,1:3);	% b-Koeffizienten des Teilsystems
			ahilf= sos_Matrix(Teilsystem,4:6);	% a-Koeffizienten des Teilsystems
			Teil_str=['H' num2str(sort_folge(Teilsystem)) '(z):'];
			for i=1:3		% Für jeden einzelnen Koeffizienten des Teilsystems
				if i~=1
					fprintf(fid,'\t');		% Beschriftung des Teilsystems
				else
					fprintf(fid,'%s\t',Teil_str);
				end;
				fprintf(fid,'b%1.0f = %11.8f',i-1,bhilf(i));	% b-Koeffizienten
				if strcmp(filter_type,'IIR') 
					fprintf(fid,'\ta%1.0f = %11.8f\n',i-1,ahilf(i)); % a-Koeffizienten
				else
					fprintf(fid,'\n');
				end;
			end; % of for-Schleife
			fprintf(fid,'\n');	% Leerzeile zwischen Teilsystemem
		end; % jede Zeile sos-Matrix
	end; % Kaskadenstruktur
	% ------------ Kaskade normiert -----------------------------
	if (Matrix(1,1)==5)		% normierte Kaskadenstruktur
		sos_Matrix= Matrix(2:size(Matrix,1),2:7);	% sos-Matrix extrahieren
		norm_koeff= Matrix(2:size(Matrix,1),1);	% Normierungs-Koeffizienten extrahieren
		Ueberschrift= ['Koeffizienten des ' filter_type '-Filters ' num2str(ordnung-1)  '. Ordnung'];
		Ueberschrift=[Ueberschrift ' in normierter Kaskaden-Struktur'];
		fprintf(fid,'%s\n\n',Ueberschrift);	% Überschrift ausgeben
		for i=0:size(sos_Matrix,1)-1                      % alle Teilsysteme suchen und Reihenfolge feststellen
		   suchtext=['H' num2str(i) '(z)'];
		    h_teilsyst= findobj ('string',suchtext);    % Teilsystem mit dem entsprechenden
	        	                                        		% String ermitteln
		    kennung = get(h_teilsyst,'userdata');
		    sort_folge(kennung(1,1)+1)= i;  % Position aus UserData ermitteln
		end;
		for Teilsystem=1:size(sos_Matrix,1)	% Jede Zeile der sos-Matrix
			bhilf= sos_Matrix(Teilsystem,1:3);	% b-Koeffizienten des Teilsystems
			ahilf= sos_Matrix(Teilsystem,4:6);	% a-Koeffizienten des Teilsystems
			Teil_str=['H' num2str(sort_folge(Teilsystem)) '(z):'];
			fprintf(fid,'%s\t',Teil_str);	% Beschriftung des Teilsystems
			fprintf(fid,'k  = %11.8f\n',norm_koeff(Teilsystem));	% Normierungs-Koeffizient ausgeben
			for i=1:3	% Für jeden einzelnen Koeffizienten des Teilsysrems
				fprintf(fid,'\tb%1.0f = %11.8f',i-1,bhilf(i));	% b-Koeffizienten
				if strcmp(filter_type,'IIR') 
					fprintf(fid,'\ta%1.0f = %11.8f\n',i-1,ahilf(i)); % a-Koeffizienten
				else
					fprintf(fid,'\n');
				end;
			end; % of for-Schleife
			fprintf(fid,'\n');	% Leerzeile zwischen Teilsystemem
		end; % jede Zeile sos-Matrix
	end; % normierte Kaskadenstruktur
	% ------------ Parallelstruktur -----------------------------
	if (Matrix(1,1)==7)		% Parallelstruktur
		sos_Matrix= Matrix(2:size(Matrix,1),2:7);	% sos-Matrix extrahieren
		Ueberschrift= ['Koeffizienten des ' filter_type '-Filters ' num2str(ordnung-1)  '. Ordnung'];
		Ueberschrift=[Ueberschrift ' in Parallelform'];
		fprintf(fid,'%s\n\n',Ueberschrift);	% Überschrift ausgeben
		for Teilsystem=1:size(sos_Matrix,1)	% Jede Zeile der sos-Matrix
			bhilf= sos_Matrix(Teilsystem,1:3);	% b-Koeffizienten des Teilsystems
			ahilf= sos_Matrix(Teilsystem,4:6);	% a-Koeffizienten des Teilsystems
			Teil_str=['H' num2str(Teilsystem-1) '(z):'];
			for i=1:3	% Für jeden einzelnen Koeffizienten des Teilsystems
				if i~=1
					fprintf(fid,'\t');		% Beschriftung des Teilsystems
				else
					fprintf(fid,'%s\t',Teil_str);
				end;
				fprintf(fid,'b%1.0f = %11.8f',i-1,bhilf(i));	% b-Koeffizienten
				fprintf(fid,'\ta%1.0f = %11.8f\n',i-1,ahilf(i)); % a-Koeffizienten
			end; % of for-Schleife
			fprintf(fid,'\n');	% Leerzeile zwischen Teilsystemem
		end; % jede Zeile sos-Matrix
		fprintf(fid,'Direktterme:');
		c_koeff= Matrix(2:size(Matrix,1),1);	% Direktterme
		for i=1:size(c_koeff,1)		% jeden Direktterm
			if c_koeff(i) ~=0
				fprintf(fid,'\tc%1.0f = %11.8f\n',i-1,c_koeff(i));
			end;
		end;
	end; % Parallelstruktur
	fclose(fid);			% Datei schließen
	command_str='abbrechen';	% Nach Speichern beenden
    end;
end;	% Textfile

% ------ Abbrechen ------------
if strcmp(command_str,'abbrechen')
	h_fig = findobj('name','Drucken');	% aktives Fenster
	delete (h_fig);				% Fenster mit allen Objekten löschen
	h_ende= findobj('tag','ende');		% Ende-Pushbutton
	h_obj = get(h_ende,'userdata');		% aktive Objekte lesen
	set (h_obj,'enable','on');		% aktiv setzen

end;	% Abbrechen
