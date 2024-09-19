#!/bin/bash

blue='\033[1;36m'
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
clear='\033[0m'

### Установка 3x-ui ###
panel_installation() {
	touch /usr/local/bin/reinstallation_check
	echo -e "${blue}Настройка 3x-ui xray${clear}"
	wget -q --show-progress https://github.com/cortez24rus/3X-UI-auto-deployment/raw/main/x-ui.db
	sleep 1
	rm -rf /etc/x-ui/x-ui.db

	stream_settings_id6
	stream_settings_id7
	stream_settings_id8
	database_change

	mv x-ui.db /etc/x-ui/
	x-ui start
	echo ""
}

### Изменение базы данных ###
stream_settings_id6() {
stream_settings_id6=$(cat <<EOF
{
  "network": "kcp",
  "security": "none",
  "externalProxy": [
    {
      "forceTls": "same",
      "dest": "www.${domain}",
      "port": 2091,
      "remark": ""
    }
  ],
  "kcpSettings": {
    "mtu": 1350,
    "tti": 20,
    "uplinkCapacity": 50,
    "downlinkCapacity": 100,
    "congestion": false,
    "readBufferSize": 1,
    "writeBufferSize": 1,
    "header": {
      "type": "srtp"
    },
    "seed": "x2aYTWwqUE"
  }
}
EOF
)
}

stream_settings_id7() {
stream_settings_id7=$(cat <<EOF
{
  "network": "tcp",
  "security": "reality",
  "externalProxy": [
    {
      "forceTls": "same",
      "dest": "www.${domain}",
      "port": 443,
      "remark": ""
    }
  ],
  "realitySettings": {
    "show": false,
    "xver": 0,
    "dest": "${reality}:443",
    "serverNames": [
      "${reality}"
    ],
    "privateKey": "0IQP3faZ4kB-boJg8QQhfAhEmCaveXn9M5Cpc2Ar_Xk",
    "minClient": "",
    "maxClient": "",
    "maxTimediff": 0,
    "shortIds": [
      "eee930481a21b35a",
      "82",
      "b58f324f09",
      "641f38df",
      "e933023c95c4db",
      "46e7226febe2",
      "3afc28",
      "9319"
    ],
    "settings": {
      "publicKey": "GKKuQzfRfJ0Q8IuPcobznJLjzrjagVz2R5krzJGktVg",
      "fingerprint": "chrome",
      "serverName": "",
      "spiderX": "/"
    }
  },
  "tcpSettings": {
    "acceptProxyProtocol": false,
    "header": {
      "type": "none"
    }
  }
}
EOF
)
}

stream_settings_id8() {
stream_settings_id8=$(cat <<EOF
{
  "network": "tcp",
  "security": "tls",
  "externalProxy": [
    {
      "forceTls": "same",
      "dest": "www.${domain}",
      "port": 443,
      "remark": ""
    }
  ],
  "tlsSettings": {
    "serverName": "www.${domain}",
    "minVersion": "1.2",
    "maxVersion": "1.3",
    "cipherSuites": "",
    "rejectUnknownSni": false,
    "disableSystemRoot": false,
    "enableSessionResumption": false,
    "certificates": [
      {
	"certificateFile": "/etc/letsencrypt/live/${domain}/fullchain.pem",
	"keyFile": "/etc/letsencrypt/live/${domain}/privkey.pem",
	"ocspStapling": 3600,
	"oneTimeLoading": false,
	"usage": "encipherment",
	"buildChain": false
      }
    ],
    "alpn": [
      "h2",
      "http/1.1"
    ],
    "settings": {
      "allowInsecure": false,
      "fingerprint": "chrome"
    }
  },
  "tcpSettings": {
    "acceptProxyProtocol": false,
    "header": {
      "type": "none"
    }
  }
}
EOF
)
}

database_change() {
DB_PATH="x-ui.db"

sqlite3 $DB_PATH <<EOF
UPDATE users SET username = '$username' WHERE id = 1;
UPDATE users SET password = '$password' WHERE id = 1;

UPDATE inbounds SET stream_settings = '$stream_settings_id6' WHERE id = 6;
UPDATE inbounds SET stream_settings = '$stream_settings_id7' WHERE id = 7;
UPDATE inbounds SET stream_settings = '$stream_settings_id8' WHERE id = 8;

UPDATE settings SET value = '${webPort}' WHERE id = 1;
UPDATE settings SET value = '/${webBasePath}/' WHERE id = 2;
UPDATE settings SET value = '${webCertFile}' WHERE id = 8;
UPDATE settings SET value = '${webKeyFile}' WHERE id = 9;
UPDATE settings SET value = '${subPort}' WHERE id = 28;
UPDATE settings SET value = '/${subPath}/' WHERE id = 29;
UPDATE settings SET value = '${webCertFile}' WHERE id = 31;
UPDATE settings SET value = '${webKeyFile}' WHERE id = 32;
UPDATE settings SET value = '${subURI}' WHERE id = 36;
UPDATE settings SET value = '/${subJsonPath}/' WHERE id = 37;
UPDATE settings SET value = '${subJsonURI}' WHERE id = 38;
EOF
}

### Окончание ###
data_output() {
	echo -e "${blue}Доступ по ссылке к 3x-ui панели:${clear}"
	echo -e "${green}https://${domain}/${webBasePath}/${clear}"
	echo ""
	if [[ $choise = "1" ]]; then
		echo -e "${blue}Доступ по ссылке к adguard-home (если вы его выбирали):${clear}"
		echo -e "${green}https://${domain}/${adguardPath}/login.html${clear}"
		echo ""
	fi
	echo ""
	echo -e "${blue}Логин: ${green}${username}${clear}"
 	echo -e "${blue}Пароль: ${green}${password}${clear}"
	echo ""
	
	sleep 3
}

### Первый запуск ###
main_script_first() {
  check_ip
  check_root
  start_installation
  data_entry
  installation_of_utilities
  dns_encryption
  add_user
  uattended_upgrade
  enable_bbr
  disable_ipv6
  warp
  issuance_of_certificates
  nginx_setup
  panel_installation
  data_output
  ssh_setup
  enabling_security
}

### Повторный запуск ###
main_script_repeat() {
  check_ip
  check_root
  start_installation
  data_entry
  installation_of_utilities
  dns_encryption
  nginx_setup
  panel_installation
  data_output
}

main_choise() {
  if [ -f /usr/local/bin/reinstallation_check ]; then
    echo ""
    echo -e "${red}Повторная установка скрипта${clear}"
    sleep 2
    main_script_repeat
    echo ""
    exit 1
  else
    main_script_first
  fi
}

main_choise
