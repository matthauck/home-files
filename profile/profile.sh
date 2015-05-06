
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

# git bash completion
if [ -d /usr/local/bash_completion.d ]; then
  source /usr/local/etc/bash_completion.d/git-completion.bash && \
  source /usr/local/etc/bash_completion.d/git-prompt.sh && \
  GIT_PS1_SHOWDIRTYSTATE=TRUE
fi

# useful homes, opts variables
export NODE_PATH=/usr/local/lib/node_modules
export GROOVY_HOME=/usr/local/opt/groovy/libexec
export JAVA_HOME=/Library/Java/Home
export JAVA_OPTS="-Xms512m -Xmx2048m"
export GOPATH=/usr/local/bin

export EDITOR="vim"
export FIGNORE=".svn:.git:.DS_Store"
export PAGER=less

# update terminal colors for ssh from putty
[ "$TERM" = "xterm" ] && TERM="xterm-256color"

# setup path
export PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:$PATH:$HOME/.cabal/bin

# init rbenv
if which rbenv > /dev/null 2>&1 ; then eval "$(rbenv init -)"; fi

# some terminal colors
reset="\[\e[00m\]"
red="\[\e[01;31m\]"
green="\[\e[01;32m\]"
yellow="\[\e[01;33m\]"
blue="\[\e[01;34m\]"
grey="\[\e[01;30m\]"

# set default color to blue. can override in conf.sh
TERMINAL_COLOR=$blue

# source custom configuration (before PS1...)
[[ -e "${MYDIR}/conf.sh" ]] && source "${MYDIR}/conf.sh"

## PS1
export PS1WITHGIT=$TERMINAL_COLOR'['$grey'$(date +"%H:%M")'$TERMINAL_COLOR'] '$TERMINAL_COLOR'\h\\\u ['$grey'\w'$TERMINAL_COLOR']'$grey'$(__git_ps1)'$TERMINAL_COLOR' \$ '$reset
export PS1NOGIT=$TERMINAL_COLOR'['$grey'$(date +"%H:%M")'$TERMINAL_COLOR'] '$TERMINAL_COLOR'\h\\\u ['$grey'\w'$TERMINAL_COLOR']'$grey$TERMINAL_COLOR' \$ '$reset

# default to git info (turn-off-able for super large git repos, i.e. chromium)
if [ "$GIT_PS1_SHOWDIRTYSTATE" = true ]; then
  export PS1=$PS1WITHGIT
else
  export PS1=$PS1NOGIT
fi

alias ps1nogit="export PS1='$PS1NOGIT'"
alias ps1withgit="export PS1='$PS1WITHGIT'"

# aliases

alias ls='ls -G'

if [ "$IS_MAC" = true ]; then
  alias vi='mvim -v'
  alias vim='mvim -v'
else
  alias vi='vim'
fi

alias Rgrep='find . | xargs grep' # for when `grep -R` is not present...
alias grep='grep --color'
alias be='bundle exec'
alias gradle="gradle --daemon"
alias up="while [[ ! -f build.gradle ]] && [[ ! -d ../../workspace ]] && [[ ! -f .gitignore ]]; do cd ..; done"
alias flushdns="sudo killall -HUP mDNSResponder"
alias ag="ag --ignore out --ignore '*.min.js*'"
alias p4changes="p4 changes -u $P4USER -s pending -c $P4CLIENT"

