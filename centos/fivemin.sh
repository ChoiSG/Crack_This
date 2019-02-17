#!/bin/sh

# [[ TODO ]] 
#   1. Ask about mail (25,110,143) ports and firewall rules 
#   2. chattr log stuffs 
#   3. Discuss with crack members and add more stuff 
#


# Script - TODO 
# 1. Change credentials (add sudo user?) 
# 2. Setup firewall 
# 3. Change sudoers + sshd_config 
# 4. Loot redteam's history 
#

setupTERMINATOR() { 
    sudo yum install -y epel-release
    sudo yum --disablerepo=epel -y update  ca-certificates
    sudo yum -y install terminator

    echo "setupTERMINATOR........ DONE" 

}


setupFIREWALL() {
    chmod +x iptables.sh
    bash ./iptables.sh
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
    for i in $(ls /home); do
        tar -czf "./fun/initial.home.$i.tar.gz" /home/$i 
    done

    echo "redteamFUN........ DONE"
}

secureSSH() {
    #SSH
    yum erase -y openssh-clients openssh-server
    yum install -y openssh-clients openssh-server
    mv /etc/ssh/sshd_config /etc/ssh/old_daemon_config
    cp ./sshd_config /etc/ssh/

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
    
    if [ -n "$(command -v cron)" ]; then 
        cronname="cron"
    else
        cronname="crond"
    fi

    if [ -n "$(command -v service)" ]; then
        service $cronname stop
    elif [ -n "$(command -v systemctl)" ]; then
        systemctl stop $cronname
        systemctl disable $cronname
    elif [ -n "$(command -v initctl)" ]; then
        initctl stop $cronname

    fi

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
changePASS 2>>changePASS.error
stopPLES 2>>stopPLES.error
redteamFUN 2>>redteamFUN.error
secureSSH 2>>secureSSH.error
secureSUDOER 2>>secureSUDOER.error
stopPLES 2>>stopPLES.error
setupTERMINATOR 2>>setupTERMINATOR.error
setupFIREWALL 2>>setupFIREWALL.error

