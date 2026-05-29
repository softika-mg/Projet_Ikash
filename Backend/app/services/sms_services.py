from app.utils.sms_parser import parse_mobile_money_sms
from app.models import Transaction
from app.services import transaction_service
from app.core.brain import IkashClassifier
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session

# Classificateur ML optionnel pour analyser la catégorie des SMS
classifier = IkashClassifier()


def handle_incoming_sms(sms_text: str):
    """Analyse un SMS sans l'enregistrer en base de données."""
    parsed_data = parse_mobile_money_sms(sms_text)
    category = classifier.predict_category(sms_text)

    if parsed_data:
        return {"status": "parsed", "category": category, "data": parsed_data}

    return {"status": "error", "message": "Format inconnu", "category": category}


def generate_sms_report(sms_text: str):
    """Génère un rapport de classification et d'analyse SMS sans enregistrer en base."""
    parsed_data = parse_mobile_money_sms(sms_text)
    classification = classifier.predict_category(sms_text)

    if parsed_data:
        return {
            "status": "parsed",
            "message": "SMS analysé avec succès.",
            "category": classification,
            "parsed_data": parsed_data,
            "text": sms_text,
        }

    return {
        "status": "error",
        "message": "Format SMS inconnu.",
        "category": classification,
        "parsed_data": None,
        "text": sms_text,
    }


# Service complet pour traiter et enregistrer le SMS
def process_incoming_sms(session: Session, sms_text: str):
    parsed_data = parse_mobile_money_sms(sms_text)
    classification = classifier.predict_category(sms_text)

    if not parsed_data:
        return {"status": "error", "message": "Format SMS inconnu", "classification": classification}

    if "reference" not in parsed_data or not parsed_data.get("reference"):
        return {
            "status": "error",
            "message": "Format SMS reconnu, mais référence manquante.",
            "classification": classification,
            "parsed_data": parsed_data,
        }

    try:
        new_transaction = Transaction(**parsed_data)
        db_transaction = transaction_service.create_transaction(session, new_transaction)
        return {
            "status": "success",
            "message": "Transaction enregistrée",
            "classification": classification,
            "data": db_transaction,
            "transaction_id": str(db_transaction.id_transaction),
        }
    except IntegrityError:
        session.rollback()
        return {
            "status": "error",
            "message": "Transaction déjà enregistrée pour cette référence",
            "classification": classification,
        }
    except Exception as e:
        session.rollback()
        return {"status": "error", "message": f"Échec de création : {str(e)}", "classification": classification}
