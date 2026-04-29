from fastapi import APIRouter, Depends, Query
from sqlmodel import Session, select
from app.models.log import LogActivite
from app.security.get_api_key import get_api_key
from app.database import get_session
from typing import List, Optional
from uuid import UUID

router = APIRouter(prefix="/logs", tags=["Logs"])


@router.get("/", response_model=List[LogActivite])
def get_logs(
    admin_id: Optional[UUID] = None,
    limit: int = Query(default=100, le=500),
    api_key: str = Depends(get_api_key),
    session: Session = Depends(get_session),
):
    # Requête de base pour récupérer les logs récents
    statement = (
        select(LogActivite).order_by(LogActivite.horodatage.desc()).limit(limit)
    )

    if admin_id:
        statement = statement.where(LogActivite.admin_id == admin_id)

    return session.exec(statement).all()
