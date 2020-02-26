#!/bin/bash

#2020-01-08 : v1.8 : ajout compatibilité RPI
#2020-01-05 : v1.7 : Correction Typo
#2019-12-30 : v1.6 : mise en place de fonction
#2019-11-26 : v1.5 : correction de l'ordre d'installation des dépendances.
#2019-11-25 : v1.3 : ajout dépôt pour install git + clé
VERSION_SCRIPT="V2.0_RC2"

NEXTDOM_DIR_LOG="/var/log/nextdom"
NEXTDOM_DIR_LIB="/var/lib/nextdom"
NEXTDOM_DIR_HTML="/var/www/html"
NEXTDOM_DIR_SHARE="/usr/share/nextdom"
NEXTDOM_DIR_TMP="/tmp/nextdom"
NEXTDOM_DIR_ARCHIVE="NA"
NEXTDOM_REMOVE_ALL="NO"
NEXTDOM_RESTORE_BCKP="NO"
NEXTDOM_TYPE_INSTALL="NA"

APT_INSTALL_TYPE="NA"
APT_NEXTDOM_CONF="/etc/apt/sources.list.d/nextdom.list"
APT_NEXTDOM_DEPOT_OFI="http://debian.nextdom.org/debian"
APT_NEXTDOM_DEPOT_NGT="http://debian-nightly.nextdom.org/debian"
APT_NEXTDOM_DEPOT_DEV="http://debian-dev.nextdom.org/debian"

GIT_NEXTDOM_URL="NA"
GIT_NEXTDOM_BRANCHE="NA"
GIT_SWITCH_BRANCHE="NA"

OS_RELEASE="/etc/os-release"

##TODO Ameliorer detection systeme
##TODO Ameliorer la fonction suppression des repertoires

function CHECK_RETURN_KO() {

    # Function. Parameter 1 is the return code
    # Para. 2 is text to display on failure.
    if [ "${1}" -ne "0" ]; then
        echo "ERROR # ${1} : ${2}"
        # as a bonus, make our script exit with the right error code.
        exit "${1}"
    fi
}

function usage() {
clear
COLUMNS=$(tput cols)

printf "%*s\n" $(((100 + COLUMNS)/2)) "****************************************************************************************************"
printf "%*s\n" $(((100 + COLUMNS)/2)) "*                                      NextDom Installer Tool                                      *"
printf "%*s\n" $(((100 + COLUMNS)/2)) "*                                             ${VERSION_SCRIPT}                                             *"
printf "%*s\n" $(((100 + COLUMNS)/2)) "****************************************************************************************************"

printf "%*s\n" $(((100 + COLUMNS)/2)) "****************************************************************************************************"
printf "%*s\n" $(((100 + COLUMNS)/2)) "*                                           Utilisation                                            *"
printf "%*s\n" $(((100 + COLUMNS)/2)) "*                                                                                                  *"
printf "%*s\n" $(((100 + COLUMNS)/2)) "*  NextDom_Installer.sh -a OFI|NGT|DEV -g url_github -b BRANCHE -s BRANCHE -r YES -i CHEMIN_BACKUP *"
printf "%*s\n" $(((100 + COLUMNS)/2)) "*     -a) : Installation via apt pour les depots Officiels (OFI), dev (DEV), et nightly (NGT)      *"
printf "%*s\n" $(((100 + COLUMNS)/2)) "*  NextDom_Installer.sh -a OFI -r YES -i /home/toto/archive.tar.gz                                 *"
printf "%*s\n" $(((100 + COLUMNS)/2)) "*     -g & -b ) : Indique l url github du projet et de la branche a installer                      *"
printf "%*s\n" $(((100 + COLUMNS)/2)) "*  NextDom_Installer.sh -g https://github.com/NextDom/nextdom-core.git -b master                   *"
printf "%*s\n" $(((100 + COLUMNS)/2)) "*     -s) : La branche du projet sur laquelle l utilisateur veut switcher                          *"
printf "%*s\n" $(((100 + COLUMNS)/2)) "*  NextDom_Installer.sh -s Develop                                                                 *"
printf "%*s\n" $(((100 + COLUMNS)/2)) "*     -r) : Suppression de tout les composants Nextdom et data                                     *"
printf "%*s\n" $(((100 + COLUMNS)/2)) "*  NextDom_Installer.sh -r YES                                                                     *"
printf "%*s\n" $(((100 + COLUMNS)/2)) "*     -i) : Restauration de backup                                                                 *"
printf "%*s\n" $(((100 + COLUMNS)/2)) "*  NextDom_Installer.sh -i /home/toto/archive.tar.gz                                               *"
printf "%*s\n" $(((100 + COLUMNS)/2)) "*     -? ou -help : Affiche l'aide et quitter                                                      *"
printf "%*s\n" $(((100 + COLUMNS)/2)) "****************************************************************************************************"

}

function INIT_NEXTDOM_ENV() {

    apt update
    apt install -y software-properties-common gnupg wget ca-certificates
    sed '/non-free/!s/main/main non-free/' /etc/apt/sources.list
    CHECK_RETURN_KO "${?}" "Problème lors de la modification /etc/apt/sources.list"
    wget -qO - http://debian.nextdom.org/debian/nextdom.gpg.key | apt-key add -
    echo "deb ${1} nextdom main" >/etc/apt/sources.list.d/nextdom.list
    CHECK_RETURN_KO "${?}" "Problème lors de la creation du fichier : ${APT_NEXTDOM_CONF}"
    CHECK_RASPBIAN
    apt update
    set -e
    apt -y install nextdom-common
}

function CHECK_APT_CONF() {

    apt update
    apt install -y software-properties-common gnupg wget ca-certificates
    sed '/non-free/!s/main/main non-free/' /etc/apt/sources.list
    CHECK_RETURN_KO "${?}" "Problème lors de la modification /etc/apt/sources.list"
    wget -qO - http://debian.nextdom.org/debian/nextdom.gpg.key | apt-key add -
    echo "deb ${1} nextdom main" >/etc/apt/sources.list.d/nextdom.list
    CHECK_RETURN_KO "${?}" "Problème lors de la creation du fichier : ${APT_NEXTDOM_CONF}"
    CHECK_RASPBIAN
    apt update
    CHECK_RETURN_KO "${?}" "Problème lors de l'apt update"
}

function CHECK_RASPBIAN() {

    if [ -f "${OS_RELEASE}" ]; then

        if [ "$(grep -w VERSION_ID ${OS_RELEASE})" == "VERSION_ID=\"10\"" ] && [ "$(grep -w ID ${OS_RELEASE})" == "ID=raspbian" ]; then

            wget -q https://ftp-master.debian.org/keys/release-10.asc -O- | apt-key add -
            echo "deb http://deb.debian.org/debian buster non-free" >>/etc/apt/sources.list
            CHECK_RETURN_KO "${?}" "Problème lors de la mise a jour des depots dans : /etc/apt/sources.list"

        else
            if [ "$(grep -w VERSION_ID ${OS_RELEASE})" == "VERSION_ID=\"10\"" ] && [ "$(grep -w ID ${OS_RELEASE})" == "ID=debian" ]; then
                echo "OS : DEBIAN"
            fi
        fi
    else
        echo "impossible de detecter la version du systeme ==> Installation Debian"
    fi

}

function INSTALL_NEXTDOM_OFI() {

    apt install -y nextdom
}

function INSTALL_NEXTDOM_NGT() {

    apt install -y nextdom
}

function INSTALL_NEXTDOM_DEV() {

    apt install -y nextdom
}

function INSTALL_NEXTDOM_GIT() {

    if [ -d "${NEXTDOM_DIR_HTML}" ]; then
        rm -Rf "${NEXTDOM_DIR_HTML}"
        CHECK_RETURN_KO "${?}" "Problème lors de la suppression du repertoire ${NEXTDOM_DIR_HTML}"
    fi

    git clone --single-branch --branch "${GIT_NEXTDOM_BRANCHE}" "${GIT_NEXTDOM_URL}" "${NEXTDOM_DIR_HTML}"
    CHECK_RETURN_KO "${?}" "Problème lors du git clone pour la branche ${GIT_NEXTDOM_BRANCHE}, du depot ${GIT_NEXTDOM_URL}"
    git config --global core.fileMode false
    bash "${NEXTDOM_DIR_HTML}"/install/postinst
    CHECK_RETURN_KO "${?}" "Problème lors du postinstall"
}

function NEXTDOM_SWITCH_BRANCHE() {

    if [ -d "${NEXTDOM_DIR_HTML}" ]; then
        rm -Rf "${NEXTDOM_DIR_HTML}"
        CHECK_RETURN_KO "${?}" "Problème lors de la suppression du repertoire ${NEXTDOM_DIR_HTML}"
    fi

    git clone --single-branch --branch "${GIT_NEXTDOM_BRANCHE}" "${GIT_NEXTDOM_URL}" "${NEXTDOM_DIR_HTML}"
    git config --global core.fileMode false
    echo "passage à la branche " "${GIT_NEXTDOM_BRANCHE}"
    git checkout --path "${NEXTDOM_DIR_HTML}"/ "${GIT_NEXTDOM_BRANCHE}"
    git reset --hard --path "${NEXTDOM_DIR_HTML}"/ origin/"${GIT_NEXTDOM_BRANCHE}"
    bash "${NEXTDOM_DIR_HTML}"/install/postinst

}

function DEL_NEXTDOM_DIR() {

    for RM_NEXTDOM_DIR in ${NEXTDOM_DIR_LOG} ${NEXTDOM_DIR_LIB} ${NEXTDOM_DIR_HTML} ${NEXTDOM_DIR_SHARE}; do
        if [ -d ${RM_NEXTDOM_DIR} ]; then
            rm -Rf ${RM_NEXTDOM_DIR}
            CHECK_RETURN_KO "${?}" "Problème lors de la suppression du repertoire : ${RM_NEXTDOM_DIR}"
            echo "Repertoire  ${RM_NEXTDOM_DIR} : supprime"

        fi
    done

    if [ -d ${NEXTDOM_DIR_TMP} ]; then
        rm -Rf "${NEXTDOM_DIR_TMP:?}"/*
        echo "Repertoire  ${NEXTDOM_DIR_TMP} : supprime"

    fi

}

function REMOVE_NEXTDOM_APT() {

    (apt purge -y nextdom nextdom-common && apt autoremove -y)
    CHECK_RETURN_KO "${?}" "Problème lors de la suppression des packets nextdom et de leurs dépendances"

}

function RESTORE_BACKUP_CHECK_ARCHIVE() {

    if [[ "${NEXTDOM_DIR_ARCHIVE:0:1}" == / ]]; then
        if [ "${NEXTDOM_DIR_ARCHIVE: -7}" != ".tar.gz" ]; then
            echo "veuillez indiquer une archive valide (ie : /home/toto/Mon_Backup.tar.gz)"
            usage
            exit
        else
            if [ ! -e "${NEXTDOM_DIR_ARCHIVE}" ]; then
                echo "Le fichier ${NEXTDOM_DIR_ARCHIVE} n'existe pas"
                usage
                exit
            fi
        fi
    else
        usage
        exit
    fi

}

function RESTORE_BACKUP_NEXTDOM() {

    sudo -u www-data php ${NEXTDOM_DIR_HTML}/install/restore.php file="${NEXTDOM_DIR_ARCHIVE}"
    CHECK_RETURN_KO "${?}" "Problème lors de la restauration du backup"

}

if [ "${NEXTDOM_REMOVE_ALL}" = "YES" ]; then

    REMOVE_NEXTDOM_APT
    DEL_NEXTDOM_DIR
fi

if [ -z "$1" ]; then
    usage
    exit
else
    while getopts a:g:b:s:r:i: options; do
        case ${options} in
        "a")
            APT_INSTALL_TYPE="${OPTARG}"
            NEXTDOM_TYPE_INSTALL="APT"
            ;;
        "g")
            GIT_NEXTDOM_URL="${OPTARG}"
            NEXTDOM_TYPE_INSTALL="GIT"
            ;;
        "b")
            GIT_NEXTDOM_BRANCHE="${OPTARG}"
            ;;
        "s")
            GIT_SWITCH_BRANCHE="${OPTARG}"
            NEXTDOM_TYPE_INSTALL="SWITCH"
            ;;
        "r")
            NEXTDOM_REMOVE_ALL="${OPTARG}"
            ;;
        "i")
            NEXTDOM_DIR_ARCHIVE="${OPTARG}"
            RESTORE_BACKUP_CHECK_ARCHIVE
            NEXTDOM_RESTORE_BCKP="YES"
            ;;
        *)
            echo "Option invalide"
            usage
            exit 1
            ;;
        esac
    done
fi

# CHECK SI CHOIX APT & GIT NE SONT PAS VALORISES
if { [ "${GIT_NEXTDOM_URL}" != "NA" ] || [ "${GIT_NEXTDOM_BRANCHE}" != "NA" ]; } && [ "${APT_INSTALL_TYPE}" != "NA" ]; then
    echo "soit git soit apt mais pas les deux"
    usage
    exit 1
fi
CHECK_RETURN_KO "${?}" "Problème lors de la verification des variables APT et GIT"

# CHECK SI CHOIX GIT & SWITCH NE SONT PAS VALORISES
if { [ "${GIT_NEXTDOM_URL}" != "NA" ] || [ "${GIT_NEXTDOM_BRANCHE}" != "NA" ]; } && [ "${GIT_SWITCH_BRANCHE}" != "NA" ]; then
    echo "soit git soit switch"
    usage
    exit 1
fi
CHECK_RETURN_KO "${?}" "Problème lors de la verification des variables GIT et Switch"

# CHECK SI CHOIX APT & SWITCH NE SONT PAS VALORISES
if [ "${APT_INSTALL_TYPE}" != "NA" ] && [ "${GIT_SWITCH_BRANCHE}" != "NA" ]; then
    echo "soit apt soit switch"
    usage
    exit 1
fi
CHECK_RETURN_KO "${?}" "Problème lors de la verification des variables APT et Switch"

if [ "$NEXTDOM_REMOVE_ALL" = "YES" ]; then

    REMOVE_NEXTDOM_APT
    DEL_NEXTDOM_DIR
fi

case "${NEXTDOM_TYPE_INSTALL}" in
APT)
    case "${APT_INSTALL_TYPE}" in
    OFI | Ofi | ofi)
        CHECK_APT_CONF "${APT_NEXTDOM_DEPOT_OFI}"
        INSTALL_NEXTDOM_OFI
        ;;
    DEV | Dev | dev)
        CHECK_APT_CONF "${APT_NEXTDOM_DEPOT_DEV}"
        INSTALL_NEXTDOM_DEV
        ;;
    NGT | Ngt | ngt)
        CHECK_APT_CONF "${APT_NEXTDOM_DEPOT_NGT}"
        INSTALL_NEXTDOM_NGT
        ;;
    *)
        echo "apt ko"
        ;;
    esac

    ;;
GIT)
    INIT_NEXTDOM_ENV "${APT_NEXTDOM_DEPOT_OFI}"
    INSTALL_NEXTDOM_GIT
    ;;
SWITCH)
    INIT_NEXTDOM_ENV "${APT_NEXTDOM_DEPOT_OFI}"
    NEXTDOM_SWITCH_BRANCHE
    ;;
*)

    echo "default"
    ;;
esac

if [ "${NEXTDOM_RESTORE_BCKP}" = "YES" ]; then

    RESTORE_BACKUP_NEXTDOM
fi

exit
