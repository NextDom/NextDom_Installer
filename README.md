
# NextDom_Installer

[![CodeFactor](https://www.codefactor.io/repository/github/therealcorwin/nextdom_installer/badge)](https://www.codefactor.io/repository/github/therealcorwin/nextdom_installer)

Script to automaticaly install NextDom from APT or GIT

To run :



 `$ sudo ./NextDom_Installer.sh -opt arg -opt2 arg2 -opt3 arg3`  

V2.0 RC1 : 20201402

V2.0 beta : USE AT YOUR OWN RISK !!!!! :20200128

- Refonte globale du script
- utilisation de variable globale pour faciliter la maintenabilité
- Commentaire du code
- Changement de l'appel du script:

NextDom_Installer.sh -a OFI|NGT|DEV -g url_github -b BRANCHE -s BRANCHE -r YES -i /home/toto/monbackup.tar.gz

 -a) : Installation via apt pour les depots Officiels (OFI), dev (DEV), et nigthly (NGT)

 NextDom_Installer.sh -a OFI -r YES -i /home/toto/archive.tar.gz

 -g & -b ) : Indique l url github du projet et de la branche a installer

 NextDom_Installer.sh -g <https://github.com/NextDom/nextdom-core.git> -b master  

 -s) : Branche du projet sur laquelle l utilisateur veut switcher

 NextDom_Installer.sh -s Develop

 -r) : Suppression de tout les composants Nextdom et data

 NextDom_Installer.sh -r YES

 -i) : Restauration de backup

 NextDom_Installer.sh -i /home/toto/archive.tar.gz  

Type -? or -help to know how use it

v1.8 : 20200108 : Add RPI compatibility  
V1.7 : 20200106 : Correction typo par GiDom  
V1.6 : 20191230 : Transformation en fonctions par iWils  
