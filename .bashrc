#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

eval "$(starship init bash)"
. "$HOME/.cargo/env"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/fustigate/miniconda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/fustigate/miniconda/etc/profile.d/conda.sh" ]; then
        . "/home/fustigate/miniconda/etc/profile.d/conda.sh"
    else
        export PATH="/home/fustigate/miniconda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

