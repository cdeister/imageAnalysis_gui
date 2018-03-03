function dSet=csHDFImport(hdfPath,hdfDSet,importRange,zDim)
	

	if nargin==2
		zDim=3;
		importRange=
	else
	end

	curHDFInfo=h5info([tP tH],['/' tDS_select]);
	dsSize=curHDFInfo.Dataspace.Size;
	zOne=get(handles.zDimFlip,'Value');

end