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

Features:
* unlimited history-size, so you never have to lose another command.
* shared history between open terminals.
* shared history between machines (using dropbox).

Usage:
Run eternalize-bash.sh and select the options you want.

One line install:
```bash
bash <(curl -s https://raw.githubusercontent.com/ivaruf/eternalize-bash/master/eternalize_bash.sh)
```

**Re-run the script to link/unlink from dropbox or to uninstall.**
Restart your shell for changes to take effect (or run "source .bashrc")

##Requirements
One of the following:
* Linux with bash shell
* Mac with bash shell
* Windows with git-bash

Optional:
* Dropbox, this is only required for machine distributed history.
