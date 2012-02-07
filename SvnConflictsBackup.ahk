#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Select working copy root
; Find all .mine files
; For each .mine file find all other extensions with the same filename (.theirs  and .rxx files)
; copy these into a SvnConflictsBackup\<date>\<directory_structure>\file
; Show Finished(remove) and Restore button
; Finish: delete all files
; Restore: choose from all .mine files and restore it and related files

; Select working copy root
ErrorLevel =
FileSelectFolder, wc_root,, 2, Please select working copy root folder:
IfEqual, wc_root,
	ExitApp
; todo - handle errors

; Find all .mine files
Now = A_Now
Loop, %wc_root%\*.mine,, 1
{
	mine_path := A_LoopFileFullPath
	StringReplace, mine_path, mine_path, %wc_root%\,,
	FileCopy, %wc_root%\%mine_path%, %A_Desktop%\SvnConflictsBackup\%Now%\%mine_path%, 1

	; For each .mine file find all other extensions with the same filename (.theirs  and .rxx files)
	; copy these into a SvnConflictsBackup\<date>\<directory_structure>\file
	StringReplace, mine_filename, %wc_root%\%mine_path%, .%A_LoopFileExt%
	Loop, %mine_filename%.*
	{
		other_path := A_LoopFileFullPath
		StringReplace, other_path, other_path, %wc_root%\,,

		FileCopy, %wc_root%\%other_path%, %A_Desktop%\SvnConflictsBackup\%Now%\%other_path%, 1
	}

}
ProcessDialog()
ExitApp

ProcessDialog() 
{
	global
	MsgBox, 4,, Would you like to restore any more conflicts? (press Yes or No)
IfMsgBox Yes
{
	; Restore: choose from all .mine files and restore it and related files
	FileSelectFile, restore_file, 3, %A_Desktop%\SvnConflictsBackup\%Now%, Please select conflicted file, Conflict (*.mine)
	
	StringReplace, restore_file, restore_filename, .mine, ; take off extension
	
	Loop, %restore_filename%.*
	{
		file_path := A_LoopFileFullPath
		StringReplace, file_path, file_path, %A_Desktop%\SvnConflictsBackup\%Now%\,,
		FileCopy, %A_Desktop%\SvnConflictsBackup\%Now%\%mine_path%, %wc_root%\%file_path%, 1
	}
    ProcessDialog() 
}
else
{
    MsgBox You pressed No. You can delete the files when they are no longer required.
	Run ,%A_Desktop%\SvnConflictsBackup\%Now%
	; Finish: delete all files
}

}


