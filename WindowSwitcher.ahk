#Requires AutoHotkey v2.0
#SingleInstance Force

; Store window information as global variables
global windowHotkeys := Map()

; Create hotkeys for numbers 1-9
Loop 9 {
    ; Create assignment hotkeys (Alt+Ctrl+Number)
    assignHotkey := "^!" . A_Index
    Hotkey assignHotkey, AssignWindow.Bind(A_Index)

    ; Create switch hotkeys (Alt+Number)
    switchHotkey := "!" . A_Index
    Hotkey switchHotkey, SwitchToWindow.Bind(A_Index)
}

; Function to switch to window
SwitchToWindow(number, *) {
    global windowHotkeys
    if windowHotkeys.Has(number) {
        windowInfo := windowHotkeys[number]
        if WinExist("ahk_id " windowInfo.id) {
            WinActivate "ahk_id " windowInfo.id
            WinShow "ahk_id " windowInfo.id
        }
    }
}

; Assign window function
AssignWindow(number, *) {
    global windowHotkeys
    
    ; Get the current window
    activeWindow := WinGetTitle("A")
    if activeWindow = "" 
        return
    
    ; Store window info with the number as the key
    windowHotkeys[number] := {
        title: activeWindow,
        id: WinGetID("A")
    }
    
    ; Show tooltip
    ToolTip "Window assigned to Alt + " number
    SetTimer () => ToolTip(), -2000
}

; Reset all windows (Ctrl+Alt+R)
^!r:: {
    global windowHotkeys
    windowHotkeys.Clear()
    ToolTip "All window assignments reset"
    SetTimer () => ToolTip(), -2000
}