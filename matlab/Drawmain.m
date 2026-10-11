function drawmain(b,a,filename)

% drawmain(b,a,filename)
%
% interne Funktion zum neuzeichnen
% eventuell eingeschalteter
% Grafikmodi im Hauptfenster
%
% Die 'Tag's sind vorgegeben !
%
% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover
%

  if ~isempty(findobj('Tag','plotter_Achse1'))
    if isempty(b), filtplot('close');
    else
      hdl_edit=findobj('Tag','plotter_title_edit');
      hdl_ax=findobj('Tag','plotter_Achse1');
      hdl_ti=get(hdl_ax,'Title');
      set(hdl_edit,'String','');
      set(hdl_ti,'String','');
      filtplot('NewDisplay');
    end
  elseif ~isempty(findobj('Tag','time_Achse1'))
    if isempty(b), filttime('close');
    else
      hdl_edit=findobj('Tag','time_title_edit');
      hdl_ax=findobj('Tag','time_Achse1');
      hdl_ti=get(hdl_ax,'Title');
      set(hdl_edit,'String','');
      set(hdl_ti,'String','');
      filttime('NewDisplay');
    end
  end