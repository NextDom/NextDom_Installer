#!/bin/bash

#2020-01-08 : v1.8 : ajout compatibilité RPI
#2020-01-05 : v1.7 : Correction Typo
#2019-12-30 : v1.6 : mise en place de fonction
#2019-11-26 : v1.5 : correction de l'ordre d'installation des dépendances.
#2019-11-25 : v1.3 : ajout dépôt pour install git + clé
VERSION_SCRIPT="V1.9"
NEXTDOM_LOG="/var/log/nextdom"
NEXTDOM_LIB="/var/lib/nextdom"
NEXTDOM_HTML="/var/www/html"
NEXTDOM_SHARE="/usr/share/nextdom"
NEXTDOM_TMP="/tmp/nextdom/"
APT_INSTALL_TYPE="NA"
APT_NEXTDOM_CONF="/etc/apt/sources.list.d/nextdom.list"
GIT_NEXTDOM_URL="NA"
GIT_NEXTDOM_BRANCHE="NA"
NEXTDOM_TYPE_INSTALL="0"


function CHECK_RETURN_KO ()
{
  # Function. Parameter 1 is the return code
  # Para. 2 is text to display on failure.
  if [ "${1}" -ne "0" ]; then
    echo "ERROR # ${1} : ${2}"
    # as a bonus, make our script exit with the right error code.
    exit "${1}"
  fi
}

function usage { 

		echo ""
		echo "NextDom Installer tool " ${VERSION_SCRIPT}
		echo ""
		echo ""
		echo "		-a OFI		: Installation via apt, dépôt officiel"
		echo "		-a NGT		: version nightly"
		echo "		-a DEV		: version dépôt develop"
		echo ""
		echo "		-git		: Installation via git"
		echo ""
		echo "		-b NOM_DE_LA_BRANCHE	: Changement de branche git"
		echo ""
		echo "		-? ou -help	: afficher l'aide et quitter"
	
}


if [ -z "$1" ]; 
then
	usage
	exit 
else
while getopts a:g:b: options
do
    case ${options} in
    "a" ) APT_INSTALL_TYPE="${OPTARG}"
		  NEXTDOM_TYPE_INSTALL=1 ;; 
    "g" ) GIT_NEXTDOM_URL="${OPTARG}" 
		  NEXTDOM_TYPE_INSTALL=2 ;; 
    "b" ) GIT_NEXTDOM_BRANCHE="${OPTARG}" ;;
	*	) echo "Option invalide"
		usage
		exit 1;; 
    esac
done
fi

if { [ "${GIT_NEXTDOM_URL}" != "NA" ] || [ "${GIT_NEXTDOM_BRANCHE}" != "NA"  ]; } && [ "${APT_INSTALL_TYPE}" != "NA" ]; then
	echo "soit git soit apt mais pas les deux"
	usage
	exit 1
else 
	echo "bingo"
fi



function CHECK_APT_CONF {

	
if [ -f "${APT_NEXTDOM_CONF}" ]; then
	echo file exists
else 
	sed '/non-free/!s/main/main non-free/' /etc/apt/sources.list
	CHECK_RETURN_KO "${?}" "Probleme lors de la modification /etc/apt/sources.list"
	wget -qO -  http://debian.nextdom.org/debian/nextdom.gpg.key  | apt-key add - 
	echo "deb  http://debian.nextdom.org/debian  nextdom main" >/etc/apt/sources.list.d/nextdom.list 1> /dev/null
	CHECK_RETURN_KO "${?}" "Probleme lors de la creation du fichier : ${APT_NEXTDOM_CONF}"
fi
}




function DEL_NEXTDOM_DIR {
    rm -Rf ${NEXTDOM_LOG} 2>/dev/null
	CHECK_RETURN_KO "${?}" "Probleme lors de la suppression du repertoire : ${NEXTDOM_LOG}"
    echo "Dossier /var/log/nextdom* supprimé"

    rm -Rf ${NEXTDOM_LIB} 2>/dev/null
	CHECK_RETURN_KO "${?}" "Probleme lors de la suppression du repertoire : ${NEXTDOM_LIB}"
    echo "Dossier /var/lib/nextdom* supprimé"

    rm -Rf ${NEXTDOM_HTML} 2>/dev/null
	CHECK_RETURN_KO "${?}" "Probleme lors de la suppression du repertoire : ${NEXTDOM_HTML}"
    echo "Dossier /var/www/html* supprimé"

    rm -Rf ${NEXTDOM_SHARE} 2>/dev/null
	CHECK_RETURN_KO "${?}" "Probleme lors de la suppression du repertoire : ${NEXTDOM_SHARE}"
    echo "Dossier /usr/share/nextdom* supprimé"

    rm -Rf ${NEXTDOM_TMP} 2>/dev/null
	CHECK_RETURN_KO "${?}" "Probleme lors de la suppression du repertoire : ${NEXTDOM_TMP}"
    echo "Suppression du dossier tmp nextdom"
}

function cleannxt {

    (apt purge -y nextdom && apt autoremove -y) || echo "Erreur lors de la purge de nextdom" exit 1
}

function basenxt {
	echo "Création dossier HTML"
	mkdir /var/www/html 2>/dev/null

	if [[ $1 == "-git" ]]; then
		echo ""
		echo "..:: Installation via GIT ::.."
		echo ""
    elif [[ $1 == "-gitbr" ]]; then
		echo ""
		echo "..:: Changement de branche via GIT ::.."
		echo ""
	else
		echo ""
		echo "..:: Installation via APT ::.."
		echo ""
	fi

	apt update
	apt install -y software-properties-common gnupg wget ca-certificates
	sed '/non-free/!s/main/main non-free/' /etc/apt/sources.list
	wget -qO -  http://debian.nextdom.org/debian/nextdom.gpg.key  | apt-key add -
	echo "deb  http://debian.nextdom.org/debian  nextdom main" >/etc/apt/sources.list.d/nextdom.list
	apt update
	set -e
	apt -y install nextdom-common
}

if [[ $1 == "-git" ]]; then
	DEL_NEXTDOM_DIR
	cleannxt
	basenxt "$1"

	cd ${NEXTDOM_HTML} || { echo "Echec de deplacement dans le dossier : "${NEXTDOM_HTML}; exit 1; }
	git clone  https://github.com/NextDom/nextdom-core .
	git config core.fileMode false
	./install/postinst
fi

if [[ "$1" == "-apt" ]]; then
	DEL_NEXTDOM_DIR
	cleannxt
	basenxt "$1"

	if [ "$2" == "" ]; then
		echo " installation de NextDom via APT sur le dépôts officiel"
		echo "deb  http://debian.nextdom.org/debian  nextdom main" >/etc/apt/sources.list.d/nextdom.list
		apt update
		apt install -y nextdom
	fi

	if [ "$2" == "-d" ]; then
		echo " installation de NextDom via APT sur le dépôts dev"
		echo "deb  http://debian-dev.nextdom.org/debian  nextdom main" >/etc/apt/sources.list.d/nextdom.list
		apt update
		apt install -y nextdom
	fi

	if [ "$2" == "-n" ]; then
		echo " installation de NextDom via APT sur le dépôts dev"
		echo "deb  http://debian-nightly.nextdom.org/debian  nextdom main" >/etc/apt/sources.list.d/nextdom.list
		apt update
		apt install -y nextdom
	fi
fi

if [[ $1 == "-gitbr" ]]; then
	DEL_NEXTDOM_DIR
	cleannxt
	basenxt "$1"

	cd ${NEXTDOM_HTML} || { echo "Echec de deplacement dans le dossier : "${NEXTDOM_HTML}; exit 1; }
	git clone  https://github.com/NextDom/nextdom-core .
	git config core.fileMode false
	echo "passage à la branche " "$2"
	git checkout "$2"
	git reset --hard origin/"$2"
	./install/postinst
fi



exit 