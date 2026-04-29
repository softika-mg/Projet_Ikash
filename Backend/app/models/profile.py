from typing import Optional, List
from uuid import UUID
from sqlmodel import SQLModel, Field, Relationship
from datetime import datetime
from .enums import RoleType
from typing import Optional, List, TYPE_CHECKING

if TYPE_CHECKING:
    from .transaction import Transaction


class Profile(SQLModel, table=True):
    __tablename__ = "profiles"

    # Identifiant unique du profil (UUID)
    id: UUID = Field(primary_key=True)
    nom: str

    # Rôle de l'utilisateur : ADMIN ou AGENT
    role: str = Field(default=RoleType.AGENT.value)

    # Code PIN optionnel pour l'authentification mobile
    code_pin: Optional[str] = None

    # Solde courant de l'agent
    solde_courant: float = Field(default=0)

    # Date de création du profil
    created_at: datetime = Field(default_factory=datetime.utcnow)

    # Administrateur lié dans le modèle multi-tenancy
    admin_id: Optional[UUID] = Field(default=None, foreign_key="profiles.id")

    # Relations ORM : un profil peut avoir plusieurs transactions
    agent_transactions: List["Transaction"] = Relationship(back_populates="agent")
