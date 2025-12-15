#######################################
# General shell behavior
#######################################

# Don't put duplicate lines or lines starting with space in history
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000

# Append to history, don't overwrite
shopt -s histappend

# Check window size after each command
shopt -s checkwinsize

# Enable color support
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

#######################################
# Colors
#######################################

# Regular colors
BLACK="\[\033[0;30m\]"
RED="\[\033[0;31m\]"
GREEN="\[\033[0;32m\]"
YELLOW="\[\033[0;33m\]"
BLUE="\[\033[0;34m\]"
PURPLE="\[\033[0;35m\]"
CYAN="\[\033[0;36m\]"
WHITE="\[\033[0;37m\]"

# Reset
RESET="\[\033[0m\]"

#######################################
# Git prompt helpers
#######################################

git_branch() {
  git symbolic-ref --short HEAD 2>/dev/null
}

git_dirty() {
  if ! git diff --quiet 2>/dev/null; then
    echo "*"
  fi
}

#######################################
# Prompt
#######################################
# Format:
# user@host:~/path (branch*) $
#
# * appears if repo is dirty

PROMPT_COMMAND='__git_ps1_prompt'

__git_ps1_prompt() {
  local EXIT="$?"
  local BRANCH=$(git_branch)
  local DIRTY=$(git_dirty)

  if [ -n "$BRANCH" ]; then
    PS1="${GREEN}\u@\h${RESET}:${BLUE}\w${RESET} ${YELLOW}(${BRANCH}${DIRTY})${RESET}\n$ "
  else
    PS1="${GREEN}\u@\h${RESET}:${BLUE}\w${RESET}\n$ "
  fi
}

#######################################
# Aliases
#######################################

# Safer commands
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Git shortcuts
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gca='git commit -a'
alias gp='git push'
alias gl='git pull'
alias gb='git branch'
alias gd='git diff'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -lah'
alias la='ls -A'

#######################################
# Environment
#######################################

export EDITOR=vim
export PAGER=less

#######################################
# Load extra configs if present
#######################################

[ -f ~/.bash_aliases ] && source ~/.bash_aliases
[ -f ~/.bash_profile ] && source ~/.bash_profile
