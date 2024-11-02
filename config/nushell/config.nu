$env.config = {
  keybindings: [
    {
        name: menu_next
        modifier: control
        keycode: char_j
        mode: [emacs vi_insert]
        event: {
            until: [
                { send: menunext }
            ]
        }
    }
    {
        name: menu_prev
        modifier: control
        keycode: char_k
        mode: [emacs vi_insert]
        event: {
            until: [
                { send: menuprevious }
            ]
        }
    }
  ]
}

source load-hooks.nu
source aliases.nu
