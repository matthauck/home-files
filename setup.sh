#!/bin/sh

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
