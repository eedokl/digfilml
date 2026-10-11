function zoomok(action,x_check)
% ZOOMOK - Zoomfunktion für das DIGFIL-Modul ZMENU
%
% ZOOMOK('down',{x_check});
% geplante Version : ZOOMOK('down',Tag1,Tag2,{x_check});
% (Tag1 und Tag2 sind bisher fest vereinbart)
%
% Eine Angabe von x_check schränkt den
% zoombaren x-Bereich ein.
%
% Zoom in erfolgt mit der linken Maustaste,
% Zoom out mit der rechten Maustaste.
%
% Version 1.0 12-Mar-97 by Oliver Klein
%
% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover


% action :
%   Down - Maustaste gedrückt, starte 'rubberband' zoom in/out
%   Off  - Zoom aus, Achsendaten verbleiben in Linien-USERDATA

maxax=16;                       % Maximale Zoomtiefe

%==================
% Button gedrückt =
%==================
if strcmp(action,'down');
  %================
  % linker Button =
  %================
  cp=get(gcf,'CurrentPoint');
  curax1=findobj('Tag','z_SP');
  curax2=findobj('Tag','z_SP2');
  if isempty(curax2), curax2=curax1; end
  pos1=get(curax1,'Position'); %Spektrum 1
  pos2=get(curax2,'Position'); %Spektrum 2
  if cp(1,1)>pos2(1)&cp(1,1)<sum(pos2([1,3]))...
    &cp(1,2)>pos2(2)&cp(1,2)<sum(pos2([2,4]))
    curax=curax2;
  elseif cp(1,1)>pos1(1)&cp(1,1)<sum(pos1([1,3]))...
        &cp(1,2)>pos1(2)&cp(1,2)<sum(pos1([2,4]))
    curax=curax1;
  else
    return;
  end

  set(gcf,'CurrentAxes',curax);
  ZOOMDATA=get(curax,'UserData');

  if ~isempty(ZOOMDATA)
    %=======================
    % neue Achse angewählt =
    %=======================
    axnum=ZOOMDATA(1);
    aspect=ZOOMDATA(2);
    axhist=zeros(maxax,4);
    axhist(:)=ZOOMDATA(4:length(ZOOMDATA));
  else
    %==================
    % speichere Achse =
    %==================
    if strcmp(action,'aspect'), aspect=1; else aspect=0; end;
    axhist=zeros(maxax,4);
    axnum=1;
    axhist(axnum,:)=axis;   % remember the first axis parameters
    ZOOMDATA=[axnum aspect curax axhist(:)'];
    set(curax,'UserData',ZOOMDATA);
  end

  % We now have the original variables.
  mousebtn = get(gcf,'SelectionType');
  %================
  % linker Button =
  %================
  if strcmp(mousebtn, 'normal');
    %==========
    % ZOOM IN =
    %==========
    if axnum<maxax,
      axnum = axnum+1;
      cpa=get(curax,'CurrentPoint');
      x1=cpa(1,1);y1=cpa(1,2);
      %========================================
      % 1.Punkt eingelesen, starte rubberband =
      %========================================
      % Achseneinstellung =
      %====================
      ax=axis;
      %=======================================
      % speichere aktuelle UNITS-Einstellung =
      %=======================================
      CurUnitsA=get(curax,'Units');
      %========================
      % Achsen-units in pixel =
      %========================
      set(curax, 'Units', 'pixels');
      fpa=get(curax, 'Position');
      %===========================
      % Achsenunits zurücksetzen =
      %===========================
      set(curax, 'Units', CurUnitsA);
      %=====================
      % Nun für das figure =
      %=====================
      CurUnitsF=get(gcf,'Units');
      set(gcf, 'Units', 'pixels');
      fpf=get(gcf, 'Position');

      ppux=fpa(3)/(ax(2)-ax(1));      % Pixel pro unit x-Achse
      ppuy=fpa(4)/(ax(4)-ax(3));      % Pixel pro unit y-Achse
      cpf=get(gcf, 'CurrentPoint');   % Original Zoom
      set(gcf, 'Units', CurUnitsF);   % setze Figure
      cp0=get(0, 'PointerLocation');  % -> immer in Pixel
%      rbbox([cpf 0 0], [cpf]);        % Aufruf von rbbox
      rbbox;
      cp0fin=get(0, 'PointerLocation');     
      dyfin=cp0fin(2)-fpf(2)-fpa(2);
      dxfin=cp0fin(1)-fpf(1)-fpa(1);
      y2=dyfin ./ ppuy + ax(3);
      x2=dxfin ./ ppux + ax(1);
      x=[x1 x2];x1=min(x);x2=max(x);  % sortieren
      y=[y1 y2];y1=min(y);y2=max(y);
      if aspect,
         if abs(x2-x1)>abs(y2-y1),
            y2=y1+(x2-x1)*(ax(4)-ax(3))/(ax(2)-ax(1));
         else
            x2=x1+(y2-y1)*(ax(2)-ax(1))/(ax(4)-ax(3));
         end;
      end;
      %========================================
      % Spektum im x-Bereich 0/0.5 belassen : =
      %========================================
      if exist('x_check')
        if x1<x_check(1),x1=x_check(1);elseif x2>x_check(2),x2=x_check(2);end
      end
      axhist(axnum,:)=[x1-eps x2+eps y1-eps y2+eps];  % Store it
      axis(axhist(axnum,:));          % Set it
      ZOOMDATA=[axnum aspect curax axhist(:)'];
      set(curax,'UserData',ZOOMDATA);
    end;

  elseif strcmp(mousebtn,'alt')
    %===========
    % ZOOM OUT =
    %===========
    if axnum>1,
      axhist(axnum,:)=ones(1,4).*NaN;
      axnum = axnum-1;
      axis(axhist(axnum,:));
      ZOOMDATA=[axnum aspect curax axhist(:)'];
      set(curax,'UserData',[axnum aspect curax axhist(:)']);
    end;
  end;
elseif strcmp(action,'off');
  %===========
  % ZOOM aus =
  %===========
  set(gca,'ButtonDownFcn','');
end

