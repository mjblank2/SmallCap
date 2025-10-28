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
    # Render uses 'postgres://', SQLAlchemy requires 'postgresql://'
    if DATABASE_URI and DATABASE_URI.startswith("postgres://"):
        DATABASE_URI = DATABASE_URI.replace("postgres://", "postgresql://", 1)
        
    # Redis Configuration (Provided by Render)
    REDIS_URL = os.environ.get("REDIS_URL", "redis://localhost:6379/0")

    # --- ADDITIONS ---

    # Sentry Logging (Recommendation)
    # Set this in your Render secret group
    SENTRY_DSN = os.environ.get("SENTRY_DSN")

    # Apple Push Notifications (APNs) (Gap 1)
    # Set these in your Render secret group
    APNS_KEY_ID = os.environ.get("APNS_KEY_ID")
    APNS_TEAM_ID = os.environ.get("APNS_TEAM_ID")
    APNS_KEY_FILE_PATH = os.environ.get("APNS_KEY_FILE_PATH", "/app/AuthKey_APNS.p8") # Path within the container
    APNS_BUNDLE_ID = os.environ.get("APNS_BUNDLE_ID", "com.yourapp.microcap") # Your app's bundle ID
    APNS_IS_SANDBOX = os.environ.get("APNS_IS_SANDBOX", "false").lower() == "true"
