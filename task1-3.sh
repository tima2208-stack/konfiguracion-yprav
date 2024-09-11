#Zadanie #1

cut -d: -f1 /etc/passwd | sort
adm
at
bin
cron
cyrus
daemon
dhcp
ftp
games
guest
halt
lp
mail
man
news
nobody
ntp
operator
postmaster
root
shutdown
smmsp
squid
sshd
svn
sync
uucp
vpopmail
xfs

#Zadanie #2
awk '{print $2, $1}' /etc/protocols | sort -nr | head -n 5
103 pim
98 encap
94 ipip
89 ospf
81 vmtp

#Zadanie #3

#!/bin/bash

text=$*
length=${#text}

for i in $(seq 1 $((length + 2))); do
    line+="-"
done

echo "+${line}+"
echo "| ${text} |"
echo "+${line}+"
