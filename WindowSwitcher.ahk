#Requires AutoHotkey v2.0
#SingleInstance Force

; Store window information as global variables
global windowHotkeys := Map()
global numberOverlays := Map()

; Create hotkeys for numbers 1-9
Loop 9 {
    ; Create assignment hotkeys (Alt+Ctrl+Number)
    assignHotkey := "^!" . A_Index
    Hotkey assignHotkey, AssignWindow.Bind(A_Index)

    ; Create switch hotkeys (Alt+Number)
    switchHotkey := "!" . A_Index
    Hotkey switchHotkey, SwitchToWindow.Bind(A_Index)
}

; Function to create number overlay
CreateOverlay(number, windowId) {
    ; Remove existing overlay for this number if exists
    if numberOverlays.Has(number) {
        existingOverlay := numberOverlays[number]
        existingOverlay.Destroy()
    }

    ; Create new overlay
    overlay := Gui("-Caption +ToolWindow +AlwaysOnTop")
    overlay.BackColor := "2D2D2D"
    overlay.SetFont("s12 cWhite", "Segoe UI")
    overlay.Add("Text", "w30 h30 Center", number)
    
    ; Get window position
    WinGetPos(&x, &y, &w, &h, "ahk_id " windowId)
    
    ; Position overlay at bottom-left
    overlay.Show("x" x " y" (y + h - 30) " NoActivate")
    
    ; Store overlay reference
    numberOverlays[number] := overlay
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
    
    windowId := WinGetID("A")
    
    ; Store window info with the number as the key
    windowHotkeys[number] := {
        title: activeWindow,
        id: windowId
    }
    
    ; Create or update overlay
    CreateOverlay(number, windowId)
    
    ; Show tooltip
    ToolTip "Window assigned to Alt + " number
    SetTimer () => ToolTip(), -2000
}

; Reset all windows (Ctrl+Alt+R)
^!r:: {
    global windowHotkeys, numberOverlays
    
    ; Remove all overlays
    for overlay in numberOverlays.Values {
        overlay.Destroy()
    }
    numberOverlays.Clear()
    
    ; Clear window assignments
    windowHotkeys.Clear()
    ToolTip "All window assignments reset"
    SetTimer () => ToolTip(), -2000
}

; Monitor window position changes to update overlay positions
SetTimer MonitorWindows, 100

MonitorWindows() {
    global windowHotkeys, numberOverlays
    
    for number, windowInfo in windowHotkeys {
        if WinExist("ahk_id " windowInfo.id) {
            WinGetPos(&x, &y, &w, &h, "ahk_id " windowInfo.id)
            if numberOverlays.Has(number) {
                overlay := numberOverlays[number]
                overlay.Show("x" x " y" (y + h - 30) " NoActivate")
            }
        }
    }
}