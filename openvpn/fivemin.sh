#Password should be changed prior to running this.
echo "This script better have been run as sudo."
echo ""

#Disable kernel modules
sysctl -w kernel.modules_disabled=1

#Save artifacts relating to users (persistent state)
getent passwd > passwd.backup
getent group > group.backup
cat /etc/sudoers > sudoers.backup
cat ~/.bashrc > bashrc.backup

#Save artifacts relating to processes (current state)
ps aux > ps.backup
netstat -ptuna > netstat.backup
service --status-all > service.backup
systemctl -l --type service --all > systemctl.backup
sysctl -a > sysctl.backup


#Who needs cron?

    echo "Disabling Cron..."
    
    if [ -n "$(command -v cron)" ]; then 
        cronname="cron"
    else
        cronname="crond"
    fi

    if [ -n "$(command -v service)" ]; then
        service $cronname stop
        service anacron stop
        service atd stop
    elif [ -n "$(command -v systemctl)" ]; then
        systemctl stop $cronname
        systemctl disable $cronname
        systemctl stop anacron
        systemctl disable anacron
        systemctl stop atd
        systemctl disable atd 
    elif [ -n "$(command -v initctl)" ]; then
        initctl stop $cronname
        initctl stop anacron
        initctl stop atd

    fi



cp ./sudoers /etc/sudoers

#Do backups of /etc/openvpn*
tar -pcvf etc.backup etc/*

echo "Now make your backdoor user. adduser username; usermod -aG sudo name"
echo "If you didn't already change your password, you did something wrong."
echo "Why not consider uninstalling cron?"


