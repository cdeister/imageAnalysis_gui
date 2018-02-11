function positionVec=decodeShaftEncoder(encVlt,inchRadius)

% pass a rotary encoder's (not quadrature) values
% and get back a positionVec like a quadradture would.
% i ask for radius of load (wheel) in inches to give 
% back position in meters.

rInMet=inchRadius*0.024;
wC=2*pi*rInMet;


% get range
dR=max(encVlt)-min(encVlt);

% min meter delta
metPerInc=wC/dR;
difTM=diff(encVlt);

% roll overs.
pRolInds=find(diff(encVlt)>(dR/2));
difTM(pRolInds)=difTM(pRolInds-1)+1;
nRolInds=find(diff(encVlt)<(-dR/2));
difTM(nRolInds)=difTM(nRolInds-1)-1;

positionVec=(-metPerInc)*cumsum(horzcat(0,difTM));

end



