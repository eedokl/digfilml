function [y,gain] = linphase(P,tol)
%LINPHASE  Linear phase reconstruction from min/maxphase.
%       [Y] = LINPHASE(P) returns a linear phase polynomial
%       for P if P was calculated by minphase or maxphase.
%       P is returned if P is already minimum phase.
%
%	[Y,G] = LINPHASE(P) returns the polynomial Y such
%	that the highest order coefficient is equal to one.
%	The gain is then returned in G.
%
%	LINPHASE(P,TOL) sets the tolerance used in pairing
%	complex roots using the CPLXPAIR command.  Default
%	tolerance is 0.0001.
%
%       See also MAXPHASE,MINPHASE

% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover
%
%       Adapted for use in DIGFILML, 23-05-97, Oliver Klein

% default return
y = [];

% figure out if we have a vector
if min(size(P)) ~= 1,
      disp('minphase: Input arg "P" must be a 1xN or Nx1 vector.');
      return
end;
if nargin ~= 2,
	tol = 0.0001;
end;

% work with Nx1 vectors
P = P(:);

% save gain
index = find(P ~= 0);
gain = P(index(1));

% find roots and sort
r = cplxpair(roots(P),0.0001);

% find multiple roots inside & outside & on unit circle
[t1,t2]=mpoles(r); r=r(t2);
index1=find(t1==2);
index2=find(t1~=2);

% mirror double roots
g=[r(index2); (1 ./ conj(r(index1)))];

% calculate new gain
gain = gain * real(prod(r(index1)));

% the reconstructed linear polynomial
if nargout <= 1,
	y = gain * real(poly(g));
else,
	y = real(poly(g));
end;
