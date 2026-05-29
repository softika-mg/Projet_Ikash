import re
from pathlib import Path
from typing import Optional

try:
    import joblib
except ImportError:
    joblib = None


class IkashClassifier:
    """Classificateur de texte iKash pour détecter le type de message."""

    MODEL_FILENAME = "ikash_model.pkl"
    CATEGORY_PERSONNEL = "PERSONNEL"

    def __init__(self):
        self.model = None
        self.model_path = Path(__file__).resolve().parent / self.MODEL_FILENAME
        self._load_model()

    def _load_model(self):
        if self.model_path.exists() and joblib is not None:
            try:
                self.model = joblib.load(self.model_path)
            except Exception as exc:
                self.model = None
                print(
                    f"Erreur : impossible de charger le modèle iKash ({exc}). "
                    "Le fallback règles sera utilisé."
                )
        else:
            self.model = None
            if joblib is None:
                print("joblib non installé : fallback règles activé.")
            else:
                print("Modèle iKash introuvable : fallback règles activé.")

    def predict_category(self, text: str) -> Optional[str]:
        """Retourne la catégorie détectée pour un texte de SMS."""
        if not text:
            return self.CATEGORY_PERSONNEL

        normalized = self._normalize_text(text)

        if self.model is not None:
            try:
                prediction = self.model.predict([normalized])[0]
                return str(prediction)
            except Exception as exc:
                print(f"Erreur de prédiction modèle : {exc}")

        return self._predict_by_keywords(normalized)

    def _normalize_text(self, text: str) -> str:
        # Mise en minuscules et suppression des caractères indésirables.
        text = text.lower().strip()
        return re.sub(r"[^a-z0-9àâäéèêëîïôöùûüç\s]+", " ", text)

    def _predict_by_keywords(self, text: str) -> str:
        """Fallback simple basé sur des mots-clés français.

        Cette méthode est utilisée lorsque le modèle ML n'est pas chargé ou en cas d'erreur.
        """
        if self._is_personal_message(text):
            return self.CATEGORY_PERSONNEL
        if self._contains_credit(text):
            return "CREDIT"
        if self._contains_withdrawal(text):
            return "RETRAIT"
        if self._contains_transfer(text):
            return "TRANSFERT"
        if self._contains_deposit(text):
            return "DEPOT"
        if self._contains_transaction_indicators(text):
            return "DEPOT"
        return self.CATEGORY_PERSONNEL

    def _contains_deposit(self, text: str) -> bool:
        return any(
            keyword in text
            for keyword in [
                "dépot",
                "depot",
                "reçu",
                "recu",
                "versement",
                "déposé",
                "depose",
                "montant",
                "payé",
                "payee",
            ]
        )

    def _contains_withdrawal(self, text: str) -> bool:
        return any(
            keyword in text
            for keyword in [
                "retrait",
                "retiré",
                "retire",
                "paiement",
                "payé",
                "encaissement",
            ]
        )

    def _contains_credit(self, text: str) -> bool:
        return any(keyword in text for keyword in ["crédit", "credit", "crédité", "credité"])

    def _contains_transfer(self, text: str) -> bool:
        return any(
            keyword in text
            for keyword in [
                "transfert",
                "envoyé",
                "envoye",
                "envoi",
                "vers",
                "virement",
                "envoyer",
                "transfer",
            ]
        )

    def _contains_transaction_indicators(self, text: str) -> bool:
        return any(keyword in text for keyword in ["ar", "mga", "montant", "référence", "ref", "numéro"])

    def _is_personal_message(self, text: str) -> bool:
        return any(
            keyword in text
            for keyword in [
                "bonjour",
                "salut",
                "merci",
                "rendez-vous",
                "rdv",
                "a bientôt",
                "a+",
                "coucou",
                "personnel",
                "message",
            ]
        ) and not self._contains_transaction_indicators(text)
