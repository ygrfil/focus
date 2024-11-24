#Requires AutoHotkey v2.0
#SingleInstance Force

; Store window information as global variables
global windowHotkeys := Map()
global numberOverlays := Map()

; Create hotkeys for numbers 1-9 and navigation
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
    overlay.SetFont("s12", "Segoe UI")
    overlay.Add("Text", "w30 h30 Center vNumberText cGray", number)
    
    ; Get window position
    WinGetPos(&x, &y, &w, &h, "ahk_id " windowId)
    
    ; Position overlay at bottom-left
    overlay.Show("x" x " y" (y + h - 30) " NoActivate")
    
    ; Store overlay reference
    numberOverlays[number] := overlay
}

; Function to highlight active window's number
UpdateOverlayHighlights() {
    global numberOverlays, windowHotkeys
    activeId := WinGetID("A")
    
    for number, windowInfo in windowHotkeys {
        if numberOverlays.Has(number) {
            overlay := numberOverlays[number]
            if (windowInfo.id = activeId) {
                overlay["NumberText"].SetFont("cLime")
            } else {
                overlay["NumberText"].SetFont("cGray")
            }
        }
    }
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
    
    ; Update highlights
    UpdateOverlayHighlights()
}

; Navigation hotkeys - completely simplified
!.:: {  ; Alt+Period for next
    global windowHotkeys
    
    if (windowHotkeys.Count = 0)
        return
        
    ; Get current active window
    activeId := WinExist("A")
    currentNumber := 0
    
    ; Find current number
    for number, windowInfo in windowHotkeys {
        if (windowInfo.id = activeId) {
            currentNumber := number
            break
        }
    }
    
    ; Find next window
    if (currentNumber = 0) {
        ; If current window isn't assigned, try number 1
        if windowHotkeys.Has(1)
            SwitchToWindow(1)
        return
    }
    
    ; Try next numbers sequentially
    nextNumber := currentNumber + 1
    while nextNumber <= 9 {
        if windowHotkeys.Has(nextNumber) {
            SwitchToWindow(nextNumber)
            return
        }
        nextNumber++
    }
    
    ; If we reached here, loop back to the beginning
    Loop 9 {
        if windowHotkeys.Has(A_Index) {
            SwitchToWindow(A_Index)
            break
        }
    }
}

!,:: {  ; Alt+Comma for previous
    global windowHotkeys
    
    if (windowHotkeys.Count = 0)
        return
        
    ; Get current active window
    activeId := WinExist("A")
    currentNumber := 0
    
    ; Find current number
    for number, windowInfo in windowHotkeys {
        if (windowInfo.id = activeId) {
            currentNumber := number
            break
        }
    }
    
    ; Find previous window
    if (currentNumber = 0) {
        ; If current window isn't assigned, try number 9
        if windowHotkeys.Has(9)
            SwitchToWindow(9)
        return
    }
    
    ; Try previous numbers sequentially
    prevNumber := currentNumber - 1
    while prevNumber >= 1 {
        if windowHotkeys.Has(prevNumber) {
            SwitchToWindow(prevNumber)
            return
        }
        prevNumber--
    }
    
    ; If we reached here, loop back to the end
    Loop 9 {
        checkNumber := 10 - A_Index  ; Count down from 9 to 1
        if windowHotkeys.Has(checkNumber) {
            SwitchToWindow(checkNumber)
            break
        }
    }
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

; Monitor window position changes and focus
SetTimer MonitorWindows, 100

MonitorWindows() {
    global windowHotkeys, numberOverlays
    static lastActiveWindow := ""
    
    try {
        currentActive := WinExist("A")
        if (currentActive && currentActive != lastActiveWindow) {
            UpdateOverlayHighlights()
            lastActiveWindow := currentActive
        }
        
        for number, windowInfo in windowHotkeys {
            if WinExist("ahk_id " windowInfo.id) {
                WinGetPos(&x, &y, &w, &h, "ahk_id " windowInfo.id)
                if numberOverlays.Has(number) {
                    overlay := numberOverlays[number]
                    overlay.Show("x" x " y" (y + h - 30) " NoActivate")
                }
            }
        }
    } catch Error {
        return
    }
}