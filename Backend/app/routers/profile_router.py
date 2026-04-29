from fastapi import APIRouter, Depends, HTTPException
from typing import List
from sqlmodel import Session, select
from app.database import get_session
from app.models import Profile
from app.services import profile_service
from app.security.get_api_key import get_api_key
from app.schemas.profile_schemas import ProfileCreate, ProfileRead, SoldeUpdateRequest
from app.models.log import LogActivite

router = APIRouter(prefix="/profiles", tags=["Profiles"])


@router.get("/", response_model=List[ProfileRead])
def get_profiles(
    session: Session = Depends(get_session), api_key: str = Depends(get_api_key)
):
    statement = select(Profile)
    return session.exec(statement).all()


@router.post("/", response_model=ProfileRead)
def create_profile(
    profile: ProfileCreate,
    session: Session = Depends(get_session),
    api_key: str = Depends(get_api_key),
):
    # Crée un nouveau profil à partir des données validées par Pydantic
    profile_obj = Profile(**profile.model_dump(exclude_none=True))
    return profile_service.create_new_profile(session, profile_obj)


@router.post("/ajuster-solde")
def ajuster_solde_agent(
    payload: SoldeUpdateRequest,
    session: Session = Depends(get_session),
    api_key: str = Depends(get_api_key),
):
    # Récupération de l'agent avant modification du solde
    agent = session.get(Profile, payload.agent_id)
    if not agent:
        raise HTTPException(status_code=404, detail="Agent non trouvé")

    ancien_solde = agent.solde_courant
    agent.solde_courant += payload.montant
    nouveau_solde = agent.solde_courant

    nouveau_log = LogActivite(
        admin_id=payload.admin_id,
        agent_id=payload.agent_id,
        action=payload.action_description,
        ancien_solde=ancien_solde,
        nouveau_solde=nouveau_solde,
    )

    # Enregistrement de l'agent et du log d'activité ensemble
    session.add(agent)
    session.add(nouveau_log)
    session.commit()
    session.refresh(agent)

    return {
        "message": "Solde mis à jour et action logguée",
        "nouveau_solde": agent.solde_courant,
        "log_id": nouveau_log.id,
    }
