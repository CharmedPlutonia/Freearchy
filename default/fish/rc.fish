if test -f ~/.config/fish/themes/Freearchy.theme
  fish_config theme choose Freearchy 2>/dev/null
end

if command -q mise
  mise activate fish | source
end

if status is-interactive; and test "$TERM" != dumb; and command -q starship
  starship init fish | source
end

if command -q zoxide
  zoxide init fish | source
end

if command -q fzf
  if test -f /usr/share/fzf/key-bindings.fish
    source /usr/share/fzf/key-bindings.fish
  end
end

if command -q eza
  alias ls 'eza -lh --group-directories-first --icons=auto'
  alias lsa 'ls -a'
  alias lt 'eza --tree --level=2 --long --icons --git'
  alias lta 'lt -a'
end

alias .. 'cd ..'
alias ... 'cd ../..'
alias g git
alias n nano
