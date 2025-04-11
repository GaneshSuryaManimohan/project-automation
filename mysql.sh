#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F:%H:%M:%S)
SCRIPT_FILE=$( echo $0 | cut -d "." -f1 )
LOGFILE=/tmp/$SCRIPT_FILE-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "Please enter the root password for DB: "
read -s mysql_root_password

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2.... $R FAILURE $N"
        exit 1 #manual exit in case of error
    else
        echo -e "$2....$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please switch to root user to execute this script"
    exit 1
else    
    echo "Running this script as a root user"
fi

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "MySQL Server Installation"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling mysqld service"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting mysqld service"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
# VALIDATE $? "Setting up root password"

mysql -h db.surya-devops.site -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    VALIDATE $? "MySQL Root password is setup"
else
    echo -e "MySQL root password is already setup... $Y SKIPPING $N"
fi