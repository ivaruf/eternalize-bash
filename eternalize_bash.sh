#!/bin/bash

cat <<"BANNER"
     _____                          __________
_______  /_________________________ ___  /__(_)__________
_  _ \  __/  _ \_  ___/_  __ \  __ `/_  /__  /___  /_  _ \
/  __/ /_ /  __/  /   _  / / / /_/ /_  / _  / __  /_/  __/
\___/\__/ \___//_/    /_/ /_/\__,_/ /_/  /_/  _____/\___/

____________               ______
____/ /__  /_______ __________  /_
__  __/_  __ \  __ `/_  ___/_  __ \
_(_  )_  /_/ / /_/ /_(__  )_  / / /
/  _/ /_.___/\__,_/ /____/ /_/ /_/
/_/
BANNER

# Variables
BASH_RC=.bashrc
DROPBOX_DEFAULT_LOCATION=~/Dropbox
DROPBOX_FOLDER=linux_dot
HISTFILE_NAME=.bash_eternal_history
OLD_HISTORY=.bash_history
CURRENT_HISTFILE=${HISTFILE}

# Colors
red='\033[0;31m'
green='\033[0;32m'
cyan='\033[1;36m'
colorless='\033[0m'

function isSymlink() {
    if [ -L $1 ]; then
        return 0
    else
        return 1
    fi
}

printf "\nHistory file currently set to:\n"
printf "${cyan}${CURRENT_HISTFILE}${colorless}"
if isSymlink ${CURRENT_HISTFILE}; then
    printf " -> "
    HISTPATH=$(readlink -f ${CURRENT_HISTFILE})
    printf ${HISTPATH}
else
    HISTPATH=${CURRENT_HISTFILE}
fi

printf "\n\n"

# go to home directory
cd

case $(uname) in
    Linux) OS=Linux;;
    Darwin) OS=Mac;;
    *) check_if_windows;;
esac

function check_if_windows() {
    if [ -n "${WINDIR}" ]; then
        OS=Windows
    else
        OS=Unknown
    fi
}

printf "${green}Operating system: ${OS}${colorless}\n\n"

function uninstall() {
    STARTLINE=`grep -n  "# Eternal bash history" ${BASH_RC} | cut -d ":" -f1`
    ENDLINE=`grep -n  "/${HISTFILE_NAME}" ${BASH_RC} | cut -d ":" -f1`

    printf "${red}Remove the following lines from ${BASH_RC}?${colorless} \n"
    sed -n "${STARTLINE},${ENDLINE}p" ${BASH_RC}
    select option in "Proceed" "Cancel"; do
        case ${option} in
            Proceed) sed "${STARTLINE},${ENDLINE}d" ${BASH_RC};break;;  # TODO - enable  (add -i)
            Cancel ) change_menu;;
        esac
    done

    printf "${green}Successfuly uninstalled, your bash is now boring again.${colorless}\n"
    exit
}

function unlink_from_dropbox() {
    printf "\nMoving ${HISTPATH} to ~/${HISTFILE_NAME} ${colorless} \n"
    # cp ${HISTPATH} ${HISTFILE_NAME} # TODO Enable =)
    sed 's/${HISTPATH}/${HISTFILE_NAME}/' ${BASH_RC} # TODO add -i
    printf "${green}Update OK${colorless}\n"
    exit 0;
}

function link_to_dropbox() {
    echo "Link"
}

function toggle_dropbox() {
    case $1 in
        Unlink) unlink_from_dropbox;;
        Link) link_to_dropbox;;
        Cancel ) change_menu;;
    esac
}

function change_menu() {
    printf "What would you like to do? \n"
     # Check if path to "Dropbox" is in ${HISTPATH}
    case ${HISTPATH} in
        *Dropbox*)
            DBOXOPTION=Unlink;;
        *)  DBOXOPTION=Link;;
    esac

    printf "\n"

    select option in "Uninstall" "${DBOXOPTION} from dropbox" "Exit"; do
        case ${option} in
            Uninstall) uninstall;;
            "${DBOXOPTION} from dropbox") toggle_dropbox ${DBOXOPTION};;
            Exit ) exit;;
        esac
    done
}

function make_bash_rc_backup() {
  printf "Making a copy of your ${BASH_RC} file to ${BASH_RC}_backup.\n"
  cp ${BASH_RC} ${BASH_RC}_backup
}

if [ -f ${BASH_RC} ]; then
  if grep -q "${HISTFILE_NAME}" "${BASH_RC}"; then
    change_menu
  fi
  exit #devguard

fi

function append_snippet() {
    ETERNAL_BASH_SNIPPET="
    # Eternal bash history
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
}

### TODO Moving this to link to dropbox
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
  ### TODO Move this to unlink
  HISTFILE_LOCATION=~/${HISTFILE_NAME}
  echo "Dropbox not found, history file is set to ${HISTFILE_LOCATION}"
  echo export HISTFILE=${HISTFILE_LOCATION} >> ${BASH_RC}
fi

### TODO read each line of ${CURREN_HISTFILE} append this NOT in ${HISTFILE_LOCATION}
if [ -f ${CURRENT_HISTFILE} ]; then
  echo "Appending ${CURRENT_HISTFILE} to ${HISTFILE_LOCATION}"
  cat ${CURRENT_HISTFILE} >> ${HISTFILE_LOCATION}
fi

### TODO move this to function
# OS X does not automatically run .bashrc, add it as source to .bash_profile.
if [ $(uname) = "Darwin" ]; then
  echo "OS X detected, adding source to ${BASH_RC} in .bash_profile"
  echo source ~/${BASH_RC} >> .bash_profile
fi
