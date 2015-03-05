#!/bin/bash

echo "Making a copy of your .bashrc file to .bashrc_backup"
cp $1 $1_backup

# Comment out any occurance of HISTSIZE and HISTFILESIZE
sed -i s/^HISTSIZE\=/#HISTSIZE\=/g $1
sed -i s/^HISTFILESIZE\=/#HISTFILESIZE\=/g $1


echo "Diff of backup and new .bashrc"
diff $1_backup $1
