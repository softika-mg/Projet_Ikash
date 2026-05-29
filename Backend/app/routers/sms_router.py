from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session
from app.database import get_session
from app.services import sms_services
from app.security.get_api_key import get_api_key
from app.schemas.sms_schemas import SmsClassificationReport, SmsReceiveRequest

# Routeur pour la réception et le traitement des SMS entrants
router = APIRouter(prefix="/sms", tags=["SMS Receiver"])


@router.post("/receive")
async def receive_and_parse_sms(
    payload: SmsReceiveRequest,
    session: Session = Depends(get_session),
    api_key: str = Depends(get_api_key),
):
    """Reçoit un SMS au format JSON et tente de l'enregistrer comme transaction."""
    try:
        sms_text = payload.text
        return sms_services.process_incoming_sms(session, sms_text)
    except Exception as e:
        raise HTTPException(
            status_code=400, detail=f"Erreur lors du traitement SMS : {str(e)}"
        )


@router.post("/report", response_model=SmsClassificationReport)
async def get_sms_classification_report(
    payload: SmsReceiveRequest,
    api_key: str = Depends(get_api_key),
):
    """Génère un rapport de classification SMS sans enregistrer de transaction."""
    try:
        return sms_services.generate_sms_report(payload.text)
    except Exception as e:
        raise HTTPException(
            status_code=400, detail=f"Erreur lors de la génération du rapport : {str(e)}"
        )
