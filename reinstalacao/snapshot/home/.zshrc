# Created by newuser for 5.9.1
eval "$(starship init zsh)"
export PATH="$HOME/.local/bin:$PATH"
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# eza no lugar do ls
alias l='eza --icons --group-directories-first'
alias ls='eza -l --icons --group-directories-first --no-permissions --no-user --header --time-style=long-iso'
alias ll='eza -l --icons --group-directories-first --header --git'
alias la='eza -la --icons --group-directories-first --header --git'
alias lt='eza --tree --level=2 --icons --group-directories-first'
