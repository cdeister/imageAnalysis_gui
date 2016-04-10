function [N,BIN] = HISTC(X,EDGES)
%HISTD  HISTC-type Histogram implemented as an .m function.
% See the HISTC mex description
% If you can't find HISTC, then see the hist2 help.
%
% N.B. It is always a better idea to use the
%      HISTC mex (a much faster compiled C code) if you have it
%      Then just replace the HISTD with HISTC in all calls
%      contained in the hist2() .m function
%
% N.B. This is NOT a fool-proof version.
%      It is a version for advanced users only,
%      that use it with a smile & at own risk ;-)
%      There is NO parameter check.
%
% Makes the hist2/histd pair version-portable & stats-toolbox independent
% HISTD is meant to be functionally similar to HISTC
%       but feel free to modify it (e.g. if BIN=0 is not what you want
%       for out of range values.
%
% (c) Nedialko Krouchev 2006, Universite de Montreal, GRSNC
%   Roughly based on HIST (c) MathWorks
%       c:\matlab\toolbox\matlab\datafun\hist.m

[m,n] = size(X);

    xx = EDGES(:);
    minX = min(min(X));
    maxX = max(max(X));

BIN = zeros(m,n);

nbin = length(xx);
nn = zeros(1,nbin);
for i=1:nbin
   kk = find( X >= xx(i) );
   BIN(kk) = i; nn(i) = length( kk );
end

kk = find( X > xx(nbin) );
BIN(kk) = 0; nn(nbin+1) = length( kk );

N = -diff(nn);
