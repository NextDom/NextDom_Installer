#!/bin/bash

#2019-12-30 : v1.6 : mise en place de fonction
#2019-11-26 : v1.5 : correction de l'ordre d'installation des dépendances.
#2019-11-25 : v1.3 : ajout dépôt pour install git + clé

if [[ $1 == "" ]]; then
    echo
    echo " Usage: "$0" [-git] installation de NextDom via GitClone"
    echo " Usage: "$0" [-apt] installation de NextDom via un paquet Deb"
    echo " 			[  ] installation depuis le dépôt officel"
    echo " 			[-d] installation du paquet depuis le dépôt dev"
    echo " 			[-n] installation du paquet depuis le dépôt nightly"
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
    apt purge -y nextdom
    apt autoremove -y
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
	add-apt-repository non-free
	wget -qO -  http://debian.nextdom.org/debian/nextdom.gpg.key  | apt-key add -
	echo "deb  http://debian.nextdom.org/debian  nextdom main" >/etc/apt/sources.list.d/nextdom.list
	apt update
	apt -y install nextdom-common
}

if [[ $1 == "-git" ]]; then
	cleanfld
	cleannxt
	basenxt $1

	cd /var/www/html/
	git clone  https://github.com/NextDom/nextdom-core .
	git config core.fileMode false
	./install/postinst
fi

if [[ $1 == "-apt" ]]; then
	cleanfld
	cleannxt
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
	cleanfld
	cleannxt
	basenxt $1

	cd /var/www/html
	git clone  https://github.com/NextDom/nextdom-core .
	git config core.fileMode false
	echo "passage à la branche " $2
	git checkout $2
	git reset --hard origin/$2
	./install/postinst
fi

if [[ $1 == "-?" ]] || [[ $1 == "-help" ]]; then
		echo ""
		echo "N A I T v1.6"
		echo ""
		echo "Nextdom Auto Installer Tool"
		echo "Developed by the Great Master of Nextdom tEsTs, alias the great @GiDom"
		echo "with a little help from the appreciative padawan tester, @vinceg77"
		echo ""
		echo "Utilisation : nait [OPTION]"
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
