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

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling nodejs version 20"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

id expense
if [ $? -ne 0 ]
then
    useradd expense
    VALIDATE $? "Adding expense user"
else
    echo -e "Expense user already added... $Y SKIPPING $N"
fi