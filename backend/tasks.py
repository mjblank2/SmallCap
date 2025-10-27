from celery import Celery
from celery.schedules import crontab
from config import Config
from data_providers import DP
from models import get_db_session, PriceAlert, AlertDirection, SectorPerformance
from datetime import datetime
# from push_service import PNS

# Initialize Celery
celery_app = Celery('tasks', broker=Config.REDIS_URL, backend=Config.REDIS_URL)

# (Existing tasks: run_daily_analysis, ingest_catalysts, process_news_sentiment)

# Feature: Price Alert Monitoring
@celery_app.task(name="tasks.monitor_price_alerts")
def monitor_price_alerts():
    """Runs every minute to check active price alerts."""
    db = get_db_session()
    try:
        # 1. Fetch all active alerts
        active_alerts = db.query(PriceAlert).filter(PriceAlert.is_active == True).all()
        if not active_alerts: return {"status": "no_active_alerts"}

        # 2. Get unique tickers and fetch bulk prices (Polygon)
        tickers = list(set(alert.ticker for alert in active_alerts))
        current_prices = DP.get_latest_trades_bulk(tickers)
        
        # 3. Evaluate conditions
        triggered_alerts = []
        for alert in active_alerts:
            current_price = current_prices.get(alert.ticker)
            if current_price is None: continue

            if alert.direction == AlertDirection.ABOVE and current_price >= alert.target_price:
                triggered_alerts.append(alert)
            elif alert.direction == AlertDirection.BELOW and current_price <= alert.target_price:
                triggered_alerts.append(alert)
        
        # 4. Trigger notifications and deactivate alerts
        for alert in triggered_alerts:
            print(f"ALERT TRIGGERED: {alert.ticker} hit target.")
            # PNS.send_targeted_notification(...)
            alert.is_active = False
            db.add(alert)
        
        db.commit()
        return {"status": "success", "triggered": len(triggered_alerts)}

    except Exception as e:
        db.rollback()
        return {"status": "error"}

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
    db = get_db_session()
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
        # 9 AM to 5 PM ET, Mon-Fri
        'schedule': crontab(minute='*', hour='9-17', day_of_week='1-5'),
    },
    'calculate-heatmap-daily': {
        'task': 'tasks.calculate_sector_heatmap',
        'schedule': crontab(hour=18, minute=0), # 6 PM ET
    },
}
