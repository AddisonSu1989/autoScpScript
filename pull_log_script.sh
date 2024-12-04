#!/bin/bash

#!/usr/bin/expect -f
set TARGET [lindex $argv 0]
set USER [lindex $argv 1]
set PASSWD [lindex $argv 2]
set PORT [lindex $argv 3]
set SOURCELOG [lindex $argv 4]
set timeout 30

# echo "$TARGET"
# echo "$USER"
# echo "$PASSWD"
# echo "$PORT"
# echo "$TARGETPATH"
# echo "$SOURCEFILE"




spawn scp   "$USER@$TARGET:$SOURCELOG"  ./
expect {
    "*yes/no" {send "yes\r"; exp_continue}
    "*password:" {send "$PASSWD\r"}
}

interact
