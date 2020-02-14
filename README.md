
# NextDom_Installer

[![CodeFactor](https://www.codefactor.io/repository/github/therealcorwin/nextdom_installer/badge)](https://www.codefactor.io/repository/github/therealcorwin/nextdom_installer)

Script to automaticaly install NextDom from APT or GIT

To run :

 `$ wget https://raw.githubusercontent.com/NextDom/NextDom_Installer/Therealcorwin/NextDom_Installer.sh | chmod 750 NextDom_Installer.sh`
 
 `$ sudo ./NextDom_Installer.sh -opt arg -opt2 arg2 -opt3 arg3`  

V2.0 RC1 : 20201402

V2.0 beta : USE A OWN RISK !!!!! :20200128

- Refonte globale du script
- utilisation de variable globale pour faciliter la maintenabilité
- 
- Changement de l'appel du script:

NextDom_Installer.sh -a OFI|NGT|DEV -g url_github -b BRANCHE -s BRANCHE -r YES -i /home/toto/monbackup.tar.gz

 -a) : Installation via apt pour les depots Officiels (OFI), dev (DEV), et nigthly (NGT)
 
 -g & -b ) : Indique l url github du projet et de la branche a installer
 
 -s) : Branche du projet sur laquelle l utilisateur veut switcher
 
 -r) : Suppression de tout les composants Nextdom et data
 
 -i) : Restauration de backup

Type -? or -help to know how use it

v1.8 : 20200108 : Add RPI compatibility  
V1.7 : 20200106 : Correction typo par GiDom  
V1.6 : 20191230 : Transformation en fonctions par iWils  
