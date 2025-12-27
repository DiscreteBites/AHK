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
    VolumeScroll_OnWheelDown(() => 
        FastScroll_OnWheelDown()
    )
}

WheelUp::
{
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
    TabScroll_OnWheelUp( )
}

~!WheelDown::
{
    WindowScroll_OnWheelDown(()=>{})
}

~!WheelUp::
{
    WindowScroll_OnWheelUp(()=>{})
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

F14::
{
   WindowScroll_OnF14Down() 
}

F14 up::
{
   WindowScroll_OnF14Up()
}

; =================================================== ;
; Tab Scroll F13 + Scroll 
; =================================================== ;

TabScroll_OnWheelDown() {
    Send("{Ctrl down}{Tab}{Ctrl up}")
    return
}

TabScroll_OnWheelUp() {
    Send("{Ctrl down}{Shift down}{Tab}{Shift up}{Ctrl up}")
    return
}

; =================================================== ;
; Window Scroll F14 + Scroll 
; =================================================== ;
global F14Bool := False

WindowScroll_OnF14Down() {
    global F14Bool
    F14Bool := True

    Send("{Alt down}")
}

WindowScroll_OnF14Up() {
    global F14Bool
    F14Bool := False

    Send("{Alt up}")
}

WindowScroll_OnWheelDown(callback) {
    global F14Bool
    
    if (F14Bool) {
        Send("{Tab}")
        return
    }

    callback.Call()
}

WindowScroll_OnWheelUp(callback) {
    global F14Bool

    if (F14Bool) {
        Send("{Shift down}{Tab}{Shift up}")
        return
    }

    callback.Call()
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