# backend/app.py
from flask import Flask, jsonify, request, abort
from analysis_features import AF
from models import get_db_session, SectorPerformance, PriceAlert
from config import Config

# (Authentication Middleware structure omitted for brevity)

app = Flask(__name__)
app.config.from_object(Config)
@app.route('/api/v1/health', methods=['GET'])
def health_check():
    """
    Health check endpoint for Render to confirm the service is live.
    """
    return jsonify({"status": "healthy"}), 200
# (Health Check, SSRV Webhook endpoints omitted for brevity)

# Internal helper to fetch the hub data
def fetch_analysis_hub_data(ticker):
    # (Implementation Required: Fetch Fundamentals, Red Flags, Insider, Liquidity, Sentiment)
    
    # NEW: Automated Technical Analysis
    technicals = AF.analyze_technicals(ticker)
    
    # NEW: Institutional Ownership
    ownership = AF.analyze_ownership(ticker)
    
    return {
        "ticker": ticker,
        # ... (Existing fields)
        "technicals": technicals,
        "ownership": ownership
    }

@app.route('/api/v1/analysis/hub/<ticker>', methods=['GET'])
# @require_subscription 
def get_analysis_hub(ticker):
    data = fetch_analysis_hub_data(ticker.upper())
    return jsonify(data)

# --- Feature: Sector Heatmap Endpoint ---
@app.route('/api/v1/market/heatmap', methods=['GET'])
# @require_subscription
def get_sector_heatmap():
    db = get_db_session()
    # Fetch data populated by the Celery task
    performance_data = db.query(SectorPerformance).all()
    results = [{"sector": item.sector, "performance_pct": item.performance_pct} for item in performance_data]
    return jsonify(results)

# --- Feature: Price Alerts API ---
# (Implementation for GET, POST, DELETE /api/v1/alerts remains as detailed in previous iterations)

# --- Admin Curation API (Integrating Conviction Score) ---

@app.route('/api/v1/admin/publish', methods=['POST'])
# @require_admin 
def publish_curated_pick():
    data = request.json
    ticker = data.get('ticker')
    
    # 1. Fetch the full analysis hub data
    analysis_hub_data = fetch_analysis_hub_data(ticker)
    
    # 2. Extract analyst inputs (e.g., thesis strength from Admin Portal)
    analyst_inputs = {
        'thesis_strength': data.get('thesis_strength', 3) # 1-5 scale
    }
    
    # 3. Calculate the Conviction Score
    conviction = AF.calculate_conviction_score(analysis_hub_data, analyst_inputs)
    
    # 4. Add the score to the payload before saving
    data['conviction_score'] = conviction['score']
    data['conviction_classification'] = conviction['classification']

    # Save to the production database and Trigger Push Notifications
    # ...

    return jsonify({"status": "published", "conviction": conviction}), 201

if __name__ == '__main__':
    # Development only.
    app.run(debug=True, host='0.0.0.0', port=5001)
