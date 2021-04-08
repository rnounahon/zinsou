#!/bin/bash
#Chercher les fichier lourds dans la racines
find / -xdev -type f -size +1G -exec ls -lh {} \;
