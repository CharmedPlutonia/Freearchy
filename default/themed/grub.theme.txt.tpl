# Freearchy GRUB theme generated from the active palette.
desktop-color: "{{ background }}"
title-color: "{{ foreground }}"
title-text: "Freearchy"
message-color: "{{ foreground }}"
message-bg-color: "{{ background }}"
terminal-font: "Unifont Regular 16"
terminal-box: "terminal_*.png"

+ boot_menu {
  left = 20%
  width = 60%
  top = 25%
  height = 50%
  item_font = "Unifont Regular 16"
  item_color = "{{ foreground }}"
  selected_item_color = "{{ background }}"
  selected_item_pixmap_style = "select_*.png"
  item_height = 32
  item_padding = 8
  item_spacing = 8
}

+ label {
  id = "__timeout__"
  left = 20%
  top = 80%
  width = 60%
  align = "center"
  text = "Booting in %d seconds"
  color = "{{ accent }}"
}
