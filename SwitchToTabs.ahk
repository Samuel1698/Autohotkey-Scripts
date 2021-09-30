#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
Tray_Icon = %A_ScriptDir%\switch.ico
IfExist, %Tray_Icon%
Menu, Tray, Icon, %Tray_Icon%

#IfWinActive 

F13:: ; Switch to Firefox
{
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
	; Loop through list of chrome windows
	WinGet,List,List, ahk_exe chrome.exe
	Loop % List {
		hwnd:=List%A_Index%
		; reset variable
		found=false
		; Get position of current chrome in list and the mouse
		WinGetPos, Wx, Wy, w, h,% "ahk_id " hwnd
		WinGetPos, Ax, Ay, w, h, A

		SysGet, xborder, 32
		SysGet, yborder, 33
		;Offset the Window position to accomodate the active window position with windows' inbuilt 8 pixel padding
		Wx += xborder
		Wy += yborder
		Ax += xborder
		Ay += yborder
		; Get monitor count (80 is the value for this)
		SysGet, MonitorCount, 80
		Loop %MonitorCount% 
		{
			; Get the bounding coordinates of monitor A_Index
			SysGet, mon, Monitor, %A_Index%
			;If the list id's position fits within the current active window, then add that id to array
			if ( Wx >= monLeft ) && ( Wx < monRight ) && ( Wy >= monTop ) && ( Wy < monBottom ) && ( Ax == Wx ) && ( Ay == Wy )
			{
				found=true
				break ; If the monitor to which the window belongs to has been found, break loop
			}
		}
		if (found=="true")
		{
			WinActivate,% "ahk_id " hwnd
			break
		}
	}
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
^F15:: ; Ctrl + F15
{
	if WinActive("ahk_exe Code.exe")
		SendInput ^+{tab}
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
!F16:: ; Alt + F16 || Close explorer window 
{
	if WinActive("ahk_exe explorer.exe")
		WinClose ahk_class CabinetWClass
	Return
}
^F16:: ; Ctrl + F16 || Duplicate Explorer Window
{
	; Open a second explorer window in the same path
	if WinActive("ahk_exe explorer.exe") {
		ClipSave := Clipboard
		Clipboard =
		SendInput, !d  ; Select file path
		SendInput, ^c
		ClipWait       ; Wait for clipboard to contain text
		Run, explorer.exe "%clipboard%"
		Clipboard = %ClipSave%
	}
	Return
}
#+C::
{
  MouseGetPos, MouseX, MouseY
  PixelGetColor, color, %MouseX%, %MouseY%, RGB
  StringLower, color, color
  clipboard := SubStr(color, 3)
  Return
}