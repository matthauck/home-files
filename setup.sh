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
# setup neovim
if [ ! -L ~/.config/nvim ]; then
  mkdir -p ~/.config > /dev/null
  ln -s ~/.vim ~/.config/nvim
fi
if [ ! -e ~/.nvimrc ]; then
  cp "${HOME_FILES_DIR}/dotvim/sample.nvimrc" ~/.nvimrc
fi

# setup tmux config
if [ ! -L ~/.tmux.conf ]; then
  if [ -e ~/.tmux.conf ]; then
    echo "Moving old .tmux.conf..."
    mv ~/.tmux.conf ~/.tmux.conf.bak
  fi
  ln -s "${HOME_FILES_DIR}/tmux.conf" ~/.tmux.conf
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
  ! has_brew "node" || install_brew node
  ! has_brew "tmux" || install_brew tmux
  ! has_brew "pass" || install_brew pass
  ! has_brew "rbenv" || install_brew rbenv

else

  function installit() {
    for pkg in $*; do
      if ! dpkg --get-selections | grep install | grep -w "$pkg" > /dev/null; then
        sudo apt-get install -y $pkg
      fi
    done
  }

  echo "Installing packages (may require password)..."
  installit silversearcher-ag
  installit git
  installit cmake
  installit ctags
  installit openssl libssl-dev
  installit openssh-server
  installit wget
  installit curl
  installit vim-nox
  installit python-dev
  installit ruby-build rbenv
  installit build-essential
  installit autoconf libtool
  installit ninja-build
  installit gnupg gnupg2 gpgsm
  installit tmux
  installit pass

  if [ ! -f /etc/apt/sources.list.d/nodesource.list ]; then
    sudo $HOME_FILES_DIR/node_setup_4.x.sh
  fi
  installit nodejs

fi

# setup p4
$HOME_FILES_DIR/p4/p4.sh

# setup ruby
if [ ! -e ~/.rbenv ]; then
    eval "$(rbenv init -)"
    rbenv install 1.9.3-p194
    rbenv global 1.9.3-p194
    rbenv rehash
fi

# setup npm packages
if ! which tslint > /dev/null; then
  sudo npm install -g tslint tsc bower karma-cli grunt-cli
fi

