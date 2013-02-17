#Yoplitein's exquisite ~/.bashrc
#Warning: may contain small amounts of command-line kung-fu

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines/lines beginning with a space in history
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# enable programmable completion features
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

#Custom titlebar stuff
case $TERM in
    xterm*)
        SETTITLE='\[\033]0;\u@\h:\w\007\]'
        ;;
    *)
        SETTITLE=''
        ;;
esac

#Display the running command in the title
#solution courtesy of Gilles from superuser.com
preexec() { :; }

preexec_invoke()
{
    #if returning from the command, do nothing
    [ -n "$COMP_LINE" ] && return
    
    local this_command=`history 1 | sed -e "s/^[ ]*[0-9]*[ ]*//g"`;
    
    echo -ne "\033]0;${USER}@${HOST}:${PWD##*/} \$$this_command\007"
    
    preexec "$this_command"
}

trap "preexec_invoke" DEBUG

#I love the fuck out of colors. Seriously.
NORMAL_COLOR='\[$(tput sgr0)\]'
RED_COLOR='\[$(tput setaf 1)\]'
GREEN_COLOR='\[$(tput setaf 2)\]'
YELLOW_COLOR='\[$(tput setaf 3)\]'
BLUE_COLOR='\[$(tput setaf 4)\]'
PURPLE_COLOR='\[$(tput setaf 5)\]'
CYAN_COLOR='\[$(tput setaf 6)\]'
BOLD_COLOR='\[$(tput bold)\]'

export PS1="$SETTITLE$YELLOW_COLOR[\D{%H:%M:%S}]$GREEN_COLOR\u$RED_COLOR@$BLUE_COLOR\h$BOLD_COLOR$PURPLE_COLOR:$YELLOW_COLOR\W $CYAN_COLOR\$$NORMAL_COLOR"

unset SETTITLE NORMAL_COLOR RED_COLOR GREEN_COLOR YELLOW_COLOR BLUE_COLOR PURPLE_COLOR CYAN_COLOR BOLD_COLOR

#add ~/bin to path
export PATH=$PATH:~/bin

#disable history expansion (so ! doesn't have to be escaped)
set +H

#disable XON/XOFF
#(out of habit, I ctrl+s in vim a lot)
stty -ixon

#Aliases and broken/stupid functionality fixes
#General aliases
alias ls='ls -A1 --color=auto'
alias lsl='ls -A1l --color=auto'
alias psa='ps -Ao %cpu:4,%mem:4,start:5,user:15,pid:5,cmd'
alias cls='clear'
alias shlvl='echo SHLVL is $SHLVL'
alias tree='tree -aAC'

#I should have to pass arguments to specify non-human-readable, ffs
alias du='du -h'
alias df='df -h'

#So I can screen -x after su'ing
function su() { chmod o+rw $SSH_TTY; $(which su) $@; chmod o-rw $SSH_TTY; }

#Stupid openSUSE behavior fixes
alias man='env MAN_POSIXLY_CORRECT=true man'
alias sudo='env PATH=$PATH:/usr/sbin:/sbin sudo -E'

#Colors are fun! wheee!!
alias grep='grep --color=auto'
alias fgrep='grep -F --color=auto'
alias egrep='grep -E --color=auto'

#Display $SHLVL on exit
#(I have a bad habit of opening shells in vim and then opening vim in those shells, and so on)
trap 'echo -e "Goodbye.\nSHLVL is now $(expr $SHLVL - 1)"; exit' 0

#Execute site-specific configurations
if [ -e ~/.bashrc-site ]; then
    source ~/.bashrc-site
fi

#Display some neat info on login
if [ "$LOGIN_INFO_SHOWN" == "" ]; then
    echo Welcome to $(tput setaf 2)$(hostname --fqdn)$(tput sgr0)
    echo System uptime: $(tput setaf 1)$(python ~/bin/uptime)$(tput sgr0)
    echo Users connected: $(tput setaf 3)$(who -q | head -n 1 | sed 's/[ ][ ]*/, /g')$(tput sgr0)
    echo Language and encoding: $(tput setaf 6)$LANG$(tput sgr0)
    LOGIN_INFO_SHOWN=1
fi
