#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Select working copy root
; Find all .working files
; For each .working file find all other extensions with the same filename (.theirs  and .rxx files)
; copy these into a SvnConflictsBackup\<date>\<directory_structure>\file
; Show Finished(remove) and Restore button
; Finish: exit and open backup folder for deletion by user
; Restore: choose from all .working files and restore it and related files

; Select working copy root
ErrorLevel =
FileSelectFolder, wc_root,, 2, Please select working copy root folder:
IfEqual, wc_root,
	ExitApp
; todo - handle errors

; Find all .working files
Now := A_Now
FileCreateDir, %A_Desktop%\SvnConflictsBackup\%Now%
Loop, %wc_root%\*.working,, 1
{
	mine_path := A_LoopFileFullPath
	StringReplace, mine_path, mine_path, %wc_root%\,,
	InDir = %A_Desktop%\SvnConflictsBackup\%Now%\%mine_path%
	SplitPath, InDir,, OutDir
	FileCreateDir, %OutDir%
	mine_filename = %wc_root%\%mine_path%
	FileCopy, %mine_filename%, %OutDir%, 1
	OutputDebug, %wc_root%\\%mine_path%
	

	; For each .working file find all other extensions with the same filename (.theirs  and .rxx files)
	; copy these into a SvnConflictsBackup\<date>\<directory_structure>\file
	StringReplace, mine_filename, mine_filename, .%A_LoopFileExt%

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
	MsgBox, 4,, Would you like to restore any (more) conflicts? (press Yes to select conflict, or No to exit)
	IfMsgBox Yes
	{
		; Restore: choose from all .working files and restore it and related files
		FileSelectFile, restore_file, 3, %A_Desktop%\SvnConflictsBackup\%Now%, Please select conflicted file, Conflict (*.working)
		
		StringReplace, restore_filename, restore_file, .working, ; take off extension
		Loop, %restore_filename%.*
		{
			file_path := A_LoopFileFullPath
			StringReplace, file_path, file_path, %A_Desktop%\SvnConflictsBackup\%Now%\,
			FileCopy, %A_Desktop%\SvnConflictsBackup\%Now%\%file_path%, %wc_root%\%file_path%, 1
		}
		Msgbox, The following file (and conflict related files) have been restored: %file_path%
		ProcessDialog() 
	}
	else
	{
		MsgBox You pressed No. You can delete the files when they are no longer required.
		Run ,%A_Desktop%\SvnConflictsBackup\%Now%
	}

}


