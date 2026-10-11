function digintro(anzahl,scale)

% Erstellt eine Rotationsdemo
% als Intro für DIGFILML
%
% Aufruf: digintro(anzahl,scale);
%
%         anzahl = Anzahl Rotationsschritte
%         scale  = Skalierungsfaktor für Rotaionskörper
%
% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover

if nargin==0
  anzahl=200; scale=700;
end


w=pi/20;
x=pi/24*4; y=pi; z=pi/2;

RKD=[-1 -1  0  1  1  0 -1 -1 -1 0 1  1  0 -1;...
     -2  2  2  1 -1 -2 -2 -2  2 2 1 -1 -2 -2;...
      0  0  0  0  0  0  0  1  1 1 1  1  1  1];
RKD(1,:)=RKD(1,:)-2;

RKI=[ -1 -1 1 1  1 -1 -1 -1 -1 -1 -1  1 1  1  1 1 -1;...
      -4  4 4 4 -4 -4  4  4 -4 -4 -4 -4 4 -4 -4 4  4;...
       0  0 0 1  1  1  1  0  0  1  0  0 0  0  1 1  1]/2;

RKG=[1 0 0 1  1  1 1  1 -1 -1 -1 1 1 -1 -1 -1 -1 -1  1;...
     0 0 0 0 -2 -2 0 -2 -2  2  2 2 2  2  2 -2 -2 -2 -2;...
     0 0 1 1  1  0 0  0  0  0  1 1 0  0  1  1  0  1  1];

RKF=[-1 -1 1 1 0 0 1  1  0  0 -1 -1 -1 1 1 0 0 1  1  0  0 -1;...
     -2  2 2 1 1 0 0 -1 -1 -2 -2 -2  2 2 1 1 0 0 -1 -1 -2 -2;...
      0  0 0 0 0 0 0  0  0  0  0  1  1 1 1 1 1 1  1  1  1  1];

RKL=[-1 -1 0  0  1  1 -1 -1 -1 0  0  1  1 -1;...
     -2  2 2 -1 -1 -2 -2 -2  2 2 -1 -1 -2 -2;...
      0  0 0  0  0  0  0  1  1 1  1  1  1  1];

RKM=[-1 -1 0 1  1  1 1 1 0 0  1 0 -1 -1 -1 -1 -1;...
     -2  2 0 2 -2 -2 2 2 0 0  2 0 2  2 -2 -2  2;...
      0  0 0 0  0  1 1 0 0 1  1 1 1  0  0  1  1];

if ~figflag('DIGFILML')
  pos=get(0,'ScreenSize');
  hf=figure;
  set(hf,'MenuBar','none','Name','DIGFILML','NumberTitle','off','position',pos);
end
l1=plot(0,0);
set(gcf,'MenuBar','none','Name','DIGFILML','NumberTitle','off');
l2=line(0,0); l3=line(0,0); l4=line(0,0); l5=line(0,0);
l6=line(0,0); l7=line(0,0); l8=line(0,0);
set([l1,l2,l3,l4,l5,l6,l7,l8],'EraseMode','background');

axis('off');

PM=[-cos(w)  cos(w) 0; -sin(w) -sin(w) 1];

CYl=[cos(y) 0 -sin(y);0 1 0; sin(y) 0 cos(y)];
CZl=[1 0 0;0 cos(z) sin(z);0 -sin(z) cos(z)];
Cl=CYl*CZl;

CXr=[cos(x) sin(x) 0;-sin(x) cos(x) 0;0 0 1];
CYr=[cos(y) 0 -sin(y);0 1 0; sin(y) 0 cos(y)];
Cr=PM*CXr*CYr;

pos=axis; pos(2)=pos(2)+2;
axis([-30000 140000 -20000 20000]);
set(gcf,'units','normalized');

for i=1:anzahl
  xl=x-4*pi/anzahl*i;
  zr=z+4*pi/anzahl*i;

  CXl=[cos(xl) sin(xl) 0;-sin(xl) cos(xl) 0;0 0 1];


  CZr=[1 0 0;0 cos(zr) sin(zr);0 -sin(zr) cos(zr)];
  factor=scale*i.^(.4);

  AMD=Cr*CZr*RKD*factor;
  AMI=PM*CXl*Cl*RKI*factor;
  AMG=Cr*CZr*RKG*factor;
  AMF=PM*CXl*Cl*RKF*factor;
  AML=Cr*CZr*RKL*factor;
  AMM=PM*CXl*Cl*RKM*factor;

  set(l1,'Xdata',AMD(1,:),'YData',AMD(2,:));
  set(l2,'Xdata',AMI(1,:),'YData',AMI(2,:));
  set(l3,'Xdata',AMG(1,:)+3*factor,'YData',AMG(2,:));
  set(l4,'Xdata',AMF(1,:)+7*factor,'YData',AMF(2,:));
  set(l5,'Xdata',AMI(1,:)+10*factor,'YData',AMI(2,:));
  set(l6,'Xdata',AML(1,:)+13*factor,'YData',AML(2,:));
  set(l7,'Xdata',AMM(1,:)+18*factor,'YData',AMM(2,:));
  set(l8,'Xdata',AML(1,:)+22*factor,'YData',AML(2,:));

  drawnow;

  if get(gcf,'UserData')==1, i=anzahl; end
end

h=text(-80000,15000,'Digitale Filter unter MATLAB');
set(h,'EraseMode','background');
for i=1:200
pos=get(h,'position'); pos(1)=pos(1)+500;
set(h,'Position',pos); drawnow;
end
h=text(120000,-16000,'Ein Filterentwurfsprogramm von Oliver Klein');
set(h,'EraseMode','background');
for i=1:200
pos=get(h,'position'); pos(1)=pos(1)-500;
set(h,'Position',pos); drawnow;
end
waitforbuttonpress;
close(hf);
