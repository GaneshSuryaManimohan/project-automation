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
        echo "$2....$R FAILURE $N"
        exit 1
    else
        echo "$2....$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0]
then
    echo "Please switch to root user to run this script"
    exit 1
else
    echo "Executing the script as a root user"
fi

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Install NGINX"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enable NGINX"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Start NGINX"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Remove default content from /usr/share/nginx/html/*"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Download Frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "Extract (unzip) frontend code in /usr/share/nginx/html"

cp /home/ec2-user/project-automation/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "Copying expense.conf to /etc/nginx/default.d/"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restart NGINX Service"