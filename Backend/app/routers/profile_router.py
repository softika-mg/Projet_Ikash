from fastapi import APIRouter, Depends
from sqlmodel import Session
from app.database import engine
from app.models import Profile
from typing import List
from app.services import profile_service
from app.security.get_api_key import get_api_key
from app.schemas.profile_schemas import SoldeUpdateRequest
from app.models.log import LogActivite
from fastapi import HTTPException
from app.database import get_session


router = APIRouter(prefix="/profiles", tags=["Profiles"])

# Dépendance pour obtenir la session de la DB
@router.get("/", response_model=List[Profile])
def get_profiles(api_key: str = Depends(get_api_key)):
    with Session(engine) as session:
        # Pour l'instant on renvoie tout pour tester
        return session.query(Profile).all()


# Route pour créer un nouveau profil
@router.post("/")
def create_profile(profile: Profile, api_key: str = Depends(get_api_key)):
    with Session(engine) as session:
        return profile_service.create_new_profile(session, profile)


@router.post("/ajuster-solde")
def ajuster_solde_agent(
    payload: SoldeUpdateRequest,
    session: Session = Depends(get_session),
    api_key: str = Depends(get_api_key),
):
    # 1. Récupérer l'agent
    agent = session.get(Profile, payload.agent_id)
    if not agent:
        raise HTTPException(status_code=404, detail="Agent non trouvé")

    # 2. Préparer les données pour le log
    ancien_solde = agent.solde_courant
    agent.solde_courant += payload.montant
    nouveau_solde = agent.solde_courant

    # 3. Créer l'entrée dans le log
    nouveau_log = LogActivite(
        admin_id=payload.admin_id,
        agent_id=payload.agent_id,
        action=payload.action_description,
        ancien_solde=ancien_solde,
        nouveau_solde=nouveau_solde,
    )

    # 4. Sauvegarder le tout
    session.add(agent)
    session.add(nouveau_log)
    session.commit()
    session.refresh(agent)

    return {
        "message": "Solde mis à jour et action logguée",
        "nouveau_solde": agent.solde_courant,
        "log_id": nouveau_log.id,
    }
