#!/bin/bash

# go to home directory
cd

if [ -f .bashrc ]; then
  if grep -q "bash_eternal_history" ".bashrc"; then
    echo "It looks like script has already been run, no changes will be made."
    exit 1
  fi
  echo "Making a copy of your .bashrc file to .bashrc_backup."
  cp .bashrc .bashrc_backup
fi

ETERNAL_BASH_SNIPPET="
# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to \"unlimited\".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT=\"[%F %T] \"
# Force prompt to write history after every command. See 'help history'
PROMPT_COMMAND=\"history -a; history -c; history -r; \$PROMPT_COMMAND\""

echo ${ETERNAL_BASH_SNIPPET} >> .bashrc

DROPBOX_DEFAULT_LOCATION=~/Dropbox

if [ -d "$DROPBOX_DEFAULT_LOCATION" ]; then
  echo "Dropbox found at default location: $DROPBOX_DEFAULT_LOCATION"
  mkdir -p  ${DROPBOX_DEFAULT_LOCATION}/linux_dot/
  cat .bash_history >> ${DROPBOX_DEFAULT_LOCATION}/linux_dot/.bash_eternal_history
  # Check if running windows, symlink will not work there.
  if [ -n "$WINDIR" ]; then
    echo "Setting HISTFILE to ${DROPBOX_DEFAULT_LOCATION}/linux_dot/.bash_eternal_history"
    echo export HISTFILE=${DROPBOX_DEFAULT_LOCATION}/linux_dot/.bash_eternal_history >> .bashrc
  else
    echo "Making link ~/.bash_eternal_history -> ${DROPBOX_DEFAULT_LOCATION}/linux_dot/.bash_eternal_history."
    echo export HISTFILE=~/.bash_eternal_history >> .bashrc
    ln -s ${DROPBOX_DEFAULT_LOCATION}/linux_dot/.bash_eternal_history .bash_eternal_history
  fi
else
  echo "Dropbox not found, history file is set to ~/.bash_eternal_history"
  echo export HISTFILE=~/.bash_eternal_history >> .bashrc
fi
