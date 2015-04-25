#!/bin/sh

set -e

MYDIR=$(cd "$( dirname $0 )" && pwd )

# add .profile
if [[ ! -f ~/.profile ]] || ! grep profile.sh ~/.profile 1> /dev/null 2> /dev/null; then
  #"$LOADED_PROFILE" != "true" ]; then
  echo "" >> ~/.profile
  echo "# add home-files profile" >> ~/.profile
  echo "source \"${MYDIR}/profile/profile.sh\"" >> ~/.profile
  source ~/.profile
fi

# add .gitconfig
if [ ! -L ~/.gitconfig ]; then
  if [ -f ~/.gitconfig ]; then 
    echo "Moving old .gitconfig..."
    mv ~/.gitconfig ~/.gitconfig.bak
  fi
  ln -s "${MYDIR}/git/gitconfig" ~/.gitconfig
fi

function installed() {
  which $1 1> /dev/null 2>&1
}


# don't check here whether it is installed yet
# in case mac comes with an unwanted default (e.g. ctags, git)
function install_brew() {
  brew install "$1"
}

function has_brew() {
  found=$(brew list | grep -w "$1")
  test -z "$found"
}

# install homebrew if not present
if ! installed "brew"; then
  echo "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew update
fi

! has_brew "the_silver_searcher" || install_brew "the_silver_searcher"
! has_brew "git" || install_brew "git"  
! has_brew "cmake" || install_brew "cmake"
! has_brew "ctags" || install_brew "ctags"
! has_brew "openssl" || install_brew "openssl"
! has_brew "wget" || install_brew "wget" 
! has_brew "macvim" || install_brew "macvim" 



