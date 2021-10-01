#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
Tray_Icon = %A_ScriptDir%\switch.ico
IfExist, %Tray_Icon%
Menu, Tray, Icon, %Tray_Icon%

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
	; Loop through all the monitors
	SysGet, MonitorCount, 80
	Loop %MonitorCount%
	{
		; Get position of the active window
		WinGetPos, Ax, Ay, w, h, A
		; Uncomment this if you'd rather the script be based on the mouse position
		; rather than the active window
		; Coordmode, Mouse, Screen
		; MouseGetPos, Ax, Ay 

		; Get the system border/padding to offset the coordinates
		SysGet, xborder, 32
		SysGet, yborder, 33
		; Offset the coordinates
		Ax += xborder
		Ay += yborder
		; Get the bounding coordinates of monitor A_Index
		SysGet, monitor, Monitor, %A_Index%

		; If the currently selected monitor matches the active window
		if ( Ax >= monitorLeft ) && ( Ax < monitorRight ) && ( Ay >= monitorTop ) && ( Ay < monitorBottom )
		{
			; Reset variable for multiple script runs
			found=false
			; Loop through list of chrome windows 
			WinGet,List,List, ahk_exe chrome.exe
			Loop % List 
			{
				hwnd:=List%A_Index%
				; Get position of the currently iterated window
				WinGetPos, Wx, Wy, w, h,% "ahk_id " hwnd
				; Offset the coordinates
				Wx += xborder
				Wy += yborder
				; If the currently iterated window is within the selected monitor, mark as found and break loop
				if ( Wx >= monitorLeft ) && ( Wx < monitorRight ) && ( Wy >= monitorTop ) && ( Wy < monitorBottom )
				{
					found=true
					break
				}
			}
			if (found=="true")
			{
				WinActivate,% "ahk_id " hwnd
				break
			}
			else ; This means the hotkey was triggered in a monitor without a chrome window on it 
			{
				; Sets the matching mode to 'contains' instead of 'starts'
				SetTitleMatchMode, 2 
				Run, chrome.exe
				; For some reason WinWait fails if there's no delay here
				sleep, 250 
				WinWait, Google Chrome
				; If window is maximized, restore it
				; There's some glitch with WinMove if the window is maximized and moved to a bigger monitor
				WinGet, MinMax, MinMax 
				if MinMax
					WinRestore
				; Get the height and width of the new window
				WinGetPos, x,y, w, h, Google Chrome
				; Move to center of the monitor
				WinMove,,, ((monitorLeft+monitorRight)/2)-(w/2), ((monitorTop+monitorBottom)/2)-(h/2)
				SetTitleMatchMode, 1 ; Reset to default
				break
			}
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