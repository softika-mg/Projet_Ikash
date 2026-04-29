from sqlmodel import SQLModel, Field
from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4
from sqlmodel import Relationship
from typing import Optional, TYPE_CHECKING


from .enums import OperatorType, TransactionType, TransactionStatus

if TYPE_CHECKING:
    from .profile import Profile

class Transaction(SQLModel, table=True):
    __tablename__ = "transactions"

    # Identifiant de transaction auto-généré
    id_transaction: Optional[UUID] = Field(default_factory=uuid4, primary_key=True)

    # Date et heure d'enregistrement de la transaction
    horodatage: datetime = Field(default_factory=datetime.utcnow)

    # Données métier liées à la transaction Mobile Money
    operateur: OperatorType
    type: TransactionType
    montant: float
    statut: TransactionStatus = Field(default=TransactionStatus.REUSSI)

    # Informations complémentaires
    bonus: float = Field(default=0)
    numero_client: Optional[str] = None

    # Référence unique pour dédoublonnage
    reference: str = Field(unique=True, index=True)
    est_saisie_manuelle: bool = Field(default=True)

    # Liaison vers l'agent qui a effectué la transaction
    agent_id: Optional[UUID] = Field(default=None, foreign_key="profiles.id")
    agent: Optional["Profile"] = Relationship(back_populates="agent_transactions")
