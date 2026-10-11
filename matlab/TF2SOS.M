function sos=tf2sos(num,den,option);

%TF2SOS	Transfer function to second-order sections linear system model conversion.
% 	SOS = TF2SOS(NUM,DEN) finds a matrix SOS in second-order sections form
% 	which represents the same system as the one with the transfer function in 
% 	numerator and denominator in vector NUM and DEN.
% 
% 	TF2SOS(NUM,DEN,'down') orders the sections so that the first row of SOS 
% 	contains the poles closest to the unit circle. Without the 'down' flag,
% 	the sections are ordered in the other direction.
% 
% 	The output SOS is an L by 6 matrix which contains the coefficients 
% 	of each second-order section in its rows:
% 	    SOS = [ b01 b11 b21  a01 a11 a21 
% 	            b02 b12 b22  a02 a12 a22
% 	            ...
% 	            b0L b1L b2L  a0L a1L a2L ]
% 	The pole-zero conjugate pairs which are closest to each other are 
% 	arranged into the same 2nd-order section.  Furthermore, the numerator
% 	coefficients of each section are scaled so that the maximum of the
% 	magnitude of the DTFT of the cascade is very close to 1.
% 
% 	The system transfer function is the product of the second-order transfer
% 	functions of the sections.  Each row of the SOS matrix describes
% 	a 2nd order transfer function as
% 	        b0k +  b1k z^-1 +  b2k  z^-2
% 	        ----------------------------
% 	        a0k +  a1k z^-1 +  a2k  z^-2
% 	where k is the row index. 
% 
% 	See also SOS2ZP, SOS2TF, SOS2SS, SS2SOS, CPLXPAIR.

% Bearbeiter: Oliver Klein
% Betreuer:   Prof.Dr.-Ing. D. Stark, FH Hannover

% First transform transfer function to state space 'tf2ss'

num=[zeros(1,length(den)-length(num)) num];
[A,B,C,D]=tf2ss(num,den);

if nargin==2
  sos=ss2sos(A,B,C,D);
else % 3
  sos=ss2sos(A,B,C,D,option);
end
  