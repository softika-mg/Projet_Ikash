from fastapi import Security, HTTPException, status
import os
from fastapi.security.api_key import APIKeyHeader

# Entête HTTP attendue pour l'authentification API
api_key_header = APIKeyHeader(name="X-API-KEY", auto_error=False)

def get_api_key(api_key: str = Security(api_key_header)):
    """Vérifie que la clé API envoyée correspond à la valeur attendue."""
    if api_key == os.getenv("API_SECRET_KEY"):
        return api_key
    raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN, detail="Accès refusé : Clé API invalide"
    )
