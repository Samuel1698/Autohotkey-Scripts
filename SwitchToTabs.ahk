#SingleInstance Force            ; Allow only one instance
SendMode("Input")               ; Use fastest send method
SetWorkingDir(A_ScriptDir)      ; Make working dir the script's dir

; Tray icon
TrayIcon := A_ScriptDir . "\\switch.ico"
if FileExist(TrayIcon)
    TraySetIcon(TrayIcon)

; F13: Switch to Visual Studio Code
F13:: {
    if !WinExist("ahk_exe Code.exe")
        Run("C:\Program Files\Microsoft VS Code\Code.exe")
    else if WinActive("ahk_exe Code.exe")
        SendInput("^{Tab}")           ; Cycle tabs in VSCode
    else
        WinActivate("ahk_exe Code.exe")
}

; F14 :: Switch to last Explorer window
F14:: {
    ; If no Explorer windows exist, open one and exit
    if !WinExist("ahk_class CabinetWClass") {
        Run("explorer.exe")
        return
    }
    ; Add all Explorer windows to group for cycling
    GroupAdd("customExplorers", "ahk_class CabinetWClass")

    if WinActive("ahk_class CabinetWClass") {
        ; If already in Explorer, cycle to next window in group
        GroupActivate("customExplorers")
    } else {
        ; Otherwise activate the most recently opened Explorer
        latest := ""
        hwndList := WinGetList("ahk_class CabinetWClass")
        for hwnd in hwndList
            latest := hwnd
        if latest
            WinActivate("ahk_id " latest)
    }
}

; Alt+F14 :: Close Explorer window
!F14:: {
    if WinActive("ahk_exe explorer.exe")
        WinClose("ahk_class CabinetWClass")
}
