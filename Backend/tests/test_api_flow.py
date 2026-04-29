import os
import unittest
import uuid
from fastapi.testclient import TestClient
from app.main import app
from app import database
from app.database import create_db_engine, create_db_and_tables


class TestApiFlow(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        os.environ["API_SECRET_KEY"] = "testkey"
        database.engine = create_db_engine("sqlite:///:memory:", echo=False)
        create_db_and_tables(database.engine)
        cls.client = TestClient(app)
        cls.headers = {"X-API-KEY": "testkey"}
        cls.profile_id = str(uuid.uuid4())
        payload = {
            "id": cls.profile_id,
            "nom": "Agent Test",
            "role": "AGENT",
            "code_pin": "1234",
            "solde_courant": 1000.0,
        }
        response = cls.client.post("/profiles/", json=payload, headers=cls.headers)
        assert response.status_code == 200

    def test_api_key_rejected(self):
        response = self.client.get("/transactions/", headers={"X-API-KEY": "badkey"})
        self.assertEqual(response.status_code, 403)

    def test_profile_created(self):
        response = self.client.get("/profiles/", headers=self.headers)
        self.assertEqual(response.status_code, 200)
        self.assertGreaterEqual(len(response.json()), 1)

    def test_transaction_creation(self):
        payload = {
            "operateur": "TELMA",
            "type": "DEPOT",
            "montant": 500.0,
            "reference": "TXREF1",
            "agent_id": self.profile_id,
        }
        response = self.client.post("/transactions/", json=payload, headers=self.headers)
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["reference"], "TXREF1")
        self.assertEqual(data["montant"], 500.0)

    def test_duplicate_transaction_reference(self):
        payload = {
            "operateur": "TELMA",
            "type": "DEPOT",
            "montant": 500.0,
            "reference": "DUPREF1",
            "agent_id": self.profile_id,
        }
        response = self.client.post("/transactions/", json=payload, headers=self.headers)
        self.assertEqual(response.status_code, 200)
        duplicate_response = self.client.post("/transactions/", json=payload, headers=self.headers)
        self.assertEqual(duplicate_response.status_code, 400)
        self.assertIn("erreur", duplicate_response.json()["detail"].lower())

    def test_sms_receive_route(self):
        sms_text = "Montant 12000 Ar Ref SMS000 Telma 0349876543"
        response = self.client.post("/sms/receive", json={"text": sms_text}, headers=self.headers)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["status"], "success")
