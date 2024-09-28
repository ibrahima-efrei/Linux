#!/bin/bash

# Définir les répertoires partagés
dir_rh="/chemin/vers/repertoire_rh"
dir_direction="/chemin/vers/repertoire_direction"

# Groupe RH avec seulement la permission de lecture (read only)
# On attribue la permission de lecture pour les fichiers déjà existants
setfacl -m g:RH:r-- "$dir_rh"

# Ici, on applique les permissions par défaut pour tous les nouveaux fichiers 
# Le groupe RH pourra seulement lire les fichiers qui seront créés plus tard
setfacl -d -m g:RH:r-- "$dir_rh"

# Groupe Direction avec permissions de lecture et écriture (read + write)
# On permet ici aux membres du groupe 'direction' de lire et écrire
setfacl -m g:direction:rw- "$dir_direction"

# Comme avant, on applique ces permissions par défaut pour les nouveaux fichiers
setfacl -d -m g:direction:rw- "$dir_direction"

# Fin du script 😎
echo "ACL configurées pour les groupes RH et Direction !"