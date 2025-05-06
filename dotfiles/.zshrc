# Set ZSH as interactive
export ZSH="$HOME/.oh-my-zsh"

# Prompt: starship (recommended)
eval "$(starship init zsh)"

# Set default editor
export EDITOR="vim"

# Add custom paths
export PATH="$HOME/bin:/usr/local/bin:$PATH"

# History config
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
setopt inc_append_history share_history

# Autocorrect and completion
setopt correct
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

# Aliases
alias ll='ls -lah --color=auto'
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias ..='cd ..'
alias please='sudo'

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Enable vi mode
bindkey -v

# Prompt theme fallback if starship isn't used
# PROMPT='%F{cyan}%n@%m%f %F{yellow}%~%f %# '

# Plugins (optional, if using Oh My Zsh)
plugins=(git docker z zsh-autosuggestions zsh-syntax-highlighting)

# Source Oh My Zsh
[ -f $ZSH/oh-my-zsh.sh ] && source $ZSH/oh-my-zsh.sh

# Starship config (create ~/.config/starship.toml if you want themed prompt)
