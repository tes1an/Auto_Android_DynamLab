#!/bin/bash

Black="\e[0;90m"
Red="\e[0;91m"
Green="\e[0;92m"
Yellow="\e[0;93m"
Blue="\e[0;94m"
Purple="\e[0;95m"
Cyan="\e[0;96m"
White="\e[0;97m"
Magenta="\e[0;35m"
FC="\e[0m"


trap ctrl_c INT

function ctrl_c(){
	echo -e "\n\n${Red}[!]${FC} Saliendo del programa...): \n${FC}"
	tput cnorm
	exit 0
}

function config(){
	echo -e "\n"
	for x in $(seq 1 80); do echo -ne "${Yellow}-"; done; echo -ne "${FC}"
	echo -e "\n\t ${Magenta}P4ndroid${FC} - Automatizacion de android environment - ${Green}Nivel 4${FC}"
	for x in $(seq 1 80); do echo -ne "${Yellow}-"; done; echo -ne "${FC}"
	which adb >/dev/null 2>&1
	if [ "$(echo $?)" -eq "0" ];then
		echo -e "\n\n${Green}[+]${FC} La herramienta ${Blue}adb${FC} se encuentra instalada."
		which frida-ps >/dev/null 2>&1
		if [ "$(echo $?)" -eq "0" ]; then
			echo -e "${Green}[+]${FC} La herramienta ${Blue}frida-ps${FC} se encuentra instalada.\n"
			sleep 2
			for x in $(seq 1 80); do echo -ne "${Yellow}-"; done; echo -ne "${FC}"
#			clear -x
			if [ -e "$PWD/cacert.der" ]; then
				echo -e "\n\n${Cyan}[-]${FC} El fichero ${Purple}cacert.pem${FC} si existe en le directorio de trabajo."
				openssl x509 -inform DER -in cacert.der -out cacert.pem
				hash=$(openssl x509 -inform PEM -subject_hash_old -in cacert.pem | head -n 1)
				mv cacert.pem $hash.0 &&  echo -e "\t${Green}[+]${FC} Fichero ${Blue}$hash.0${FC} generado correctamente.\n"
				for x in $(seq 1 80); do echo -ne "${Yellow}-"; done; echo -ne "${FC}"
				echo -e "\n\n${Cyan}[-]${FC} Comprobando conexion con el dispositivo ${Yellow}$ip_host${FC}"
				bash -c "ping -c 2 $ip_host" &>/dev/null
				if [ "$(echo $?)" -eq "0" ]; then
					connect=$(adb connect $ip_host:5555 | wc -c)
					if [ "$(echo $connect)" -lt "42" ] && [ "$(echo $connect)" -gt "20" ]; then
						echo -e "\t${Green}[+]${FC} El dispositivo se conecto con ${Yellow}adb${FC} correctamente.\n"
						adb devices
						adb shell mount -o rw,remount /system
						echo -e "${Green}[+]${FC} Enviando ${Purple}$hash.0${FC} al dispositivo ${Yellow}$ip_host${FC}"
						adb push $hash.0 /system/etc/security/cacerts/$hash.0 &>/dev/null
						adb shell chmod 644 /system/etc/security/cacerts/$hash.0
						for x in $(seq 1 80); do echo -ne "${Yellow}-"; done; echo -ne "${FC}"
						echo -e "\n${Green}[+]${FC} Comprobando la existencia de ${Purple}frida-server${FC} en el directorio actual"
						if [ -e "$PWD/frida-server" ]; then
							echo -e "\t${Green}[+]${FC} Fichero ${Purple}frida-server${FC} encontrado\n\t${Green}[+]${FC} Se instalara ${Cyan}Frida${FC} en el dispositivo."
							adb push $PWD/frida-server /data/local/tmp/frida-server &>/dev/null
							adb shell chmod 777 /data/local/tmp/frida-server
							adb shell /data/local/tmp/frida-server & 2>/dev/null
							for x in $(seq 1 80); do echo -ne "${Yellow}-"; done; echo -ne "${FC}"
							echo -e "\n${Green}[+]${FC} Listando los primeros 5 procesos con ${Purple}frida-ps${FC}\n"
							frida-ps -U 2>/dev/null | head -n 7
							for x in $(seq 1 80); do echo -ne "${Yellow}-"; done; echo -ne "${FC}"
							echo -e "\n\n${Purple}[+]${FC} Entorno configurado con exito.\n"
						else
							echo -e "${Red}[!]${FC} ${Purple}firda-server${FC} no se encuentra en el directorio actual de trabajo, por lo que se procedera a descargar"
							wget -q "https://github.com/tes1an/Auto_Android_DynamLab/raw/main/frida-server"
							sleep 2
							clear -x
							config
						fi
						exit 0
					else
						echo -e "${Red}[!]${FC} El dispositivo NO logro conectarse con ${Yellow}adb${FC}"
						exit 1
					fi
				else
				echo -e "\t${Red}[!]${FC} Error de red, no se ha podido establecer conexion con el $ip dispositivo: ${Yellow}$ip_host${FC}"
					echo -e "\t${Cyan}[-]${FC} Compruebe la conexion con el dispositivo y vuelva a ejecutar el script."
					sleep 2
					exit 1
				fi
			else
			echo -e "\n${Red}[!]${FC} El fichero ${Purple}cacert.der${FC} no existe en el directorio actual de trabajo: ${Yellow}$PWD/${FC}"
				echo -e "\t${Yellow}[-]${FC} Exporte su certificado de ${Purple}BurpSuite${FC} e ingreselo en el directorio actual de trabajo con el nombre de: ${Purple}cacert.pem${FC} y vuelva a iniciar el script."
				exit 1
			fi

		else
			echo -e "\n${Red}[!]${FC} El programa ${Blue}frida-ps${FC} no se encuentra instalado."
			echo -e "\t${Green}[+]${FC} Instalando ${Blue}frida-ps${FC}..."
			pip install frida-tools  && echo -e "\t${Green}[+]${FC}${Blue} frida-tools${FC} se ha instalado de manera correcta."
			sleep 3
			clear -x
			config
		fi
	else
		echo -e "\n${Red}[!]${FC} El programa adb no se encuentra instalado."
		echo -e "\t${Green}[+]${FC} Instalando ${Blue}adb${FC}..."
		sudo apt-get install adb -y &>/dev/null && echo -e "\t${Green}[+]${FC}${Blue} adb${FC} se ha instalado de manera correcta."
		sleep 3
		clear -x
		config
	fi

}

function help(){
	echo -e "\n[+] Usage: ./p4ndroid.sh\n\t-d\tIndicar direccion IP del dispositivo a conectar por adb.\n\t-h\tMuestra el panel de ayuda.\n\n    Example: ./p4ndroid -d 192.168.0.10"
}

count=0; while getopts "d:h" arg; do
	case $arg in
		d) ip_host=$OPTARG; let count+=1;;
		h) ;;
	esac
done



if [ $count -eq 0 ]; then
	help
else
	if [ "ip_host" ]; then
		config $ip_host
	else
		echo -e "\n\t ${Red}[-]${FC}\tError, comprueba los parametros ingresados."
		help
	fi
fi
