#!/bin/bash

# Définir des variables pour le répertoire des rapports et l'adresse e-mail
report_dir="/chemin/vers/repertoire_rapport"
report_file="$report_dir/rapport_$(date +'%Y%m%d').txt"
email_recipient="ibrahima.djobou1@gmail.com"

# Créer le répertoire de rapport s'il n'existe pas
mkdir -p "$report_dir"

# Générer la liste des utilisateurs et des groupes
echo "=== Rapport Utilisateurs et Groupes ===" > "$report_file"
echo "" >> "$report_file"
echo "Utilisateurs :" >> "$report_file"
cut -d: -f1 /etc/passwd >> "$report_file"
echo "" >> "$report_file"
echo "Groupes :" >> "$report_file"
cut -d: -f1 /etc/group >> "$report_file"
echo "" >> "$report_file"

# Générer la liste des permissions ACL pour les répertoires partagés
echo "=== Permissions ACL ===" >> "$report_file"
echo "" >> "$report_file"
echo "Répertoire RH :" >> "$report_file"
getfacl /chemin/vers/repertoire_rh >> "$report_file"
echo "" >> "$report_file"
echo "Répertoire Direction :" >> "$report_file"
getfacl /chemin/vers/repertoire_direction >> "$report_file"
echo "" >> "$report_file"

# Détecter les utilisateurs inactifs
echo "=== Utilisateurs Inactifs ===" >> "$report_file"
inactive_users=$(lastlog | awk '$3 > 90 {print $1}') # Changer 90 par le nombre de jours
if [ -z "$inactive_users" ]; then
    echo "Aucun utilisateur inactif détecté." >> "$report_file"
else
    echo "Utilisateurs inactifs :" >> "$report_file"
    echo "$inactive_users" >> "$report_file"
    echo "" >> "$report_file"
fi

# Envoyer le rapport par e-mail
mail -s "Rapport Hebdomadaire des Utilisateurs" "$email_recipient" < "$report_file"

# Ou sauvegarder le rapport dans un fichier log
echo "Le rapport a été enregistré à : $report_file"

# Fin du script 🚀