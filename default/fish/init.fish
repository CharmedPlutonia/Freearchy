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

  function cd --description 'zoxide-aware cd'
    if test (count $argv) -eq 0
      builtin cd ~
      return
    else if test -d $argv[1]
      builtin cd $argv[1]
      return
    end

    if not z $argv
      echo "Error: Directory not found"
      return 1
    end

    printf '\U000F17A9 '
    pwd
  end
end

if command -q fzf; and test -f /usr/share/fzf/key-bindings.fish
  source /usr/share/fzf/key-bindings.fish
end
