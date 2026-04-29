from fastapi import FastAPI
from app.database import create_db_and_tables
from app.routers import transaction_router
from scalar_fastapi import get_scalar_api_reference
from app.routers import sms_router, profile_router, log_router
from fastapi import Depends
from app.security.get_api_key import get_api_key


# Application FastAPI principale pour iKash
app = FastAPI(
    title="iKash API",
    description="Système de gestion de transactions Mobile Money",
    version="1.0.0",
    docs_url=None, 
    redoc_url=None,  
)


@app.on_event("startup")
def on_startup():
    create_db_and_tables()

# Inclusion des routeurs principaux de l'API
# Les routes de profil sont protégées par la clé API
app.include_router(transaction_router)
app.include_router(sms_router)
app.include_router(log_router)
app.include_router(profile_router, dependencies=[Depends(get_api_key)])

@app.get("/scalar", include_in_schema=False)
async def scalar_html():
    return get_scalar_api_reference(
        openapi_url=app.openapi_url,
        title=app.title,
    )
