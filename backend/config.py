import os
from dotenv import load_dotenv
load_dotenv()

class Config:
    # API Keys (Set these securely in your Render Environment Group)
    POLYGON_API_KEY = os.environ.get("POLYGON_API_KEY")
    TIINGO_API_KEY = os.environ.get("TIINGO_API_KEY")
    SSRV_WEBHOOK_SECRET = os.environ.get("SSRV_WEBHOOK_SECRET")
    
    # Database Configuration (Handles Render's format for SQLAlchemy)
    DATABASE_URI = os.environ.get("DATABASE_URL", "sqlite:///microcap_engine.db")
    if DATABASE_URI and DATABASE_URI.startswith("postgres://"):
        DATABASE_URI = DATABASE_URI.replace("postgres://", "postgresql://", 1)
        
    # Redis Configuration (Provided by Render)
    REDIS_URL = os.environ.get("REDIS_URL", "redis://localhost:6379/0")
