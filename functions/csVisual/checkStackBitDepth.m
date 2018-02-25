function [imType,imSize]=checkStackBitDepth(canaryImport)

	% csImage utility function that returns a string (imType)
	% that describes the appropriate units for the data contained in 'canaryImport'
	% this is used to preallocate arrays before imports of large datasets etc.


	imSize=size(canaryImport);
	canaryInfo=whos('canaryImport');
	imType=canaryInfo.class;

end