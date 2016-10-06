
Function TxtSave_Recursive(wRoot, wList, fName)
	String wRoot, wList, fName
	TxtSave(wRoot, wList, fName)
	Variable i,Ni=CountObjects(wRoot,4)
	for(i=0;i<Ni;i+=1)
		String folder=PossiblyQuoteName(GetIndexedObjName(wRoot,4,i))
		TxtSave_Recursive(wRoot+folder+":", wList, fName)
	endfor
End

Function TxtSave(wPath, wList, fName)
	String wPath, wList, fName
	//print wPath
	if(WaveListExists(wPath,wList) && DataFolderExists(wPath))
		String fPath = ConvertToExternalPath(wPath)
		String pName = MakeParentDirectoriesAsNeeded(fPath)
		DFREF here=GetDataFolderDFR()
		SetDataFolder wPath
		Save/B/G/M=LF()/O/P=$pName/W wList as fName
		SetDataFolder here
	endif
End

Function WaveListExists(wPath,wList)
	String wPath, wList
	Variable i,Ni=ItemsInList(wList)
	for(i=0;i<Ni;i+=1)
		if(!WaveExists($wPath+StringFromList(i,wList)))
			return 0
		endif
	endfor
	return 1
End

Function/S ConvertToExternalPath(wPath)
	String wPath
	String fRoot=IgorInfo(1)+"_txtfiles", fPath
	PathInfo home
	sprintf fPath,"%s%s:%s",S_path,fRoot,ReplaceString("\'",wPath,"") 
	return fPath
End

Function/S MakeParentDirectoriesAsNeeded(fPath)
	String fPath
	String parent="", pName="Txtsave_TmpDir"
	Variable i,Ni=ItemsInList(fPath,":")
	for(i=0;i<Ni;i+=1)
		sprintf parent,"%s%s:",parent,StringFromList(i,fPath,":")
		NewPath/C/O/Q $pName,parent 
	endfor
	return pName
End

Function/S LF()
	return SelectString(cmpstr(IgorInfo(2),"Windows"),"\r\n","\n")
End
