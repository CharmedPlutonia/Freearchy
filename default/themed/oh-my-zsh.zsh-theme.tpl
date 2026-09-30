# Freearchy Oh My Zsh theme — generated from the active palette.

autoload -Uz colors && colors

FREEARCHY_ACCENT="%F{{{ accent }}}"
FREEARCHY_FG="%F{{{ foreground }}}"
FREEARCHY_DIM="%F{{{ color8 }}}"
FREEARCHY_OK="%F{{{ color2 }}}"
FREEARCHY_ERR="%F{{{ color1 }}}"

PROMPT='${FREEARCHY_ACCENT}%n@%m%f ${FREEARCHY_FG}%~%f $(git_prompt_info)${FREEARCHY_ACCENT}❯%f '
RPROMPT='${FREEARCHY_DIM}%T%f'

ZSH_THEME_GIT_PROMPT_PREFIX="${FREEARCHY_DIM}(${FREEARCHY_OK}"
ZSH_THEME_GIT_PROMPT_SUFFIX="${FREEARCHY_DIM}) %f"
ZSH_THEME_GIT_PROMPT_DIRTY="${FREEARCHY_ERR}*%f"
ZSH_THEME_GIT_PROMPT_CLEAN=""
