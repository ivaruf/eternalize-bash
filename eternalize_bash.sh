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

# Color print functions
function print_green() {
    printf "${green}${1}${colorless}\n"
}
function print_red() {
    printf "${red}${1}${colorless}\n"
}
function print_cyan() {
    printf "${cyan}${1}${colorless}\n"
}
function print_orange() {
    printf "${orange}${1}${colorless}\n"
}


function check_if_windows() {
    if [ -n "${WINDIR}" ]; then
        OS=Windows
    else
      print_red "Unable to detect operating system."
      exit 1;
    fi
}

function isSymlink() {
    if [ -L $1 ]; then
        return 0
    else
        return 1
    fi
}

function uninstall() {
    STARTLINE=`grep -n  "# Eternal bash history" ${BASH_RC} | cut -d ":" -f1`
    ENDLINE=`grep -n  "/${HISTFILE_NAME}" ${BASH_RC} | cut -d ":" -f1`

    print_red "Remove the following lines from ${BASH_RC}?"
    sed -n "${STARTLINE},${ENDLINE}p" ${BASH_RC}
    select option in "Proceed" "Cancel"; do
        case ${option} in
            Proceed) break;;
            Cancel ) change_menu;;
        esac
    done

    # Remove eternal bash config from .bashrc
    sedX "${STARTLINE},${ENDLINE}d" ${BASH_RC};
    # Restore previous HISTSIZE and HISTFILESIZE variables
    sedX s/^#HISTSIZE\=/HISTSIZE\=/g ${BASH_RC}
    sedX s/^#HISTFILESIZE\=/HISTFILESIZE\=/g ${BASH_RC}

    # Remove changes in .bash_profile on Mac
    if [ ${OS} = "Mac" ]; then
        sedX "/source.*.${BASH_RC}/d" ${BASH_PROFILE}
    fi

    append_old_history ~/.bash_history

    print_green "Successfuly uninstalled, your bash is now boring again."
    exit_reminder
}

#TODO append history when unlinking
function unlink_from_dropbox() {
    printf "Moving ${HISTPATH} to ~/${HISTFILE_NAME}\n"

    if isSymlink ${HISTFILE_NAME}; then
        rm ${HISTFILE_NAME};
    fi

    cp ${HISTPATH} ${HISTFILE_NAME}

    if [ ${OS} = "Windows" ]; then
      sed -i "/${HISTFILE_NAME}/c\export HISTFILE=~\/${HISTFILE_NAME}" ${BASH_RC}
    fi

    print_green "Update OK"
    exit_reminder
}

function append_old_history() {
    printf "Copy all unique commands:\nfrom ${CURRENT_HISTFILE} to ${1}\n"

    # Magic
    cat  $1 ${CURRENT_HISTFILE} | awk '!x[$0]++' > $1

    # No, but seriously - this will concat new and old history file and remove
    # duplicate entries while still maintaining order of commands. So, when
    # you restart your shell, the previous command will be on top of the
    # history. As expected.
}

function link_to_dropbox() {
    mkdir -p  ${DROPBOX_DEFAULT_LOCATION}/${DROPBOX_FOLDER}/
    HISTFILE_LOCATION=${DROPBOX_DEFAULT_LOCATION}/${DROPBOX_FOLDER}/${HISTFILE_NAME}

    # Append history BEFORE linking, to avoid history-loss
    append_old_history ${HISTFILE_LOCATION}

    if [ ${OS} = "Windows" ]; then
        printf "Setting HISTFILE to ${HISTFILE_LOCATION} in ${BASH_RC}\n"

        if ! grep -q "${HISTFILE_NAME}" "${BASH_RC}"; then
            echo export HISTFILE=${HISTFILE_LOCATION} >> ${BASH_RC}
        else
            sed -i "/${HISTFILE_NAME}/c\export HISTFILE=${HISTFILE_LOCATION}" ${BASH_RC}
        fi
    else
        printf "Making link ~/${HISTFILE_NAME} -> ${HISTFILE_LOCATION}\n"
        touch ${HISTFILE_LOCATION}

        # Force symlink file might exist if first installed locally, then linked to dropbox
        ln -sf ${HISTFILE_LOCATION} ${HISTFILE_NAME}
        printf "Setting HISTFILE to ~/${HISTFILE_NAME} in ${BASH_RC}\n"

        # Only export HISTFILE if it has not been done.
        if ! grep -q "${HISTFILE_NAME}" "${BASH_RC}"; then
            echo export HISTFILE=~/${HISTFILE_NAME} >> ${BASH_RC}
        fi
    fi

    print_green "Successfuly installed! You now have *distributed* eternal history."
    exit_reminder
}

function toggle_dropbox() {
    printf "\n"
    case $1 in
        Unlink) unlink_from_dropbox;;
        Link) link_to_dropbox;;
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
            Exit ) exit 0;;
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
    sedX s/^HISTSIZE\=/#HISTSIZE\=/g ${BASH_RC}
    sedX s/^HISTFILESIZE\=/#HISTFILESIZE\=/g ${BASH_RC}
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
}

function local_install() {
    common_install
    HISTFILE_LOCATION=~/${HISTFILE_NAME}
    append_old_history ${HISTFILE_LOCATION}
    echo export HISTFILE=${HISTFILE_LOCATION} >> ${BASH_RC}
    print_green "Successfuly installed! You now have eternal history on this machine."
    exit_reminder
}

function dropbox_install() {
    if ! [[ -d "${DROPBOX_DEFAULT_LOCATION}" ]]; then
        print_red "Dropbox not found!"
        menu
    else
        common_install
        link_to_dropbox
    fi
}

function menu() {
    print_orange "Installation can be changed later by re-running script."
    printf "What would you like to do? \n"

    select option in "Install locally" "Install with Dropbox" "Exit"; do
        case ${option} in
            "Install locally") local_install;;
            "Install with Dropbox") dropbox_install;;
            Exit ) exit 0;;
        esac
    done
}

function exit_reminder() {
    print_red "Remember to restart your shell!"
    exit 0
}

# God damn it Mac.
function sedX() {
    if [ ${OS} = "Mac" ]; then
        sed -i '' -E $1 $2
    else
        sed -i $1 $2
    fi
}

case $(uname) in
    Linux) OS=Linux;;
    Darwin) OS=Mac;;
    *) check_if_windows;;
esac

if [ ${HISTFILE} ]; then
    CURRENT_HISTFILE=${HISTFILE}
else
    print_red "Unable to find current history file."
    exit 1;
fi

printf "\nHistory file currently set to:\n"
printf "${cyan}${CURRENT_HISTFILE}${colorless}"
if isSymlink ${CURRENT_HISTFILE}; then
    printf " -> "
    HISTPATH=$(readlink ${CURRENT_HISTFILE})
    printf ${HISTPATH}
else
    HISTPATH=${CURRENT_HISTFILE}
fi

printf "\n\n"

print_green "Operating system: ${OS}\n"

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
