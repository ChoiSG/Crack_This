#!/bin/sh

# [[ TODO ]] 
#   1. Ask about mail (25,110,143) ports and firewall rules 
#   2. chattr log stuffs 
#   3. Discuss with crack members and add more stuff 
#
# Stuart's vpn is a nono

# Script - TODO 
# 1. Change credentials (add sudo user?) 
# 2. Setup firewall 
# 3. Change sudoers + sshd_config 
# 4. Loot redteam's history 
#

setupBACKUPUSER() {
    useradd go
    echo "Wkwkdaus!" | passwd --stdin go
    usermod go -aG wheel go 
}


changePASS() {
    echo "Changing password for following users..." 
    echo `getUSERS`
    echo -n "type new password: "
    read passwd
    getUSERS | xargs -d'\n' -I {} sh -c "echo {}:$passwd | chpasswd"

    echo "changePass........ DONE"
}

getUSERS() {
    while IFS=: read a b c
    do
        if [ ! "$b" == "!" ] && [ ! "$b" == "*" ]; then 
            echo "$a"
        fi
    done < /etc/shadow
}

getUSERS2() {
    for i in $(cat /etc/shadow); do
        for j in $(echo $i | awk -F ':' '{
                    if ($2 != "*")
                        print $1
                }'); do
            echo "Change $j!"    #"$j:$NEWPASS" | chpasswd
        done
    done
}

redteamFUN() {
    mkdir "./fun"
    tar -czvf "./fun/initials.tar.gz" ~/.ssh ~/.profile ~/.bash_history ~/.bashrc ~/.lesshst
    #for i in $(ls /home); do
    #    tar -czf "./fun/initial.home.$i.tar.gz" /home/$i 
    #done

    echo "redteamFUN........ DONE"
}

secureSSH() {
    mv /etc/ssh/sshd_config /etc/ssh/old_daemon_config
    cp ./sshd_config /etc/ssh
    echo 'sshd_enable="YES"' >> /etc/rc.conf
    /etc/rc.d/sshd restart

    echo "secureSSH........ DONE"
}

secureSUDOER() {
    cp /etc/sudoers ./fun/red_team_sudoers.bak
    mv /etc/sudoers /etc/sudoers.nono
    cp ./sudoers /etc/
    chmod 400 /etc/sudoers

    echo "secureSUDOER........ DONE"
}

stopPLES() {
    echo "Disabling Cron..."
    
	echo 'cron_enable="NO"' >> /etc/rc.conf
	/etc/rc.d/cron stop

    echo "stopPLES........ DONE"
}

# checkERROR



############# MAIN FUNC ##############

# DEBUG MODE 
if [ $1 == "debug" ]; then 
    echo "Debug mode..."

    rm -rf ./fun
    echo "Removing ./fun dir........ DONE"

    rm *.error
    echo "Removing all error files........ DONE"

    iptables -F
    echo "Flushing iptables........ DONE"
    exit
fi

# If not debug mode, fire away
pkg install bash vim-console curl
changePASS 2>>changePASS.error
#setupBACKUPUSER 2>>setupBACKUPUSER.error
stopPLES 2>>stopPLES.error
redteamFUN 2>>redteamFUN.error
secureSSH 2>>secureSSH.error
secureSUDOER 2>>secureSUDOER.error

curl https://raw.githubusercontent.com/ChoiSG/Crack_This/master/freebsd/pf.conf -o /etc/pf.conf
kldload pf
pfctl -e
pfctl -f /etc/pf.conf
echo 'pf_enable="YES"' >> /etc/rc.conf
echo 'pf_rules="/etc/pf.conf"' >> /etc/rc.conf
echo "Waiting for 5s to clear the firewalls..."
sleep 5
echo "Clearing firewalls...  RUN pfctl -e IF THE RULES WORK"
pfctl -d
