#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
Tray_Icon = C:\Users\Samuel\Documents\icons\icons8_color_dropper.ico
IfExist, %Tray_Icon%
Menu, Tray, Icon, %Tray_Icon%

#+C::
{
  MouseGetPos, MouseX, MouseY
  PixelGetColor, color, %MouseX%, %MouseY%, RGB
  StringLower, color, color
  clipboard := SubStr(color, 3)
  Return
}