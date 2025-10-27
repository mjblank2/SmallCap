import pandas as pd
import numpy as np

class MicroCapAnalyzer:
    def __init__(self):
        # Configuration Parameters
        self.MIN_MARKET_CAP = 50 # $50M
        self.MIN_LIQUIDITY = 100000 # $100k daily volume
        self.MIN_ROIC = 0.10 # 10% Return on Invested Capital

    def fetch_and_preprocess(self):
        """
        CRITICAL STEP: Integrate your licensed financial data provider (e.g., Polygon.io, FMP) here.
        This must pull fundamentals and pricing data from your database or API.
        """
        print("Fetching data (Simulation Placeholder)...")
        
        # SIMULATION: Replace this structure with your actual data source.
        np.random.seed(42)
        N_STOCKS = 2000
        data = {
            'Ticker': [f'TICK{i}' for i in range(N_STOCKS)],
            'MarketCap': np.random.uniform(20, 3000, N_STOCKS),
            'Volume': np.random.randint(10000, 1000000, N_STOCKS),
            'PE_Ratio': np.random.uniform(1, 60, N_STOCKS),
            'ROIC': np.random.uniform(-0.1, 0.4, N_STOCKS),
            'InsiderOwnership': np.random.uniform(0.01, 0.9, N_STOCKS),
        }
        df = pd.DataFrame(data)
        
        # Data Cleaning
        df = df.replace([np.inf, -np.inf], np.nan).dropna()
        return df

    def apply_strict_filters(self, df):
        """Filters the universe based on non-negotiable criteria."""
        df = df[(df['MarketCap'] >= self.MIN_MARKET_CAP) & (df['Volume'] >= self.MIN_LIQUIDITY)]
        df = df[df['ROIC'] >= self.MIN_ROIC]
        df = df[df['PE_Ratio'] > 0] # Focus on profitable companies
        return df.copy()

    def multi_factor_ranking(self, df):
        """Ranks the filtered stocks using a normalized, multi-factor model."""
        if df.empty:
            return df

        # Normalize using Percentile Ranking (Robust against outliers)
        df['Rank_Value'] = df['PE_Ratio'].rank(pct=True, ascending=True)
        df['Rank_Quality'] = df['ROIC'].rank(pct=True, ascending=False)
        df['Rank_Alignment'] = df['InsiderOwnership'].rank(pct=True, ascending=False)

        # Composite Score (Weighted: e.g., 40% Q, 40% V, 20% A)
        df['CompositeScore'] = (
            (df['Rank_Quality'] * 0.40) + (df['Rank_Value'] * 0.40) + (df['Rank_Alignment'] * 0.20)
        )
        return df.sort_values(by='CompositeScore', ascending=False)

    def run_analysis(self):
        """Executes the full pipeline."""
        df = self.fetch_and_preprocess()
        filtered_df = self.apply_strict_filters(df)
        ranked_df = self.multi_factor_ranking(filtered_df)
        
        # The Curation Queue: Top candidates for human review in the Admin Portal
        candidates = ranked_df.head(10)
        # In production: The Flask endpoint calls this and returns the candidates.
        return candidates
