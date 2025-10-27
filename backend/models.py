from sqlalchemy import create_engine, Column, Integer, String, Boolean, DateTime, Text, Float, ForeignKey, Enum
from sqlalchemy.orm import declarative_base, sessionmaker
from config import Config
import enum
from datetime import datetime

Base = declarative_base()
engine = create_engine(Config.DATABASE_URI)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db_session():
    db = SessionLocal()
    try:
        return db
    finally:
        db.close()

class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True, index=True)
    uid = Column(String, unique=True, index=True, nullable=False)
    is_subscribed = Column(Boolean, default=False)

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
    user_uid = Column(String, ForeignKey('users.uid'), nullable=False, index=True)
    ticker = Column(String, nullable=False, index=True)
    target_price = Column(Float, nullable=False)
    direction = Column(Enum(AlertDirection), nullable=False)
    is_active = Column(Boolean, default=True, index=True)

# Feature: Sector Heatmap Cache
class SectorPerformance(Base):
    __tablename__ = 'sector_performance'
    sector = Column(String, primary_key=True, index=True)
    performance_pct = Column(Float, nullable=False)
    last_updated = Column(DateTime, nullable=False)

# (Other models: EventCatalyst, DeviceToken remain)
