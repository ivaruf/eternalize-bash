#!/bin/bash

# go to home directoy
cd

if [ -f .bashrc ]; then

  if grep -q "bash_eternal_history" ".bashrc"; then
    echo "It looks like script has already been run, no changes will be made."
    exit 1
  fi

  echo "Making a copy of your .bashrc file to .bashrc_backup"
  cp .bashrc .bashrc_backup
  echo "Comment out old occurances of HISTSIZE and HISTFILESIZE"
  sed -i s/^HISTSIZE\=/#HISTSIZE\=/g .bashrc
  sed -i s/^HISTFILESIZE\=/#HISTFILESIZE\=/g .bashrc
fi

ETERNAL_BASH_SNIPPET="
# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to \"unlimited\".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT=\"[%F %T] \"
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND=\"history -a; history -c; history -r; \$PROMPT_COMMAND\""

echo "Appending eternal bash snippet to .bashrc"
echo "${ETERNAL_BASH_SNIPPET}" >> .bashrc

DROPBOX_DEFAULT_LOCATION=~/Dropbox/

if [ -d "$DROPBOX_DEFAULT_LOCATION" ]; then
  echo "Dropbox found at default location: $DROPBOX_DEFAULT_LOCATION"
  echo "Adding history-file to dropbox and making symlink:"
  mkdir -p  ${DROPBOX_DEFAULT_LOCATION}/linux_dot/
  touch ${DROPBOX_DEFAULT_LOCATION}/linux_dot/.bash_eternal_history
  ln -s ${DROPBOX_DEFAULT_LOCATION}/linux_dot/.bash_eternal_history .bash_eternal_history
  echo "~/.bash_eternal_history -> ${DROPBOX_DEFAULT_LOCATION}linux_dot/.bash_eternal_history"
else
  echo "Dropbox not found, not adding symlink"
fi

echo "Setting new .bashrc as source"
source .bashrc
