function [Filter_Matrix, a_Origin, b_Origin, Quantisierungsdaten, dos_name]=sichern(command_str,filename,pathname)
% SICHERN 	speichert und lädt die notwendigen Daten eines quantisierten Filters
%		innerhalb eines mat-Files. Diese Datenspeicherung ist für die Erstellung
%		und Simulation einer Filterbank notwendig.
%
%
% ------------------- Funktions Header --------------------------------------
% Autor:               Jörg Rose / Roman Ußkurat
% Erstellungsdatum:    7-10/97
% Version:             MATLAB Version 5 / Student Edition
% 
% Betreuer: Prof. Dr.-Ing. Stark
%
%
global a b

%----------laden--------------
if strcmp(command_str,'laden') | strcmp(command_str,'Filterladen')
  cd temp; 
 [filename,pathname] = uigetfile ('*.mat','Laden der Filterdaten');	% Datei auswählen
    if filename ~= 0	
	lade_str=['load ' pathname filename];		% MATLAB-Befehl erstellen
	eval (lade_str);				% und ausführen
	dos_name= [pathname filename];
    end;
  cd ..;
end; % 'laden'
%----------Filterladen--------------
if strcmp(command_str,'Filterladen')
	if filename~=0					% nur, wenn Datei ausgewählt
		h_matrix = findobj('tag','antwort');		% Finde Pushbutton Amplitude/Phase
		set (h_matrix,'UserData',Filter_Matrix);	% Filter-Matrix in UserData schreiben
		a=a_Origin;	% unquantisierte Werte neu setzen
		b=b_Origin;
		h_skalierung= findobj('tag','Skalierung');	% Checkbox für Skalierung
		set(h_skalierung,'userdata',sort_folge);	% Sortierreihenfolge der Kaskadenformen
		quantisierung=Quantisierungsdaten(1);		% Flag Quantisierung ein/aus;
		h_check_quant = findobj('tag','quantisierung'); % Check Box 'Quantisierung'
		set (h_check_quant,'Value',quantisierung);	% Checkbox setzen
		if quantisierung ==1
			arithmetik=Quantisierungsdaten(2);	% Flag auf Arithmetik
			h_pop_arith = findobj('tag','arithmetik');	% Finde Popupmenü 'arithmetik'
			set(h_pop_arith,'Value',arithmetik);		% PopUp-Menü setzen
			if (arithmetik==1)		% Gleitkommaarithmetik
				h_edit_mantisse  = findobj('tag','gleitkomma','userdata',1);	% Editierfeld für Mantisse
				set(h_edit_mantisse,'string',num2str(Quantisierungsdaten(3)));	% Mantisse schreiben
				h_edit_mantispei = findobj('tag','gleitkomma','userdata',3);	% Editierfeld für Mantisse (Speicher)
				set(h_edit_mantispei,'string',num2str(Quantisierungsdaten(6))); % Mantisse schreiben
				h_edit_exponent  = findobj('tag','gleitkomma','userdata',2);	% Editierfeld für Exponent
				set(h_edit_exponent,'string',num2str(Quantisierungsdaten(4)));	% Exponent schreiben
				h_edit_expospei  = findobj('tag','gleitkomma','userdata',4);	% Editierfeld für Exponent (Speicher)
				set(h_edit_expospei,'string',num2str(Quantisierungsdaten(7)));	% Exponent schreiben
				h_check_runden = findobj('tag','gleitkomma','style','radiobutton');	% Radiobutton für Runden
				set(h_check_runden,'value',Quantisierungsdaten(5));		% 0: Abschneiden, 1: Runden
			end;
			if (arithmetik == 2)            % Festkommaarithmetik
				h_edit_bits = findobj('tag','festkomma','userdata',2);		% Editierfeld für Anzahl der Bits
				set(h_edit_bits,'string',num2str(Quantisierungsdaten(5)));	% Anzahl der Bits
				h_edit_bitspei = findobj('tag','festkomma','userdata',5);	% Editierfeld für Anzahl der Bits (Speicher)
				set(h_edit_bitspei,'string',num2str(Quantisierungsdaten(10)));	% Anzahl der Bits
				h_check_runden = findobj('tag','festkomma','userdata',3);	% Radiobutton Runden an/aus
				set(h_check_runden,'value',Quantisierungsdaten(7));		% Zustand des Radiobutton setzen
				h_check_over = findobj('tag','festkomma','userdata',4);		% Radiobutton Überlaufbehandlung
				set(h_check_over,'value',Quantisierungsdaten(6));		% Clipping oder Komplement
			end;
		end;	%quantisierung==1
		h_festkomma = findobj('tag','festkomma');	% Ermittle alle Objekte mit dem Kennzeichen 'festkomma'
		h_gleitkomma = findobj('tag','gleitkomma');	% Ermittle alle Objekte mit dem Kennzeichen 'gleitkomma'
		h_ueber=findobj('tag','quant_uebernehmen');	% Pushbutton Übernehmen
		if (quantisierung == 0)				% Wenn keine Quantisierung

			set (h_ueber,'visible','off');		% Pushbutton Übernehmen unsichtbar setzen 
			set(h_festkomma,'visible','off');	% Objekte mit Kennzeichen 'festkomma' unsichtbar setzen
			set(h_gleitkomma,'visible','off');      % Objekte mit Kennzeichen 'gleitkomma' unsichtbar setzen
		end;
		if (quantisierung == 1)% Wenn Quantisierung an
			set (h_ueber,'visible','on');		% Pushbutton Übernehmen sichtbar setzen
			if (arithmetik == 1)            	% Wenn Gleitkommaarithmetik
								% Setze alle Objekte mit dem
	        	   set(h_festkomma,'visible','off');	% Kennzeichen 'festkomma' unsichtbar
	      						        % Setze alle Objekte mit dem
		           set(h_gleitkomma,'visible','on');	% Kennzeichen 'gleitkomma' sichtbar
			end                             	% Ende von Gleitkommaarithmetik
			if (arithmetik == 2)  			% Wenn Festkommaarithmetik
							        % Setze alle Objekte mit dem
	        	   set(h_gleitkomma,'visible','off');	% Kennzeichen 'gleitkomma' unsichtbar
	     				        		% Setze alle Objekte mit dem
	        	   set(h_festkomma,'visible','on');	% Kennzeichen 'festkomma' sichtbar
			end;					% Ende von Festkommaarithmetik
		end;	% Quantisierung an
		h_pop_struktur = findobj('tag','struktur');	% Finde Popup-Menü 'struktur'
		set(h_pop_struktur,'value',Filter_Matrix(1,1));	% Struktur auf Direktform setzen
		h_axes=findobj('tag','axes');			% Axes-Objekt mit Netzwerk
		set (h_axes,'UserData',1);			% Flag für Netzwerk setzen
	    	h_ueber=findobj('tag','quant_uebernehmen');	% Pushbutton Übernehmen
	    	aktual_str=get (h_ueber,'callback');	% Callback lesen, da dieser auf "aktualisieren" der momentanen Anzeige steht
		eval(aktual_str);			% Aktualisierungsbefehl ausführen
	end; 	% wenn Dateiname vorhanden
end;	% 'Filterladen'
		
%---------speichern------------------
if strcmp(command_str,'speichern')
    if nargin==1	% wenn kein Filename angegeben
	cd temp;
	[filename,pathname] = uiputfile ('*.mat','Speichern der Filterdaten');
	cd ..;
    end;
    if filename ~= 0	
	h_matrix=findobj('tag','antwort');	% Handle auf Pushbutton Amplitude/Phase
	Filter_Matrix=get(h_matrix,'userdata'); % aktuelle Filtermatrix
	a_Origin=a;	% unquantisierte Werte merken
	b_Origin=b;
	h_quant= findobj('tag','speichern');	% Pushbutton Speichern
	Quantisierungsdaten= get(h_quant,'userdata');	% Daten für quantisierte Filterung

	% eventuelle Sortierreihenfolge feststellen
	if Filter_Matrix(1,1)==4 | Filter_Matrix(1,1)==5	% Kaskadenformen
		sort_folge=[];		% Sortierreihenfolge löschen
              	for i=0:size(Filter_Matrix,1)-2                 % alle Teilsysteme suchen und Reihenfolge feststellen
		    suchtext=['H' num2str(i) '(z)'];
		    h_teilsyst= findobj ('string',suchtext);    % Teilsystem mit dem entsprechenden
								% String ermitteln
		    kennung = get(h_teilsyst,'userdata');
		    sort_folge(kennung(1,1)+1)= i+1; 	% Position aus UserData ermitteln
		end;                                    	% Vektor sort_folge gibt die Reihenfolge der Teilsystme an
	else		
		sort_folge=[0];
	end;
	speicher_str=['save ' pathname filename ' Filter_Matrix a_Origin b_Origin Quantisierungsdaten sort_folge'];
	eval (speicher_str);
    end;
end; % 'speichern'
