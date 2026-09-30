/* Freearchy Firefox chrome — generated from the active palette. */
:root {
  --freearchy-bg: {{ background }};
  --freearchy-fg: {{ foreground }};
  --freearchy-accent: {{ accent }};
  --toolbar-bgcolor: {{ background }} !important;
  --toolbar-color: {{ foreground }} !important;
  --lwt-accent-color: {{ background }} !important;
  --lwt-text-color: {{ foreground }} !important;
  --tab-selected-bgcolor: {{ color0 }} !important;
}

#navigator-toolbox,
#TabsToolbar,
#nav-bar,
#PersonalToolbar {
  background-color: var(--freearchy-bg) !important;
  color: var(--freearchy-fg) !important;
}

.tab-background[selected] {
  background-color: {{ color0 }} !important;
}

#urlbar-background {
  background-color: {{ color0 }} !important;
}

#urlbar-input,
.urlbar-input-box {
  color: {{ foreground }} !important;
}
