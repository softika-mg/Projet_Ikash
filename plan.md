# 📊 ANALYSE COMPLÈTE : Frontend Flutter + Backend Python

**Date**: 29 mai 2026  
**Status**: ⚠️ **PAS PRÊT POUR PRODUCTION** - Incompatibilités majeures détectées

---

## 🎯 État Global

| Composant | État | Score |
|-----------|------|-------|
| **Frontend (Flutter)** | Prêt architecturalement | 70% ✅ |
| **Backend (FastAPI)** | Structure bonne, bugs critiques | 65% ⚠️ |
| **Intégration Front-Back** | Incompatibilités majeures | 40% 🔴 |

---

## 🔴 INCOMPATIBILITÉS CRITIQUES DÉTECTÉES

### 1. DIFFÉRENCE DE STRUCTURE DES ID 🔴 **PRIORITÉ MAXIMALE**

**Frontend (Drift):**
```dart
IntColumn get id => integer().autoIncrement()();  // Int auto-increment
```

**Backend (SQLModel):**
```python
id: UUID = Field(primary_key=True)              # UUID primaire
id_transaction: UUID = Field(default_factory=uuid4)  # UUID auto-généré
```

**Problème**: Conflit total sur la synchronisation
- Flutter génère des IDs locaux `int` 
- Backend génère des `UUID`
- Impossible de matcher une transaction du Flutter avec celle du backend

**Impact**: ❌ Sync impossible, dédoublonnage impossible

---

### 2. PARSEUR SMS INCOMPATIBLE 🔴

**Parseur backend retourne:**
```python
{
    "reference_sms": "ABC123",
    "type_op": "TRANSFERT",
    "raw_text": "...",
    "agent_id": None,
}
```

**Modèle Transaction attendu:**
```python
{
    "reference": "ABC123",        # ← Clé différente!
    "type": "TRANSFERT",          # ← OK
    "operateur": "TELMA",         # ← Manquant du parseur!
    "agent_id": None,
}
```

**Impact**: ❌ SMS reçus ne peuvent pas être enregistrés → erreur 400

---

### 3. AUTHENTIFICATION INCOMPATIBLE 🔴

**Frontend:**
- PIN 4 chiffres local uniquement
- Pas de token, pas de JWT

**Backend:**
- `X-API-KEY` pour authentification (statique)
- Pas de JWT
- Pas de gestion de session utilisateur

**Problème**: Aucun mécanisme pour identifier "quel agent Flutter" envoie les requêtes
- Backend ne sait pas qui est l'utilisateur actuel
- Impossible d'assigner les transactions au bon agent

**Impact**: ❌ Toutes les requêtes anonymes → impossible de suivre qui fait quoi

---

### 4. CONFIGURATION SERVEUR ABSENTE

**Frontend:**
```dart
// api_service.dart → VIDE
// Pas de URL backend, pas de configuration
```

**Backend:**
```bash
# .env défini
API_SECRET_KEY=change_moi_pour_une_clef_secrete
DATABASE_URL=sqlite:///./ikash.db
```

**Impact**: ⚠️ Backend lancé, mais frontend ne sait pas où l'appeler

---

## ⚠️ BUGS BACKEND À CORRIGER IMMÉDIATEMENT

| Bug | Fichier | Sévérité | Détail |
|-----|---------|----------|--------|
| Table `logs_activites` manquante | `app/database.py` | 🔴 Blocage | Tests crash |
| Dépréciation Pydantic `dict()` | `profile_router.py:28` | 🟡 | Doit utiliser `model_dump()` |
| `datetime.utcnow()` dépréciée | Plusieurs fichiers | 🟡 | Doit utiliser `datetime.now(UTC)` |
| requirements.txt en UTF-16 | - | 🟡 | Problème d'outils CI/CD |
| Module `core/brain/` inutilisé | Orphelin | 🟢 | À nettoyer |

---

## 📋 COMPARAISON MODÈLES DONNÉES

### Modèle Profil

| Champ | Frontend (Drift) | Backend (SQLModel) | Compat? |
|-------|------------------|-------------------|--------|
| `id` | `int auto_increment` | `UUID` | ❌ **NON** |
| `nom` | `text` | `str` | ✅ |
| `role` | `intEnum<RoleType>` | `str (RoleType.value)` | ⚠️ Mapping requis |
| `codePin` | `text nullable` | `str nullable` | ✅ |
| `soldeCourant` | `real` | `float` | ✅ |
| `createdAt` | `datetime` | `datetime.utcnow()` | ✅ |
| `adminId` | `int FK` | `UUID FK` | ❌ **NON** |

---

### Modèle Transaction

| Champ | Frontend | Backend | Compat? |
|-------|----------|---------|--------|
| `id` | `int auto_increment` | `UUID` | ❌ **NON** |
| `horodatage` | `datetime` | `datetime` | ✅ |
| `montant` | `real` | `float` | ✅ |
| `type` | `intEnum<TransactionType>` | `Enum str` | ⚠️ Mapping |
| `reference` | `text UNIQUE NOT NULL` | `str UNIQUE` | ✅ |
| `agentId` | `int FK` | `UUID FK` | ❌ **NON** |
| `statut` | `intEnum<TransactionStatus>` | `Enum str` | ⚠️ Mapping |
| `numeroClient` | `text nullable` | `str nullable` | ✅ |
| `fraisOperateur` | `real (new in v2)` | ❌ Absent | ⚠️ À ajouter |

---

## 🛠️ PLAN DE CORRECTION (Ordre de Priorité)

### PHASE 1 - CRITIQUE (Jour 1-2) 🔴

#### 1.1. **Corriger les IDs - Stratégie Hybrid**

```
Option A (Recommandée): Backend SQLite + Sync UUID
├─ Backend : garder UUID (standard)
├─ Frontend : ajouter colonne uuid_remote (nullable)
├─ Sync : Frontend envoie ses transactions, backend retourne UUID
└─ Dédoublonnage : matcher sur (reference + horodatage)

Option B: Tout passer à int
└─ Trop de breaking changes, déconseillé
```

**Détails**:
- Modifier [lib/models/transactions.dart](Mobile/ikash_interface/lib/models/transactions.dart) : ajouter colonne `uuidRemote`
- Modifier [Backend/app/models/transaction.py](Backend/app/models/transaction.py) : ajouter `local_id` int nullable
- API endpoint `/transactions/sync` : retourner mapping `{local_id: remote_uuid}`

---

#### 1.2. **Corriger le Parseur SMS**

Fichier: [Backend/app/utils/sms_parser.py](Backend/app/utils/sms_parser.py)

Actuellement retourne:
```python
{
    "reference_sms": "ABC123",
    "type_op": "TRANSFERT",
}
```

À changer pour:
```python
{
    "reference": "ABC123",
    "type": "TRANSFERT",
    "operateur": "TELMA",  # À extraire du SMS!
    "montant": 50000,
}
```

**Action**: Mettre à jour `parse_mobile_money_sms()` pour retourner les clés exactes attendues par le modèle

---

#### 1.3. **Implémenter Authentication Bearer/JWT**

**Backend** - Ajouter endpoint:
```python
# app/routers/auth_router.py (nouveau)
@router.post("/auth/login")
async def login(credentials: LoginRequest, session: Session = Depends(get_session)):
    """
    Login avec PIN
    
    Request:
    {
        "pin": "1234",
        "agent_id": "uuid-or-null"  
    }
    
    Response:
    {
        "access_token": "jwt_token_here",
        "token_type": "bearer",
        "agent_id": "uuid-assigned"
    }
    """
```

**Frontend** - Implémenter:
```dart
// lib/services/api_service.dart
Future<AuthResponse> login(String pin) async {
  final response = await http.post(
    Uri.parse('$BASE_URL/auth/login'),
    body: jsonEncode({"pin": pin}),
  );
  
  final token = response['access_token'];
  await storage.write(key: 'auth_token', value: token);
  return AuthResponse.fromJson(response);
}
```

---

### PHASE 2 - HAUTE (Jour 2-3) 🟡

#### 2.1. **Remplir l'ApiService Flutter**

Fichier: [Mobile/ikash_interface/lib/services/api_service.dart](Mobile/ikash_interface/lib/services/api_service.dart)

Structure requise:
```dart
class ApiService {
  static const String BASE_URL = 'http://192.168.x.x:8000'; // À configurer
  
  // Authentification
  Future<AuthResponse> login(String pin) 
  
  // Transactions
  Future<TransactionResponse> createTransaction(Transaction tx)
  Future<List<Transaction>> getTransactions()
  Future<SyncResponse> syncTransactions(List<Transaction> local)
  
  // SMS
  Future<SmsResponse> uploadSms(SmsData sms)
  
  // Gestion token Bearer
  Future<void> setToken(String token)
  Future<String?> getToken()
}
```

Dépendances à ajouter:
```yaml
flutter_secure_storage: ^9.0.0  # Stockage sécurisé tokens
```

---

#### 2.2. **Ajouter flux d'authentification**

- Backend retourne JWT après login PIN
- Frontend stocke en `flutter_secure_storage`
- Toutes les requêtes incluent `Authorization: Bearer <token>`
- Refresh token logic (si JWT expire)

---

#### 2.3. **Implémenter sync bidirectionnelle**

```
Sync upstream (Flutter → Backend):
├─ Lire transactions locales non-syncées
├─ POST /transactions/batch avec flutter local_id
├─ Backend retourne mapping {local_id: uuid_remote}
└─ Flutter met à jour uuidRemote localement

Sync downstream (Backend → Flutter):
├─ GET /transactions avec since=last_sync_timestamp
├─ Flutter reçoit transactions du cloud
└─ Merge avec données locales (éviter doublons via uuid)

Gestion offline:
├─ Queue locale si pas internet
└─ Retry automatique au reconnect
```

---

### PHASE 3 - MOYEN (Jour 3-4) 🟢

#### 3.1. **Corriger bugs backend**

**Task 1**: Migration table `logs_activites`
```python
# Backend/app/database.py - Line ~40
# Importer LogActivite et s'assurer qu'elle est dans metadata
from app.models.log import LogActivite  # ← À ajouter

@DriftDatabase(tables=[Profile, Transaction, LogActivite])
```

**Task 2**: Pydantic v2 deprecations
- ✅ `model_dump()` au lieu de `dict()`
- ✅ `from_attributes=True` au lieu de `orm_mode=True`
- ✅ `datetime.now(UTC)` au lieu de `datetime.utcnow()`

**Task 3**: requirements.txt UTF-8
```bash
# Reconvertir le fichier en UTF-8
iconv -f UTF-16 -t UTF-8 Backend/requirements.txt > temp.txt
mv temp.txt Backend/requirements.txt
```

---

#### 3.2. **Tests end-to-end**

```bash
# Backend - Tests unitaires
cd Backend
python -m pytest tests/

# Frontend - Tests unitaires  
cd Mobile/ikash_interface
flutter test

# E2E manual:
# 1. Backend: uvicorn app.main:app --reload
# 2. Frontend: flutter run
# 3. Tester: Login → Create Txn → Sync → Verify DB
```

---

## ✅ CHECKLIST D'INTÉGRATION

### Backend (Python)

- [ ] Corriger table `logs_activites` manquante
- [ ] Implémenter endpoint `/auth/login` (JWT)
- [ ] Fixer parseur SMS (clés + operateur)
- [ ] Ajouter endpoint `/transactions/sync` (batch)
- [ ] Ajouter colonne `local_id` nullable dans Transaction
- [ ] Pydantic v2 deprecations
- [ ] requirements.txt en UTF-8
- [ ] Tests: POST /transactions/ + GET /transactions/
- [ ] Tests: POST /auth/login + JWT validation
- [ ] Tests: POST /sms/receive avec SMS valides

### Frontend (Flutter)

- [ ] Ajouter `flutter_secure_storage` à pubspec.yaml
- [ ] Implémenter ApiService complète
- [ ] Configurer BASE_URL du backend
- [ ] Implémenter login → token Bearer
- [ ] Ajouter colonne `uuidRemote` à Transactions
- [ ] Sync transactions upstream (POST batch)
- [ ] Sync transactions downstream (GET avec since)
- [ ] Gestion offline (queue local)
- [ ] Tests: login → token stocké
- [ ] Tests: upload transaction → reçoit uuid

### Intégration

- [ ] E2E test: Login → Create Txn → Sync → Verify DB backend
- [ ] CORS configuration si frontend ≠ backend URL
- [ ] SSL/TLS pour production
- [ ] Rate limiting API backend
- [ ] Logging centralisé
- [ ] Error handling cohérent (codes HTTP)
- [ ] Documentation API (OpenAPI/Scalar)
- [ ] Deployment checklist

---

## 📡 ARCHITECTURE CIBLE

```
┌─────────────────────────────────────────────────────────────┐
│                    IKASH MOBILE (Flutter)                    │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ ApiService (http + Bearer Token JWT)                 │   │
│  │  - login(pin) → Token JWT (stocké sécurisé)         │   │
│  │  - uploadTransactions() → Sync upstream             │   │
│  │  - downloadTransactions() → Pull downstream         │   │
│  └────────────────┬─────────────────────────────────────┘   │
│                   │                                            │
│  ┌────────────────▼──────────────────────────────────────┐   │
│  │ Local SQLite (Drift)                                  │   │
│  │  - Profiles (id int + uuid_remote nullable)          │   │
│  │  - Transactions (id int + uuid_remote nullable)      │   │
│  │  - AgentNumbers, Tarifs, SMS, etc.                   │   │
│  │  - Queue for sync if offline                         │   │
│  └────────────────────────────────────────────────────────┘   │
│                                                                 │
└───────────────────────┬──────────────────────────────────────┘
                        │ HTTP/REST + JWT Bearer
                        │ Content-Type: application/json
                        │
┌───────────────────────▼──────────────────────────────────────┐
│                  IKASH BACKEND (FastAPI)                      │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Routers                                               │   │
│  │  - POST /auth/login → JWT Token + Agent UUID         │   │
│  │  - POST /transactions/ + GET /transactions/          │   │
│  │  - POST /transactions/sync → Batch sync upstream    │   │
│  │  - POST /sms/receive (avec parsing corrigé)          │   │
│  │  - POST /profiles/ + GET /profiles/                  │   │
│  └────────────────┬─────────────────────────────────────┘   │
│                   │                                            │
│  ┌────────────────▼──────────────────────────────────────┐   │
│  │ Services + SQLModel                                   │   │
│  │  - Profile: UUID PK (multi-agent support)            │   │
│  │  - Transaction: UUID PK + local_id fk (sync)         │   │
│  │  - Logs: Audit trail                                 │   │
│  │  - SMS Parsing: reference, type, operateur, montant │   │
│  └────────────────────────────────────────────────────────┘   │
│                   │                                            │
│  ┌────────────────▼──────────────────────────────────────┐   │
│  │ SQLite / PostgreSQL                                   │   │
│  │  - Central source of truth                           │   │
│  │  - Transactions avec UUID cloud                       │   │
│  └────────────────────────────────────────────────────────┘   │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

---

## 🎯 DÉTAIL DES FICHIERS À MODIFIER

### Backend (Python)

| Fichier | Action | Complexité |
|---------|--------|-----------|
| `app/routers/auth_router.py` | **Créer nouveau** | Moyen |
| `app/models/transaction.py` | Ajouter `local_id` | Faible |
| `app/utils/sms_parser.py` | Corriger clés retournées | Moyen |
| `app/database.py` | Importer LogActivite | Faible |
| `app/routers/profile_router.py` | Pydantic v2 fixes | Faible |
| `app/routers/transaction_router.py` | Ajouter `/sync` endpoint | Moyen |
| Plusieurs fichiers | `datetime.utcnow()` → `datetime.now(UTC)` | Faible |
| `requirements.txt` | Reconvertir en UTF-8 | Faible |

### Frontend (Flutter)

| Fichier | Action | Complexité |
|---------|--------|-----------|
| `pubspec.yaml` | Ajouter `flutter_secure_storage` | Faible |
| `lib/services/api_service.dart` | **Implémenter complètement** | Moyen-Haut |
| `lib/models/transactions.dart` | Ajouter `uuidRemote` | Faible |
| `lib/models/profiles.dart` | Ajouter `uuidRemote` | Faible |
| `lib/services/auth_service.dart` | Intégrer JWT backend | Moyen |
| `lib/providers/theme_provider.dart` | Ajouter Bearer header setup | Faible |

---

## ⏱️ TIMELINE ESTIMÉE

| Phase | Durée | Tâches |
|-------|-------|--------|
| **Phase 1** | 2 jours | IDs, SMS parser, Auth JWT |
| **Phase 2** | 2 jours | ApiService, Sync, Offline |
| **Phase 3** | 1 jour | Bugs backend, Tests |
| **Buffer** | 1 jour | Imprévus, Debugging |
| **Total** | ~1 semaine | 6 jours de travail |

---

## 🎓 RESSOURCES DE RÉFÉRENCE

### Frontend
- Flutter HTTP: https://pub.dev/packages/http
- Riverpod: https://riverpod.dev/
- Drift Database: https://drift.simonbinder.eu/
- Secure Storage: https://pub.dev/packages/flutter_secure_storage

### Backend
- FastAPI: https://fastapi.tiangolo.com/
- SQLModel: https://sqlmodel.tiangolo.com/
- Pydantic v2: https://docs.pydantic.dev/latest/
- JWT: https://python-jose.readthedocs.io/

---

## ❓ QUESTIONS OUVERTES

1. **Environnement réseau**: Où sera le backend déployé? (localhost dev, IP interne prod, cloud?)
2. **Rate limiting**: Besoin de restriction de débit API?
3. **Multi-tenancy**: Plusieurs entreprises/admins partagent la même instance?
4. **Backup/Recovery**: Stratégie de récupération en cas de perte sync?
5. **Notifications**: Besoin de push notifications pour les transactions?

---

## ✨ CONCLUSION

**Status**: ⚠️ **PAS PRÊT** - 3 incompatibilités majeures bloquent l'intégration

**Prochaines étapes immédiatement**:
1. ✅ Valider ce plan avec l'équipe
2. 🔧 Implémenter Phase 1 (2 jours)
3. ✅ Tests d'intégration complets
4. 🚀 Deployment staging → production

**Recommandation**: Commencer par les corrections critiques de **Phase 1** avant d'avancer.
