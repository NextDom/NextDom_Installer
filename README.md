# NextDom_Installer

Script to automaticaly install NextDom from APT or GIT

Be carreful, it will wipe all previous data and backup of NextDom

To run :

 `$ wget https://raw.githubusercontent.com/NextDom/NextDom_Installer/master/NextDom_Installer.sh`  
 `$ sudo chmod +x NextDom_Installer.sh`  
 `$ sudo ./NextDom_Installer.sh -opt -arg`  

Type -? or -help to know how use it

V2.0 beta : USE A OWN RISK !!!!! :20200128

- Refonte globale du script
- utilisation de variable globale pour faciliter la maintenabilité
- Changement de l'appel du script:
.NextDom_Installer.sh -a OFI|NGT|DEV -g url_github -b BRANCHE -s BRANCHE -r YES -i CHEMIN_BACKUP
 -a) : Installation via apt pour les depots Officiels (OFI), dev (DEV), et nigthly (NGT)
 -g & -b ) : Indique l url github du projet et de la branche a installer
 -s) : Branche du projet sur laquelle l utilisateur veut switcher
 -r) : Suppression de tout les composants Nextdom et data (Comming Soon)
 -i) : Restauration de backup (Coming Soon)

v1.8 : 20200108 : Add RPI compatibility  
V1.7 : 20200106 : Correction typo par GiDom  
V1.6 : 20191230 : Transformation en fonctions par iWils  
