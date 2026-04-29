from sqlmodel import SQLModel, Field, Relationship
from typing import Optional
from uuid import UUID, uuid4
from datetime import datetime


class LogActivite(SQLModel, table=True):
    """Table de journalisation des actions administratives et agents."""
    __tablename__ = "logs_activites"

    id: UUID = Field(default_factory=uuid4, primary_key=True)

    # Liens vers les profils
    admin_id: Optional[UUID] = Field(default=None, foreign_key="profiles.id")
    agent_id: Optional[UUID] = Field(default=None, foreign_key="profiles.id")

    action: str  # ex: 'MODIFICATION_SOLDE', 'CHANGEMENT_ROLE'
    ancien_solde: Optional[float] = None
    nouveau_solde: Optional[float] = None

    horodatage: datetime = Field(default_factory=datetime.utcnow)

    # Optionnel : Relations pour faciliter les jointures en Python
    # admin: Optional["Profile"] = Relationship()
    # agent: Optional["Profile"] = Relationship()
