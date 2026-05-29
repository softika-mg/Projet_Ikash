"""Entraînement et génération du modèle iKash pour la classification de SMS.

Ce module crée un pipeline de machine learning et sauvegarde le modèle entraîné
dans le fichier `ikash_model.pkl` situé dans le même dossier que ce fichier.

Lancer l'entraînement depuis le répertoire `Backend` :
    PYTHONPATH=. ./venv/bin/python app/core/brain/model_trainer.py
"""

import joblib  # Pour sauvegarder le "cerveau" une fois entraîné
from pathlib import Path
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import make_pipeline
from app.core.brain.data.training_data import X_train, y_train

try:
    import matplotlib.pyplot as plt
except ImportError:
    plt = None

MODEL_FILENAME = "ikash_model.pkl"
VISUALIZATION_FILENAME = "ikash_model.png"


def train_and_save_model(output_path: Path = None) -> Path: # type: ignore
    """Entraîne le classificateur à partir du jeu de données et l'enregistre.

    Retourne le chemin du fichier de modèle sauvegardé.
    """
    output_file = output_path or Path(__file__).resolve().parent / MODEL_FILENAME

    # Pipeline de transformation et de classification.
    # TfidfVectorizer convertit le texte en vecteurs pondérés.
    pipeline = make_pipeline(
        TfidfVectorizer(ngram_range=(1, 2), stop_words=None),
        MultinomialNB(),
    )

    # Entraînement du modèle avec les exemples et les étiquettes.
    pipeline.fit(X_train, y_train)
    joblib.dump(pipeline, output_file)
    print(f"Cerveau iKash entraîné et sauvegardé dans {output_file}")
    return output_file


def save_model_visualization(model, output_path: Path = None, top_features: int = 10) -> Path: # type: ignore
    """Génère un PNG contenant un graphique des mots importants du modèle."""
    if plt is None:
        raise ImportError(
            "matplotlib n'est pas installé. Installe-le avec 'pip install matplotlib' "
            "pour générer la visualisation PNG."
        )

    output_file = output_path or Path(__file__).resolve().parent / VISUALIZATION_FILENAME

    if not hasattr(model, "named_steps"):
        raise ValueError("Le modèle doit être un pipeline sklearn avec des étapes nommées.")

    vectorizer = model.named_steps.get("tfidfvectorizer")
    classifier = model.named_steps.get("multinomialnb")

    if vectorizer is None or classifier is None:
        raise ValueError(
            "Le pipeline doit contenir 'tfidfvectorizer' et 'multinomialnb'."
        )

    feature_names = vectorizer.get_feature_names_out()
    class_labels = classifier.classes_
    if hasattr(classifier, "coef_"):
        coef = classifier.coef_
    elif hasattr(classifier, "feature_log_prob_"):
        coef = classifier.feature_log_prob_
    else:
        raise ValueError(
            "Impossible d'extraire les poids du classificateur."
        )

    n_classes = len(class_labels)
    fig, axes = plt.subplots(n_classes, 1, figsize=(12, 3 * n_classes), squeeze=False)

    for idx, label in enumerate(class_labels):
        class_coefs = coef[idx]
        top_idx = class_coefs.argsort()[-top_features:][::-1]
        top_words = feature_names[top_idx]
        top_values = class_coefs[top_idx]

        ax = axes[idx][0]
        ax.barh(top_words[::-1], top_values[::-1], color="tab:blue")
        ax.set_title(f"Top {top_features} mots pour {label}")
        ax.set_xlabel("Coefficient")

    fig.tight_layout()
    fig.savefig(output_file) # type: ignore
    plt.close(fig)
    print(f"Visualisation enregistrée dans {output_file}")
    return output_file


def load_saved_model(model_path: Path = None): # type: ignore
    """Charge le modèle iKash sauvegardé depuis le disque."""
    model_file = model_path or Path(__file__).resolve().parent / MODEL_FILENAME
    if not model_file.exists():
        raise FileNotFoundError(f"Modèle introuvable : {model_file}")

    loaded_model = joblib.load(model_file)
    print(f"Modèle chargé depuis {model_file}")
    return loaded_model


if __name__ == "__main__":
    print("Démarrage de l'entraînement du classificateur iKash...")
    saved_model_path = train_and_save_model()
    loaded_model = load_saved_model(saved_model_path)

    try:
        visualization_path = save_model_visualization(loaded_model)
        print(f"Graphique PNG généré : {visualization_path}")
    except ImportError as exc:
        print(exc)
    except Exception as exc:
        print(f"Impossible de générer la visualisation du modèle : {exc}")

    print("Lecture du modèle entraîné terminée. Le modèle est prêt à être utilisé.")
