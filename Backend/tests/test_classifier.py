import unittest
from app.core.brain.classifier import IkashClassifier


class TestIkashClassifier(unittest.TestCase):
    def setUp(self):
        self.classifier = IkashClassifier()

    def test_classifie_depot(self):
        text = "Montant de 25000 Ar reçu sur votre compte"
        self.assertEqual(self.classifier.predict_category(text), "DEPOT")

    def test_classifie_retrait(self):
        text = "Retrait de 10000 Ar effectué"
        self.assertEqual(self.classifier.predict_category(text), "RETRAIT")

    def test_classifie_credit(self):
        text = "Crédit de 15000 Ar appliqué"
        self.assertEqual(self.classifier.predict_category(text), "CREDIT")

    def test_classifie_transfert(self):
        text = "Transfert de 20000 Ar vers 0349876543"
        self.assertEqual(self.classifier.predict_category(text), "TRANSFERT")

    def test_classifie_personnel(self):
        text = "Bonjour, peux-tu me rappeler demain ?"
        self.assertEqual(self.classifier.predict_category(text), "PERSONNEL")
