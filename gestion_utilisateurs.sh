#!/bin/bash

# Chemin vers le fichier des utilisateurs
USER_FILE="users.txt"

# Fonction pour générer un mot de passe aléatoire
generate_password() {
    openssl rand -base64 12
}

# Fonction pour ajouter ou modifier un utilisateur
manage_user() {
    username=$1
    group=$2
    shell=$3
    home_dir=$4

    # Vérifier si le groupe existe, sinon le créer
    if ! getent group "$group" > /dev/null; then
        echo "Création du groupe $group..."
        groupadd "$group"
    fi

    # Vérifier si l'utilisateur existe déjà
    if id "$username" &>/dev/null; then
        echo "Modification de l'utilisateur $username..."
        usermod -g "$group" -s "$shell" -d "$home_dir" "$username"
    else
        echo "Ajout de l'utilisateur $username..."
        useradd -g "$group" -s "$shell" -d "$home_dir" -m "$username"

        # Générer un mot de passe aléatoire
        password=$(generate_password)
        echo "$username:$password" | chpasswd

        # Expiration automatique du mot de passe (doit être modifié au premier login)
        chage -d 0 "$username"

        echo "Mot de passe pour $username: $password"
    fi
}

# Vérifier si le fichier des utilisateurs existe
if [ ! -f "$USER_FILE" ]; then
    echo "Le fichier $USER_FILE est introuvable!"
    exit 1
fi

# Lire le fichier utilisateur ligne par ligne
while IFS=: read -r username group shell home_dir; do
    if [[ -n "$username" && -n "$group" && -n "$shell" && -n "$home_dir" ]]; then
        manage_user "$username" "$group" "$shell" "$home_dir"
    else
        echo "Format de ligne incorrect : $username, $group, $shell, $home_dir"
    fi
done < "$USER_FILE"

echo "Gestion des utilisateurs terminée."
