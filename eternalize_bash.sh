#!/bin/bash

BASH_RC=.bashrc
DROPBOX_DEFAULT_LOCATION=~/Dropbox
DROPBOX_FOLDER=linux_dot
HISTFILE_NAME=.bash_eternal_history

# go to home directory
cd

if [ -f ${BASH_RC} ]; then
  if grep -q "${HISTFILE_NAME}" "${BASH_RC}"; then
    echo "It looks like script has already been run, no changes will be made."
    exit 1
  fi
  echo "Making a copy of your ${BASH_RC} file to ${BASH_RC}_backup."
  cp ${BASH_RC} ${BASH_RC}_backup
fi

ETERNAL_BASH_SNIPPET="
# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to 'unlimited'.
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT=\"[%F %T] \"
# Force prompt to write history after every command. See 'help history'
PROMPT_COMMAND=\"history -a; history -c; history -r; \${PROMPT_COMMAND}\""

# Important with quotes here, so the snippet will retain line-breaks
echo "${ETERNAL_BASH_SNIPPET}" >> ${BASH_RC}

if [ -d "${DROPBOX_DEFAULT_LOCATION}" ]; then
  echo "Dropbox found at default location: ${DROPBOX_DEFAULT_LOCATION}"
  HISTFILE_LOCATION=${DROPBOX_DEFAULT_LOCATION}/${DROPBOX_FOLDER}/${HISTFILE_NAME}
  mkdir -p  ${DROPBOX_DEFAULT_LOCATION}/${DROPBOX_FOLDER}/

  # Check if running windows, symlink will not work there.
  if [ -n "${WINDIR}" ]; then
    echo "Windows detected"
    echo "Setting HISTFILE to ${HISTFILE_LOCATION} in ${BASH_RC}"
    echo export HISTFILE=${HISTFILE_LOCATION} >> ${BASH_RC}
  else
    echo "Making link ~/${HISTFILE_NAME} -> ${HISTFILE_LOCATION}"
    touch ${HISTFILE_LOCATION}
    ln -s ${HISTFILE_LOCATION} ${HISTFILE_NAME}
    echo "Setting HISTFILE to ~/${HISTFILE_NAME} in ${BASH_RC}"
    echo export HISTFILE=~/${HISTFILE_NAME} >> ${BASH_RC}
  fi
else
  HISTFILE_LOCATION=~/${HISTFILE_NAME}
  echo "Dropbox not found, history file is set to ${HISTFILE_LOCATION}"
  echo HISTFILE=${HISTFILE_LOCATION} >> ${BASH_RC}
fi

echo "Appending .bash_history to ${HISTFILE_LOCATION}"
cat ~/.bash_history >> ${HISTFILE_LOCATION}
