#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/roboshop"
logs_file="${logs_folder}/${0}.log"
R="/e[31m"
G="/e[32m"
Y="/e[33m"
N="/e[0m"

if [ $user_id -ne 0 ] ; then
    echo "Please run this script with sudo access"
    exit 1
fi

mkdir -p $logs_folder

timestamp(){
    date +"%F %T"
}

echo "$(timestamp) [INFO] === script execution started ===" | tee -a $logs_file

validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$(timestamp) [ERROR] ${2}..${R}FAILED${N}" | tee -a $logs_file
        exit 1
    else
        echo -e "$(timestamp) [INFO] ${2}..${G}SUCCESS${N}" | tee -a $logs_file
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-org -y &>> $logs_file
validate $? "mangodb installation"

systemctl enable mongod &>> $logs_file
systemctl start mongod
validate $? "enable and start of mongodb"

sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
validate $? "updating the remote configuration file"

systemctl restart mongod &>> $logs_file
validate $? "restarted mongodb"

echo "$(timestamp) [INFO] script executed in $Seconds seconds"
echo "$(timestamp) [INFO] === script executiom completed ===" | tee -a $logs_file