function [y,gain] = maxphase(P,tol)
%MAXPHASE  Maximum phase polynomial.
%       [Y] = MAXPHASE(P) returns a maximum phase polynomial 
%       for P.  P is returned if P is already maximum phase.
%
%	[Y,G] = MAXPHASE(P) returns the polynomial Y such 
%	that the highest order coefficient is equal to one.
%	The gain is then returned in G.
%
%       Algorithm:  Multiply the polynomial by the following 
%       factor for each root that is less than 1 in magnitude:
%
%                           1 - z Conj[z0]
%               Pmax = P *  ---------------
%                               z - z0
%
%       This can be done by first convolving the numerator with 
%       P to perform the polynomial multiplication and then 
%       deconvolving P with the denominator to perform the 
%       polynomial division.
%
%	MAXPHASE(P,TOL) sets the tolerance used in pairing
%	complex roots using the CPLXPAIR command.  Default
%	tolerance is 0.0001.
%
%       See also MINPHASE

% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover
%
%       Adapted for use in DIGFILML, 18-05-97, Oliver Klein


%       Ref: Therrien, Discrete Random Signals and Statistical 
%           Signal Processing, 1992, ss 5.5.1, pp 250-253.
%       Oppenheim, Schafer, Digital Signal Processing, 1975,
%           ss 7.2, pp 345-353.

% default return
y = [];

% figure out if we have a vector
if min(size(P)) ~= 1,
	disp('maxphase: Input arg "P" must be a 1xN or Nx1 vector.');
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
r = cplxpair(roots(P),tol);

% find roots inside & outside & on unit circle
ra = abs(r);
onner = find(ra == 1.0);
inner = find(ra <  1.0);
outer = find(ra >  1.0);


% move root inside
g = [r(onner) ; r(outer) ; (1 ./ conj(r(inner)))];

% find inner complex roots
gain = gain * real(prod(r(inner)));

% the minimum phase polynomial
if nargout <= 1,
	y = gain * real(poly(g));
else,
	y = real(poly(g));
end;

