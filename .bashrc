# .bashrc

# Exit early if not running interactively
[[ $- != *i* ]] && return

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Extend PATH
export PATH="$PATH:$HOME/.local/bin"

# Clear screen and welcome message
if [[ $SHLVL -eq 1 ]]; then
    clear
    printf "Welcome back \e[95m$(whoami)\e[0m — \e[96m%s\e[0m\n" "$(date +'%a, %b %d %H:%M')"
    ls -lhF --color=auto
fi

# Aliases
alias cl='clear' # clear the terminal
alias pwd='printf "\e[95m$(builtin pwd)\e[0m\n"' # print the current directory in color
alias l='pwd && ls -lhF --color=auto' # print the current directory and list its contents with details and color
alias la='pwd && ls -lhFa --color=auto' # print the current directory and list all its contents (including hidden files) with details and color
alias gh='history | grep' # search command history for a specific term
alias envs='cd /home/username/.conda/envs' # go to the directory where conda environments are stored
alias b='cd ..' # go up one directory
alias h='cd ${HOME}' # go to the home directory
alias load='ml Conda; ml CUDA; ml uge' # load necessary modules for work
alias du='du -h' # show disk usage in human-readable format

# Enhanced 'cd' with color, history and content listing
cd() {
  builtin cd "$@" && l
}

back() {
  printf "Changing from \e[92m%s\e[0m back to \e[92m%s\e[0m\n" "$PWD" "$OLDPWD"
  builtin cd - >/dev/null && l
}

# Make quick commits
commit() {
  git add .
  git commit -m "${1:?commit message required}"
  git push
}

# Unset RETICULATE_PYTHON to allow reticulate to find the correct Python environment
unset RETICULATE_PYTHON
