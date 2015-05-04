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

## Features
* Unlimited history-size, so you never have to lose another command.
* Shared history between open terminals.
* Shared history between machines (using dropbox).

## Usage
* Download the script. 
* Run `./eternalize_bash.sh`. 
* Select the options you want.

*Re-run the script to link/unlink from dropbox or to uninstall.*

**Restart your shell for changes to take effect (or run "source .bashrc")**

##"I can't be bothered, give me a one-liner to paste in my shell."

Linux & OS X:
```bash
bash <(curl -s https://raw.githubusercontent.com/ivaruf/eternalize-bash/master/eternalize_bash.sh)
```
Windows with git-bash (does not support process substitution):
```bash
curl -s https://raw.githubusercontent.com/ivaruf/eternalize-bash/master/eternalize_bash.sh > tmp.sh && ./tmp.sh && rm tmp.sh
```

##Requirements
One of the following:
* Linux with bash shell.
* Mac with bash shell.
* Windows with git-bash.

Optional:
* Dropbox, for multi-machine history.
