# Revue du projet iKash Backend

## 1. Aperçu général

Ce projet est une API FastAPI pour gérer des transactions Mobile Money, des profils et la réception de SMS. La structure est raisonnablement organisée avec :

- `app/main.py` : point d'entrée FastAPI.
- `app/database.py` : configuration SQLModel / SQLAlchemy.
- `app/routers/` : routeurs pour transactions, SMS, profils et logs.
- `app/services/` : logique métier séparée pour les transactions, profils et SMS.
- `app/models/` : définitions des entités `Profile`, `Transaction` et `LogActivite`.
- `app/utils/` : parseur de SMS.
- `app/security/` : authentification par clé API.
- `app/core/brain/` : module ML expérimental.

## 2. Points positifs

- Architecture modulaire claire : routers, services, modèles et utilitaires sont bien séparés.
- Usage de `SQLModel` pour les modèles de données et la création automatique des tables.
- Sécurisation des routes avec `X-API-KEY` via `app/security/get_api_key.py`.
- Endpoint `/scalar` pour générer automatiquement la documentation d'API via `scalar_fastapi`.
- État initial bien orienté pour gérer les transactions et les profils.

## 3. Fonctionnalités présentes

- `POST /transactions/` : création de transaction.
- `GET /transactions/` : liste des transactions.
- `POST /sms/receive` : réception et parsing de SMS pour enregistrer une transaction.
- `GET /profiles/` : liste des profils.
- `POST /profiles/` : création d'un profil.
- `POST /profiles/ajuster-solde` : ajustement de solde d'un agent avec journalisation.

## 4. Problèmes critiques détectés

### 4.1. Incohérence entre le parseur SMS et le modèle Transaction

Le parseur `app/utils/sms_parser.py` renvoie des champs comme :

- `reference_sms`
- `type_op`
- `raw_text`
- `agent_id`

Alors que le modèle `Transaction` attend :

- `reference`
- `type`
- `operateur`
- `agent_id`

Cette incompatibilité empêche la création correcte des transactions à partir de SMS et provoque des erreurs lors de l'appel à `Transaction(**parsed_data)`.

### 4.2. Usage partiel de SQLModel / SQLAlchemy

- `Profile` est défini avec un champ `role: str = Field(default=RoleType.AGENT.value)` plutôt qu'un type enum dédié.
- `app/routers/profile_router.py` utilise `session.query(Profile).all()` au lieu de `select(Profile)`.
- `app/database.py` importe des modèles (`Profile`, `Transaction`, `LogActivite`) uniquement pour les métadonnées, ce qui fonctionne mais peut être simplifié.

### 4.3. Validation et schémas manquants

- Les routes exposent directement les modèles SQLModel comme entrées/sorties.
- Il n'y a pas de schémas dédiés pour les requêtes de transaction ou pour le SMS entrant.
- `app/routers/sms_router.py` accepte un `dict` brut, ce qui laisse la validation du payload très faible.

### 4.4. Fichier `requirements.txt` encodé en UTF-16

Le fichier est en UTF-16, ce qui est inhabituel pour un fichier de dépendances et peut poser des problèmes d'outils et d'intégration continue.

### 4.5. Modules inutilisés / incohérences

- `app/routers/__init__.py` est vide.
- Le dossier `app/core/brain/` contient un modèle ML non utilisé et un fichier de données d'entraînement vide.
- `app.services.sms_services.handle_incoming_sms` n'est pas utilisé par le routeur, qui appelle `process_incoming_sms`.

## 5. Recommandations d'amélioration

### 5.1. Corriger le parsing SMS

- Harmoniser les clés renvoyées par `parse_mobile_money_sms` avec le modèle `Transaction`.
- Ajouter un mapping explicite du parseur vers le modèle :
  - `reference_sms` → `reference`
  - `type_op` → `type`
  - `numero_client` ou `operateur`
- Ajouter des tests unitaires pour les formats de SMS les plus courants.

### 5.2. Utiliser des schémas Pydantic dédiés

- Créer des schémas `TransactionCreate`, `ProfileCreate`, `SoldeUpdateRequest`, `SmsReceiveRequest`.
- Ne pas exposer directement les modèles tables comme entrées brutes.
- Séparer les modèles de lecture et d'écriture.

### 5.3. Clarifier la gestion de session

- Centraliser `get_session()` dans `app.database` et réutiliser ce dépendance dans tous les routeurs.
- Fermer proprement les sessions à chaque appel.

### 5.4. Nettoyer l’architecture

- Retirer ou intégrer le module `app/core/brain/` si ce n’est pas utilisé.
- Supprimer `app/routers/__init__.py` vide ou ajouter des imports de routeurs si besoin.
- Corriger `requirements.txt` pour le mettre en UTF-8.

### 5.5. Ajouter de la documentation et des tests

- Créer un `README.md` avec instructions d’installation, variables d’environnement et routes disponibles.
- Ajouter des tests unitaires pour :
  - parsing SMS,
  - création de transaction,
  - création d’un profil,
  - authentification API key.

## 6. Points de vigilance techniques

- `Transaction.reference` est unique : l’import SMS doit gérer les doublons.
- `Profile.id` est un UUID primaire, mais l’initialisation de nouveaux profils dépend du client pour fournir cet UUID.
- `LogActivite` peut comporter des `admin_id` ou `agent_id` nuls : vérifier les usages attendus.
- `sqlmodel` version 0.0.31 est compatible avec `SQLAlchemy 2.0`, mais attention aux différences de session et de requête.

## 7. Conclusion

Le projet a une bonne base modulaire et une logique métier claire. Il reste toutefois des corrections importantes sur le parsing SMS, la validation des entrées et la cohérence des modèles avant de pouvoir être considéré comme prêt pour la production.

---

### Fichiers clés à revoir en priorité

- `app/utils/sms_parser.py`
- `app/services/sms_services.py`
- `app/routers/sms_router.py`
- `app/routers/profile_router.py`
- `app/database.py`
- `requirements.txt`
