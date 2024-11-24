#Requires AutoHotkey v2.0
#SingleInstance Force

; Store window information as global variables
global windowHotkeys := Map()
global currentHotkeyNumber := 1
global mainGui := {}

; Create settings object with default values
global settings := {
    windowHotkey: "!"       ; Default: Alt
}

; Create the GUI
CreateSettingsGui() {
    global mainGui
    
    mainGui := Gui("+AlwaysOnTop -MinimizeBox", "Window Switcher Settings")
    mainGui.BackColor := "0x2D2D2D"
    mainGui.SetFont("s10 cWhite", "Segoe UI")
    
    ; Modifier key for window switching
    mainGui.Add("Text", "x20 y20 w200", "Select Modifier Key:")
    modifierDropDown := mainGui.Add("DropDownList", "x20 y45 w200 h25 v_windowModifier", ["Alt", "Ctrl", "Win", "Shift"])
    modifierDropDown.Choose("Alt")
    
    ; Save button
    saveBtn := mainGui.Add("Button", "x20 y85 w200 h30", "Save Settings")
    saveBtn.OnEvent("Click", SaveSettings)
    
    ; Instructions
    mainGui.Add("Text", "x20 y125 w200", "How to use:")
    mainGui.Add("Text", "x20 y150 w200", "1. Ctrl+Alt+A to assign window")
    mainGui.Add("Text", "x20 y175 w200", "2. " . (settings.windowHotkey = "!" ? "Alt" : "Modifier") . "+Number to switch")
    mainGui.Add("Text", "x20 y200 w200", "3. Ctrl+Alt+R to reset all")
    
    ; Status text
    mainGui.Add("Text", "x20 y230 w200 v_statusText cLime")
    
    return mainGui
}

SaveSettings(*) {
    global settings, mainGui
    
    ; Get values from GUI
    newSettings := mainGui.Submit(false)
    
    ; Convert modifier selection to AutoHotkey symbol
    modifierMap := Map(
        "Alt", "!",
        "Ctrl", "^",
        "Win", "#",
        "Shift", "+"
    )
    settings.windowHotkey := modifierMap[newSettings._windowModifier]
    
    ; Show success message
    mainGui["_statusText"].Value := "Settings saved!"
    SetTimer () => mainGui["_statusText"].Value := "", -2000
}

; Function to switch to window
SwitchToWindow(*) {
    global windowHotkeys
    ThisHotkey := A_ThisHotkey
    if windowHotkeys.Has(ThisHotkey) {
        windowInfo := windowHotkeys[ThisHotkey]
        if WinExist("ahk_id " windowInfo.id) {
            WinActivate "ahk_id " windowInfo.id
            WinShow "ahk_id " windowInfo.id
        }
    }
}

; Assign window hotkey
^!a:: {
    global currentHotkeyNumber, windowHotkeys, settings
    
    activeWindow := WinGetTitle("A")
    if activeWindow = "" 
        return
    
    hotkeyCombo := settings.windowHotkey . currentHotkeyNumber
    
    ; Store window info
    windowHotkeys[hotkeyCombo] := {
        title: activeWindow,
        id: WinGetID("A")
    }
    
    ; Create the hotkey
    try {
        Hotkey hotkeyCombo, "Off"
    }
    Hotkey hotkeyCombo, SwitchToWindow
    
    ; Show tooltip
    modifierName := Map("!", "Alt", "^", "Ctrl", "#", "Win", "+", "Shift")[settings.windowHotkey]
    ToolTip "Window assigned to " modifierName " + " currentHotkeyNumber
    SetTimer () => ToolTip(), -2000
    
    currentHotkeyNumber := Mod(currentHotkeyNumber, 9) + 1
    if currentHotkeyNumber = 0
        currentHotkeyNumber := 1
}

; Reset all windows
^!r:: {
    global currentHotkeyNumber, windowHotkeys
    
    ; Remove all hotkeys
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

; Create and show the GUI
settingsGui := CreateSettingsGui()
settingsGui.Show()