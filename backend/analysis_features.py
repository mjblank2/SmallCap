# backend/analysis_features.py
from data_providers import DP
import pandas as pd
try:
    import talib
except ImportError:
    print("WARNING: TA-Lib not installed. Technical analysis disabled.")
    talib = None

class AnalysisFeatures:
    
    # (Helper functions: _get_severity, _get_value remain)
    # (Red Flag Engine functions: analyze_red_flags and sub-functions remain)
    # (Insider Activity and Liquidity functions remain)

    # --- Feature: Automated Technical Analysis (TA-Lib Integration) ---
    def analyze_technicals(self, ticker):
        if talib is None:
            return {"error": "Technical Analysis engine offline."}

        df = DP.get_daily_ohlcv(ticker, days_back=200)
        if df.empty or len(df) < 50:
            return {"error": "Insufficient historical data."}

        # Calculate Indicators
        sma_50 = talib.SMA(df['Close'], timeperiod=50)
        sma_200 = talib.SMA(df['Close'], timeperiod=200)
        rsi = talib.RSI(df['Close'], timeperiod=14)

        # Analyze Signals
        signals = []
        current_price = df['Close'].iloc[-1]
        current_rsi = rsi.iloc[-1]
        
        # Pattern Recognition: Golden Cross / Death Cross
        if len(df) >= 200:
            if sma_50.iloc[-1] > sma_200.iloc[-1] and sma_50.iloc[-2] <= sma_200.iloc[-2]:
                signals.append({"signal": "Golden Cross", "sentiment": "Bullish", "description": "Strong bullish signal: 50-day SMA crossed above 200-day SMA."})
            elif sma_50.iloc[-1] < sma_200.iloc[-1] and sma_50.iloc[-2] >= sma_200.iloc[-2]:
                signals.append({"signal": "Death Cross", "sentiment": "Bearish", "description": "Strong bearish signal: 50-day SMA crossed below 200-day SMA."})

        # Momentum Signals (RSI)
        # ... (Implementation remains)

        # Trend Strength (Implementation remains)
        # ... (Logic to determine trend)

        return {
            "trend": trend,
            "indicators": {
                "RSI_14": current_rsi,
                "SMA_50": sma_50.iloc[-1],
                "SMA_200": sma_200.iloc[-1] if len(df) >= 200 else None,
            },
            "signals": signals
        }

    # --- Feature: Institutional Ownership Analysis (Tiingo 13F) ---
    def analyze_ownership(self, ticker):
        data = DP.get_institutional_ownership(ticker)
        if not data:
            return {"top_holders": [], "concentration": 0}

        data.sort(key=lambda x: x.get('marketValue', 0), reverse=True)
        
        top_holders = []
        total_value = sum(item.get('marketValue', 0) for item in data)
        
        for holder in data[:10]: # Top 10 holders
            name = holder.get('entityName')
            value = holder.get('marketValue', 0)
            change = holder.get('changeInShares', 0)
            
            if name and value > 0:
                top_holders.append({
                    "name": name,
                    "value_held": value,
                    "change_in_shares": change
                })

        top_10_value = sum(h['value_held'] for h in top_holders)
        concentration = (top_10_value / total_value) * 100 if total_value > 0 else 0

        return {
            "top_holders": top_holders,
            "concentration": concentration
        }

    # --- Feature: Conviction Score Methodology ---
    def calculate_conviction_score(self, analysis_hub, analyst_input):
        """Synthesizes analysis into a proprietary score (0-10)."""
        score = 5.0 # Start neutral

        # 1. Quantitative Factors
        # Red Flags (Impact: -3 to 0)
        risk_score = analysis_hub.get('red_flags', {}).get('composite_risk_score')
        if risk_score is not None:
            if risk_score > 75: score -= 3.0
            elif risk_score > 50: score -= 1.5
        
        # Insider Activity (Impact: -1.5 to +2.5)
        insider_sentiment = analysis_hub.get('insider_activity', {}).get('sentiment')
        if insider_sentiment == 'Bullish': score += 2.5
        elif insider_sentiment == 'Bearish': score -= 1.5

        # Technical Trend (Impact: -2 to +2)
        trend = analysis_hub.get('technicals', {}).get('trend')
        if trend == 'Strong Uptrend': score += 2.0
        elif trend == 'Strong Downtrend': score -= 2.0
        
        # 2. Qualitative Factors (Analyst Input from Curation Portal)
        # Thesis Strength (Impact: -2 to +3)
        thesis_strength = analyst_input.get('thesis_strength', 3) # 1-5 scale
        if thesis_strength == 5: score += 3.0
        elif thesis_strength == 4: score += 1.5
        elif thesis_strength <= 2: score -= 2.0
        
        # 3. Finalization
        final_score = max(0.0, min(10.0, score))
        
        if final_score >= 8.5: classification = "High Conviction"
        elif final_score >= 7.0: classification = "Strong Opportunity"
        elif final_score >= 5.0: classification = "Monitor"
        else: classification = "Low Conviction"

        return {"score": round(final_score, 1), "classification": classification}

AF = AnalysisFeatures()
