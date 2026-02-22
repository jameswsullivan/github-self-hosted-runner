#!/bin/bash

echo
echo "Configuring msmtprc ... "
echo

sudo sed -i "s|SMTP_RELAY|${SMTP_RELAY}|g" /etc/msmtprc
sudo sed -i "s|SMTP_PORT|${SMTP_PORT}|g" /etc/msmtprc
sudo sed -i "s|MSMTP_LOG_PATH|${MSMTP_LOG_PATH}|g" /etc/msmtprc
sudo sed -i "s|MSMTP_NOTIF_EMAIL_FROM|${MSMTP_NOTIF_EMAIL_FROM}|g" /etc/msmtprc

echo "/etc/msmtprc has been configured with the following settings: "
echo

cat /etc/msmtprc

echo
echo "Configuring msmtprc completed."
echo

if [ ! -f ".runner" ]; then
    
    install-runner.sh

else
    echo "Runner already installed, starting runner ... "
fi

exec ./run.sh


