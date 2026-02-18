#Requires AutoHotkey v2.0
A_MaxHotkeysPerInterval := 200
ProcessSetPriority "High"

SetCapsLockState "AlwaysOff"

; --- Global Variables for Multiplier ---
global multiplierBuffer := ""
global isProcessing := false
global ih := InputHook("L0 V I1") ; L0: no limit, V: visible (don't block), I1: ignore script-sent keys
ih.KeyOpt("{All}","+N")
ih.KeyOpt("0123456789{Backspace}{CapsLock}","-N")   ; Allow these keys to retain multiplier buffer

; This function resets the buffer
ResetMultiplier(*) {
    global multiplierBuffer := ""
    UpdateTooltip()
}

ih.OnKeyDown := (ih, vk, sc) => ResetMultiplier()
ih.Start() ; Start listening

OnAnyKeyDown(ih, vk, sc) {
    ResetMultiplier()
}

; --- Number Capture ---
; We use ~ so the numbers actually type on screen first
~1::capture("1")
~2::capture("2")
~3::capture("3")
~4::capture("4")
~5::capture("5")
~6::capture("6")
~7::capture("7")
~8::capture("8")
~9::capture("9")
~0::capture("0")
~Backspace::
{
    global multiplierBuffer
    if (StrLen(multiplierBuffer) > 0) {
        multiplierBuffer := SubStr(multiplierBuffer, 1, -1)
    }
    UpdateTooltip()
}

capture(num) {
    global multiplierBuffer .= num
    UpdateTooltip()
}

; --- Modified Navigation (With Multiplier Support) ---
#HotIf GetKeyState("CapsLock", "P")

; --- Modifiers (Using * to allow them to work with each other) ---
*$sc021::SendEvent "{Blind}{Control DownR}"   ; f
*$sc021 up::SendEvent "{Blind}{Control Up}"   

*$sc020::SendEvent "{Blind}{Shift DownR}"     ; d
*$sc020 up::SendEvent "{Blind}{Shift Up}"

*$sc01F::SendEvent "{Blind}{Alt DownR}"       ; s
*$sc01F up::SendEvent "{Blind}{Alt Up}"

; --- Navigation (Using {Blind} allows the mods above to pass through) ---
*$sc017:: ExecuteJump("Up")              ; i
*$sc025:: ExecuteJump("Down")            ; k

*$sc024:: {
    ResetMultiplier()
    SendEvent "{Blind}{Left}"
}
*$sc026:: {
    ResetMultiplier()
    SendEvent "{Blind}{Right}"
}

*$sc016::SendEvent "{Blind}{Home}"            ; u
*$sc018::SendEvent "{Blind}{End}"             ; o

*$sc015::SendEvent "{Blind}{PgUp}"            ; y
*$sc023::SendEvent "{Blind}{PgDn}"            ; h

#HotIf

*CapsLock up::
{
    if !GetKeyState("LControl", "P")
        Send "{Blind}{LControl Up}"
    if !GetKeyState("LShift", "P")
        Send "{Blind}{LShift Up}"
}

ExecuteJump(direction) {
    global multiplierBuffer

    if (multiplierBuffer != "") {
        count := Integer(multiplierBuffer)
        ; Delete the numbers typed before jumping up/down
        Send("{Blind}{BackSpace " . StrLen(multiplierBuffer) . "}{Blind}{" . direction . " " . count . "}")
        ResetMultiplier()
    } else {
        Send("{Blind}{" . direction . "}")
    }
}

; Uncomment this to show multiplierBuffer as a tooltip
UpdateTooltip() {
    ; global multiplierBuffer
    ; if (multiplierBuffer != "") {
    ;     ToolTip("Jump Buffer: " . multiplierBuffer)
    ; } else {
    ;     ToolTip() 
    ; }
}

; Rebooting if deactivated by spam
F12::
{
    SoundBeep(750, 200)
    Reload
}

; Emergency Hatch = Ctrl + Esc
^Esc::ExitApp