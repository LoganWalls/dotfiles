if application "Ghostty" is running then
   tell application "Ghostty" to activate
   delay 0.1
   tell application "System Events"
      -- The keymap for `reload_config` in Ghostty. Change this if necessary:
      keystroke "," using {shift down, command down}
   end tell
end if
