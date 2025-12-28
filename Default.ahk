#Requires AutoHotkey v2.0
#SingleInstance Force

A_MaxHotkeysPerInterval := 200

; =================================================== ;
; Key Mappings                                        ;
; =================================================== ;
Xbutton1::
{
    ; vscode comment / uncomment
    Send("+!K")
}

Xbutton2::
{
    VolumeScroll_OnXbutton2Down()
    ; vscode comment /uncomment
    Send("+!U")
}

Xbutton2 up::
{
    VolumeScroll_OnXbutton2Up()
}

WheelDown::
{
    ToolTip(
    "d"
    )
    VolumeScroll_OnWheelDown(() => 
        FastScroll_OnWheelDown()
    )
}
        
WheelUp::
{
    ToolTip(
        "u"
    )
    VolumeScroll_OnWheelUp(() => 
        FastScroll_OnWheelUp()
    )
}

F13 & WheelDown::
{
    TabScroll_OnWheelDown()
}

F13 & WheelUp::
{
    TabScroll_OnWheelUp()
}

F14 & WheelDown::
{
    TabScroll_OnWheelDown()
}

F14 & WheelUp::
{
    TabScroll_OnWheelUp
}

+^Up::
{
    FastScroll_OnUpPressed()
}

+^Down::
{
    FastScroll_OnDownPressed()
}

+^Left::
{
    FastScroll_OnLeftPressed()
}

+^Right::
{
    FastScroll_OnRightPressed()
}

~F13::
{
    Send("{Ctrl down}")
}

~F13::
{
    Send("{Ctrl up}")
}

~F14::
{
    Send("{Alt down}")
}

~F14 up::
{
    Send("{Alt up}")
}


; =================================================== ;
; Tab Scroll F13 / F14 + Scroll 
; =================================================== ;

TabScroll_OnWheelDown() {
    Send("{Tab}")
    return
}

TabScroll_OnWheelUp() {
    Send("{Shift down}{Tab}{Shift up}")
    return
}

; =================================================== ;
; Scroll Volume when Mouse button 5 is held down      ;
; =================================================== ;
global ScrollVolumeBool := False

VolumeScroll_OnXbutton2Down() {
    global ScrollVolumeBool
    ScrollVolumeBool := True
}

VolumeScroll_OnXbutton2Up() {
    global ScrollVolumeBool
    ScrollVolumeBool := False
}

VolumeScroll_OnWheelDown(callback) {
    global ScrollVolumeBool

    if (ScrollVolumeBool) {
        Send("{Volume_Down}")
        return
    }

    callback.Call()
}

VolumeScroll_OnWheelUp(callback) {
    global ScrollVolumeBool

    if (ScrollVolumeBool) {
        Send("{Volume_Up}")
        return
    }

    callback.Call()
}

; =================================================== ;
; Toggle Scroll Speed                                 ;
; =================================================== ;
global window
global windowHandle
global textCtrl

global SpeedIncr := 2
global MaxIncr := 4
global Incr := 0

global SpeedVar := 1

FastScroll_OnWheelUp() {
    global SpeedVar
    Send("{WheelUp " SpeedVar " }")
}

FastScroll_OnWheelDown() {
    global SpeedVar
    Send("{WheelDown " SpeedVar " }")
}

FastScroll_OnUpPressed() {
    global Incr
    global MaxIncr
    global SpeedVar
    global SpeedIncr
    
    ; Protect button mash
    if (GetKeyState('Down' , 'P') 
        || GetKeyState('Left', 'P') 
        || GetKeyState('Right', 'P')
    ) {
        return
    }
    
    if (Incr < MaxIncr) {
        Incr++
    } else {
        Incr := 0
    }

    SpeedVar := 1 + Incr * SpeedIncr
    Notify(SpeedVar)
}

FastScroll_OnDownPressed() {
    global Incr
    global MaxIncr
    global SpeedVar
    global SpeedIncr

    ; Protect button mash
    if (GetKeyState('Up' , 'P') 
        || GetKeyState('Left', 'P') 
        || GetKeyState('Right', 'P')
    ) {
        return
    }

    if (Incr == 0) {
        Incr := MaxIncr
    } else {
        Incr--
    }

    SpeedVar := 1 + Incr * SpeedIncr
    Notify(SpeedVar)
}

FastScroll_OnLeftPressed() {
    global Incr
    global MaxIncr
    global SpeedVar
    global SpeedIncr

    ; Protect button mash
    if (GetKeyState('Up' , 'P') 
        || GetKeyState('Down', 'P') 
        || GetKeyState('Right', 'P')
    ) {
        return
    }
    
    Incr := 0
    SpeedVar := 1 + Incr * SpeedIncr
    Notify(SpeedVar)
}

FastScroll_OnRightPressed() {
    global Incr
    global MaxIncr
    global SpeedVar
    global SpeedIncr

    ; Protect button mash
    if (GetKeyState('Up' , 'P') 
        || GetKeyState('Down', 'P') 
        || GetKeyState('Left', 'P')
    ) {
        return
    }
    
    Incr := MaxIncr
    SpeedVar := 1 + Incr * SpeedIncr
    Notify(SpeedVar)
}


ClearNotify() {
    global window
    if isSet(window)
    {
        try {
            window.Destroy()
            window := unset
            textCtrl := unset
            windowHandle := unset
        }
    }
}

Notify(SpeedVar) {
    global window
    global windowHandle
    global textCtrl

    SetTimer(ClearNotify, 0)

    if !IsSet(window) {
        
        ; Create Gui Element
        window := Gui("-Resize +AlwaysOnTop -MinimizeBox -Caption +Border", "ScrollSpeed")
        window.SetFont("s10 q5")
        textCtrl := window.AddText("R1 vScrollSpeed", "Scroll Speed:  " SpeedVar)

        ; Get the GUI's dimensions
        window.GetPos(&X, &Y, &W, &H)

        dX := A_ScreenWidth - window.MarginX - 235
        dY := A_ScreenHeight- window.MarginY - 145
        window.Show("w130 h34 x" dX " y" dY)
        windowHandle := window.Hwnd

    } else if (IsSet(windowHandle) 
        && WinExist("ahk_id " windowHandle) 
        && WinActive(windowHandle)) {
        
        textCtrl.Text :=  "Scroll Speed:  " SpeedVar

    }

    ; Always clean up
    SetTimer(ClearNotify, -500)
    Return
}

; =================================================== ;
; Debug pop up window                                 ;
; =================================================== ;

Debug(message) {
    global debugWindow
    global debugWindowHandle
    global debugTextCtrl

    if !IsSet(debugWindow) {
        
        ; Create Gui Element
        debugWindow := Gui("-Resize +AlwaysOnTop -MinimizeBox -Caption +Border", "Debug")
        debugWindow.SetFont("s10 q5")
        debugTextCtrl := debugWindow.Add("Text", , "Debug:  " message)
        
        ; Get the GUI's dimensions
        debugWindow.GetPos(&X, &Y, &W, &H)

        dX := A_ScreenWidth - debugWindow.MarginX - 235
        dY := A_ScreenHeight- debugWindow.MarginY - 145
        debugWindow.Show("w130 h34 x" dX " y" dY)
        debugWindowHandle := debugWindow.Hwnd

    } else if (IsSet(debugWindowHandle) 
        && WinExist("ahk_id " debugWindowHandle)) {

        debugTextCtrl.Text :=  "Debug:  " message

    }

    Return
}