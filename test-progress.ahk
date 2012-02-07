#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
Loop,100
{
	m := Mod(A_Index,100)
	Progress, , , Counting: %m%, 
	Sleep, 1
	}
Progress, Off
