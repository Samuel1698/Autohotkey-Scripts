#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
Tray_Icon = C:\Users\Samuel\Documents\icons\icons8_switch.ico
IfExist, %Tray_Icon%
Menu, Tray, Icon, %Tray_Icon%

#IfWinActive 

F13:: ; Switch to Firefox
{
	sendinput, {SC0E8} ;scan code of an unassigned key. Do I NEED this?
	IfWinNotExist, ahk_class MozillaWindowClass
		Run, firefox.exe
	if WinActive("ahk_exe firefox.exe")
		Send ^{tab}
	else{
		WinActivate ahk_exe firefox.exe
	}
	Return
}

F14:: ; Switch to Chrome
{
	IfWinNotExist, ahk_exe chrome.exe
		Run, chrome.exe

	if WinActive("ahk_exe chrome.exe")
		Sendinput ^{tab}
	else
		WinActivate ahk_exe chrome.exe
	Return
}
F15:: ; Switch to VSCode
{
	IfWinNotExist, ahk_exe Code.exe
		Run, Code.exe, C:\Program Files\Microsoft VS Code
	if WinActive("ahk_exe Code.exe")
		SendInput ^{tab}
	Else
		WinActivate, ahk_exe Code.exe
	Return
}
F16:: ; Switch to Last explorer window
{
	IfWinNotExist, ahk_class CabinetWClass
		Run, explorer.exe
	GroupAdd, customExplorers, ahk_class CabinetWClass
	If WinActive("ahk_exe explorer.exe")
		GroupActivate, customExplorers, r
	Else
		WinActivate ahk_class CabinetWClass ;you have to use WinActivatebottom if you didn't create a window group.
	Return
}
+F16:: ; Alt + F16 || Close explorer window 
{
	if WinActive("ahk_exe explorer.exe")
		WinClose ahk_class CabinetWClass
	Return
}
^F16:: ; Ctrl + F16 || Duplicate Explorer Window
{
	; Open a second explorer window in the same path
	if WinActive("ahk_exe explorer.exe") {
		Send, !d
		Sleep 50
		Send, ^c
		Sleep 100
		Run, explorer.exe "%clipboard%"
	}
	Return
}