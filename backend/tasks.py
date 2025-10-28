from celery import Celery
from celery.schedules import crontab
from config import Config
from data_providers import DP
from models import get_db_session, PriceAlert, AlertDirection, SectorPerformance, DeviceToken
from datetime import datetime
from push_service import PNS # Import the new push service (Gap 1)

# Initialize Celery
celery_app = Celery('tasks', broker=Config.REDIS_URL, backend=Config.REDIS_URL)

# (Existing tasks: run_daily_analysis, ingest_catalysts, process_news_sentiment)

# Feature: Price Alert Monitoring (Updated for Gap 1)
@celery_app.task(name="tasks.monitor_price_alerts")
def monitor_price_alerts():
    """Runs every minute to check active price alerts."""
    
    # Use the context manager for safer db sessions
    with get_db_session() as db:
        try:
            # 1. Fetch all active alerts
            active_alerts = db.query(PriceAlert).filter(PriceAlert.is_active == True).all()
            if not active_alerts: 
                return {"status": "no_active_alerts"}

            # 2. Get unique tickers and fetch bulk prices (Polygon)
            tickers = list(set(alert.ticker for alert in active_alerts))
            if not tickers:
                return {"status": "no_tickers_in_alerts"}
                
            current_prices = DP.get_latest_trades_bulk(tickers)
            
            # 3. Evaluate conditions
            triggered_alerts = []
            for alert in active_alerts:
                current_price = current_prices.get(alert.ticker)
                if current_price is None: 
                    continue

                if alert.direction == AlertDirection.ABOVE and current_price >= alert.target_price:
                    triggered_alerts.append((alert, current_price)) # Pass price for the message
                elif alert.direction == AlertDirection.BELOW and current_price <= alert.target_price:
                    triggered_alerts.append((alert, current_price)) # Pass price for the message
            
            if not triggered_alerts:
                return {"status": "success", "triggered": 0}

            # 4. Trigger notifications and deactivate alerts
            for alert, price in triggered_alerts:
                print(f"ALERT TRIGGERED: {alert.ticker} hit target {alert.target_price}. Current: {price}")
                
                # --- Push Notification Logic (Gap 1) ---
                # Find all devices for the user who owns the alert
                user_tokens = db.query(DeviceToken).filter(DeviceToken.user_uid == alert.user_uid).all()
                
                alert_title = f"Price Alert: {alert.ticker}"
                alert_body = f"{alert.ticker} has reached your target of ${alert.target_price:.2f}. Current price: ${price:.2f}"
                
                for token in user_tokens:
                    PNS.send_notification(token.token, alert_title, alert_body)
                # --- End Push Logic ---

                alert.is_active = False
                db.add(alert)
            
            db.commit()
            return {"status": "success", "triggered": len(triggered_alerts)}

        except Exception as e:
            db.rollback()
            print(f"Error in monitor_price_alerts: {e}")
            return {"status": "error", "message": str(e)}

# Feature: Sector Heatmap Calculation
@celery_app.task(name="tasks.calculate_sector_heatmap")
def calculate_sector_heatmap():
    """Calculates daily sector performance."""
    # IMPLEMENTATION REQUIRED: Use Polygon/Tiingo to calculate actual sector performance.
    # Simulated Results
    heatmap_data = {
        "Technology": 2.5, "Healthcare": 1.1, "Energy": -0.5, "Industrials": 0.2,
    }
    
    # Save/Update results in the database
    with get_db_session() as db:
        for sector, performance in heatmap_data.items():
            # (SQLAlchemy logic to update SectorPerformance table)
            pass
        db.commit()
    return {"status": "success"}

# Celery Beat Schedule
celery_app.conf.beat_schedule = {
    # (Existing schedules)
    'monitor-alerts-every-minute': {
        'task': 'tasks.monitor_price_alerts',
        # 9 AM to 5 PM ET, Mon-Fri (Adjust as needed, e.g., 9:30-16:00 for market hours)
        'schedule': crontab(minute='*', hour='9-17', day_of_week='1-5'),
    },
    'calculate-heatmap-daily': {
        'task': 'tasks.calculate_sector_heatmap',
        'schedule': crontab(hour=18, minute=0), # 6 PM ET
    },
}
