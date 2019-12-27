#!/bin/sh
#batch install zabbix-agent
ip_file=/work/ip.txt
pass_file=/work/pass.txt
conn_ssh(){
if [ $# != 2 ] ; then
 echo "USAGE: $0 ip your command"
 echo " e.g.: $0 10.10.10.64 hostname"
 exit 1;
fi

ip=$1
cmd=$2
echo $ip $cmd
#test ssh key can work
ssh $ip -o PreferredAuthentications=publickey -o StrictHostKeyChecking=no hostname >/dev/null 2>&1
ssh_status=`echo $?`
if [ $ssh_status -eq 0 ]; then
 #echo ssh key can work
 ssh $ip $cmd
else
 /usr/bin/expect << EOF
 set timeout 3
 spawn ssh root@$ip "$cmd"
 expect {
  "yes/no" {send "yes\r";exp_continue}
  "password" {send "$pass\r" }
  "denied" exit
  "Last login" exit
 }
 expect eof
EOF
fi
}

conn_scp_worksh(){
ip=$1
#test ssh key can work
ssh $ip -o PreferredAuthentications=publickey -o StrictHostKeyChecking=no hostname >/dev/null 2>&1
ssh_status=`echo $?`
if [ $ssh_status -eq 0 ]; then
# echo ssh key can work
 scp $sourcePath/$worksh root@$ip:$destPath
else
 /usr/bin/expect << EOF
 set timeout 3
 spawn scp /tmp/zabbix_agentd.conf  root@$ip:/etc/zabbix/
 expect {
   "yes/no" {send "yes\r";exp_continue}
   "password" {send "$pass\r" }
   "denied" exit
   "Last login" exit
 }
 expect eof
EOF
fi
}


for ip in `cat $ip_file`
 do
   echo handle $ip
   pass=$(grep $ip $pass_file | awk '{print $2 }')
   #change char meaning ,like java \
   #echo create work dir
   echo scp rpm
   #conn_scp_worksh $ip
   #exec work ssh
   echo run  rpm
   conn_ssh $ip "service zabbix-agent start"
   echo handle $ip success
   echo
done
