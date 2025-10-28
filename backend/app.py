import sentry_sdk
from flask import Flask, jsonify, request, abort
from analysis_features import AF
from models import get_db_session, SectorPerformance, PriceAlert, User, DeviceToken
from config import Config
from functools import wraps
import pandas as pd

# Import the analyzer for the admin route (Gap 3)
from analysis_engine import MicroCapAnalyzer

# --- Recommendation: Initialize Sentry ---
if Config.SENTRY_DSN:
    sentry_sdk.init(
        dsn=Config.SENTRY_DSN,
        integrations=[sentry_sdk.integrations.flask.FlaskIntegration()],
        traces_sample_rate=1.0,
        send_default_pii=True
    )
# --- End Sentry Init ---


app = Flask(__name__)
app.config.from_object(Config)

# --- Authentication Decorator (Stub) ---
# You MUST implement this using your authentication provider (e.g., Firebase Admin SDK)
# to validate the 'Authorization: Bearer <TOKEN>' header.
def require_auth(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        if not auth_header:
            abort(401, description="Missing Authorization Header")
        
        try:
            # Example: token = auth_header.split(' ')[1]
            # user_data = auth.verify_id_token(token)
            # request.user_uid = user_data['uid']
            
            # --- SIMULATION (Remove for production) ---
            if auth_header == "Bearer VALID_ADMIN_TOKEN":
                request.user_uid = "admin_user_uid" # Simulated admin
                request.is_admin = True
            elif auth_header == "Bearer VALID_USER_TOKEN":
                 request.user_uid = "simulated_user_uid" # Simulated user
                 request.is_admin = False
            else:
                raise Exception("Invalid Token")
            # --- End Simulation ---

        except Exception as e:
            print(f"Auth Error: {e}")
            abort(401, description="Invalid or expired token")
            
        return f(*args, **kwargs)
    return decorated_function

# (Health Check, SSRV Webhook endpoints omitted for brevity)
@app.route('/api/v1/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy"}), 200

# Internal helper to fetch the hub data
def fetch_analysis_hub_data(ticker):
    # (Implementation Required: Fetch Fundamentals)
    
    # NEW: Automated Technical Analysis
    technicals = AF.analyze_technicals(ticker)
    
    # NEW: Institutional Ownership
    ownership = AF.analyze_ownership(ticker)
    
    return {
        "ticker": ticker,
        "redFlags": AF.analyze_red_flags(ticker),
        "insiderActivity": AF.analyze_insider_activity(ticker),
        "liquidity": AF.analyze_liquidity(ticker),
        "sentiment": {"score": 0.1, "sentiment": "Neutral", "articleCount": 5}, # Placeholder
        "fundamentalsChart": [], # Placeholder
        "technicals": technicals,
        "ownership": ownership
    }

@app.route('/api/v1/analysis/hub/<ticker>', methods=['GET'])
@require_auth 
def get_analysis_hub(ticker):
    data = fetch_analysis_hub_data(ticker.upper())
    return jsonify(data)

# --- Feature: Sector Heatmap Endpoint ---
@app.route('/api/v1/market/heatmap', methods=['GET'])
@require_auth
def get_sector_heatmap():
    with get_db_session() as db:
        performance_data = db.query(SectorPerformance).all()
    results = [{"sector": item.sector, "performance_pct": item.performance_pct} for item in performance_data]
    return jsonify(results)

# --- Feature: Price Alerts API ---
# (Implementation for GET, POST, DELETE /api/v1/alerts remains as detailed in previous iterations)


# --- Admin Curation API (Integrating Conviction Score) ---
@app.route('/api/v1/admin/publish', methods=['POST'])
@require_auth 
def publish_curated_pick():
    if not getattr(request, 'is_admin', False):
         abort(403, description="Admin privileges required")
         
    data = request.json
    ticker = data.get('ticker')
    
    analysis_hub_data = fetch_analysis_hub_data(ticker)
    
    analyst_inputs = {
        'thesis_strength': data.get('thesis_strength', 3) # 1-5 scale
    }
    
    conviction = AF.calculate_conviction_score(analysis_hub_data, analyst_inputs)
    
    data['conviction_score'] = conviction['score']
    data['conviction_classification'] = conviction['classification']

    # (Save to the production database and Trigger Push Notifications)
    # ...

    return jsonify({"status": "published", "conviction": conviction}), 201


# --- GAP 1 Fix: Register Device for Push Notifications ---
@app.route('/api/v1/user/register_device', methods=['POST'])
@require_auth
def register_device():
    data = request.json
    token = data.get('token')
    if not token:
        abort(400, description="Device token is required.")

    user_uid = request.user_uid

    with get_db_session() as db:
        try:
            # Check if this token already exists
            existing = db.query(DeviceToken).filter(DeviceToken.token == token).first()
            
            if existing:
                # If it exists, update its user_uid and timestamp
                existing.user_uid = user_uid
            else:
                # If new, create it
                new_token = DeviceToken(user_uid=user_uid, token=token)
                db.add(new_token)
            
            db.commit()
            return jsonify({"status": "success", "message": "Device registered."}), 201
        except Exception as e:
            db.rollback()
            print(f"Error registering device: {e}")
            abort(500, description="Could not register device.")


# --- GAP 2 Fix: Account Deletion ---
@app.route('/api/v1/user/account', methods=['DELETE'])
@require_auth
def delete_account():
    user_uid = request.user_uid
    
    with get_db_session() as db:
        try:
            user = db.query(User).filter(User.uid == user_uid).first()
            if not user:
                return jsonify({"status": "not_found", "message": "User not found."}), 404
            
            # Deleting the user will automatically delete their
            # PriceAlerts and DeviceTokens thanks to `ondelete="CASCADE"`
            db.delete(user)
            db.commit()
            
            # --- CRITICAL ---
            # You MUST also make API calls here to delete the user
            # from your Auth Provider (Firebase/Auth0) and
            # your subscription provider (RevenueCat).
            # Example:
            # auth.delete_user(user_uid)
            # revenuecat.delete_user(user_uid)
            
            print(f"User {user_uid} deleted from local DB. Provider deletion needed.")
            
            return jsonify({"status": "success", "message": "Account deletion initiated."}), 200
        except Exception as e:
            db.rollback()
            print(f"Error deleting account: {e}")
            abort(500, description="Could not process account deletion.")


# --- GAP 3 Fix: Admin Portal Candidates Route ---
@app.route('/api/v1/admin/candidates', methods=['GET'])
@require_auth
def get_admin_candidates():
    if not getattr(request, 'is_admin', False):
         abort(403, description="Admin privileges required")
         
    try:
        analyzer = MicroCapAnalyzer()
        # This function fetches data, filters, and ranks
        candidates_df = analyzer.run_analysis()
        
        # Add live price from data provider
        tickers = candidates_df['Ticker'].tolist()
        if tickers:
            prices = DP.get_latest_trades_bulk(tickers)
            candidates_df['Price'] = candidates_df['Ticker'].map(prices)
        
        # Convert DataFrame to JSON format expected by the admin portal
        # 'records' format: [{"Ticker": "ACME", "MarketCap": 120.5, ...}]
        candidates_json = candidates_df.to_dict(orient='records')
        
        return jsonify(candidates_json)
    except Exception as e:
        print(f"Error in /admin/candidates: {e}")
        abort(500, description=f"Analysis engine failed: {e}")


if __name__ == '__main__':
    # Development only.
    app.run(debug=True, host='0.0.0.0', port=5001)
