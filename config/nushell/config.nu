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
    {
        name: fuzzy_dir
        modifier: control
        keycode: char_f
        mode: [emacs, vi_normal, vi_insert]
        event: [
          {
              send: executehostcommand
              cmd: "commandline edit --insert (
                  ls **/*
                  | where type == dir
                  | sk 
                      --format {get name}
                      --prompt ' Select directory: '
                      --height 20
                      --layout reverse
                      --color=border:#1e1e2e
                  | get name
              )"
          }
      ]
    }
    {
        name: fuzzy_file
        modifier: control
        keycode: char_t
        mode: [emacs, vi_normal, vi_insert]
        event: [
          {
              send: executehostcommand
              cmd: "commandline edit --insert (
                  ls **/*
                  | where type == file
                  | sk 
                      --format {get name}
                      --preview {bat --force-colorization ($in | get name)}
                      --prompt '󰈞 Select file: '
                      --height 20
                      --layout reverse
                  | get name
              )"
          }
      ]
    }
  ]
}

source load-hooks.nu
source aliases.nu
