#Requires AutoHotkey v2.0
#SingleInstance Force

; =================================================== ;
; Toggle Scroll Speed Using ctrl + shift + arrow Keys ;
; =================================================== ;
global window
global windowHandle
global textCtrl

global SpeedIncr := 2
global MaxIncr := 4
global Incr := 0

global SpeedVar := 1

WheelDown::
{
    global SpeedVar
    Send "{WheelDown " SpeedVar " }"
}

WheelUp::
{
    global SpeedVar
    Send "{WheelUp " SpeedVar " }"
}

+^Up::
{
    global Incr
    global MaxIncr
    global SpeedVar
    global SpeedIncr

    if GetKeyState('Down' , 'P') {
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

+^Down::
{
    global Incr
    global MaxIncr
    global SpeedVar
    global SpeedIncr

    if GetKeyState('UP' , 'P') {
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

ClearNotify()
{
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

Notify(SpeedVar)
{
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