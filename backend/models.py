from contextlib import contextmanager
from datetime import datetime
import enum

from sqlalchemy import create_engine, Column, Integer, String, Boolean, DateTime, Text, Float, ForeignKey, Enum
from sqlalchemy.orm import declarative_base, sessionmaker, relationship

from config import Config

Base = declarative_base()
engine = create_engine(Config.DATABASE_URI)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@contextmanager
def get_db_session():
    """Context manager that yields a SQLAlchemy session and ensures it is closed."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True, index=True)
    uid = Column(String, unique=True, index=True, nullable=False)
    is_subscribed = Column(Boolean, default=False)

    # Relationships to enable cascade deletes (Gap 2)
    price_alerts = relationship("PriceAlert", back_populates="user", cascade="all, delete-orphan")
    device_tokens = relationship("DeviceToken", back_populates="user", cascade="all, delete-orphan")

class StockPick(Base):
    __tablename__ = 'stock_picks'
    id = Column(String, primary_key=True, index=True)
    ticker = Column(String, index=True, nullable=False)
    # ... (Other fields: company_name, thesis, pricing, etc.)
    # Feature: Conviction Score
    conviction_score = Column(Float, nullable=True)
    conviction_classification = Column(String, nullable=True)

# Feature: Dynamic Price Alerts
class AlertDirection(enum.Enum):
    ABOVE = "above"
    BELOW = "below"

class PriceAlert(Base):
    __tablename__ = 'price_alerts'
    id = Column(Integer, primary_key=True, index=True)
    # Updated ForeignKey to use cascade delete (Gap 2)
    user_uid = Column(String, ForeignKey('users.uid', ondelete="CASCADE"), nullable=False, index=True)
    ticker = Column(String, nullable=False, index=True)
    target_price = Column(Float, nullable=False)
    direction = Column(Enum(AlertDirection), nullable=False)
    is_active = Column(Boolean, default=True, index=True)
    
    user = relationship("User", back_populates="price_alerts")

# Feature: Sector Heatmap Cache
class SectorPerformance(Base):
    __tablename__ = 'sector_performance'
    sector = Column(String, primary_key=True, index=True)
    performance_pct = Column(Float, nullable=False)
    last_updated = Column(DateTime, nullable=False)

# --- NEW TABLE (Gap 1) ---
class DeviceToken(Base):
    """Stores user device tokens for APNs"""
    __tablename__ = 'device_tokens'
    id = Column(Integer, primary_key=True, index=True)
    # Updated ForeignKey to use cascade delete (Gap 2)
    user_uid = Column(String, ForeignKey('users.uid', ondelete="CASCADE"), nullable=False, index=True)
    token = Column(String, unique=True, nullable=False, index=True)
    last_registered = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    user = relationship("User", back_populates="device_tokens")

# (Other models: EventCatalyst remain)

