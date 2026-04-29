import joblib
from pathlib import Path


class IkashClassifier:
    """Charge et exécute le modèle de classification de SMS iKash."""

    def __init__(self):
        model_path = Path(__file__).resolve().parent / "ikash_model.pkl"
        if model_path.exists():
            try:
                self.model = joblib.load(model_path)
            except Exception as exc:
                self.model = None
                print(
                    f"Erreur : impossible de charger le modèle iKash ({exc}). "
                    "Lancez model_trainer.py ou installez scikit-learn."
                )
        else:
            self.model = None
            print("Erreur : Le modèle iKash n'existe pas. Lancez model_trainer.py d'abord.")

    def predict_category(self, text: str):
        """Prédit la catégorie du SMS si le modèle est chargé."""
        if not self.model:
            return None
        return self.model.predict([text])[0]
