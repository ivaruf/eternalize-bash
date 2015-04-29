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

Eternalize-bash is a script that will make your bash history distributed between open terminals and even between machines, if you have Dropbox and run the script on all machines.

Run the eternalize-bash-script, and you will get distributed eternal bash history happiness ☯

Can be done without cloning the project:
```bash
curl -s https://raw.githubusercontent.com/ivaruf/eternalize-bash/master/eternalize_bash.sh | bash
```

Restart your shell for changes to take effect (or run "source .bashrc")

##Requirements
One of the following:
* Linux with bash shell
* Mac with bash shell
* Windows with git-bash

Optional:
* Dropbox, installed in default location. The script will run without it, but it will only give you distributed
bash history between terminals on one machine.

##Disclaimer
This is experimental stuff, I have tried to make the script so that there is very little chance it will break
anything, but i give no guarantees.
