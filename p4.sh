#!/bin/bash

# Download and install perforce `p4` command line tool
# Also download the p4 c++ and python APIs and install

set -e

TMP_DIR=$(mktemp -d /tmp/p4temp.XXXX)
pushd $TMP_DIR > /dev/null

## p4 cli

if [ "$IS_MAC" = true ]; then
  CLI_URL=http://www.perforce.com/downloads/perforce/r15.1/bin.macosx105x86_64/p4
else
  # assume x86 linux
  CLI_URL=http://filehost.perforce.com/perforce/r15.1/bin.linux26x86/p4api.tgz
fi

if [ ! -e /usr/local/bin/p4 ]; then
  echo "Downloading p4 command line tool (may require password)..."
  curl -o p4 $CLI_URL
  chmod +x p4
  sudo mv p4 /usr/local/bin/p4
fi

## p4 c++ api

P4_DIR=/usr/local/opt/perforce
P4_API_DIR=$P4_DIR/p4-api

if [ ! -e $P4_DIR/.complete ]; then
  echo "Installing p4 api (may require password)..."
  sudo rm -fr ${P4_DIR}
  sudo mkdir -p ${P4_DIR}

  if [ "$IS_MAC" = true ]; then
    API_URL=http://cdist2.perforce.com/perforce/r15.1/bin.macosx105x86_64/p4api.tgz
  else
    # assume x86 linux
    API_URL=http://cdist2.perforce.com/perforce/r15.1/bin.linux26x86/p4api.tgz
  fi

  curl -L -o p4api.tgz $API_URL
  tar -xzf p4api.tgz

  # there should only be one...
  sudo mv p4api-* $P4_API_DIR
    
  # install p4 python
  curl -L -o p4python.tgz http://www.perforce.com/downloads/perforce/r14.2/bin.tools/p4python.tgz
  tar -xzf p4python.tgz
  # there should only be one
  cd p4python-*

  python setup.py build --apidir ${P4_API_DIR}

  sudo python setup.py install --apidir ${P4_API_DIR}

  sudo touch $P4_DIR/.complete
fi


popd > /dev/null
rm -fr $TMP_DIR



