function printok(parameter);
%
% printok(parameter);
%
% parameter : 'Landscape' oder 'Portrait'
%
% Drucke aktuelle Grafik auf A4
% Parameter = Portrait / Landscape
% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover

if strcmp(parameter,'Portrait')
  PapPos=[1 2.6 18 26.4];
elseif strcmp(parameter,'Landscape')
  PapPos=[0.6 1.9 26.4 18];
else
  disp('Parameter unbekannt ! Druck abgebrochen ...');
  return
end
ax=findobj(gcf,'Type','axes');
if isempty(ax)
  uiwait(msgbox('Druckauftrag angehalten','Fehler','none','Modal')); 
else
  old=get(gcf,'Units');
  set(gcf,'Units','normalized');

  global b a;

  dat=sprintf('%s',date);
  dx=-0.58;
  time=clock; time=time(4:5); time=sprintf('%02d:%02d',time);
  order=max(length(b),length(a))-1;

  h=text(dx,.95,'DSP-Labor: DIGFILML','color','k','Units','normalized');
  h(2)=text(dx,.9,['Datum: ',dat],'color','k','units','normalized');
  h(3)=text(dx,.85,['Uhrzeit: ',time,' Uhr'],'color','k','units','normalized');
  h(4)=text(dx,.75,sprintf('Filterordnung: %d',order),'color','k','units','normalized');
  h(5)=text(dx,.65,'Filterkoeffizienten:','color','k','units','normalized');
  h(6)=text(dx,.60,' >> siehe Protokolldatei','color','k','units','normalized');

  set(gcf,'Paperorientation',parameter,...
          'PaperType','A4Letter',...
          'PaperUnits','Centimeters',...
          'PaperPosition',PapPos);

  drawnow;
  print -dwin -noui

  delete(h);
  set(gcf,'Units',old);

end
