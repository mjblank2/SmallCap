import requests
import pandas as pd
from config import Config
from datetime import datetime, timedelta

class DataProviders:
    """Centralized service for interacting with Polygon and Tiingo."""
    
    def __init__(self):
        self.polygon_key = Config.POLYGON_API_KEY
        self.tiingo_key = Config.TIINGO_API_KEY
        self.tiingo_headers = {'Authorization': f'Token {self.tiingo_key}', 'Content-Type': 'application/json'}

    # --- Polygon: Market Data, OHLCV, News ---
    
    def get_daily_ohlcv(self, ticker, days_back=200):
        """Fetches daily OHLCV for technical analysis (TA-Lib)."""
        if not self.polygon_key: return pd.DataFrame()
        
        to_date = datetime.now()
        from_date = to_date - timedelta(days=days_back + 100) 

        url = f"https://api.polygon.io/v2/aggs/ticker/{ticker}/range/1/day/{from_date.strftime('%Y-%m-%d')}/{to_date.strftime('%Y-%m-%d')}?adjusted=true&sort=asc&limit=500&apiKey={self.polygon_key}"
        
        try:
            response = requests.get(url)
            response.raise_for_status()
            results = response.json().get('results', [])
            if not results: return pd.DataFrame()

            df = pd.DataFrame(results)
            df = df.rename(columns={'c': 'Close', 'o': 'Open', 'h': 'High', 'l': 'Low', 'v': 'Volume', 't': 'Timestamp'})
            df['Date'] = pd.to_datetime(df['Timestamp'], unit='ms')
            df = df.set_index('Date')
            return df[['Open', 'High', 'Low', 'Close', 'Volume']]

        except requests.exceptions.RequestException:
            return pd.DataFrame()

    def get_latest_trades_bulk(self, tickers):
        """Fetches the latest trade price for a list of tickers (Polygon Snapshots)."""
        if not self.polygon_key or not tickers: return {}
        
        url = f"https://api.polygon.io/v2/snapshot/locale/us/markets/stocks/tickers?tickers={','.join(tickers)}&apiKey={self.polygon_key}"
        try:
            response = requests.get(url)
            response.raise_for_status()
            data = response.json().get('tickers', [])
            
            price_map = {}
            for item in data:
                if 'lastTrade' in item and item['lastTrade'] and 'p' in item['lastTrade']:
                     price_map[item['ticker']] = item['lastTrade']['p']
            return price_map

        except requests.exceptions.RequestException:
            return {}
            
    # (get_latest_quote_nbbo, get_news_feed implementations remain)

    # --- Tiingo: Fundamentals, Insider Trading, 13F ---
            
    # (get_fundamentals, get_insider_transactions implementations remain)
        
    def get_institutional_ownership(self, ticker):
        """Fetches the latest institutional holders (13F Filings)."""
        if not self.tiingo_key: return []
        
        url = f"https://api.tiingo.com/tiingo/fundamentals/{ticker}/ownership"
        try:
            response = requests.get(url, headers=self.tiingo_headers)
            response.raise_for_status()
            return response.json().get('ownership', [])
        except requests.exceptions.RequestException:
            return []

DP = DataProviders()
