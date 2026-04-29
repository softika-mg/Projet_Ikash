from sqlmodel import Session, select
from app.models import Transaction


def create_transaction(session: Session, transaction_data: Transaction):
    """Enregistre une transaction en base de données."""
    session.add(transaction_data)
    session.commit()
    session.refresh(transaction_data)
    return transaction_data


def get_all_transactions(session: Session):
    """Récupère toutes les transactions enregistrées."""
    statement = select(Transaction)
    return session.exec(statement).all()
