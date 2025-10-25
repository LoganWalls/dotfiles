def filtered-dirs [] {
  fd --type dir --print0
  | split row (char -u '0000')
  | compact --empty
  | ls -D ...$in
}

def filtered-files [] {
  fd --type file --print0
  | split row (char -u '0000')
  | compact --empty
  | ls ...$in
}

const menu_style = {
  text: green
  selected_text: green_reverse
  description_text: white
}

const sk_theme = "bg:empty,bg+:empty,cursor:5,info:7,prompt:12,fg+:12,current:12,matched:0,current_match:12,matched_bg:157,current_match_bg:153,spinner:12"

$env.config = {
  show_banner: false
    menus: [
      {
        name: completion_menu
        only_buffer_difference: false
        marker: "| "
        type: {
            layout: columnar
            columns: 4
            col_width: 20
            col_padding: 2
        }
        style: $menu_style
      } 
      {
      name: history_menu
      only_buffer_difference: true 
      marker: "? "
      type: {
          layout: list
          page_size: 10
      }
      style: $menu_style
      }
  ]
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
        name: help_menu
        modifier: control
        keycode: char_h
        mode: [emacs vi_insert vi_normal]
        event: {
          until: [
            { send: menu name: help_menu }
            { send: menupagenext }
          ]
        }
    }
    {
        name: fuzzy_dir
        modifier: shift_control
        keycode: char_f
        mode: [emacs, vi_normal, vi_insert]
        event: [
          {
              send: executehostcommand
              cmd: $"commandline edit --insert \(
                  filtered-dirs
                  | sk 
                      --format {get name}
                      --preview {tree --icons=always --color=always \($in | get name\)}
                      --prompt '󰥨 '
                      --layout reverse
                      --color=($sk_theme)
                  | default { name: "" } 
                  | get name
              \)"
          }
      ]
    }
    {
        name: fuzzy_file
        modifier: control
        keycode: char_f
        mode: [emacs, vi_normal, vi_insert]
        event: [
          {
              send: executehostcommand
              cmd: $"commandline edit --insert \(
                  filtered-files
                  | sk 
                      --format {get name}
                      --preview {bat --force-colorization \($in | get name\)}
                      --prompt '󰈞 '
                      --layout reverse
                      --color=($sk_theme)
                  | default { name: "" } 
                  | get name
              \)"
          }
      ]
    }
  ]
}
source load-hooks.nu
source aliases.nu
