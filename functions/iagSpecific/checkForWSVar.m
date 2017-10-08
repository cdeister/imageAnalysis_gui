function [exState]=checkForWSVar(varString,scopeString)
	if nargin==1
		scopeString='base';
	else
	end

exState=evalin(scopeString,['exist(' '''' varString '''' ');']);

end