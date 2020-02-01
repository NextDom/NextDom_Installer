#!/bin/bash

#2020-01-08 : v1.8 : ajout compatibilité RPI
#2020-01-05 : v1.7 : Correction Typo
#2019-12-30 : v1.6 : mise en place de fonction
#2019-11-26 : v1.5 : correction de l'ordre d'installation des dépendances.
#2019-11-25 : v1.3 : ajout dépôt pour install git + clé
VERSION_SCRIPT="V2.0 BETA USE AT OWN RISK"

NEXTDOM_DIR_LOG="/var/log/nextdom"
NEXTDOM_DIR_LIB="/var/lib/nextdom"
NEXTDOM_DIR_HTML="/var/www/html"
NEXTDOM_DIR_SHARE="/usr/share/nextdom"
NEXTDOM_DIR_TMP="/tmp/nextdom"
NEXTDOM_DIR_ARCHIVE="NA"
NEXTDOM_REMOVE_ALL="NO"
NEXTDOM_RESTORE_BCKP="NO"
NEXTDOM_TYPE_INSTALL="0"

APT_INSTALL_TYPE="NA"
APT_NEXTDOM_CONF="/etc/apt/sources.list.d/nextdom.list"
APT_NEXTDOM_DEPOT_OFI="http://debian.nextdom.org/debian"
APT_NEXTDOM_DEPOT_NGT="http://debian-nightly.nextdom.org/debian"
APT_NEXTDOM_DEPOT_DEV="http://debian-dev.nextdom.org/debian"

GIT_NEXTDOM_URL="NA"
GIT_NEXTDOM_BRANCHE="NA"
GIT_SWITCH_BRANCHE="NA"

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

    echo ""
    echo "		 NextDom Installer tool " ${VERSION_SCRIPT}
    echo ""
    echo ""
    echo "	NextDom_Installer.sh -a OFI|NGT|DEV -g url_github -b BRANCHE -s BRANCHE -r YES -i CHEMIN_BACKUP"
    echo ""
    echo "		-a) : Installation via apt pour les depots Officiels (OFI), dev (DEV), et nigthly (NGT)"
    echo "		-g & -b ) : Indique l url github du projet et de la branche a installer"
    echo "		-s) : La branche du projet sur laquelle l utilisateur veut switcher"
    echo "      -r) : Suppression de tout les composants Nextdom et data (Comming Soon)"
    echo "      -i) : Restauration de backup (Coming Soon)"
    echo ""
    echo "		-? ou -help				: Affiche l'aide et quitter"

}

function INIT_NEXDOM_ENV() {
    apt update
    apt install -y software-properties-common gnupg wget ca-certificates
    sed '/non-free/!s/main/main non-free/' /etc/apt/sources.list
    CHECK_RETURN_KO "${?}" "Probleme lors de la modification /etc/apt/sources.list"
    wget -qO - http://debian.nextdom.org/debian/nextdom.gpg.key | apt-key add -
    echo "deb ${1} nextdom main" >/etc/apt/sources.list.d/nextdom.list
    CHECK_RETURN_KO "${?}" "Probleme lors de la creation du fichier : ${APT_NEXTDOM_CONF}"
    apt update
    set -e
    apt -y install nextdom-common
}

function CHECK_APT_CONF() {
    apt update
    apt install -y software-properties-common gnupg wget ca-certificates
    sed '/non-free/!s/main/main non-free/' /etc/apt/sources.list
    CHECK_RETURN_KO "${?}" "Probleme lors de la modification /etc/apt/sources.list"
    wget -qO - http://debian.nextdom.org/debian/nextdom.gpg.key | apt-key add -
    echo "deb ${1} nextdom main" >/etc/apt/sources.list.d/nextdom.list
    CHECK_RETURN_KO "${?}" "Probleme lors de la creation du fichier : ${APT_NEXTDOM_CONF}"
    apt update
    CHECK_RETURN_KO "${?}" "Probleme lors de l'apt update"
}

function INSTALL_NEXTDOM_OFI() {
    set -e
    apt install -y nextdom
}
function INSTALL_NEXTDOM_NGT() {
    set -e
    apt install -y nextdom
}
function INSTALL_NEXTDOM_DEV() {
    set -e
    apt install -y nextdom
}

function INSTALL_NEXTDOM_GIT() {
    git clone --single-branch --branch "${GIT_NEXTDOM_BRANCHE}" "${GIT_NEXTDOM_URL}" "${NEXTDOM_DIR_HTML}"
    CHECK_RETURN_KO "${?}" "Probleme lors du git clone pour la branche ${GIT_NEXTDOM_BRANCHE}, du depot ${GIT_NEXTDOM_URL}"
    git config --global core.fileMode false
    bash "${NEXTDOM_DIR_HTML}"/install/postinst
    CHECK_RETURN_KO "${?}" "Probleme lors du postinstall"
}

function NEXTDOM_SWITCH_BRANCHE() {
    git clone --single-branch --branch "${GIT_NEXTDOM_BRANCHE}" "${GIT_NEXTDOM_URL}" "${NEXTDOM_DIR_HTML}"
    git config --global core.fileMode false
    echo "passage à la branche " "${GIT_NEXTDOM_BRANCHE}"
    git checkout --path "${NEXTDOM_DIR_HTML}"/ "${GIT_NEXTDOM_BRANCHE}"
    git reset --hard --path "${NEXTDOM_DIR_HTML}"/ origin/"${GIT_NEXTDOM_BRANCHE}"
    bash "${NEXTDOM_DIR_HTML}"/install/postinst
}

function DEL_NEXTDOM_DIR() {

    for RM_NEXTDOM_DIR in ${NEXTDOM_DIR_LOG} ${NEXTDOM_DIR_LIB} ${NEXTDOM_DIR_HTML} ${NEXTDOM_DIR_SHARE} ${NEXTDOM_DIR_TMP}; do
        if [ -d ${RM_NEXTDOM_DIR} ]; then
            rm -Rf ${RM_NEXTDOM_DIR}
            echo "Repertoire  ${RM_NEXTDOM_DIR} : supprime"
            CHECK_RETURN_KO "${?}" "Probleme lors de la suppression du repertoire : ${RM_NEXTDOM_DIR}"
        fi
    done
}

function REMOVE_NEXTDOM_APT() {

    (apt purge -y nextdom nextdom-common && apt autoremove -y)
    CHECK_RETURN_KO "${?}" "Probleme lors de la suppression des packets nextdom et de leurs dependances"
}

function RESTORE_BACKUP_CHECK_ARCHIVE() {
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
}
function RESTORE_BACKUP_NEXTDOM() {

    sudo -u www-data php ${NEXTDOM_DIR_HTML}/install php file="${NEXTDOM_DIR_ARCHIVE}"
    CHECK_RETURN_KO "${?}" "Probleme lors de la restauration du backup"
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
            NEXTDOM_TYPE_INSTALL=1
            ;;
        "g")
            GIT_NEXTDOM_URL="${OPTARG}"
            NEXTDOM_TYPE_INSTALL=2
            ;;
        "b")
            GIT_NEXTDOM_BRANCHE="${OPTARG}"
            ;;
        "s")
            GIT_SWITCH_BRANCHE="${OPTARG}"
            NEXTDOM_TYPE_INSTALL=3
            ;;
        "r")
            NEXTDOM_REMOVE_ALL="${OPTARG}"
            ;;
        "i")
            RESTORE_BACKUP_CHECK_ARCHIVE
            NEXTDOM_RESTORE_BCKP="${OPTARG}"
            NEXTDOM_DIR_ARCHIVE="${OPTARG}"
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
CHECK_RETURN_KO "${?}" "Probleme lors de la verification des variables APT et GIT"

# CHECK SI CHOIX GIT & SWITCH NE SONT PAS VALORISES
if { [ "${GIT_NEXTDOM_URL}" != "NA" ] || [ "${GIT_NEXTDOM_BRANCHE}" != "NA" ]; } && [ "${GIT_SWITCH_BRANCHE}" != "NA" ]; then
    echo "soit git soit switch"
    usage
    exit 1
fi
CHECK_RETURN_KO "${?}" "Probleme lors de la verification des variables GIT et Switch"

# CHECK SI CHOIX APT & SWITCH NE SONT PAS VALORISES
if [ "${APT_INSTALL_TYPE}" != "NA" ] && [ "${GIT_SWITCH_BRANCHE}" != "NA" ]; then
    echo "soit apt soit switch"
    usage
    exit 1
fi
CHECK_RETURN_KO "${?}" "Probleme lors de la verification des variables APT et Switch"

if [ "$NEXTDOM_REMOVE_ALL" = "YES" ]; then

    REMOVE_NEXTDOM_APT
    DEL_NEXTDOM_DIR
fi

case "${NEXTDOM_TYPE_INSTALL}" in
1)
    case "${APT_INSTALL_TYPE}" in
    OFI)
        CHECK_APT_CONF "${APT_NEXTDOM_DEPOT_OFI}"
        INSTALL_NEXTDOM_OFI
        ;;
    DEV)
        CHECK_APT_CONF "${APT_NEXTDOM_DEPOT_DEV}"
        INSTALL_NEXTDOM_DEV
        ;;
    NGT)
        CHECK_APT_CONF "${APT_NEXTDOM_DEPOT_NGT}"
        INSTALL_NEXTDOM_NGT
        ;;
    *)
        echo "apt ko"
        ;;
    esac

    ;;
2)
    INIT_NEXDOM_ENV "${APT_NEXTDOM_DEPOT_OFI}"
    INSTALL_NEXTDOM_GIT
    ;;
3)
    INIT_NEXDOM_ENV "${APT_NEXTDOM_DEPOT_OFI}"
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
