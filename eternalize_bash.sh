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
BASH_PROFILE=.bash_profile
DROPBOX_DEFAULT_LOCATION=~/Dropbox
DROPBOX_FOLDER=linux_dot
HISTFILE_NAME=.bash_eternal_history

ETERNAL_BASH_SNIPPET="
# Eternal bash history
# ---------------------
# Undocumented feature which sets the size to 'unlimited'.
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
# Force prompt to write history after every command. See 'help history'
PROMPT_COMMAND=\"history -a; history -c; history -r; \${PROMPT_COMMAND}\""

# Colors
red='\033[0;31m'
green='\033[0;32m'
orange='\033[0;33m'
cyan='\033[1;36m'
colorless='\033[0m'

if [ ${HISTFILE} ]; then
    CURRENT_HISTFILE=${HISTFILE}
else
    CURRENT_HISTFILE=~/.bash_history
fi

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

printf "${green}Operating system: ${OS}${colorless}\n\n"

function uninstall() {
    STARTLINE=`grep -n  "# Eternal bash history" ${BASH_RC} | cut -d ":" -f1`
    ENDLINE=`grep -n  "/${HISTFILE_NAME}" ${BASH_RC} | cut -d ":" -f1`

    printf "${red}Remove the following lines from ${BASH_RC}?${colorless} \n"
    sed -n "${STARTLINE},${ENDLINE}p" ${BASH_RC}
    select option in "Proceed" "Cancel"; do
        case ${option} in
            Proceed) break;;
            Cancel ) change_menu;;
        esac
    done

    # Remove eternal bash config from .bashrc
    sed -i "${STARTLINE},${ENDLINE}d" ${BASH_RC};
    # Restore previous HISTSIZE and HISTFILESIZE variables
    sed -i s/^#HISTSIZE\=/HISTSIZE\=/g ${BASH_RC}
    sed -i s/^#HISTFILESIZE\=/HISTFILESIZE\=/g ${BASH_RC}

    # Remove changes in .bash_profile on Mac
    if [ ${OS} = "Mac" ]; then
        sed -i 'source ~\/${BASH_RC}/d' ${BASH_PROFILE}
    fi

    append_old_history ~/.bash_history

    printf "${green}Successfuly uninstalled, your bash is now boring again.${colorless}\n"
    exit 0
}

function unlink_from_dropbox() {
    printf "Moving ${HISTPATH} to ~/${HISTFILE_NAME} ${colorless}\n"

    if isSymlink ${HISTFILE_NAME}; then
        rm ${HISTFILE_NAME};
    fi

    cp ${HISTPATH} ${HISTFILE_NAME}
    sed -i 's/${HISTPATH}/${HISTFILE_NAME}/' ${BASH_RC}
    printf "${green}Update OK${colorless}\n"
    exit 0
}

function append_old_history() {
    printf "Appending all distinct lines from old history-file to new history-file\n"

    # TODO : Fix theese errors when there are hypens or brackets in the history
    # grep: Invalid range end
    # grep: Unmatched [ or [^

    # In case file does not exists yet, can't grep an empty file
    touch $1
    while read line; do
        # Ignore commented lines
        if grep -q "^#" <<< "${line}"; then
          continue
        fi

        if ! grep -q "${line}" $1; then
          echo ${line} >> $1
        fi
    done <${CURRENT_HISTFILE}
}

function link_to_dropbox() {
    mkdir -p  ${DROPBOX_DEFAULT_LOCATION}/${DROPBOX_FOLDER}/
    HISTFILE_LOCATION=${DROPBOX_DEFAULT_LOCATION}/${DROPBOX_FOLDER}/${HISTFILE_NAME}

    if [ ${OS} = "Windows" ]; then
        printf "Setting HISTFILE to ${HISTFILE_LOCATION} in ${BASH_RC}\n"
        if grep -q "${HISTFILE_NAME}" "${BASH_RC}"; then
            echo export HISTFILE=${HISTFILE_LOCATION} >> ${BASH_RC}
        else
            sed -i 's/${HISTPATH}/${HISTFILE_LOCATION}/' ${BASH_RC}
        fi
    else
        printf "Making link ~/${HISTFILE_NAME} -> ${HISTFILE_LOCATION}\n"
        touch ${HISTFILE_LOCATION}

        # Append history BEFORE linking, to avoid history-loss
        append_old_history ${HISTFILE_LOCATION}

        # Force symlink file might exist if first installed locally, then linked to dropbox
        ln -sf ${HISTFILE_LOCATION} ${HISTFILE_NAME}
        printf "Setting HISTFILE to ~/${HISTFILE_NAME} in ${BASH_RC}\n"

        # Only export HISTFILE if it has not been done.
        if ! grep -q "${HISTFILE_NAME}" "${BASH_RC}"; then
            echo export HISTFILE=~/${HISTFILE_NAME} >> ${BASH_RC}
        fi
    fi

    printf "${green}Successfuly installed! You now have *distributed* eternal history.${colorless}\n"
    printf "${red}Remember to restart your shell!${colorless}\n"
    exit 0
}

function toggle_dropbox() {
    printf "\n"
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
            DBOXOPTION="Unlink from";;
        *)  DBOXOPTION="Link to";;
    esac

    printf "\n"

    select option in "Uninstall" "${DBOXOPTION} dropbox" "Exit"; do
        case ${option} in
            Uninstall) uninstall;;
            "${DBOXOPTION} dropbox") toggle_dropbox ${DBOXOPTION};;
            Exit ) exit;;
        esac
    done
}

function make_bash_rc_backup() {
    printf "Making a copy of your ${BASH_RC} file to ${BASH_RC}_backup.\n"
    cp ${BASH_RC} ${BASH_RC}_backup
}

function comment_default_history_variables() {
    # Unless we remove / comment theese lines from default ubuntu install
    # HISTFILE will still be truncated at 2000 lines (even if it was much bigger!)
    sed -i s/^HISTSIZE\=/#HISTSIZE\=/g ${BASH_RC}
    sed -i s/^HISTFILESIZE\=/#HISTFILESIZE\=/g ${BASH_RC}
}

function append_snippet() {
    # Important with quotes here, so the snippet will retain line-breaks
    echo "${ETERNAL_BASH_SNIPPET}" >> ${BASH_RC}
}

function common_install() {
    if [ -f ${BASH_RC} ]; then
        make_bash_rc_backup
        comment_default_history_variables
    fi
    append_snippet

    if [ ${OS} = "Mac" ]; then
        printf "Adding source to .bashrc in .bash_profile\n"
        echo source ~/${BASH_RC} >> ${BASH_PROFILE}
    fi

    printf "History variables and command-promt setup added to ${BASH_RC}\n"
    printf "History file is set to ~/${HISTFILE_NAME}\n"
}

function local_install() {
    common_install
    HISTFILE_LOCATION=~/${HISTFILE_NAME}
    append_old_history ${HISTFILE_LOCATION}
    echo export HISTFILE=${HISTFILE_LOCATION} >> ${BASH_RC}
    printf "${green}Successfuly installed! You now have eternal history on this machine.${colorless}\n"
    printf "${red}Remember to restart your shell!${colorless}\n"

    exit 0
}

function dropbox_install() {
    if ! [[ -d "${DROPBOX_DEFAULT_LOCATION}" ]]; then
        print "${red}Dropbox not found!${colorless}\n"
        menu
    else
        common_install
        link_to_dropbox
    fi
}

function menu() {
    printf "${orange}Installation can be changed later by re-running script.${colorless}\n"
    printf "What would you like to do? \n"

    select option in "Install locally" "Install with Dropbox" "Exit"; do
        case ${option} in
            "Install locally") local_install;;
            "Install with Dropbox") dropbox_install;;
            Exit ) exit 0;;
        esac
    done
}

# go to home directory
cd

# If .bashrc exist and we find .bash_eternal_histor in it, we open the change menu
if [ -f ${BASH_RC} ]; then
  if grep -q "${HISTFILE_NAME}" "${BASH_RC}"; then
    change_menu
  fi
fi

# Start main menu
menu
