from typing import List

# Ensemble d'exemples de SMS pour entraîner le classificateur
X_train: List[str] = [
    # Dépôts
    "Montant de 20000 Ar reçu sur votre compte",
    "Dépôt effectué de 15000 Ar",
    "Vous avez reçu 50000 Ar",
    "Depot confirmé pour 3000 Ar",
    "Versement de 12000 Ar réussi",

    # Retraits
    "Retrait de 10000 Ar effectué",
    "Retrait autorisé à 0341234567",
    "Argent retiré avec succès",
    "Demande de retrait 5000 Ar",
    "Retrait du compte validé",

    # Crédits
    "Crédit de 25000 Ar appliqué",
    "Votre crédit de 18000 Ar est disponible",
    "Ligne de crédit mise à jour",
    "Achat en crédit de 15000 Ar",
    "Crédit ajouté sur votre compte",

    # Transferts
    "Transfert de 20000 Ar vers 0349876543",
    "Argent envoyé à LANTO",
    "Transfert confirmé",
    "Envoi de fonds vers le numéro suivant",
    "Transfert vers un autre compte réussi",

    # Messages personnels
    "Bonjour, peux-tu me rappeler ?",
    "Merci pour ton aide, à bientôt",
    "Rendez-vous demain à 14h",
    "Je t'envoie un message personnel",
    "Ceci n'est pas une transaction",
]

y_train: List[str] = [
    # Dépôts
    "DEPOT",
    "DEPOT",
    "DEPOT",
    "DEPOT",
    "DEPOT",

    # Retraits
    "RETRAIT",
    "RETRAIT",
    "RETRAIT",
    "RETRAIT",
    "RETRAIT",

    # Crédits
    "CREDIT",
    "CREDIT",
    "CREDIT",
    "CREDIT",
    "CREDIT",

    # Transferts
    "TRANSFERT",
    "TRANSFERT",
    "TRANSFERT",
    "TRANSFERT",
    "TRANSFERT",

    # Messages personnels
    "PERSONNEL",
    "PERSONNEL",
    "PERSONNEL",
    "PERSONNEL",
    "PERSONNEL",
]
