#pragma ModuleName=TxtSave

strconstant TxtSave_Menu="TxtSave"

/////////////////////////////////////////////////////////////////////////////////
// Menu /////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

Menu StringFromList(0,TxtSave_Menu)
	RemoveListItem(0,TxtSave_Menu)
	"Save Waves as txt Files",TxtSave#Dialog()
	TxtSave#MenuItemShowSavedFiles(),/Q,TxtSave#MenuCommandShowSavedFiles()
	SelectString(strlen(TxtSave#MenuItem(0)),"","-")
	TxtSave#MenuItem(0),/Q
	TxtSave#MenuItem(1),/Q
	TxtSave#MenuItem(2),/Q
	TxtSave#MenuItem(3),/Q
	TxtSave#MenuItem(4),/Q
	TxtSave#MenuItem(5),/Q
	TxtSave#MenuItem(6),/Q
	TxtSave#MenuItem(7),/Q
	TxtSave#MenuItem(8),/Q
	TxtSave#MenuItem(9),/Q
	TxtSave#MenuItem(10),/Q
	TxtSave#MenuItem(11),/Q
	TxtSave#MenuItem(12),/Q
	TxtSave#MenuItem(13),/Q
	TxtSave#MenuItem(14),/Q
	TxtSave#MenuItem(15),/Q
	TxtSave#MenuItem(16),/Q
	TxtSave#MenuItem(17),/Q
	TxtSave#MenuItem(18),/Q
	TxtSave#MenuItem(19),/Q
End
static Function Dialog()
	String root="root:"
	String wList=WaveList("*",";","")
	String fName=SelectString(ItemsInList(wList),"txtsave.txt",StringFromList(0,wList)+"++.txt")
	String ignore="root:Packages:;"
	
	Prompt root,"Root:"
	Prompt fName,"File name:"
	Prompt wList,"Saved waves:"
	Prompt ignore,"Unsaved data folders:"

	String help=""
	DoPrompt/HELP=help "TxtSave",root,fName,wList,ignore
	if(V_Flag)
		return NaN
	endif
	TxtSave_Recursive(root,wList,fName,ignore=ignore)
End

static Function/S MenuItem(i)
	Variable i
	String fs=FunctionList("txtsave*",";","")
	fs=RemoveFromList("TxtSave",fs)
	fs=RemoveFromList("TxtSave_Recursive",fs)
	return StringFromList(i,fs)
End

static Function/S MenuItemShowSavedFiles()
	PathInfo home
	NewPath/O/Q/Z Txtsave_RootDir,S_path+IgorInfo(1)+"_txtfiles" 
	return SelectString(V_Flag,"","(")+"Show Saved Files"
End

static Function MenuCommandShowSavedFiles()
	PathInfo home
	NewPath/C/O/Q Txtsave_RootDir,S_path+IgorInfo(1)+"_txtfiles" 
	PathInfo/SHOW Txtsave_RootDir
End

/////////////////////////////////////////////////////////////////////////////////
// Public Functions /////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

Function TxtSave_Recursive(wFolder,wList,fName [ignore])
	String wFolder, wList, fName, ignore
	if(ParamIsDefault(ignore))
		ignore=""
	endif
	wFolder=AbsFolder(GetDataFolder(1),wFolder)	
	TxtSave_Recursive_(wFolder,wList,fName,ignore=ignore,root=GetDataFolder(1))
End
static Function TxtSave_Recursive_(wFolder, wList, fName [ignore,root])
	String wFolder, wList, fName, ignore, root
	if(!FolderMatch(wFolder,root,ignore))
		print wFolder,root,FolderMatch(wFolder,root,ignore)
		TxtSave_(wFolder, wList, fName)
	endif
	Variable i,Ni=CountObjects(wFolder,4)
	for(i=0;i<Ni;i+=1)
		String wSub=PossiblyQuoteName(GetIndexedObjName(wFolder,4,i))
		TxtSave_Recursive_(wFolder+wSub+":", wList, fName,ignore=ignore,root=root)
	endfor
End

Function TxtSave(wFolder,wList,fName)
	String wFolder,wList,fName
	wFolder=AbsFolder(GetDataFolder(1),wFolder)	
	TxtSave_(wFolder,wList,fName)
End
static Function TxtSave_(wFolder,wList,fName)
	String wFolder,wList,fName
	if(WaveListExists(wFolder,wList) && DataFolderExists(wFolder))
		String fPath = ConvertToExternalPath(wFolder)
		String pName = MakeParentDirectoriesAsNeeded(fPath)
		DFREF here=GetDataFolderDFR()
		SetDataFolder $wFolder
		Save/B/G/M=LF()/O/P=$pName/W wList as fName
		SetDataFolder here
	endif
End

/////////////////////////////////////////////////////////////////////////////////
// Static Functions /////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

// Check existance of all waves in the given path
static Function WaveListExists(wPath, wList)
	String wPath, wList
	Variable i,Ni=ItemsInList(wList)
	for(i=0;i<Ni;i+=1)
		if(!WaveExists($wPath+StringFromList(i,wList)))
			return 0
		endif
	endfor
	return 1
End

// Return absolute folder path name based on the given root path
// Return "" when an illegal path is given
static Function/S AbsFolder(root,folder)
	String root,folder
	String absPath=""
	DFREF here=GetDataFolderDFR()
	Execute/Z "cd "+RemoveEnding(root,":")+":"
	Execute/Z "cd "+RemoveEnding(folder,":")+":"
	if(!V_Flag)
		absPath=GetDataFolder(1)
	endif
	SetDataFolder here
	return absPath
End

// Convert a data folder path for Igor Pro into external file path written with :
static Function/S ConvertToExternalPath(wPath)
	String wPath
	String fRoot=IgorInfo(1)+"_txtfiles", fPath
	PathInfo home
	sprintf fPath,"%s%s:%s",S_path,fRoot,ReplaceString("\'",wPath,"") 
	return fPath
End

// mkdir -p
static Function/S MakeParentDirectoriesAsNeeded(fPath)
	String fPath
	String parent="", pName="Txtsave_TmpDir"
	Variable i,Ni=ItemsInList(fPath,":")
	for(i=0;i<Ni;i+=1)
		sprintf parent,"%s%s:",parent,StringFromList(i,fPath,":")
		NewPath/C/O/Q $pName,parent 
	endfor
	return pName
End

// Line feed according to the OS
static Function/S LF()
	return SelectString(cmpstr(IgorInfo(2),"Windows"),"\r\n","\n")
End


// Compare a folder name and expressions
// Latter expression has priority
static Function FolderMatch(folder,root,exprs)
	String folder,root,exprs
	Variable i,N=ItemsInList(exprs),result=0
	for(i=0;i<N;i+=1)
		Variable bool=FolderMatch_(folder,root,StringFromList(i,exprs))
		if(bool>0)
			result=1
		elseif(bool<0)
			result=0
		endif
	endfor
	return result
End

// 1: Match (positive pattern)
// 0: No Match
//-1: Match (negative pattern)
Function FolderMatch_(folder,root,expr)
	String folder,root,expr
	Variable neg=1
	if(GrepString(expr,"^!"))
		neg=-1
		expr=expr[1,inf]
	endif
	if(GrepString(expr,"^:"))
		expr=RemoveEnding(root,":")+expr
	endif
	if(GrepString(folder,"^:"))
		folder=RemoveEnding(root,":")+folder
	endif
	expr=RemoveEnding(expr,":")+":"
	folder=RemoveEnding(folder,":")+":"
	Variable Ne=ItemsInList(expr,":")
	Variable Nf=ItemsInList(folder,":")
	Variable i
	for(i=0;i<Nf-Ne+1;i+=1)
		if(StringMatch(Slice(folder,i,i+Ne,":"),expr))
			return 1*neg
		endif
	endfor
	return 0
End

// Slice list as wave slice: w[1,3]
Function/S Slice(list,n,m,del)
	String list,del; Variable n,m
	String buf=""
	Variable i
	for(i=n;i<m;i+=1)
		buf=AddListItem(StringFromList(i,list,del),buf,del,inf)
	endfor
	return buf
End
