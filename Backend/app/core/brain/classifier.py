import joblib


class IkashClassifier:
    def __init__(self):
        # On charge le cerveau qu'on a créé avec le trainer
        try:
            self.model = joblib.load("app/core/brain/ikash_model.pkl")
        except:
            print("Erreur : Le modèle n'existe pas. Lancez model_trainer.py d'abord.")

    def predict_category(self, text: str):
        # L'IA nous donne la catégorie probable
        return self.model.predict([text])[0]
