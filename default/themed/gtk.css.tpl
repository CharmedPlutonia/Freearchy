@define-color window_bg_color {{ background }};
@define-color window_fg_color {{ foreground }};
@define-color view_bg_color {{ background }};
@define-color view_fg_color {{ foreground }};
@define-color accent_bg_color {{ accent }};
@define-color accent_fg_color {{ background }};
@define-color accent_color {{ accent }};
@define-color headerbar_bg_color {{ color0 }};
@define-color headerbar_fg_color {{ foreground }};
@define-color card_bg_color {{ color0 }};
@define-color popover_bg_color {{ color0 }};
@define-color popover_fg_color {{ foreground }};
@define-color sidebar_bg_color {{ background }};
@define-color sidebar_fg_color {{ foreground }};
@define-color theme_bg_color {{ background }};
@define-color theme_fg_color {{ foreground }};
@define-color theme_selected_bg_color {{ selection_background }};
@define-color theme_selected_fg_color {{ selection_foreground }};

* {
  border-radius: 0;
  -gtk-outline-radius: 0;
}

window,
dialog,
headerbar,
button,
entry,
textview,
.boxed-list,
.card,
popover,
menu,
notebook,
tab,
switch,
scale,
progressbar,
scrollbar,
tooltip,
.sidebar,
.navigation-sidebar {
  border-radius: 0;
}
