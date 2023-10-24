#!/bin/bash

if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

clear

installTheme(){
    cd /var/www/
    tar -cvf panel-themebackup.tar.gz pterodactyl
    echo "Asennetaan tätä hauskaa themea!"
    cd /var/www/pterodactyl
    rm -r panel-theme
    git clone https://github.com/Thearex/panel-theme.git
    cd panel-theme
    rm /var/www/pterodactyl/resources/scripts/panel-theme.css
    rm /var/www/pterodactyl/resources/scripts/index.tsx
    mv index.tsx /var/www/pterodactyl/resources/scripts/index.tsx
    mv panel-theme.css /var/www/pterodactyl/resources/scripts/panel-theme.css
    cd /var/www/pterodactyl

    curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    apt update
    apt install -y nodejs

    npm i -g yarn
    yarn

    cd /var/www/pterodactyl
    yarn build:production
    sudo php artisan optimize:clear
}

installThemeQuestion(){
    while true; do
        read -p "Are you sure that you want to install the theme [y/n]? " yn
        case $yn in
            [Yy]* ) installTheme; break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

repair(){
    bash <(curl https://raw.githubusercontent.com/Thearex/panel-theme/main/repair.sh)
}

restoreBackUp(){
    echo "Restoring backup..."
    cd /var/www/
    tar -xvf panel-themebackup.tar.gz
    rm panel-themebackup.tar.gz

    cd /var/www/pterodactyl
    yarn build:production
    sudo php artisan optimize:clear
}

echo "Copyright (c) 2022 Angelillo15 | angelillo15.es"
echo "This program is free software: you can redistribute it and/or modify"
echo ""
echo "Discord: https://discord.angelillo15.es/"
echo "Website: https://angelillo15.es/"
echo ""
echo "[1] Asenna tama hauska theme!"
echo "[2] Restore backup"
echo "[3] Repair panel (use if you have an error in the theme installation)"
echo "[4] Lahde ja et asenna themea"

read -p "Please enter a number: " choice
if [ $choice == "1" ]
    then
    installThemeQuestion
fi
if [ $choice == "2" ]
    then
    restoreBackUp
fi
if [ $choice == "3" ]
    then
    repair
fi
if [ $choice == "4" ]
    then
    exit
fi
