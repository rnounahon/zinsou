#!/bin/bash
#Chercher les fichier lourds dans la racines
echo "vous aurez les fichiers de plus de 1GB"
find / -xdev -type f -size +1G -exec ls -lh {} \;
