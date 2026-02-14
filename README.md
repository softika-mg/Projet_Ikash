#  IKash - Digitalisation & Audit Intelligent des Flux Cash Point

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)

**iKash** est une solution écosystémique conçue pour moderniser la gestion des points de vente de monnaie électronique à Madagascar. En combinant l'interception automatique des SMS et un moteur d'audit centralisé, iKash sécurise les revenus des gérants.

---

## 📂 Organisation du Projet

Le projet est structuré pour séparer strictement l'infrastructure, la logique serveur et l'expérience mobile :

### 📂 `backend/` (Le Noyau iKash)
*Architecture MVC avec FastAPI + SQLModel*
* **Models** : Définition des tables PostgreSQL et validation des données.
* **Controllers** : Logique métier de réconciliation et moteur d'audit.
* **Routes** : Endpoints API pour la communication avec l'application mobile.

### 📂 `mobile/` (L'Application Flutter)
*Architecture en couches (Layered Architecture)*
* `lib/core/` : Fondations (thèmes, constantes, utilitaires).
* `lib/data/` : Gestion des données (modèles Drift/SQLite et connecteurs API).
* `lib/logic/` : Intelligence métier et gestion des états (State Management).
* `lib/ui/` : Interface utilisateur (Vues Admin/Agent et widgets).

### 📂 `scripts/`
* Outils DevOps pour l'automatisation des migrations, les backups et le déploiement.

### 📂 `docs/`
* Documentation technique, schémas de base de données et ressources de conception (Figma).

---

## 🚀 Fonctionnalités Clés

* **Interception SMS Éthique :** Capture automatique des données de transaction.
* **Réconciliation en Temps Réel :** Audit instantané entre saisie manuelle et confirmation opérateur.
* **Mode Offline-First :** Persistance locale SQLite pour garantir le service sans connexion.
* **Multi-Tenancy :** Isolation stricte des données par point de vente via Supabase RLS.

---

## 👤 Développement & Contact
* **Lovaxcoding** - Développeur Fullstack stagiaire chez **SOFTIKA MG**
* **Contact** : [lnantenaina78@gmail.com](mailto:lnantenaina78@gmail.com)
* **Prototype** : [Maquette Figma](https://crayon-repair-18309931.figma.site/)

---

## 📝 Propriété
Développé sous l'égide de **SOFTIKA MG**. Tous droits réservés - 2026.
