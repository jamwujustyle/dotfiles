# Prevent execution in non-interactive shells
case $- in
    *i*) ;;
      *) return;;
esac

# History Settings
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

# Window size check
shopt -s checkwinsize

# Lesspipe for better file viewing
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Basic Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Custom Prompt Logic (jamwujustyle)
set_prompt() {
    local last_cmd=$?
    local arrow_color="\[\e[1;32m\]"
    if [ $last_cmd -ne 0 ]; then
        arrow_color="\[\e[1;31m\]"
    fi

    local cyan="\[\e[1;36m\]"
    local blue="\[\e[1;34m\]"
    local red="\[\e[1;31m\]"
    local yellow="\[\e[1;33m\]"
    local reset="\[\e[0m\]"

    local git_info=""
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
    
    if [ -n "$branch" ]; then
        local dirty=""
        if [ -n "$(git status --porcelain 2> /dev/null)" ]; then
            dirty=" ${yellow}✗"
        fi
        git_info=" ${blue}git:(${red}${branch}${blue})${dirty}"
    fi

    PS1="${arrow_color}➜ ${cyan}\W${git_info}${reset} "
}
PROMPT_COMMAND=set_prompt

# Development Aliases & Functions
alias db='pgcli postgresql://postgres:postgres@localhost:5432/postgres'
alias pg-dev='pgcli postgresql://postgres:postgres@localhost:5432/postgres'

app() {
    docker exec -it openbook_app bash
}

migrate() {
    docker exec -it openbook_app bash -c "alembic revision --autogenerate -m 'auto' && alembic upgrade head"
}

lsof() {
    sudo lsof -i -P -n | grep LISTEN
}

kill_proc() {
    sudo kill -9 "$@"
}

freee() {
  local port=$1
  if sudo fuser -k "$port/tcp"; then
    echo "successfully killed $port"
  fi
}

tree() {
    command tree -I '__pycache__|node_modules|.git|.venv|dist|build|coverage|.pytest_cache|venv' "$@"
}

# Path Exports (Generalized for any user)
export PATH="$PATH:$HOME/.foundry/bin"
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/.local/share/yabridge"
export PATH="$PATH:$(go env GOPATH 2>/dev/null)/bin"

# NVM Support
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Conditional Source for ble.sh (Prevents error if not installed)
[ -f "$HOME/.local/share/blesh/ble.sh" ] && source "$HOME/.local/share/blesh/ble.sh"

# Source Bash Aliases if file exists
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Enable Bash Completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
