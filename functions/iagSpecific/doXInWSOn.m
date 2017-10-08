function varargout=doXInWSOn(funcString,varString)	
	[varargout{1:nargout}]=evalin('base',[funcString '(' varString ');']);
end