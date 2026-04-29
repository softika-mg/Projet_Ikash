# iKash Backend

API FastAPI pour la gestion de transactions Mobile Money, profils et réception de SMS.

## Installation

1. Créez un environnement Python 3.11+.
2. Installez les dépendances :

```bash
python3 -m pip install -r requirements.txt
```

3. Définissez les variables d'environnement :

```bash
export DATABASE_URL="sqlite:///./ikash.db"
export API_SECRET_KEY="votre_clef_api"
```

4. Lancez l'application :

```bash
uvicorn app.main:app --reload
```

## Endpoints

### Authentification

- Header HTTP requis : `X-API-KEY`
- Valeur : `API_SECRET_KEY` du `.env` ou de l'environnement.

### Profils

- `GET /profiles/` : liste les profils.
- `POST /profiles/` : crée un profil.
- `POST /profiles/ajuster-solde` : ajuste le solde d'un agent et crée un log.

### Transactions

- `POST /transactions/` : crée une transaction.
- `GET /transactions/` : liste les transactions.

### SMS

- `POST /sms/receive` : reçoit un SMS et tente de le parser puis d'enregistrer la transaction.

### Logs

- `GET /logs/` : liste des logs d'activité.

## Architecture

- `app/main.py` : application FastAPI.
- `app/database.py` : moteur SQLModel et session centralisée.
- `app/models/` : modèle de données SQLModel.
- `app/routers/` : routeurs API.
- `app/services/` : logique métier.
- `app/schemas/` : schémas Pydantic de validation.
- `app/utils/sms_parser.py` : parsing des SMS.
- `app/core/brain/` : classification des SMS pour audit et réconciliation.

## Tests

Exécuter les tests avec :

```bash
python3 -m unittest discover -s tests
```
