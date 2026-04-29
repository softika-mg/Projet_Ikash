import re
from typing import Optional, Dict
from app.models.enums import OperatorType, TransactionType


def parse_mobile_money_sms(sms_text: str) -> Optional[Dict]:
    """Analyse un texte de SMS Mobile Money et retourne les champs extraits."""
    sms_text = sms_text.replace("\n", " ").strip()
    lower_text = sms_text.lower()

    montant_pattern = r"(?:montant[:\s]+)?(\d+[\d\s\.]*)\s?(?:ar|mga)?"
    montant_match = re.search(montant_pattern, sms_text, re.IGNORECASE)

    ref_pattern = r"(?:ref[:\s]+|transaction\s*id[:\s]+|id[:\s]+)([A-Z0-9]+)"
    ref_match = re.search(ref_pattern, sms_text, re.IGNORECASE)

    operator_pattern = r"\b(telma|airt?el|orange)\b"
    operator_match = re.search(operator_pattern, sms_text, re.IGNORECASE)
    operator = None
    if operator_match:
        operator_value = operator_match.group(1).upper()
        if operator_value == "AIRTEL":
            operator = OperatorType.AIRTEL
        elif operator_value == "TELMA":
            operator = OperatorType.TELMA
        elif operator_value == "ORANGE":
            operator = OperatorType.ORANGE
        else:
            operator = OperatorType.AUTRE

    client_pattern = r"(\+?261\s?3[2348][\d\s\.]+|03[2348][\d\s\.]+)"
    client_match = re.search(client_pattern, sms_text)
    numero_client = None
    if client_match:
        # Normalise le numéro malgache en supprimant les espaces et points
        numero_client = client_match.group(0).replace(" ", "").replace(".", "")

    if montant_match and ref_match:
        raw_montant = montant_match.group(1).replace(" ", "").replace(".", "")
        montant = float(raw_montant)

        if "retrait" in lower_text or "retir" in lower_text:
            transaction_type = TransactionType.RETRAIT
        elif "transfert" in lower_text or "envoy" in lower_text:
            transaction_type = TransactionType.TRANSFERT
        elif "credit" in lower_text or "crédit" in lower_text:
            transaction_type = TransactionType.CREDIT
        else:
            transaction_type = TransactionType.DEPOT

        return {
            "montant": montant,
            "reference": ref_match.group(1),
            "type": transaction_type,
            "operateur": operator,
            "numero_client": numero_client,
            "est_saisie_manuelle": False,
        }

    return None
