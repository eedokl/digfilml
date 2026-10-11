function b=meteor(action,param,hilf,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15);

% meteor('extern',Lsmallest1,Llargest2,symtype3,whattodo4,spectype5,sense6,...
%      interpolate7,hug8,anz9,left10,right11,bound1 12,bound2 13, whichwy, bandpushed);
% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover


if nargin==0, action='init'; end

MAXPIVOTS = 1000;
SMALL = 1e-8;
LARGE = 1e31;
MMAX = 64;
NCOLMAX = 6000;
EPS = 1e-8;

global done unbounded optimal
global result iteration m n symtype
global pivotcol pivotrow pivotel
global cbar coeff carry phase basis nspec spectype
global left right freq bound1 bound2
global sense interpolate firstcol lastcol foundfeas
global mlargest msmallest ncol tab d c curcol
global curcost hug whattodo npushed whichway bandpushed oddlength
global beste

if strcmp(action,'init')
  meteor('getdata');
  if strcmp(whattodo,'findlen'), meteor('getm');
  elseif strcmp(whattodo,'pushedge'), meteor('getedge');
  elseif strcmp(whattodo,'maxdist'), meteor('getmaxdist'); end
  meteor('wrapup');

elseif strcmp(action,'getdata')
  Lsmallest=16*2*2; Llargest=16*2*2;
  Lsmallest=28; Llargest=28;
  symtype='cosine';
  oddlength=rem(Lsmallest,2);
  if oddlength
    if strcmp(symtype,'cosine')
      msmallest=fix((Lsmallest+1)/2);
      mlargest=fix((Llargest+1)/2);
    else
      msmallest=fix((Lsmallest-1)/2);
      mlargest=fix((Llargest-1)/2);
    end
  else
    msmallest=fix(Lsmallest/2);
    mlargest=fix(Llargest/2);
  end
  whattodo='pushedge';
%  whattodo='maxdist';
  spectype='llll';
  sense='+-+-';
  interpolate='aaaa';
  hug='nnnn';
  n=201;
  whichway='ll';
%  left= [  0   0 .3 .3];
%  right=[.25 .25 .5 .5];
%  bound1=[1.1 .9 .01 -.01];
%  bound2=[1.1 .9 .01 -.01];

  left= [ 0  0 .3 .3];
  right=[.2 .2 .5 .5];
  Rp=3;Rs=60;
  devs = [ (10^(Rp/20)-1)/(10^(Rp/20)+1)  10^(-Rs/20) ];
  bound1=[1+devs(1),1-devs(1),devs(2),-devs(2)]; bound2=bound1;

  nspec=4;
  for i=1:nspec, meteor('makebands',i); end
  ncol=lastcol(nspec);
  bandpushed=[3 4];
  npushed=length(bandpushed);
  m=msmallest;

elseif strcmp(action,'extern')
  Lsmallest=param;
  Llargest=hilf;
  symtype=p3;
  oddlength=rem(Lsmallest,2);
  if oddlength
    if strcmp(symtype,'cosine')
      msmallest=fix((Lsmallest+1)/2);
      mlargest=fix((Llargest+1)/2);
    else
      msmallest=fix((Lsmallest-1)/2);
      mlargest=fix((Llargest-1)/2);
    end
  else
    msmallest=fix(Lsmallest/2);
    mlargest=fix(Llargest/2);
  end
  whattodo=p4;
  spectype=p5;
  sense=p6;
  interpolate=p7;
  hug=p8;
  n=p9;

  left=p10;
  right=p11;
  bound1=p12;
  bound2=p13;
  nspec=length(left);
  for i=1:nspec, meteor('makebands',i); end
  ncol=lastcol(nspec);
  if strcmp(whattodo,'findlen'), meteor('getm');
  elseif strcmp(whattodo,'pushedge'),
    whichway=p14;
    bandpushed=p15;
    m=msmallest;
    npushed=length(bandpushed);
    meteor('getedge');
  elseif strcmp(whattodo,'maxdist'), meteor('getmaxdist'); end
  meteor('wrapup');

elseif strcmp(action,'makebands')
  i=param;
  if i==1, firstcol(i)=1; else firstcol(i)=lastcol(i-1)+1; end
  kmax=floor((right(i)-left(i))*n/0.5+SMALL);
  if kmax==0, freq(firstcol(i))=2*pi*left(i);
  else
    freq(firstcol(i)+(0:kmax))=2*pi*(left(i)+(right(i)-left(i))*(0:kmax)/kmax);
  end
  lastcol(i)=firstcol(i)+kmax;

elseif strcmp(action,'getm')
  foundfeas=0; iteration=0;
  leftm=msmallest; rightm=mlargest;
  foundm=0; checkedleft=0; checkedright=0;
  while ~foundm
    if iteration==0, m=leftm+fix((rightm-leftm)/2); end
    iteration=iteration+1;
    title(sprintf('Iteration %d',iteration));
    if oddlength
      if strcmp(symtype,'cosine'), xlabel(sprintf('Ordnung N= %d',2*m-2));
      else, xlabel(sprintf('Ordnung N= %d',2*m)); end
    else, xlabel(sprintf('Ordnung N= %d',2*m-1)); end
    drawnow;
    meteor('setup');
    meteor('simplex');
    meteor('printresult');

    if result==5
      foundfeas=1;
      rightm=m; bestm=m;
      checkedright=1;
      if oddlength
        if strcmp(symtype,'cosine'),
          ylabel(sprintf('neue minimale Ordnung N= %d',2*bestm-2));
        else ylabel(sprintf('neue minimale Ordnung N= %d',2*bestm)); end
      else, ylabel(sprintf('neue minimale Ordnung N= %d',2*bestm-1)); end
      coeff(1:m)=-carry(1,2:(m+1));
    end
    if result~=5, leftm=m; checkedleft=1; end
    if rightm > (leftm+1), m=leftm+fix((rightm-leftm)/2); end
    if rightm == (leftm+1)
      if ~checkedleft, m=leftm; checkedleft=1;
      elseif ~checkedright, m=rightm; checkedright=1;
      else foundm=1; end
    end
    if rightm==leftm, foundm=1; end
  end %while
  if ~foundfeas, title('keine Lösung gefunden'); return; end
  m=bestm;
  if oddlength
    if strcmp(symtype,'cosine')
      title(sprintf('Filter %d. Ordnung gefunden',2*bestm-2));
    else
      title(sprintf('Filter %d. Ordnung gefunden',2*bestm));
    end
  else, title(sprintf('Filter %d. Ordnung gefunden',2*bestm-1)); end

elseif strcmp(action,'setup')
  for i=1:nspec
    if spectype(i)=='c', meteor('convex',i);
    elseif spectype(i)=='l', meteor('limit',i); end
  end
  ncol=lastcol(nspec);

elseif strcmp(action,'simplex')
  done=0; phase=1;

  carry=zeros(m+2,MMAX+2);
  carry(2:(m+2),2:(m+2))=eye(m+1);
  carry(1,1)=-1;
  curcost=-carry(1,1);
  carry(m+2,1)=1;
  basis(1:(m+1))=-(0:m);
  if ncol <= NCOLMAX
    d(1:ncol)=-sum( tab(1:(m+1),1:ncol) );
  else
    done=1; result=1; % too many cloumns used
  end
  numpivots=0;
  while (numpivots < MAXPIVOTS)&(~done)&((curcost>(-EPS))|(phase==1))
    meteor('columnsearch');
    if ~optimal
      meteor('rowsearch');
      if unbounded, done=1; result=2;
      else, meteor('pivot'); numpivots=numpivots+1; end
    else
      if phase==1
        if curcost>EPS, done=1; result=3;
        else, meteor('changephase'); end
      else, done=1; result=5; end
    end
  end
  if (curcost <= (-EPS))&(phase==2), result=6; end
  if (numpivots >= MAXPIVOTS), result=4; end

elseif strcmp(action,'columnsearch')
  tempcost=d(1:ncol)+ carry(1,2:(m+2))*tab(1:(m+1),1:ncol);
  [cbar,pivotcol]=min(tempcost);
  if cbar > -EPS, optimal=1; else optimal=0; end

elseif strcmp(action,'rowsearch')
  curcol(1:(m+2))=[cbar (carry(2:(m+2),2:(m+2)) * tab(1:(m+1),pivotcol)).'];
  pivotrow=-1; minratio=LARGE;
  pivotrow=max(pivotrow);
  for i=0:m
    if curcol(i+2)>EPS
      ratio=carry(i+2,1)/curcol(i+2);
      if minratio>ratio
        minratio=ratio; pivotrow=i;
        pivotel=curcol(i+2);
      else
        if (minratio==ratio)&(pivotel<curcol(i+2)),
          pivotrow=i; pivotel=curcol(i+2);
        end
      end
    end
  end
  if pivotrow==-1, unbounded=1;
  else unbounded=0; end

elseif strcmp(action,'pivot')
  basis(pivotrow+1)=pivotcol;
  carry(pivotrow+2,1:(m+2))=carry(pivotrow+2,1:(m+2))/pivotel;
  i=-1:m; i(find(i==pivotrow))=[];
  dummy=carry(pivotrow+2,1:(m+2)); dummy2=curcol(i+2);
  carry(i+2,1:(m+2))=carry(i+2,1:(m+2))-dummy(ones(1,(m+1)),:).*dummy2(ones(1,(m+2)),:).';
  curcost=-carry(1,1);

elseif strcmp(action,'changephase')
  phase=2;
  d(1:ncol)=c(1:ncol);
  carry(1,1:(m+2))=zeros(1,m+2);
  index=find(basis(1:(m+1))>=1);
  carry(1,1:(m+2))=carry(1,1:(m+2))-c(basis(index))*carry(index+1,1:(m+2));
  curcost=-carry(1,1);

elseif strcmp(action,'printresult')
  if result==1
    title('Spezifikation zu aufwendig');
  elseif result==2
    title('Spezifikation verletzt');
  elseif result==3
    title('Spezifikation verletzt');
  elseif result==4
    title('too many pivots');
  elseif result==5
    title('Optimum gefunden');
  elseif result==6
    title('Spezifikation verletzt');
  end
  drawnow;
elseif strcmp(action,'convex')
  i=param;
  meteor('makebands',i);
  col=firstcol(i):lastcol(i);
  c(col)=zeros(1,length(col));
  matrix1=0:(m-1).'; matrix1=matrix1(ones(1,length(col)),:).';
  matrix2=freq(col); matrix2=matrix2(ones(1,m),:);
  tab(1:m,col)=meteor('trig2',matrix1,matrix2);
  if sense(i)=='+', tab(1:m,col)=-tab(1:m,col); end
  tab(m+1,col)=zeros(1,length(col));

elseif strcmp(action,'limit')
  i=param;
  meteor('makebands',i);
  col=firstcol(i):lastcol(i);
  if firstcol(i)==lastcol(i), c(col)=bound1(i);
  else
    if interpolate(i)=='g'
      c(col)=bound1(i)*exp(((col-firstcol(i))/(lastcol(i)-firstcol(i)))*log(abs(bound2(i)/bound1(i))));
    elseif interpolate(i)=='a'
      c(col)=bound1(i)+((col-firstcol(i))/(lastcol(i)-firstcol(i))*(bound2(i)-bound1(i)));
    end
  end
  if sense(i)=='-', c(col)=-c(col); end
  matrix1=0:(m-1).'; matrix1=matrix1(ones(1,length(col)),:).';
  matrix2=freq(col); matrix2=matrix2(ones(1,m),:);
  tab(1:m,col)=meteor('trig0',matrix1,matrix2);
  if sense(i)=='-', tab(1:m,col)=-tab(1:m,col); end
  if hug(i) ~= 'h', tab(m+1,col)=ones(1,length(col));
  else tab(m+1,col)=zeros(1,length(col)); end

elseif strcmp(action,'trig0')
  i=param; f=hilf;
  if oddlength
    if strcmp(symtype,'cosine'), b=cos(i.*f);
    else b=sin((i+1).*f); end
  else
    if strcmp(symtype,'cosine'), b=cos((i+.5).*f);
    else b=sin((i+.5).*f); end
  end

elseif strcmp(action,'trig2')
  i=param; f=hilf;
  if oddlength
    if strcmp(symtype,'cosine'), b=-i.*i.*cos(i.*f);
    else b=-(i+1).*(i+1).*sin((i+1).*f); end
  else
    if strcmp(symtype,'cosine'), b=-(i+0.5).*(i+0.5).*cos((i+.5).*f);
    else b=-(i+0.5).*(i+0.5).*sin((i+.5).*f); end
  end

elseif strcmp(action,'getedge')
  onespace=0.5/n;
  stopspace=onespace/10;
  if strcmp(whichway,'rr')
    lefte=left(bandpushed(1));
    for i=2:npushed
      if left(bandpushed(i)) > lefte, lefte=left(bandpushed(i)); end
    end
    righte=0.5;
  else
    lefte=0;
    righte=right(bandpushed(1));
    for i=2:npushed
      if right(bandpushed(i)) < righte, righte=right(bandpushed(i)); end
    end
  end
  iteration=0;
  foundfeas=0;
  while (righte-lefte) > stopspace
    iteration=iteration+1;
    newe=(righte+lefte)/2;
    title(sprintf('Iteration %d',iteration));
    xlabel(sprintf('teste Eckfrequenz: %f',newe));
    for i=1:npushed
      if strcmp(whichway,'rr'), right(bandpushed(i))=newe;
      else left(bandpushed(i))=newe; end
    end
    meteor('setup');
    meteor('simplex');
    meteor('printresult');
    if result==5
      if strcmp(whichway,'rr'), lefte=newe; else righte=newe; end
      foundfeas=1;
      beste=newe;
      for i=0:(m-1), coeff(i+1)=-carry(1,i+2); end
    else
      if strcmp(whichway,'rr'), righte=newe; else lefte=newe; end
    end
  end
  if ~foundfeas, title('keine Eckfrequenz gefunden'); return; end
  title(sprintf('Eckfrequenz %f gefunden',beste));
  for i=1:npushed
    if strcmp(whichway,'rr'), right(bandpushed(i))=beste;
    else left(bandpushed(i))=beste; end
  end
  for i=1:nspec, meteor('makebands',i); end

elseif strcmp(action,'getmaxdist')
  meteor('setup');
  meteor('simplex');
  if result==5
    xlabel(sprintf('final cost= distance from constraints= %f',curcost));
    for i=0:(m-1), coeff(i+1)=-carry(1,i+2); end
  else
    return;
  end

elseif strcmp(action,'wrapup')
  if foundfeas
    if oddlength & strcmp(symtype,'cosine')
      num=[coeff(m:-1:2)/2 coeff(1) coeff(2:m)/2];
    end
    if ~oddlength & strcmp(symtype,'cosine')
      num=[coeff(m:-1:1)/2 coeff(1:m)/2];
    end
    if oddlength & strcmp(symtype,'sine')
      num=[-coeff(m:-1:1)/2 0 coeff(1:m)/2];
    end
    if ~oddlength & strcmp(symtype,'sine')
      num=[-coeff(m:-1:1)/2 coeff(1:m)/2];
    end
    hdl=findobj('Tag','MeteorForm');
    if ~isempty(hdl) % beste -> neue Eckfrequenz oder []
      set(hdl,'UserData',[num beste]); % OK_Button von Meteoform
    end
  end
  clear global done unbounded optimal
  clear global result iteration
  clear global m n
  clear global pivotcol pivotrow pivotel
  clear global cbar coeff carry phase basis nspec spectype
  clear global left right freq bound1 bound2
  clear global sense interpolate firstcol lastcol foundfeas
  clear global mlargest msmallest ncol tab d c curcol
  clear global curcost hug whattodo npushed whichway bandpushed oddlength
  clear global symtype beste

end
