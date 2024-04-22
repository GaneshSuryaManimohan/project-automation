#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F:%H:%M:%S)
SCRIPT_FILE=$( echo $0 | cut -d "." -f1 )
LOGFILE=/tmp/$SCRIPT_FILE-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "Installation of $2.... $R FAILURE $N"
        exit 1 #manual exit in case of error
    else
        echo -e "Installation of $2....$G SUCCESS $N"
    fi

if [ $USERID -ne 0 ]
then
    echo "Please switch to root user to execute this script"
    exit 1
else    
    echo "Running this script as a root user"
fi

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "MySQL Server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling mysqld service"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting mysqld service"

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "Setting up root password"