function fig=ctrlmenu(parameterfile,fig);

% CTRLMENU - creates a pull down menu in the title bar of a figure
% --------------------------------------------------------------------------------
% Syntax:
% fig=ctrlmenu(parameterfile,fig);
%
% This command creates a pull down menu in the title bar of a MATLAB
% figure. You can optionally specify the name of the parameterfile (string)
% and the figure handle (real). The parameterfile describes the menu-
% hierarchy in a special ASCII-file with the following syntax:
%
% Syntax Parameterfile:
%
%         <		-	Begin of submenu
%         >		-	End of submenu
%         ~		-	The menu is checked
%         @		-	The following letter is the key-combination with CTRL
%         &		-	The following letter is the key-combination with ALT
%         §		-	The menu is not enabled
%         %		-	Comment
%	  Spaceline	-	Separating line between the menus
%         ,		-	After ',' follows the MATLAB command
%         =		-	The previous name '=' described the global variable
%
% Type CTRLMENU without parameters, to display the example from CTRLMENU.TXT.

% J. Stöcker, 11/94
% Copyright (c) 1994 by Scientific Computers, Germany
% All Rights Reserved.

if nargin==0
	parameterfile='ctrlmenu.txt';
	fig=[];
elseif nargin==1
	fig=[];
elseif nargin==2
	if isempty(find(get(0,'Children')==fig))&~isempty(fig)
		error('Invalid figure handle!');
	end
else
	error('Wrong number of input parameters!');
end                           

if exist(parameterfile)==2
	[file message]=fopen(parameterfile,'r');
	if file==-1
		error(message);
	else
		ebene=0;
        counter=0;
        
		line=fgetl(file);
		while line~=-1
			if find(line=='%')
				pos=find(line=='%');
				if pos(1)~=1
					line=line(1:pos(1)-1);
					pos=find(abs(line)>32);
					if isempty(pos)
						line=0;
					end
				else
					line=0;
				end
			end
			if find(abs(line)>32)
				i=find(abs(line)>32);
				line=line(i(1):i(length(i)));				% clear leading spaces
				
				if ~isempty(find(line=='<'))
					ebene=ebene+1;
				elseif ~isempty(find(line=='>'))
					ebene=ebene-1;
				else
					if find(line==',')						% seperate title from command
						i=find(line==',');
						titel=line(1:i(1)-1);
						befehl=line(i(1)+1:length(line));
					else
						titel=line;
						befehl='';
					end	
			        if find(titel=='@')						% Accelerator
			        	i=find(titel=='@');
			        	acc_char=titel(i+1);
			        	titel=[titel(1:i(1)-1) '	Ctrl ' acc_char];
			        else
			        	acc_char='';
					end
					if find(titel=='~')						% Checked on
			        	check='on';
			        	i=find(titel=='~');
			        	if i(1)==1
				        	titel=titel(2:length(titel));
				       	elseif i(1)<length(titel)
				        	titel=[titel(1:i(1)-1) titel(i(1)+1:length(titel))];
				       	else
				        	titel=titel(1:i(1)-1);
				        end
			        else
			        	check='off';
					end

					if find(titel=='§')						% Enabled off
			        	enable='off';
			        	i=find(titel=='§');
			        	if i(1)==1
				        	titel=titel(2:length(titel));
				       	elseif i(1)<length(titel)
				        	titel=[titel(1:i(1)-1) titel(i(1)+1:length(titel))];
				       	else
				        	titel=titel(1:i(1)-1);
				        end
			        else
			        	enable='on';
					end

			        if ~isempty(find(titel=='='))			% global variable
			        	pos=find(titel=='=');
			        	var=titel(1:pos-1);
			        	titel=titel(pos+1:length(titel));
			        else
			        	var=[];
					end
					if (ebene==0)&isempty(fig)
						fig=figure(	'Name',titel,'Visible','off');
						h(1)=fig;
					elseif (ebene==0)
						set(fig,'Name',titel);
						h(1)=fig;
					else
						h(ebene+1)=uimenu(h(ebene),'Label',titel,'Callback',befehl,'Separator',sep_flag,'Accelerator',acc_char,'Checked',check,'Enable',enable);
						if ~isempty(var)
							command=['global ' var];
							eval(command);
							command=[var '=h(' num2str(ebene+1) ');'];
							eval(command);
						end
					end
				end
				sep_flag='off';
			else
				if line~=0
					sep_flag='on';
				end
			end
			line=fgetl(file);
		end
		fclose('all');

		if nargin==0
			set(fig,'MenuBar','none');
			set(fig,'NumberTitle','off');
			set(fig,'Visible','on');
		end

		if ebene~=0
			message='Hierarchie-Ebenen Fehler, ungleiche Anzahl von < und >!';
			error(message);
		end
    end
else
	message=['Parameterfile ' parameterfile ' existiert nicht!'];
	error(message);
end
