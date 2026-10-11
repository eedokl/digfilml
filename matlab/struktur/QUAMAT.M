function [matrix,rech,spei,quantisierung,arithmetik,sort_folge]= quamat (f_struktur, null_korrektur)
% QUAMAT 	ermittelt die aktuellen Quantisierungsdaten und 
%		erstellt die Filter-Matrix. 
%		
% ------------------- Funktions Header --------------------------------------
% Autor:               Jörg Rose / Roman Ußkurat
% Erstellungsdatum:    7-10/97
% Version:             MATLAB Version 5 / Student Edition
% 
% Betreuer: Prof. Dr.-Ing. Stark
% 
global a b

arithmetik=0;
rech=[];spei=[];
sort_folge=0;


% ----------- Quantisierungsdaten ------------
  h_check_quant = findobj('tag',...% Check Box 'Quantisierung'
        'quantisierung'); 
  quantisierung = get(h_check_quant,'value'); % 0: keine Quantisierung
                                              % 1: Quantisierung
  if (quantisierung ==1)
    h_pop_arith = findobj('tag',... % Finde Popupmenue 'arithmetik'
        'arithmetik');
    arithmetik = get(h_pop_arith,'value'); % 1: Gleitkomma, 2: Festkomma
    if (arithmetik == 1)            % Wenn Gleitkommaarithmetik
      h_edit_mantisse  = findobj('tag','gleitkomma',...
        'userdata',1);              % Editierfeld fuer Mantisse
      mantisse = str2num(get(h_edit_mantisse,'string')); % Lies Mantisse
      h_edit_mantisspei  = findobj('tag','gleitkomma',...
        'userdata',3);              % Editierfeld fuer Mantisse (Speicher)
      mantispei = str2num(get(h_edit_mantisspei,'string')); % Lies Mantisse (Speicher)
      h_edit_exponent  = findobj('tag','gleitkomma',...
        'userdata',2);              % Editierfeld fuer Exponent
      exponent = str2num(get(h_edit_exponent,'string')); % Lies Exponent (Speicher)
      h_edit_expospei  = findobj('tag','gleitkomma',...
        'userdata',4);              % Editierfeld fuer Exponent
      expospei = str2num(get(h_edit_expospei,'string')); % Lies Exponent (Speicher)
      h_check_runden = findobj('tag','gleitkomma',...
        'style','popupmenu');        % Popup-Menü für Runden
      runden = get(h_check_runden,'value'); % Zustand lesen
      h_check_unter= findobj('tag','gleitkomma',...
	'style','checkbox');	     % Checkbox für Unterlaufbehandlung
      unterlauf= get (h_check_unter,'value');
      if unterlauf==0			% kein sofortiger Unterlauf
	runden=runden+3;
      end;      
      rech = [mantisse exponent runden];% Uebergabe fuer Quantisierung  (ALU)
      spei = [mantispei expospei runden];% Uebergabe fuer Quantisierung (Speicher)
      if unterlauf==0			% kein sofortiger Unterlauf
	mantisse= mantisse+1;
      end;
    end;
    if (arithmetik == 2)            % Festkommaarithmetik
      h_edit_bits = findobj('tag','festkomma',...
        'userdata',2);              % Editierfeld fuer Anzahl der Bits
      bits = str2num(get(h_edit_bits,'string')); % Anzahl der Bits
      h_edit_bitspei = findobj('tag','festkomma',...
        'userdata',5);              % Editierfeld fuer Anzahl der Bits (Speicher)
      bitspei = str2num(get(h_edit_bitspei,'string')); % Anzahl der Bits (Speicher)
      h_check_runden = findobj('tag','festkomma',...
        'userdata',3);              % radiobutton Runden an/aus
      runden = get(h_check_runden,'value');% Lies Zustand 
      h_check_over = findobj('tag','festkomma',...
        'userdata',4);              % radiobutton Ueberlaufbehandlung
      overflow = get(h_check_over,'value');% Clipping oder Komplement
      rech = [1 -1 bits overflow runden];% Uebergabe fuer Quantisierung
      spei = [1 -1 bitspei overflow runden];% Uebergabe fuer Quantisierung (Speicher)
    end;
  end;   % of quantisierung ==1


% -------- Koeffizienten-Matrix neu erstellen --------

h_systemantwort = findobj...        % Finde Pushbutton Systemantwort
  ('tag','antwort');

    h_axes=findobj('tag','axes');	% Axes-Objekt mit Netzwerk
    h_flag_laden= get(h_axes,'UserData');	% Flag für Laden lesen
    if isempty(h_flag_laden)
		h_flag_laden=0;
	 end;
    set(h_axes,'UserData',[]);		% Flag löschen
    h_strukt=findobj('string','Struktur');
	if (f_struktur ~= 4 & f_struktur ~= 5)		% keine kaskadierte Form
			set (h_strukt,'UserData',0);	% keine Nullstellenkorrektur 
	end;
    if (f_struktur == 1) | (f_struktur == 2) | (f_struktur == 3)  %Direktform, 1. und 2. kanonische
        ahilf=a;                            % Koeffizienten zuweisen
        bhilf=b;
        if (quantisierung == 1 & arithmetik == 1)   % Gleitkomma-Quantisierung
            ahilf=flpoint(ahilf,mantisse,exponent,3);	% 3= Koeffizienten Runden
            ahilf(1)=1;		% a0 belassen
            bhilf=flpoint(bhilf,mantisse,exponent,3);
        end;
        if (quantisierung == 1 & arithmetik == 2)   % Festkomma-Quantisierung
            ahilf=fixkoef(ahilf,bits);
            ahilf(1)=1;     % a0 belassen
            bhilf=fixkoef(bhilf,bits);
        end;
        matrix= [f_struktur 0;bhilf' ahilf'];     % neue Koeffizienten-Matrix
    end;
    h_data = findobj('buttondownfcn',...% Finde alle Objekte mit der buttondown
        	  'kaskade(''kaskade'');');   % 'kaskade...', in jedem ist sos-matrix
	                                % in userdata abgespeichert 
    if isempty(h_data)
	h_data = findobj('buttondownfcn',...% Finde alle Objekte mit der buttondown
        	  'kaskade(''kaskadenorm'');');% 'kaskade...', in jedem ist 
		                            % sos-matrix in userdata abgespeichert 
    end;
   if (f_struktur == 4) | (f_struktur == 5) 	% eine der Kaskadenformen
        [z,p,k]= tf2zp(b,a);    % Umwandlung in sos-Matrix
		Null_kenn=0;				% Kennung für Nullstellen bei Butterworth und Cheb. 1 Filtern
		Kriterium1=abs(sum(z)/length(z));
		Kriterium2=sum(abs(z))/length(z);
		if (Kriterium1 < 1.00001 & Kriterium1 > 1-0.00001)
			Null_kenn=1;					% TP oder HP
		end;
		if (Kriterium1 < 0.000001 & Kriterium1 > -0.000001)	
			if (Kriterium2 > 1.00000000001 | Kriterium2 < 1-0.00000000001)
				Null_kenn=2;				% BP oder BS
			end;		
		end;
		filter_check = a(2:length(a));
		if ~any(filter_check)                % Pruefe, ob IIR- oder FIR-Filter
         Null_kenn=0;		% Bei FIR-Filtern nicht
      end;
	if nargin < 2
		null_korrektur=0;
	end;

	if null_korrektur==1 & Null_kenn ~=0		% Nullkorrektur abfragen
		Fenstertext = (['Wenn es sich bei dem aktuellen Filter um ein Butterworth oder Tschebyscheff (I) IIR-Filter handelt, so kann ',...
		'aufgrund der Filterentwicklung eine Nullstellenkorrektur vorgenommen werden. Soll diese Nullstellenkorrektur bei Filtern in kaskadierter Form vorgenommen werden ?']);			
Abfrage=fenster (Fenstertext,'Nullstellenkorrektur',1,3);
if Abfrage ==6      % Ja
			set (h_strukt,'UserData',1);
		else
			set (h_strukt,'UserData',0);
		end;
	end;

	null_korrektur= get (h_strukt,'UserData');
	
	if null_korrektur==1 & Null_kenn ~=0		% Nullkorrektur abfragen
		if Null_kenn==1			% TP / HP
			z=sign(real(z))*1;
		end;
		if Null_kenn==2			% BP / BS
			if (sum(abs(imag(z)))/ length(z) > 0.8) 	% Entscheidung BS = ja / BP = nein
				z=sign(imag(z))*j;
			else
				z=sign(real(z))*1;		
			end;
		end;
	end;

        sos= zp2sos(z,p,k);
        sort_folge=[1:size(sos,1)];	% Feld für Sortieren initialisieren
        if ~isempty(h_data) | h_flag_laden ==1            % vorherige Struktur eine der Kaskadenformen oder Laden mit Kaskadenform
		sort_folge=[];		% Sortierreihenfolge löschen
		if  (h_flag_laden ~=1)		% kein Flag gesetzt
	        	for i=0:size(sos,1)-1                      % alle Teilsysteme suchen und Reihenfolge feststellen
			    suchtext=['H' num2str(i) '(z)'];
			    h_teilsyst= findobj ('string',suchtext);	% Teilsystem mit dem entsprechenden
									% String ermitteln
			    kennung = get(h_teilsyst,'userdata');
			    sort_folge(kennung(1,1)+1)= i+1; 	% Position aus UserData ermitteln
			end;                                    	% Vektor sort_folge gibt die Reihenfolge der Teilsystme an
		else			% Flag gesetzt --> Reihenfolge aus Matrizenvergleich ermitteln
			h_skalieren= findobj('tag','Skalierung');	% Checkbox Skalierung
			sort_folge= get (h_skalieren,'userdata');	% Sortierreihenfolge lesen
		end;		% Flag gesetzt
	
		sos = sos(sort_folge,:);		% sos-Matrix sortieren
	end;
	h_skal= findobj('tag','Skalierung');		% Checkbox Skalierung
	skal_wert= get (h_skal,'value');
	if skal_wert ==1				% neues Skalieren der Teilsysteme
		Hconvb=[1];
		Hconva=[1];
		for Reihe=1:size(sos,1)		% jede Reihe der SOS
			Hb= sos(Reihe,1:3);
			Ha= sos(Reihe,4:6);
			Htestb= conv (Hb,Hconvb);
			Htesta= conv (Ha,Hconva);
			Hmax=max(abs(freqz(Htestb,Htesta)));
			sos (Reihe,1:3) = sos (Reihe,1:3)./Hmax;
			Hconvb = conv (Hconvb,sos(Reihe,1:3));
			Hconva = Htesta;
		end;

	end;
   end;
    if (f_struktur == 4)          % Kaskade
	if (quantisierung == 1 & arithmetik == 1)   % Quantisierung der sos-Matrix
            for i=1:size(sos,1)
                zeile=sos(i,:);
                zeile= flpoint(zeile,mantisse,exponent,3); % Gleitkomma-Quantisierung
                sos(i,:)=zeile;
                sos(i,4)=1;        % a0 belassen
            end;
        end;
        if (quantisierung == 1 & arithmetik == 2)       % Festkomma-Quantisierung
            for i=1:size(sos,1)
                zeile=sos(i,:);
                zeile= fixkoef(zeile,bits);
                sos(i,:)=zeile;
                sos(i,4)=1;        % a0 belassen
            end;
        end;

        matrix= [4 0 0 0 0 0;sos];    % neue Koeffizienten-Matrix
    end;
    if (f_struktur == 5)          % Kaskade normiert
        K= sos(:,1);            % erste Spalte b0-Koeffizienten
        sos(:,1)=sos(:,1)./K;   % Normierung auf b0
        sos(:,2)=sos(:,2)./K;
        sos(:,3)=sos(:,3)./K;

        if (quantisierung == 1 & arithmetik == 1)   % Quantisierung der sos-Matrix
            K=K';
            K=flpoint(K,mantisse,exponent,3);  % Quantisierung der Normierungskoeffizienten
            K=K';
            for i=1:size(sos,1)
                zeile=sos(i,:);
                zeile= flpoint(zeile,mantisse,exponent,3);     % Gleitkomma-Quantisierung
                sos(i,:)=zeile;
                sos(i,1)=1;     % b0 = 1
                sos(i,4)=1;     % a0 = 1
            end;
        end;
        if (quantisierung == 1 & arithmetik == 2) 
            K=K';
            K=fixkoef(K,bits); % Quantisierung der Normierungskoeffizienten
            K=K';
            for i=1:size(sos,1)
                zeile=sos(i,:);
                zeile= fixkoef(zeile,bits);    % Festkomma-Quantisierung
                sos(i,:)=zeile;
                sos(i,1)=1;     % b0 = 1
                sos(i,4)=1;     % a0 = 1
            end;
        end;

        matrix= [[5;K] [0 0 0 0 0 0;sos]];      % neue Koeffizienten-Matrix
    end;
    if (f_struktur == 6)          % Lattice-Ladder-Struktur
        [K,C]=lattice(b,a);     % Lattice-Ladder-Umwandlung
        if (quantisierung == 1 & arithmetik == 1)       % Gleitkomma-Quantisierung
            K=flpoint(K,mantisse,exponent,3);
            C=flpoint(C,mantisse,exponent,3);
        end;
        if (quantisierung == 1 & arithmetik == 2)       % Festkomma-Quantisierung
            K=fixkoef(K,bits);
            C=fixkoef(C,bits);
        end;
        matrix = [[6;K';0] [0;C']];         % neue Koeffizienten-Matrix
    end;
    if (f_struktur == 7)      % Parallelform
        [C,sos]= dir2par(b,a);      % Umwandlung in Parallelform
        if isempty(C)                % Wenn kein Direktterm
            C = 0;
        end;
        C= [C zeros(1, size(sos,1) - length(C))]';    % mit Nullen auffüllen
        if (quantisierung == 1 & arithmetik == 1)   % Gleitkomma-Quantisierung
            C=C';
            C=flpoint(C,mantisse,exponent,3);  % Quantisierung der Direktterme
            C=C';
            for i=1:size(sos,1)
                zeile=sos(i,:);
                zeile= flpoint(zeile,mantisse,exponent,3);  
                sos(i,:)=zeile;
                sos(i,4)=1;         % a0 = 1
            end;
        end;
        if (quantisierung == 1 & arithmetik == 2)   % Festkomma-Quantisierung
            C=C';
            C=fixkoef(C,bits);  % Quantisierung der Direktterme
            C=C';
            for i=1:size(sos,1)
                zeile=sos(i,:);
                zeile= fixkoef(zeile,bits);  
                sos(i,:)=zeile;
                sos(i,4)=1;         % a0 = 1
            end;
        end;
        matrix = [[7;C] [0 0 0 0 0 0;sos]];     % neue Koeffizientenmatrix
    end;
    set(h_systemantwort,'userdata',matrix);     % Koeffizienten-Matrix ablegen
    h_speichern= findobj('tag','speichern');	% Quantisierungsdaten für diesen Filter ablegen
    set(h_speichern,'userdata',[quantisierung arithmetik rech spei]);


