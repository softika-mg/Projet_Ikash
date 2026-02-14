import re
from typing import Optional, Dict


def parse_mobile_money_sms(sms_text: str) -> Optional[Dict]:
    # On nettoie un peu le texte pour éviter les problèmes de sauts de ligne
    sms_text = sms_text.replace("\n", " ").strip()

    # 1. Regex Montant : Cherche des chiffres suivis de 'Ar', 'MGA' ou précédés de 'Montant'
    # Gère : "50.000 Ar", "50000Ar", "Montant: 50000"
    montant_pattern = r"(?:Montant[:\s]+)?(\d+[\d\s\.]*)\s?(?:Ar|MGA)?"
    montant_match = re.search(montant_pattern, sms_text, re.IGNORECASE)

    # 2. Regex Référence : Cherche un code alphanumérique après 'Ref' ou 'Transaction ID'
    ref_pattern = r"(?:Ref|ID|Transaction)[:\s]+([A-Z0-9]+)"
    ref_match = re.search(ref_pattern, sms_text, re.IGNORECASE)

    # 3. Regex Expéditeur/Agent : Cherche un numéro malgache (032, 034, 033, 038)
    # Gère : "0340000000", "+261340000000", "034 00 000 00"
    sender_pattern = r"(?:de|par)\s?(\+?261)?\s?(03[2348]\s?\d{2}\s?\d{3}\s?\d{2})"
    sender_match = re.search(sender_pattern, sms_text, re.IGNORECASE)

    if montant_match and ref_match:
        # Nettoyage propre du montant
        raw_montant = montant_match.group(1).replace(" ", "").replace(".", "")
        montant = float(raw_montant)

        # Nettoyage du numéro (on garde le format standard 034...)
        raw_sender = (
            sender_match.group(2).replace(" ", "") if sender_match else "UNKNOWN"
        )

        return {
            "montant": montant,
            "reference_sms": ref_match.group(1),
            "type_op": "RECEPTION",  # On pourra affiner cela plus tard
            "agent_id": raw_sender,
            "raw_text": sms_text,  # Toujours garder l'original pour audit
        }

    return None
