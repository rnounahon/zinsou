#!/bin/bash
#Bash script qui creer un fichier et l'envoie sur un serveur
NOW=$(date +"%H%M%S")
HOST="vagrant@192.168.33.11:/home/vagrant"
cd 
touch fichier_client_$NOW
scp fichier_client_$NOW  $HOST
exit
