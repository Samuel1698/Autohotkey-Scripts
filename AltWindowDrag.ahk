#Requires AutoHotkey v2.0
#SingleInstance Force

SetTitleMatchMode(2)
Tray_Icon := A_ScriptDir "\drag.ico"
if FileExist(Tray_Icon)
    TraySetIcon(Tray_Icon)

;––– Make these names truly global –––
EWD_MouseStartX   := 0
EWD_MouseStartY   := 0
EWD_MouseWin      := ""
EWD_OriginalPosX  := 0
EWD_OriginalPosY  := 0

global EWD_MouseStartX, EWD_MouseStartY
global EWD_MouseWin
global EWD_OriginalPosX, EWD_OriginalPosY
!LButton:: {
    global EWD_MouseStartX, EWD_MouseStartY, EWD_MouseWin

    CoordMode("Mouse")
    MouseGetPos(&EWD_MouseStartX, &EWD_MouseStartY)  ; Get cursor position

    ; 1) Get the deepest window at the cursor, then its root
    pt    := (EWD_MouseStartX & 0xFFFFFFFF) | (EWD_MouseStartY << 32)
    child := DllCall("User32.dll\WindowFromPoint", "UInt64", pt, "Ptr")
    EWD_MouseWin := DllCall("User32.dll\GetAncestor"
        , "Ptr", child
        , "UInt", 2        ; GA_ROOT
        , "Ptr")

    ; 2) Fallback if needed
    if (!EWD_MouseWin)
        EWD_MouseWin := WinGetID("A")

    ; 3) Only start dragging if not maximized
    if (WinGetMinMax("ahk_id " EWD_MouseWin) = 0)
        SetTimer(EWD_WatchMouse, 10)

    return
}

EWD_WatchMouse() {
    global EWD_MouseStartX, EWD_MouseStartY
    global EWD_MouseWin, EWD_OriginalPosX, EWD_OriginalPosY

    if !GetKeyState("LButton", "P") {
        SetTimer(EWD_WatchMouse, 0)
        return
    }
    if GetKeyState("Escape", "P") {
        SetTimer(EWD_WatchMouse, 0)
        WinMove("ahk_id " EWD_MouseWin, EWD_OriginalPosX, EWD_OriginalPosY)
        return
    }
    CoordMode("Mouse")
    MouseGetPos(&X, &Y)
    WinGetPos(&WX, &WY, &_, &_, "ahk_id " EWD_MouseWin)
    SetWinDelay(-1)
    WinMove(WX + X - EWD_MouseStartX,
            WY + Y - EWD_MouseStartY, , ,
            "ahk_id " EWD_MouseWin)
    EWD_MouseStartX := X
    EWD_MouseStartY := Y
}