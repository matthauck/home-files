
# whether or not on mac
if [ $(uname) = "Darwin" ]; then
  export IS_MAC=true
  export IS_X64=true
else
  export IS_MAC=false
  if [[ $(uname -m) =~ i[0-9]86 ]]; then
    export IS_X64=false
  else
    export IS_X64=true
  fi
fi


# http://stackoverflow.com/a/246128
MYDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

MYDIR=$( cd "$( dirname "$0" )" && pwd )

. $MYDIR/is_mosh.sh
. $MYDIR/../git/git.zsh

if [ "$IS_MAC" = true ]; then
#  if [ -f $(brew --prefix)/etc/bash_completion ]; then
#    . $(brew --prefix)/etc/bash_completion.d/git-completion.bash
#    . $(brew --prefix)/etc/bash_completion.d/git-prompt.sh
#    . $(brew --prefix)/etc/bash_completion.d/pass
#  fi

  if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

    autoload -Uz compinit
    compinit
  fi
fi


# useful homes, opts variables
if [ "$IS_MAC" = true ]; then
  export JAVA_HOME=/Library/Java/Home
  export EDITOR="nvim"
else
  export JAVA_HOME=/usr/lib/jvm/default-java
  export EDITOR="vim"
fi

export JAVA_OPTS="-Xms512m -Xmx2048m"

export FIGNORE=".svn:.git:.DS_Store"
export PAGER=less

# update terminal colors for ssh from putty
[ "$TERM" = "xterm" ] && TERM="xterm-256color"

# setup path
export PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:$PATH:$GOPATH/bin:$HOME/.cabal/bin

# init rbenv
if which rbenv > /dev/null 2>&1 ; then eval "$(rbenv init -)"; fi

# some terminal colors
reset="\[\e[00m\]"
red="\[\e[01;31m\]"
green="\[\e[01;32m\]"
yellow="\[\e[01;33m\]"
#blue="\[\e[01;34m\]"
#grey="\[\e[01;30m\]"

blue=39
grey=246

# set default color to blue. can override in conf.sh
TERMINAL_COLOR=$blue

# source custom configuration (before PS1...)
[[ -e ~/conf.sh ]] && source ~/conf.sh

## PS1
# export PS1WITHGIT=$TERMINAL_COLOR'['$grey'$(date +"%H:%M")'$TERMINAL_COLOR'] '$TERMINAL_COLOR'\h\\\u ['$grey'\w'$TERMINAL_COLOR']'$grey'$(__git_ps1)'$TERMINAL_COLOR' \$ '$reset
#export PS1NOGIT=$TERMINAL_COLOR'['$grey'$(date +"%H:%M")'$TERMINAL_COLOR'] '$TERMINAL_COLOR'\h\\\u ['$grey'\w'$TERMINAL_COLOR']'$grey$TERMINAL_COLOR' \$ '$reset

export ZSH_THEME_GIT_PROMPT_PREFIX="("
export ZSH_THEME_GIT_PROMPT_SUFFIX=") "
export ZSH_THEME_GIT_PROMPT_DIRTY=" *"

setopt prompt_subst

export PROMPT='%F{'$blue'}[%F{'$grey'}$(date +"%H:%M")%F{'$blue'}] %n\\%m [%F{'$grey'}%~%F{'$blue'}] %F{'$grey'}$(git_prompt_info)%F{'$blue'}\$ %f'
#export PROMPT='%n\\%m $(git_prompt_info)\$ %f'


# snap sometimes messes with $XDG_RUNTIME_DIR
RUN_DIR=/run/user/$(id -u)
if [ -e $RUN_DIR/gnupg ]; then
  GNUPG_SOCKETS=$RUN_DIR/gnupg
else
  GNUPG_SOCKETS=$HOME/.gnupg
fi

THE_GPG_SSH_SOCK=$GNUPG_SOCKETS/S.gpg-agent.ssh

# enable/launch gpg-agent if installed -- pre-2.0
function enable_gpg_agent() {
  if which gpg-agent > /dev/null 2>&1; then
    gpgconf --launch gpg-agent
    if [ -e $GNUPG_SOCKETS/S.gpg-agent.ssh ]; then
      export SSH_AUTH_SOCK=$THE_GPG_SSH_SOCK
    else
      if test -f $HOME/.gpg-agent-info && \
        kill -0 `cut -d: -f 2 $HOME/.gpg-agent-info` 2> /dev/null; then
        eval $(cat $HOME/.gpg-agent-info)
        export GPG_AGENT_INFO
        export SSH_AUTH_SOCK
        export SSH_AGENT_PID
      else
        eval $(gpg-agent --daemon --write-env-file --enable-ssh)
      fi
      export GPG_TTY=$(tty)
    fi
  fi
}

# don't enable gpg agent over ssh since this breaks agent forwarding
if [[ -z "$SSH_CLIENT" ]] && [[ -z "$SSH_TTY" ]]; then
   enable_gpg_agent
fi

if is_mosh; then
  export SSH_AUTH_SOCK=$THE_GPG_SSH_SOCK
fi

# source fzf for mac only since it auto installs on linux
if [ "$IS_MAC" = true ]; then
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

# aliases

alias ls='ls -G'

if [ "$IS_MAC" = true ]; then
  alias vi='nvim'
  alias vim='nvim'
  alias flushdns="sudo killall -HUP mDNSResponder"
else
  alias vi='vim'
fi

alias Rgrep='find . | xargs grep' # for when `grep -R` is not present...
alias grep='grep --color'
alias be='bundle exec'
alias gradle="gradle --daemon"
alias up="while [[ ! -f build.gradle ]] && [[ ! -d ../../workspace ]] && [[ ! -f .gitignore ]]; do cd ..; done"
alias p4changes="p4 changes -u $P4USER -s pending -c $P4CLIENT"

function forward-gpg1() {
  host=$1
  if [ -z "$host" ]; then
    echo "Usage: forward-gpg host [ <remote-user> ]"
    return
  fi
  if [ -z $2 ]; then
    user=$(whoami)
  else
    user=$2
  fi
  ssh -N -o "StreamLocalBindUnlink=yes" -R /home/$user/.gnupg/S.gpg-agent:$GNUPG_SOCKETS/S.gpg-agent.extra $user@$host
}

function forward-gpg() {
  host=$1
  if [ -z "$host" ]; then
    echo "Usage: forward-gpg host [ <remote-user> ]"
    return
  fi
  if [ -z $2 ]; then
    user=$(whoami)
  else
    user=$2
  fi
  ssh -N -o "StreamLocalBindUnlink=yes" -R $GNUPG_SOCKETS/S.gpg-agent:$GNUPG_SOCKETS/S.gpg-agent.extra $user@$host
}
