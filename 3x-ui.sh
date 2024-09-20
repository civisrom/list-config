#!/bin/bash

### INFO ###
Green="\033[32m"
Red="\033[31m"
Yellow="\e[1;33m"
Blue="\033[36m"
Orange="\033[38;5;214m"
Font="\e[0m"

OK="${Green}[OK]${Font}"
ERROR="${Red}[!]${Font}"
QUESTION="${Green}[?]${Font}"

function msg_banner()	{ echo -e "${Yellow} $1 ${Font}"; }
function msg_ok()		{ echo -e "${OK} ${Blue} $1 ${Font}"; }
function msg_err()		{ echo -e "${ERROR} ${Orange} $1 ${Font}"; }
function msg_inf()		{ echo -e "${QUESTION} ${Yellow} $1 ${Font}"; }
function msg_out()		{ echo -e "${Green} $1 ${Font}"; }
function msg_tilda()	{ echo -e "${Orange}$1${Font}"; }

### Проверка ввода ###
answer_input () {
	read answer
	if [[ $answer != "y" ]] && [[ $answer != "Y" ]]; then
		echo
		msg_err "ОТМЕНА"
		echo
		exit
	fi
	echo
}

validate_path() {
	local path_variable_name=$1
	while true; do
		read path_value
		# Проверка на пустой ввод
		if [[ -z "$path_value" ]]; then
			msg_err "Ошибка: путь не должен быть пустым"
			echo
			msg_inf "Пожалуйста, введите путь заново:"
		# Проверка на наличие запрещённых символов
		elif [[ $path_value =~ ['{}\$/'] ]]; then
			msg_err "Ошибка: путь не должен содержать символы (/, $, {}, \)"
			echo
			msg_inf "Пожалуйста, введите путь заново:"
		else
			eval $path_variable_name=\$path_value
			break
		fi
	done
}

# Функция для генерации случайного порта
generate_port() {
	echo $(( ((RANDOM<<15)|RANDOM) % 49152 + 10000 ))
}
# Функция для проверки, занят ли порт
is_port_free() {
	local port=$1
	nc -z 127.0.0.1 $port &>/dev/null
	return $?
}
# Основной цикл для генерации и проверки порта
port_issuance() {
	while true; do
		PORT=$(generate_port)
		if ! is_port_free $PORT; then  # Если порт свободен, выходим из цикла
			echo $PORT
			break
		fi
	done
}

choise_dns () {
	while true; do
		read choise
		case $choise in
			1)
				echo
				msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
				echo
				msg_inf "Введите путь к adguard-home (без символов /, $, {}, \):"
				validate_path adguardPath
				break
				;;
			2)
				msg_ok "Выбран systemd-resolved"
				break
				;;
			*)	
				msk_err "Неверный выбор, попробуйте снова"
				;;
		esac
	done
}

domain_input() {
	read domain
	domain=$(echo "$domain" 2>&1 | tr -d '[:space:]' )
	if [[ "$domain" == "www."* ]]; then
		domain=${domain#"www."}
	fi
}

### IP сервера ###
check_ip() {
	IP4_REGEX="^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"
	IP4=$(ip route get 8.8.8.8 2>&1 | grep -Po -- 'src \K\S*')
	[[ $IP4 =~ $IP4_REGEX ]] || IP4=$(curl -s ipinfo.io/ip);
}

### Проверка рута ###
check_root() {
	[[ $EUID -ne 0 ]] && echo "not root!" && sudo su -
}

### Баннер ###
banner_1() {
	clear
	echo
	msg_banner " ╻ ╻┏━┓┏━┓╻ ╻   ┏━┓┏━╸╻ ╻┏━╸┏━┓┏━┓┏━╸   ┏━┓┏━┓┏━┓╻ ╻╻ ╻ "
	msg_banner " ┏╋┛┣┳┛┣━┫┗┳┛   ┣┳┛┣╸ ┃┏┛┣╸ ┣┳┛┗━┓┣╸    ┣━┛┣┳┛┃ ┃┏╋┛┗┳┛ "
	msg_banner " ╹ ╹╹┗╸╹ ╹ ╹    ╹┗╸┗━╸┗┛ ┗━╸╹┗╸┗━┛┗━╸   ╹  ╹┗╸┗━┛╹ ╹ ╹  "
	echo
	echo
}

### Начало установки ###
start_installation() {
 	msg_err "ВНИМАНИЕ!"
	echo
	msg_ok "Перед запуском скрипта рекомендуется выполнить следующие действия:"
	msg_err "apt update && apt full-upgrade -y && reboot"
	echo
	msg_inf "Скрипт установки 3x-ui. Начать установку? Выберите опцию [y/N]"
	answer_input
}


### Ввод данных ###
data_entry() {
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
	msg_inf "Введите имя пользователя:"
	read username
	msg_inf "Введите пароль пользователя:"
	read password
	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
	msg_inf "Укажите свой домен:"
	domain_input
	msg_inf "Введите доменное имя, под которое будете маскироваться Reality:"
	read reality
	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
	msg_inf	"Введите 1, для установки adguard-home (DoH-DoT)"
	msg_inf	"Введите 2, для установки systemd-resolved (DoT)"
	choise_dns
	msg_inf "Введите путь к панели (без символов /, $, {}, \):"
	validate_path webBasePath
	msg_inf "Введите путь к подписке (без символов /, $, {}, \):"
	validate_path subPath
	msg_inf "Введите путь к JSON подписке (без символов /, $, {}, \):"
	validate_path subJsonPath
	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
	msg_inf "Введите вашу почту, зарегистрированную на Cloudflare:"
	read email
	msg_inf "Введите ваш API токен Cloudflare (Edit zone DNS) или Cloudflare global API key:"
	read cftoken
	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
	msg_inf "Введите ключ для регистрации WARP или нажмите Enter для пропуска:"
	read warpkey
	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
	webPort=$(port_issuance)
	subPort=$(port_issuance)

	webCertFile=/etc/letsencrypt/live/${domain}/fullchain.pem
	webKeyFile=/etc/letsencrypt/live/${domain}/privkey.pem
	subURI=https://${domain}/${subPath}/
	subJsonURI=https://${domain}/${subJsonPath}/
}

### Обновление системы и установка пакетов ###
installation_of_utilities() {
	msg_inf "Обновление системы и установка необходимых пакетов"
	apt-get update && apt-get upgrade -y
	apt-get install -y gnupg2	
	apt-get update && apt-get upgrade -y
	apt-get install -y net-tools apache2-utils gnupg2 sqlite3 unattended-upgrades tilda
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
}

### NGINX ###
nginx_setup() {
	msg_inf "Настройка NGINX"
	mkdir -p /etc/nginx/stream-enabled/
	touch /etc/nginx/.htpasswd

	nginx_conf
	stream_conf
	local_conf

	nginx -s reload
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
}

nginx_conf() {
	cat > /etc/nginx/nginx.conf <<EOF
user                              www-data;
pid                               /run/nginx.pid;
worker_processes                  auto;
worker_rlimit_nofile              65535;
error_log                         /var/log/nginx/error.log;

include                           /etc/nginx/modules-enabled/*.conf;

events {
	multi_accept                  on;
	worker_connections            65535;
}

http {
	sendfile                      on;
	tcp_nopush                    on;
	tcp_nodelay                   on;
	server_tokens                 off;
	log_not_found                 off;
	types_hash_max_size           2048;
	types_hash_bucket_size        64;
	client_max_body_size          16M;

	# timeout
	keepalive_timeout             60s;
	keepalive_requests            1000;
	reset_timedout_connection     on;

	# MIME
	include                       /etc/nginx/mime.types;
	default_type                  application/octet-stream;

	# SSL
	ssl_session_timeout           1d;
	ssl_session_cache             shared:SSL:10m;
	ssl_session_tickets           off;

	# Mozilla Intermediate configuration
	ssl_prefer_server_ciphers on;
	ssl_protocols                 TLSv1.2 TLSv1.3;
	ssl_ciphers                   TLS13_AES_128_GCM_SHA256:TLS13_AES_256_GCM_SHA384:TLS13_CHACHA20_POLY1305_SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305;

	# OCSP Stapling
	ssl_stapling                  on;
	ssl_stapling_verify           on;
	resolver                      1.1.1.1 valid=60s;
	resolver_timeout              2s;

	# access_log /var/log/nginx/access.log;
	gzip                          on;

	include /etc/nginx/conf.d/*.conf;
}

stream {
	include /etc/nginx/stream-enabled/stream.conf;
}
EOF
}

stream_conf() {
	cat > /etc/nginx/stream-enabled/stream.conf <<EOF
map \$ssl_preread_server_name \$backend {
	${reality}        reality;
	www.${domain}     trojan;
	${domain}         web;
}
upstream reality        { server 127.0.0.1:7443; }
upstream trojan         { server 127.0.0.1:9443; }
upstream web            { server 127.0.0.1:36076; }

server {
	listen 443          reuseport;
	ssl_preread         on;
	proxy_pass          \$backend;
}
EOF
}

local_conf() {
	cat > /etc/nginx/conf.d/local.conf <<EOF
# Main
server {
	listen                      36076 ssl default_server;

	# SSL
	ssl_reject_handshake        on;
	ssl_session_timeout         1h;
	ssl_session_cache           shared:SSL:10m;
}
server {
	listen                      36076 ssl http2;
	server_name                 ${domain} www.${domain};

	# SSL
	ssl_certificate             ${webCertFile};
	ssl_certificate_key         ${webKeyFile};
	ssl_trusted_certificate     /etc/letsencrypt/live/${domain}/chain.pem;

	# Disable direct IP access
	if (\$host = ${IP4}) {
		return 444;
	}

	# Auth
	location / {
		auth_basic "Restricted Content";
		auth_basic_user_file /etc/nginx/.htpasswd;
	}
	# X-ui Admin panel
	location /${webBasePath} {
		proxy_redirect off;
		proxy_set_header Host \$host;
		proxy_set_header X-Real-IP \$remote_addr;
		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
		proxy_set_header X-Real-IP \$remote_addr;
		proxy_set_header Range \$http_range;
		proxy_set_header If-Range \$http_if_range;
		proxy_pass https://127.0.0.1:${webPort}/${webBasePath};
		break;
	}
	# Subscription 
	location /${subPath} {
		proxy_redirect off;
		proxy_set_header Host \$host;
		proxy_set_header X-Real-IP \$remote_addr;
		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
		proxy_pass https://127.0.0.1:${subPort}/${subPath};
		break;
	}
	# Subscription json
	location /${subJsonPath} {
		proxy_redirect off;
		proxy_set_header Host \$host;
		proxy_set_header X-Real-IP \$remote_addr;
		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
		proxy_pass https://127.0.0.1:${subPort}/${subJsonPath};
		break;
	}
	# Adguard home
	${comment_agh}
}
EOF
}

### Установка 3x-ui ###
panel_installation() {
	touch /usr/local/bin/reinstallation_check
	msg_inf "Настройка 3x-ui xray"
	while ! wget -q --show-progress --timeout=30 --tries=10 --retry-connrefused https://github.com/cortez24rus/3X-UI-auto-deployment/raw/main/x-ui.db; do
    	msg_err "Скачивание не удалось, пробуем снова..."
    	sleep 3
	done

	stream_settings_id6
	stream_settings_id7
	stream_settings_id8
	database_change

	x-ui stop
	rm -rf /etc/x-ui/x-ui.db
	mv x-ui.db /etc/x-ui/
	x-ui start
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
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
	echo
	printf '0\n' | x-ui | grep --color=never -i ':'
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo -n "Доступ по ссылке к 3x-ui панели: " && msg_out "https://${domain}/${webBasePath}/"
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	if [[ $choise = "1" ]]; then
		echo -n "Доступ по ссылке к adguard-home: " && msg_out "https://${domain}/${adguardPath}/login.html"
		msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	fi
	echo -n "Подключение по ssh: " && msg_out "ssh ${username}@${IP4}"
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo -n "Username: " && msg_out "${username}"
	echo -n "Password: " && msg_out "${password}"
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
	msg_err "PLEASE SAVE THIS SCREEN!"
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
}

### Первый запуск ###
main_script_first() {
	check_ip
	check_root
	banner_1
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
	enabling_security
	data_output
	ssh_setup
}

### Повторный запуск ###
main_script_repeat() {
	check_ip
	check_root
	banner_1
	start_installation
	data_entry
	dns_encryption
	nginx_setup
	panel_installation
	enabling_security
	data_output
	ssh_setup
}

### Проверка запуска ###
main_choise() {
	if [ -f /usr/local/bin/reinstallation_check ]; then
		echo
		msg_err "Повторная установка скрипта"
		sleep 2
		main_script_repeat
		echo
		exit 1
	else
		main_script_first
	fi
}

main_choise
