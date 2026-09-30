# File system
if command -q eza
  alias ls 'eza -lh --group-directories-first --icons=auto'
  alias lsa 'ls -a'
  alias lt 'eza --tree --level=2 --long --icons --git'
  alias lta 'lt -a'
end

if test "$TERM" = xterm-kitty
  alias ff "fzf --preview 'switch (file --mime-type -b {})\n    case image/\*\n      kitty icat --clear --transfer-mode=memory --stdin=no --place=\$FZF_PREVIEW_COLUMNS\x\$FZF_PREVIEW_LINES@0x0 {}\n    case \*\n      bat --style=numbers --color=always {}\n    end'"
else
  alias ff "fzf --preview 'bat --style=numbers --color=always {}'"
end

function n
  if test (count $argv) -eq 0
    command nano .
  else
    command nano $argv
  end
end

function open
  xdg-open $argv >/dev/null 2>&1 &
end

# Directories
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'

# Tools
alias c opencode
alias d docker
alias r rails
alias t 'tmux attach || tmux new -s Work'
alias mup 'MISE_MINIMUM_RELEASE_AGE=0 mise up'

# Git
alias g git
alias gcm 'git commit -m'
alias gcam 'git commit -a -m'
alias gcad 'git commit -a --amend'
