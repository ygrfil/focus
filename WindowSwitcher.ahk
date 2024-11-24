#Requires AutoHotkey v2.0

; Store window information as global variables
global windowHotkeys := Map()
global currentHotkeyNumber := 1

; Function to switch to window
SwitchToWindow(*) {
    global windowHotkeys
    hotkeyCombo := A_ThisHotkey
    windowInfo := windowHotkeys[hotkeyCombo]
    if WinExist("ahk_id " windowInfo.id)
        WinActivate "ahk_id " windowInfo.id
}

; Ctrl + Alt + A to assign a hotkey to the current active window
^!a:: {
    global currentHotkeyNumber, windowHotkeys
    
    activeWindow := WinGetTitle("A")
    if activeWindow = ""
        return

    ; Create hotkey combination (Alt + Number)
    hotkeyCombo := "!" . currentHotkeyNumber
    
    ; Store window info
    windowHotkeys[hotkeyCombo] := {
        title: activeWindow,
        id: WinGetID("A")
    }
    
    ; Create the hotkey without condition
    try {
        Hotkey hotkeyCombo, "Off"  ; Turn off existing hotkey if it exists
    }
    Hotkey hotkeyCombo, SwitchToWindow
    Hotkey hotkeyCombo, "On"
    
    ; Show tooltip with assigned hotkey
    ToolTip "Window assigned to Alt + " currentHotkeyNumber
    SetTimer () => ToolTip(), -2000  ; Hide tooltip after 2 seconds
    
    currentHotkeyNumber := Mod(currentHotkeyNumber, 9) + 1
}

; Ctrl + Alt + R to reset all assignments
^!r:: {
    global currentHotkeyNumber, windowHotkeys
    
    ; Turn off all existing hotkeys
    for hotkeyCombo in windowHotkeys {
        try {
            Hotkey hotkeyCombo, "Off"
        }
    }
    
    windowHotkeys.Clear()
    currentHotkeyNumber := 1
    ToolTip "All window assignments reset"
    SetTimer () => ToolTip(), -2000
} 