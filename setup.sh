#!/bin/bash

set -e

# get absolute path to directory of setup.sh
HOME_FILES_DIR=$(cd "$( dirname $0 )" && pwd )

function update_git_submodule() {
  # parens -> `cd` has no net change to directory
  (cd "$1" && git submodule init && git submodule update)
}

# update home-files
update_git_submodule "$HOME_FILES_DIR"
# update dotvim
update_git_submodule "$HOME_FILES_DIR/dotvim"

# add .profile
if [[ ! -f ~/.profile ]] || ! grep profile.sh ~/.profile 1> /dev/null 2> /dev/null; then
  #"$LOADED_PROFILE" != "true" ]; then
  echo "" >> ~/.profile
  echo "# add home-files profile" >> ~/.profile
  echo "source \"${HOME_FILES_DIR}/profile/profile.sh\"" >> ~/.profile
  source ~/.profile

  cp "${HOME_FILES_DIR}/profile/conf.sh.sample" ~/conf.sh
fi

# add .gitconfig
if [ ! -L ~/.gitconfig ]; then
  if [ -f ~/.gitconfig ]; then
    echo "Moving old .gitconfig..."
    mv ~/.gitconfig ~/.gitconfig.bak
  fi
  ln -s "${HOME_FILES_DIR}/git/gitconfig" ~/.gitconfig
fi

# add vim config
if [ ! -L ~/.vim ]; then
  if [ -e ~/.vim ]; then
    echo "Moving old .vim folder..."
    mv ~/.vim ~/.vim.bak
  fi
  ln -s "${HOME_FILES_DIR}/dotvim" ~/.vim
fi
if [ ! -e ~/.vimrc ]; then
  cp "${HOME_FILES_DIR}/dotvim/sample.vimrc" ~/.vimrc
fi

# install some basic oft-used packages

function installed() {
  which $1 1> /dev/null 2>&1
}

if [ "$IS_MAC" = true ]; then
  # don't check here whether it is installed yet
  # in case mac comes with an unwanted default (e.g. ctags, git)
  function install_brew() {
    brew install $*
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

  echo "Installing packagess..."
  ! has_brew "the_silver_searcher" || install_brew the_silver_searcher
  ! has_brew "git" || install_brew git
  ! has_brew "cmake" || install_brew cmake
  ! has_brew "ctags" || install_brew ctags
  ! has_brew "openssl" || install_brew openssl
  ! has_brew "wget" || install_brew wget
  ! has_brew "macvim" || (install_brew macvim --with-lua && brew linkapps macvim)

else

  echo "Installing packages (may require password)..."
  ! installed "ag" || sudo apt-get install -y the_silver_searcher
  ! installed "git" || sudo apt-get install -y  git
  ! installed "cmake" || sudo apt-get install -y  cmake
  ! installed "ctags" || sudo apt-get install -y  ctags
  ! installed "openssl" || sudo apt-get install -y  openssl
  ! installed "wget" || sudo apt-get install -y  wget
  ! installed "curl" || sudo apt-get install -y  curl
  ! installed "vim" || sudo apt-get install -y  vim-nox
  sudo apt-get install -y python-dev
  sudo apt-get install -y build-essential
  sudo apt-get install -y libssl-dev

fi

