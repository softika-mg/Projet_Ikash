import re
from typing import Optional, Dict


class IKashLogicParser:
    def __init__(self):
        # On utilise [\d\s]+ pour capturer les montants comme "195 000"
        self.patterns = {
            "DEPOT": r"Depot de Ar(?P<montant>[\d\s]+).*ID:(?P<ref>[\w\.]+)",
            "TRANSFERT": r"(?P<montant>[\d\s]+)\s?Ar envoye a (?P<client>.*?) \((?P<phone>\d+)\).* Ref: (?P<ref>\d+)",
            "RECEPTION": r"(?P<montant>[\d\s]+)\s?Ar recu de .* Ref: (?P<ref>\d+)",
            "CREDIT": r"credite .* de (?P<montant>[\d\s]+)\s?Ar .* Ref: (?P<ref>\d+)",
        }

    def clean_amount(self, raw_amount: str) -> float:
        """Nettoie les espaces et convertit en nombre."""
        return float(raw_amount.replace(" ", "").replace("\xa0", ""))

    def parse(self, sms_text: str) -> Optional[Dict]:
        text = " ".join(sms_text.split())

        # Dispatcher (Identification du type)
        op_type = None
        if "Depot de" in text:
            op_type = "DEPOT"
        elif "envoye a" in text:
            op_type = "TRANSFERT"
        elif "recu de" in text:
            op_type = "RECEPTION"
        elif "credite" in text:
            op_type = "CREDIT"

        if not op_type:
            return None

        match = re.search(self.patterns[op_type], text, re.IGNORECASE)
        if match:
            data = match.groupdict()
            return {
                "operation": op_type,
                "montant": self.clean_amount(data["montant"]),
                "reference": data["ref"],
            }
        return None


# --- LE TESTEUR ---
if __name__ == "__main__":
    parser = IKashLogicParser()

    # Tes exemples réels Telma
    sms_test = [
        "Depot de Ar20000 pour ARMAND RAKOTONDRANAIVO *38054332.Commission 208 Ar.Solde Ar170771.5 ID:CI251216.1022.C11191",
        "38 000 Ar envoye a LANTONIRINA (0348503254) le 16/12/25 a 17:20. Frais: 300 Ar. Raison: 2. Solde : 92 324 Ar. Ref: 878012262",
        "195 000 Ar recu de marieflavienne (0341376615) le 16/12/25 a 17:24. Solde : 951 656 Ar. Ref: 878179170",
        "Vous avez credite Mahatradraibe Basile Tarson(0385771148) de 500 000 Ar le 16/12/25 a 16:19. Solde : 749 382 Ar. Ref: 875254271",
    ]

    print(f"\n{'OPÉRATION':<12} | {'MONTANT':<10} | {'RÉFÉRENCE':<15}")
    print("-" * 45)

    for sms in sms_test:
        res = parser.parse(sms)
        if res:
            print(
                f"{res['operation']:<12} | {res['montant']:<10.0f} | {res['reference']:<15} ✅"
            )
        else:
            print(f"ÉCHEC sur : {sms[:30]}... ❌")
