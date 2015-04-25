#!/bin/sh

MYDIR=$(cd "$( dirname $0 )" && pwd )

# add 
if [[ ! -f ~/.profile ]] || ! grep profile.sh ~/.profile 1> /dev/null 2> /dev/null; then
  #"$LOADED_PROFILE" != "true" ]; then
  echo "" >> ~/.profile
  echo "# add home-files profile" >> ~/.profile
  echo "source \"${MYDIR}/profile/profile.sh\"" >> ~/.profile
  source ~/.profile
fi
