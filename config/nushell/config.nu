use lib.nu [pick-dirs pick-files filtered-files]
use completion/main.nu [commandline-fuzzy-complete-dwim]

const menu_style = {
  text: green
  selected_text: green_reverse
  description_text: white
}


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
        name: echo_line
        modifier: control
        keycode: char_i
        mode: [emacs vi_insert]
        event: [
          {
            send: executehostcommand
            cmd: "commandline-fuzzy-complete-dwim"
          }
        ]
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
        modifier: control
        keycode: char_e
        mode: [emacs, vi_normal, vi_insert]
        event: [
          {
              send: executehostcommand
              cmd: $"commandline edit --insert \(pick-dirs\)"
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
              cmd: $"commandline edit --insert \(pick-files\)"
          }
      ]
    }
  ]
}

source load-hooks.nu
source aliases.nu
