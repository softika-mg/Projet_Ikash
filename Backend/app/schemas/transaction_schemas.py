from datetime import datetime
from typing import Optional
from uuid import UUID
from pydantic import BaseModel
from app.models.enums import OperatorType, TransactionType, TransactionStatus


class TransactionCreate(BaseModel):
    # Schéma d'entrée pour la création d'une transaction
    operateur: Optional[OperatorType] = None
    type: TransactionType
    montant: float
    statut: Optional[TransactionStatus] = TransactionStatus.REUSSI
    bonus: Optional[float] = 0
    numero_client: Optional[str] = None
    reference: str
    est_saisie_manuelle: Optional[bool] = True
    agent_id: Optional[UUID] = None


class TransactionRead(TransactionCreate):
    id_transaction: UUID
    horodatage: datetime

    class Config:
        from_attributes = True
