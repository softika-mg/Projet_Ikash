import unittest
from app.utils.sms_parser import parse_mobile_money_sms
from app.models.enums import TransactionType


class TestSmsParser(unittest.TestCase):
    def test_parse_depot_sms(self):
        sms = "Montant 50000 Ar Ref ABC123 Telma 0341234567"
        parsed = parse_mobile_money_sms(sms)
        self.assertIsNotNone(parsed)
        self.assertEqual(parsed["montant"], 50000.0)
        self.assertEqual(parsed["reference"], "ABC123")
        self.assertEqual(parsed["type"], TransactionType.DEPOT)
        self.assertEqual(parsed["operateur"].value, "TELMA")
        self.assertEqual(parsed["numero_client"], "0341234567")

    def test_parse_transfert_sms(self):
        sms = "Transfert de 12000 Ar Ref TST001 Orange 0349876543"
        parsed = parse_mobile_money_sms(sms)
        self.assertIsNotNone(parsed)
        self.assertEqual(parsed["type"], TransactionType.TRANSFERT)
        self.assertEqual(parsed["reference"], "TST001")
        self.assertEqual(parsed["operateur"].value, "ORANGE")

    def test_parse_unknown_sms_returns_none(self):
        sms = "Bonjour, ceci est un message sans transaction."
        parsed = parse_mobile_money_sms(sms)
        self.assertIsNone(parsed)
