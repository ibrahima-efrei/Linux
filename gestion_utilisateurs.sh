#!/bin/bash
a
# Fichier d'utilisateur
USER_FILE="users.txt"
INACTIVITY_DAYS=90
BACKUP_DIR="/backup/users"

# --- Fonction de gestion des utilisateurs (ajout/modification) ---
generate_password() {
    openssl rand -base64 12
}

manage_user() {
    username=$1
    group=$2
    shell=$3
    home_dir=$4

    if ! getent group "$group" > /dev/null; then
        echo "Création du groupe $group..."
        groupadd "$group"
    fi

    if id "$username" &>/dev/null; then
        echo "Modification de l'utilisateur $username..."
        usermod -g "$group" -s "$shell" -d "$home_dir" "$username"
    else
        echo "Ajout de l'utilisateur $username..."
        useradd -g "$group" -s "$shell" -d "$home_dir" -m "$username"

        password=$(generate_password)
        echo "$username:$password" | chpasswd
        chage -d 0 "$username"

        echo "Mot de passe pour $username: $password"
    fi
}

if [ ! -f "$USER_FILE" ]; then
    echo "Le fichier $USER_FILE est introuvable!"
    exit 1
fi

while IFS=: read -r username group shell home_dir; do
    if [[ -n "$username" && -n "$group" && -n "$shell" && -n "$home_dir" ]]; then
        manage_user "$username" "$group" "$shell" "$home_dir"
    else
        echo "Format de ligne incorrect : $username, $group, $shell, $home_dir"
    fi
done < "$USER_FILE"

echo "Gestion des utilisateurs ajout/modification terminée."

# --- Fonction de gestion des utilisateurs inactifs (suppression/verrouillage) ---
find_inactive_users() {
    echo "Recherche des utilisateurs inactifs depuis plus de $INACTIVITY_DAYS jours..."
    lastlog -b $INACTIVITY_DAYS | awk 'NR>1 && $NF!="Never" {print $1}'
}

backup_home_directory() {
    username=$1
    home_dir="/home/$username"
    
    if [ -d "$home_dir" ]; then
        echo "Sauvegarde du répertoire personnel de l'utilisateur $username..."
        mkdir -p "$BACKUP_DIR"
        tar -czf "$BACKUP_DIR/${username}_home_backup.tar.gz" "$home_dir"
        echo "Sauvegarde terminée : $BACKUP_DIR/${username}_home_backup.tar.gz"
    else
        echo "Le répertoire personnel de $username n'existe pas ou a déjà été supprimé."
    fi
}

lock_user() {
    username=$1
    echo "Verrouillage du compte de $username..."
    passwd -l "$username"
}

delete_user() {
    username=$1
    backup_home_directory "$username"
    echo "Suppression de l'utilisateur $username..."
    userdel -r "$username"
    echo "Utilisateur $username supprimé avec succès."
}

manage_inactive_users() {
    inactive_users=$(find_inactive_users)

    if [ -z "$inactive_users" ]; then
        echo "Aucun utilisateur inactif trouvé."
        exit 0
    fi

    for username in $inactive_users; do
        echo "Utilisateur inactif détecté : $username"
        echo "Souhaitez-vous verrouiller (l) ou supprimer (s) cet utilisateur ? (l/s)"
        read -r choice

        case "$choice" in
            l|L)
                lock_user "$username"
                ;;
            s|S)
                delete_user "$username"
                ;;
            *)
                echo "Choix invalide. Passer à l'utilisateur suivant."
                ;;
        esac
    done
}

# --- Lancer la gestion des utilisateurs inactifs ---
manage_inactive_users

echo "Gestion des utilisateurs inactifs terminée."
