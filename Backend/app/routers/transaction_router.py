from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session
from app.database import engine
from app.models import Transaction
from app.services import transaction_service
from app.security.get_api_key import get_api_key

router = APIRouter(prefix="/transactions", tags=["Transactions"])


# Dépendance pour obtenir la session de la DB
def get_session():
    with Session(engine) as session:
        yield session


@router.post("/", response_model=Transaction)
def add_transaction(transaction: Transaction, session: Session = Depends(get_session), api_key: str = Depends(get_api_key)):
    try:
        return transaction_service.create_transaction(session, transaction)
    except Exception as e:
        # On utilise f"" pour injecter la variable str(e)
        raise HTTPException(
            status_code=400, detail=f"Erreur lors de l'ajout : {str(e)}"
        )


@router.get("/")
def list_transactions(
    session: Session = Depends(get_session), api_key: str = Depends(get_api_key)
):
    return transaction_service.get_all_transactions(session)
