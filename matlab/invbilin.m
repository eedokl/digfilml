function [zs,ps]=invbilin(zd,pd,Fs);

% Funktionsaufruf: [zs,ps]=invbilin(zd,pd,{Fs});
%
% INVBILIN transformiert digitale Pole und Nullstellen
% der z-Ebene in analoge Pole und Nullstellen der s-Ebene.
% Wird die Abtastfrequenz Fs nicht angegeben gilt Fs=1.
%
% Der Verstärkungfaktor wird nicht berücksichtigt.


% quick & dirty
% Schleife, da sonst NaN-Meldung (warum auch immer)
% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover

if nargin==2, Fs=1; end

  for i=1:length(zd)
    if zd(i)==0, zs(i)=-2*Fs;
    elseif zd(i)==-1, zs(i)=Inf;
    else zs(i)=2*Fs*(1-1./zd(i))./(1+1./zd(i)); end
  end

  for i=1:length(pd)
    if pd(i)==0, ps(i)=-2*Fs;
    elseif pd(i)==-1, ps(i)=Inf;
    else ps(i)=2*Fs*(1-1./pd(i))./(1+1./pd(i)); end
  end







