function ansicht
% ANSICHT
%
% Die Funktion schaltet zwischen Teilansicht und Gesamtansicht
% der aktuellen Netzwerkstruktur um
% Funktionsaufruf
%   ansicht
%
%
% ------------------- Funktions Header --------------------------------------
% Autor:               Jörg Rose / Roman Ußkurat
% Erstellungsdatum:    7-10/97
% Version:             MATLAB Version 5 / Student Edition
% 
% Betreuer: Prof. Dr.-Ing. Stark
%
% ------------------------- Globale Variablen -------------------------------
global a b

ordnung = max(length(a),length(b));   % Ermittle Ordnung der aktuellen Struktur
h_axes = findobj...                   % Finde Axes-Objekt 'axes' fuer Struktur
  ('tag','axes');
h_pop_struktur = findobj...           % Finde Popupmenue 'struktur'
  ('tag','struktur');
h_radio_ansicht = findobj...          % Finde Radiobutton 'ansicht'
  ('tag','ansicht');
h_slider_senk = findobj...            % Finde Handle des senkrechten sliders
  ('tag','slidery');
h_slider_waag = findobj...            % Finde Handle des waagerechten sliders
  ('tag','slider');

%h_text = findobj...                   % Finde alle Handles der Textobjekte
%  ('type','text');                    % der Struktur
h_textobj= findobj('tag','multiplizierer_b',...  % Dies muß in der Studentenversion 4.0
	'type','text');				 % bei mehr als 100 Objekten einzeln geschehen,
h_text=h_textobj;				 % da es sonst zu Schutzverletzungen kommen kann.
h_textobj= findobj('tag','multiplizierer_a',...
	'type','text');
h_text=[h_text; h_textobj];
h_textobj= findobj('tag','multiplizierer_c',...
	'type','text');
h_text=[h_text; h_textobj];
h_textobj= findobj('tag','multiplizierer_k',...
	'type','text');
h_text=[h_text; h_textobj];
h_textobj= findobj('tag','multiplizierer_-k',...
	'type','text');
h_text=[h_text; h_textobj];
h_textobj= findobj('tag','multiplizierer_ny',...
	'type','text');
h_text=[h_text; h_textobj];
h_textobj= findobj('tag','(z)',...
	'type','text');
h_text=[h_text; h_textobj];
h_textobj= findobj('tag','verzoegerung',...
	'type','text');
h_text=[h_text; h_textobj];
h_textobj= findobj('tag','h(z)',...
	'type','text');
h_text=[h_text ;h_textobj];

h_push_ant = findobj...               % Finde Pushbutton 'antwort'
  ('tag','antwort');
h_push_filt = findobj...              % Finde Popupmenue 'filterung'
  ('tag','filterung');
h_push_gene = findobj...              % Finde Popupmenue 'generator'
  ('tag','generator_mat');
h_check_quant = findobj...            % Finde Checkbox 'quantisierung'
  ('tag','quantisierung');
struktur = get...                     % Lies dargestellte Struktur
  (h_pop_struktur,'value');
ansicht=get(h_radio_ansicht,'value'); % Lies Ansicht
if ( ansicht == 1)                    % Wenn Gesamtansicht
  x_lim = get(h_axes,'xlim');         % Lies waagerechte Grenzwerte
  y_lim = get(h_axes,'ylim');         % Lies senkrechte Grenzwerte
  new_value = get(h_slider_senk,'value');   % neue Sliderposition
  senkrecht = (0 - new_value)*10;     % Differenz ermitteln
  new_value = get(h_slider_waag,'value');   % neue Sliderposition
  set(h_radio_ansicht,...             % Setze String des Radiobuttons 'ansicht'
    'string','Gesamtansicht',...      % = 'Gesamtansicht'
    'userdata',[x_lim y_lim]);        % Speichere alte Grenzwerte in Userdata
 h_druck= findobj('tag','drucken');   % Pushbutton Drucken
 h_hilfe = findobj('tag','hilfe');    % Pushbutton Hilfe
 h_ende = findobj('tag','ende');      % Pushbutton Ende
 h_enable= findobj('type','uicontrol','enable','on');  % alle aktiven UIControl-Objekte
 set (h_enable,'enable','off');       % inaktiv setzen
 set (h_hilfe,'userdata',h_enable);   % vormals aktive Elemente merken
 set (h_radio_ansicht,'enable','on');  % notwendige Bedienelemente aktiv setzen
 set (h_druck,'enable','on');
 set (h_hilfe,'enable','on');
 set (h_ende,'enable','on');

  if((struktur == 1)|(struktur == 2)|(struktur == 3))
                                      % Wenn Direktform, 1.kan. Form oder 2.kan.Form
    set(h_slider_senk,...             % Setze senkrechten slider unsichtbar
      'visible','off');
    faktor = ordnung/5;               % Ermittle Verkleinerungsfaktor
    if (faktor < 1)                   % Wenn Faktor < 1 (weniger Elemente vor-
      faktor = 1;                     % handen als darstellbar) dann Faktor = 1
    end
    x_lim = x_lim .* faktor;          % Aktualisiere waagerechte Grenzwerte
    y_lim = (y_lim+senkrecht).*faktor;% Aktualisiere senkrechte Grenzwerte
  end                          
  if((struktur == 4)|(struktur == 5)|(struktur == 6)|(struktur == 7))
                                      % Wenn 3.kan. Form, Lattice oder Parallelform
    set(h_slider_waag,...             % Setze Waagerechten slider unsichtbar
      'visible','off');
    [z,p,k]=tf2zp(b,a);
    sos = zp2sos(z,p,k);              % sos aus Koeffizienten-Matrix lesen
    groesse_sos = size(sos);          % Matrixgroesse ermitteln
    ordnung = groesse_sos(1);         % Ordnung = Anzahl der Reihen
    faktor = ordnung/5;               % Ermittle Verkleinerungsfaktor
    waagerecht = (0 - new_value)*10;  % Differenz ermitteln
    if(struktur == 6)                 % Wenn Lattice-Struktur
      waagerecht=(0 - new_value)*10;% Differenz ermitteln
      [k,c] = lattice(b,a);           % Berechne Gitterkoeffizienten
      ordnung = length(k);            % Anzahl der Gitterstrukturen
      faktor = ordnung / 2;           % Ermittle Verkleinerungsfaktor
    end
    if (faktor < 1)                   % Wenn Faktor < 1 (weniger Elemente vor-
      faktor = 1;                     % handen als darstellbar) dann Faktor = 1
    end
    x_lim =(x_lim+waagerecht).*faktor;% Aktualisiere waagerechte Grenzwerte
    y_lim = y_lim .* faktor;          % Aktualisiere senkrechte Grenzwerte
  end
  set(h_axes,...                      % Aktualisiere Grenzwerte des Axesobjektes
    'xlim',x_lim,...
    'ylim',y_lim);
  if ( faktor > 1.5 )                 % Wenn Faktor > 1,5
    set(h_text,...                    % Setze Schriftgroesse aller Text-Objekte
      'fontsize',5);                  % innerhalb Axes auf 5
  end
else                                  % Wenn Teilansicht
  matrix = get...                     % Lies alte Grenzwerte aus userdata
    (h_radio_ansicht,'userdata');
  x_lim = matrix(1:2);                % Extrahiere waagerechte Grenzwerte
  y_lim = matrix(3:4);                % Extrahiere senkrechte Grenzwerte
  set(h_radio_ansicht,...             % Setze String = 'Ausschnitt'
    'string','Teilansicht');
  if((struktur == 1)|(struktur == 2)|(struktur == 3))
                                      % Wenn Direktform, 1.kan. Form oder 2.kan.Form
    set(h_slider_senk,...             % Setze senkrechten Slider sichtbar
      'visible','on');
  end
  if((struktur == 4)|(struktur == 5)|(struktur == 6)|(struktur == 7))
                                      % Wenn 3.kan. Form, Lattice oder Parallelform
    set(h_slider_waag,...             % Setze waagerechten Slider sichtbar
      'visible','on');
  end
  set(h_axes,...                      % Aktualisiere die Grenzwerte des 
    'xlim',x_lim,...                  % Axes-Objektes
    'ylim',y_lim);
  set(h_text,...                      % Ruecksetzen der Schriftgroesse aller
    'fontsize',12);                   % Textobjekte innerhalb Axes auf 12
 h_hilfe = findobj('tag','hilfe');    % Pushbutton Hilfe
 h_enable = get (h_hilfe,'userdata'); % Vormals aktive Elemente ermitteln
 set (h_enable,'enable','on');        % aktiv setzen
end                                   % Ende von Teil- oder Gesamtansicht
