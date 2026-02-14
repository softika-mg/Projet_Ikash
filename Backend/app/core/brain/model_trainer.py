import joblib  # Pour sauvegarder le "cerveau" une fois entraîné
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import make_pipeline

# 1. Préparation des données d'entraînement
X_train = [
    "Depot de Ar 20000",
    " Depot reçu",
    "Confirmation de depot",
    "envoye a LANTO",
    "transfert vers le numero",
    "Ar envoye",
    "recu de marie",
    "argent recu",
    "vous avez reçu",
]
y_train = [
    "DEPOT",
    "DEPOT",
    "DEPOT",
    "TRANSFERT",
    "TRANSFERT",
    "TRANSFERT",
    "RECEPTION",
    "RECEPTION",
    "RECEPTION",
]

# 2. Création du modèle
# TfidfVectorizer transforme le texte en poids statistiques (quels mots sont importants)
model = make_pipeline(TfidfVectorizer(), MultinomialNB())

# 3. Entraînement
model.fit(X_train, y_train)

# 4. Sauvegarde pour le dossier brain
joblib.dump(model, "app/core/brain/ikash_model.pkl")
print("Cerveau iKash entraîné et sauvegardé ! ")
