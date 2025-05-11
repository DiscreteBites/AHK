#Requires AutoHotkey v2.0

global window
global textCtrl

global SpeedIncr := 2
global MaxIncr := 4
global Incr := 0

global SpeedVar := 1

^Up::
{
    global Incr
    global MaxIncr
    global SpeedVar
    global SpeedIncr

    if (Incr < MaxIncr) {
        Incr++
    } else {
        Incr := 0
    }

    SpeedVar := 1 + Incr * SpeedIncr
    Notify(SpeedVar)
}

^Down::
{
    global Incr
    global MaxIncr
    global SpeedVar
    global SpeedIncr

    if (Incr == 0) {
        Incr := MaxIncr
    } else {
        Incr--
    }

    SpeedVar := 1 + Incr * SpeedIncr
    Notify(SpeedVar)
}


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

ClearNotify()
{
    global window
    if isSet(window)
    {
        try {
            window.Destroy()
            window := unset
            textCtrl := unset
        }
    }
}

Notify(SpeedVar)
{
    global window
    global textCtrl

    if (IsSet(window) && WinActive(window.Hwnd)){

        textCtrl.Text :=  "Scroll Speed:  " SpeedVar
        
    } else {

        window := Gui("-Resize +AlwaysOnTop -MinimizeBox -Caption +Border", "ScrollSpeed")
        window.SetFont("s10 q5")
        textCtrl := window.AddText("R1 vScrollSpeed", "Scroll Speed:  " SpeedVar)

        ; Get the GUI's dimensions
        window.GetPos(&X, &Y, &W, &H)

        dX := A_ScreenWidth - 235
        dY := A_ScreenHeight- 145
        window.Show("w130 h34 x" dX " y" dY)
    }

    SetTimer(ClearNotify, 500)
    Return
}