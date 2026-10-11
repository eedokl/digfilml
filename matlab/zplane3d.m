function [hdl,hdl2]=zplane3d(b,a);

% Diese Funktion zeichnet eine dreidimensionale
% z-Ebene
%
% Der Aufruf erfolgt aus der Funktion filtplot.m;
%
% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover
%

ANZAHL=50;

% Berechne komplexe z-Werte
if nargin==1, a=1; end
z=cplxgrid(ANZAHL)*2;
iZ=1./(z+eps);

% Berechne Amplitude = f(z)
Wb=0;
for k=1:length(b)
  Wb=Wb+b(k).*(iZ.^(k-1));
end
Wa=0;
for k=1:length(a)
  Wa=Wa+a(k).*(iZ.^(k-1));
end

% Logarithmische Darstellung
Wb=Wb./Wa; Wb=20*log10(abs(Wb)+eps);

% Begrenzung des Darstellungsbereiches
ind=find(Wb>100); Wb(ind)=100*ones(size(ind));
ind=find(Wb<-95); Wb(ind)=-95*ones(size(ind));

% Zeichne z-Ebene
hdl=surf(real(z),imag(z),Wb); hold on;

% 'Boden'-Darstellung
z=cplxgrid(ceil(ANZAHL/5*2))*2;
hdl2=mesh(real(z),imag(z),-100+zeros(size(z))); hold off;

% Ymin auf -100 setzen
limit=get(gca,'Zlim');
set(gca,'ZLim',[-100 limit(2)]);

% set Viewpoint and colormap
view(-10,30); colormap(pink); grid on;

% set some text to the plot
set(hdl,'Erasemode','background');
set(gca,'ZColor','k','XColor','k','YColor','k');
xlabel('Re(z)','Color','k'); ylabel('Im(z)','Color','k');
zlabel('Amplitude in dB','Color','k');
