function InfoDigf(action)
%***************************************************************%
% function InfoDigf.m						%
% Modul gehört zum Programm:		DIGFILML		%
% erstellt von:				Oliver Klein		%
% letzte Änderung:			Mai 1997		%
%								%
% Aufgabe:		Diese Funktion erzeugt ein Infofenster	%
%***************************************************************%

if nargin == 0
 
if ~exist('FONTSIZE')
	size = get(0,'ScreenSize');
	if size(3:4) == [640 480];
		FONTSIZE = 12;
	elseif size(3:4) == [800 600]; 
		FONTSIZE = 10;
	end;
end;	
 
text1 = 'DIGFILML';
text2 = 'Digitale Filter unter MATLAB - Diplomarbeit 04 / 97 - 07 / 97';
text3 = 'FH Hannover';
text4 = 'FB Elektrotechnik / FG Kommunikationstechnik';
text5 = 'erstellt von';
text6 = 'Oliver Klein';
text7 = 'Betreuer';
text8 = 'Prof. Dr.-Ing. Dieter Stark';
text9 = 'Prof. Dr.-Ing. Rudolf Nocker';

breite = 0.6*size(3); hoehe = 0.5*size(4);
x_links = 0.5*(size(3)-breite); y_unten = 0.5*(size(4)-hoehe);

fig = figure('Name','Information zu DIGFILML / Version 2.0',...
             'Color',[1 1 225/255],'Position',...
             [x_links y_unten breite hoehe],'NumberTitle','off','Resize',...
             'off','MenuBar','none','KeyPressFcn','dummy = 1;');

uicontrol('Style','pushbutton','Units','normalized','Position',...
[0.35 0.03 0.3 0.08],'String','O K','CallBack','InfoDigf(''close'')');
axes('XColor',[0 0 1],'YColor',[0 0 1],'Box','off','Visible','off');
text('String',text1,'Position',[0.5 0.95],'Color',[0 0 1],...
	'FontSize',FONTSIZE+15,'FontWeight','bold',...
	'HorizontalAlignment','center');
text('String',text2,'Position',[0.5 0.80],'Color',[0 0 1],...
	'FontSize',FONTSIZE,'FontWeight','bold',...
	'HorizontalAlignment','center');
text('String',text3,'Position',[0.5 0.65],'Color',[0 0 0],...
	'FontSize',FONTSIZE+3,'FontWeight','bold',...
	'HorizontalAlignment','center');
text('String',text4,'Position',[0.5 0.55],'Color',[0 0 0],'FontSize',...
	FONTSIZE,'FontWeight','bold','HorizontalAlignment','center');
text('String',text5,'Position',[0.05 0.35],'Color',[0 0 0],'FontSize',...
	FONTSIZE,'FontWeight','bold');
text('String',':','Position',[0.3 0.35],'Color',[0 0 0],'FontSize',...
	FONTSIZE,'FontWeight','bold');
text('String',text6,'Position',[0.5 0.35],'FontSize',FONTSIZE,...
	'FontWeight','bold','Color',[0 0 0]);
text('String',text7,'Position',[0.05 0.25],'Color',[0 0 0],'FontSize',...
	FONTSIZE,'FontWeight','bold');
text('String',':','Position',[0.3 0.25],'Color',[0 0 0],'FontSize',...
	FONTSIZE,'FontWeight','bold','Color',[0 0 0]);
text('String',text8,'Position',[0.5 0.25],'FontSize',FONTSIZE,...
	'FontWeight','bold','Color',[0 0 0]);
text('String',text9,'Position',[0.5 0.15],'FontSize',FONTSIZE,...
	'FontWeight','bold','Color',[0 0 0]);

else	
	if strcmp(action,'close')  
		close(gcf);
	end;
end;
