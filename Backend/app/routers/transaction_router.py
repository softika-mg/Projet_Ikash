from fastapi import APIRouter, Depends, HTTPException
from typing import List
from sqlmodel import Session
from app.database import get_session
from app.models import Transaction
from app.services import transaction_service
from app.security.get_api_key import get_api_key
from app.schemas.transaction_schemas import TransactionCreate, TransactionRead

# Routeur pour gérer les transactions Mobile Money
router = APIRouter(prefix="/transactions", tags=["Transactions"])


@router.post("/", response_model=TransactionRead)
def add_transaction(
    transaction: TransactionCreate,
    session: Session = Depends(get_session),
    api_key: str = Depends(get_api_key),
):
    """Crée une transaction à partir des données validées."""
    try:
        transaction_obj = Transaction(**transaction.model_dump(exclude_none=True))
        return transaction_service.create_transaction(session, transaction_obj)
    except Exception as e:
        raise HTTPException(
            status_code=400, detail=f"Erreur lors de l'ajout : {str(e)}"
        )


@router.get("/", response_model=List[TransactionRead])
def list_transactions(
    session: Session = Depends(get_session), api_key: str = Depends(get_api_key)
):
    """Retourne toutes les transactions enregistrées en base."""
    return transaction_service.get_all_transactions(session)
