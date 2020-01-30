#!/bin/bash

#2020-01-08 : v1.9a : on purge avant la suppression des dossiers
#2020-01-08 : v1.9 : modification chemin pour tirage des sources
#2020-01-08 : v1.8 : ajout compatibilité RPI
#2020-01-05 : v1.7 : Correction Typo
#2019-12-30 : v1.6 : mise en place de fonction
#2019-11-26 : v1.5 : correction de l'ordre d'installation des dépendances.
#2019-11-25 : v1.3 : ajout dépôt pour install git + clé

if [[ $1 == "" ]]; then
    echo
    echo " Usage: "$0" [-git] installation de NextDom via GitClone"
    echo " Usage: "$0" [-apt] installation de NextDom via un paquet Deb"
    echo " 	       [-apt]	[  ] installation depuis le dépôt officiel"
    echo " 	       [-apt]	[-d] installation du paquet depuis le dépôt dev"
    echo " 	       [-apt]	[-n] installation du paquet depuis le dépôt nightly"
    echo
fi

function cleanfld {
    rm -Rf /var/log/nextdom* 2>/dev/null
    echo "Dossier /var/log/nextdom* supprimé"

    rm -Rf /var/lib/nextdom* 2>/dev/null
    echo "Dossier /var/lib/nextdom* supprimé"

    rm -Rf /var/www/html* 2>/dev/null
    echo "Dossier /var/www/html* supprimé"

    rm -Rf /usr/share/nextdom* 2>/dev/null
    echo "Dossier /usr/share/nextdom* supprimé"

    rm -Rf /tmp/nextdom/* 2>/dev/null
    echo "Suppression du dossier tmp nextdom"
}

function cleannxt {
    apt purge -y nextdom*
    apt autoremove -y
}

function basenxt {
	echo "Création dossier NextDom"
	mkdir /usr/share/nextdom 2>/dev/null

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
	apt -y install nextdom-common
}

if [[ $1 == "-git" ]]; then
	cleannxt
	cleanfld
	basenxt $1

	cd /usr/share/nextdom
	git clone  https://github.com/NextDom/nextdom-core .
	git config core.fileMode false
	./install/postinst
fi

if [[ $1 == "-apt" ]]; then
	cleannxt
	cleanfld
	basenxt $1

	if [ $2 == "" ]; then
		echo " installation de NextDom via APT sur le dépôts officiel"
		echo "deb  http://debian.nextdom.org/debian  nextdom main" >/etc/apt/sources.list.d/nextdom.list
		apt update
		apt install -y nextdom
	fi

	if [ $2 == "-d" ]; then
		echo " installation de NextDom via APT sur le dépôts dev"
		echo "deb  http://debian-dev.nextdom.org/debian  nextdom main" >/etc/apt/sources.list.d/nextdom.list
		apt update
		apt install -y nextdom
	fi

	if [ $2 == "-n" ]; then
		echo " installation de NextDom via APT sur le dépôts dev"
		echo "deb  http://debian-nightly.nextdom.org/debian  nextdom main" >/etc/apt/sources.list.d/nextdom.list
		apt update
		apt install -y nextdom
	fi
fi

if [[ $1 == "-gitbr" ]]; then
	cleannxt
	cleanfld
	basenxt $1

	cd /usr/share/nextdom
	git clone  https://github.com/NextDom/nextdom-core .
	git config core.fileMode false
	echo "passage à la branche " $2
	git checkout $2
	git reset --hard origin/$2
	./install/postinst
fi

if [[ $1 == "-?" ]] || [[ $1 == "-help" ]]; then
		echo ""
		echo "NextDom Installer tool v1.9"
		echo ""
		echo ""
		echo "		-apt		: Installation via apt, dépôt officiel"
		echo "		-apt -n		: version nightly"
		echo "		-apt -d		: version dépôt develop"
		echo ""
		echo "		-git		: Installation via git"
		echo ""
		echo "		-gitbr NOM_DE_LA_BRANCHE	: Changement de branche git"
		echo ""
		echo "		-? ou -help	: afficher l'aide et quitter"
fi

exit 
