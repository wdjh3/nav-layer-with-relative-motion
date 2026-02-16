#Requires AutoHotkey v2.0

SetCapsLockState "AlwaysOff"

; --- Global Variables for Multiplier ---
global multiplierBuffer := ""
global ih := InputHook("L0 V I1") ; L0: no limit, V: visible (don't block), I1: ignore script-sent keys

; This function resets the buffer
ResetMultiplier(*) {
    global multiplierBuffer := ""
}

; Define what happens when a key is pressed while "counting"
ih.OnKeyDown := OnAnyKeyDown
ih.Start() ; Start listening for a "break" key (non-numeric)

OnAnyKeyDown(ih, vk, sc) {
    return ( !(vk >=  && vk <= 57) ? ResetMultiplier() : "" )
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

capture(num) {
    global multiplierBuffer .= num
}

; --- Modified Navigation (With Multiplier Support) ---
#HotIf GetKeyState("CapsLock", "P")

; --- Modifiers (Using * to allow them to work with each other) ---
*sc021::Send "{Blind}{Control DownR}"   ; f
*sc021 up::Send "{Blind}{Control Up}"   

*sc020::Send "{Blind}{Shift DownR}"     ; d
*sc020 up::Send "{Blind}{Shift Up}"

*sc01F::Send "{Blind}{Alt DownR}"       ; s
*sc01F up::Send "{Blind}{Alt Up}"

; --- Navigation (Using {Blind} allows the mods above to pass through) ---
*sc017:: ExecuteJump("Up")    ; i
*sc025:: ExecuteJump("Down")  ; k

*sc024:: {
    ResetMultiplier()
    Send "{Blind}{Left}"
}
*sc026:: {
    ResetMultiplier()
    Send "{Blind}{Right}"
}

*sc016::Send "{Blind}{Home}"            ; u
*sc018::Send "{Blind}{End}"             ; o

#HotIf

ExecuteJump(direction) {
    global multiplierBuffer
    if (multiplierBuffer != "") {
        count := Integer(multiplierBuffer)
        ; 1. Delete the numbers typed on screen
        Send("{BackSpace " . StrLen(multiplierBuffer) . "}")
        
        ; 2. Perform the jump (no -1 needed here because we intercepted the key)
        Loop count {
            Send("{Blind}{" . direction . "}")
        }
        ResetMultiplier()
    } else {
        Send("{Blind}{" . direction . "}")
    }
}

