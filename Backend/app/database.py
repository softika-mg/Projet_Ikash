import os
from dotenv import load_dotenv
from typing import Optional
from sqlalchemy.engine import Engine
from sqlalchemy.pool import StaticPool
from sqlmodel import create_engine, SQLModel, Session
from app.models.profile import Profile
from app.models.transaction import Transaction
from app.models.log import LogActivite

# On charge le fichier d'environnement pour récupérer DATABASE_URL et API_SECRET_KEY
load_dotenv()

# URL de la base de données, avec une valeur locale par défaut
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./ikash.db")


def create_db_engine(database_url: Optional[str] = None, echo: bool = False):
    database_url = database_url or DATABASE_URL
    if database_url == "sqlite:///:memory:":
        # Utilisation d'un pool statique pour conserver la DB en mémoire entre les connexions.
        return create_engine(
            database_url,
            echo=echo,
            connect_args={"check_same_thread": False},
            poolclass=StaticPool,
        )
    return create_engine(database_url, echo=echo)


engine = create_db_engine(echo=True)


def get_session():
    """Dépendance FastAPI pour ouvrir et fermer une session SQLModel."""
    with Session(engine) as session:
        yield session


def create_db_and_tables(engine_override: Optional[Engine] = None):
    """Crée les tables SQLModel si elles n'existent pas encore."""
    SQLModel.metadata.create_all(engine_override or engine)
    print("Base de données et tables créées.")
