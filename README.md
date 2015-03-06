#eternalize-bash
Eternalize-bash is a script that will make your bash history distributed between open terminals and even between machines, if you have Dropbox and run the script on all machines.

Run the eternalize-bash-script, and you will get distributed eternal bash history happiness.

```bash
./eternalize-bash.sh
```

##Alternate install
If you do not want to run the script, find the changes you need in eternal_bash_history.txt and add them manually to your .bashrc file (should also work to use this in a .profile file for mac users, feedback welcome).

##Requirements
* Enviroment that uses .bashrc in a home folder on the format /home/$USER. If you for example run Ubuntu and
use default settings, this will work.
* Dropbox, installed in default location. The script will work without it, but it will only give you distributed
bash history between terminals on one machine.

##Disclaimer
This is experimental stuff, I have tried to make the script so that there is very little chance it will break
anything, but i give no guarantees.
