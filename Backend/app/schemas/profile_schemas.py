from datetime import datetime
from typing import Optional
from uuid import UUID
from pydantic import BaseModel
from app.models.enums import RoleType


class ProfileCreate(BaseModel):
    # Schéma d'entrée pour créer un profil
    id: UUID
    nom: str
    role: RoleType = RoleType.AGENT
    code_pin: Optional[str] = None
    solde_courant: float = 0
    admin_id: Optional[UUID] = None


class ProfileRead(ProfileCreate):
    created_at: datetime

    class Config:
        from_attributes = True


class SoldeUpdateRequest(BaseModel):
    """Payload pour ajuster le solde d'un agent et créer un log d'opération."""
    agent_id: UUID
    admin_id: UUID
    montant: float
    action_description: str = "Ajustement manuel du solde"
