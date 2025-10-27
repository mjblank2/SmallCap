import SwiftUI
import Charts

struct IdeaDetailView: View {
    let idea: StockIdea
    @EnvironmentObject private var watchlistVM: WatchlistViewModel
    @EnvironmentObject private var realTimeService: RealTimeService

    // Initialize the new AnalysisViewModel
    @StateObject private var analysisVM: AnalysisViewModel
    @State private var livePrice: Double?
    
    // Initializer to inject the ticker into the ViewModel
    init(idea: StockIdea) {
        self.idea = idea
        _analysisVM = StateObject(wrappedValue: AnalysisViewModel(ticker: idea.ticker))
    }

    var body: some View {
        ZStack {
            Color.backgroundMain.edgesIgnoringSafeArea(.all)
            
            List {
                // 1. Overview & Live Price
                Section(header: SectionHeaderView(title: "Overview")) {
                     MetricRow(title: "Company", value: idea.companyName)
                     
                     // Real-Time Pricing
                     if let currentPrice = livePrice {
                        MetricRow(title: "Live Price (Bid)", value: String(format: "$%.2f", currentPrice), valueColor: .brandAccent)
                     } else if let entry = idea.entryPrice {
                         MetricRow(title: "Entry Price (Approx)", value: String(format: "$%.2f", entry))
                     }
                }
                .listRowBackground(Color.backgroundCard)

                // 2. Investment Thesis (The Core Product)
                Section(header: SectionHeaderView(title: "Investment Thesis")) {
                    Text(idea.thesis).padding(.vertical, 5).lineSpacing(4).foregroundColor(.textPrimary)
                }
                .listRowBackground(Color.backgroundCard)
                
                // --- Analysis Hub Integration ---
                if analysisVM.isLoading {
                    Section {
                        ProgressView("Loading Advanced Analysis...").tint(.brandAccent).frame(maxWidth: .infinity, alignment: .center)
                    }
                    .listRowBackground(Color.backgroundCard)
                } else if let hub = analysisVM.analysisHub {
                    
                    // 3. Real-Time Metrics (Liquidity and Sentiment)
                    Section(header: SectionHeaderView(title: "Real-Time Metrics")) {
                        LiquidityScoreView(liquidity: hub.liquidity)
                        NewsSentimentView(sentiment: hub.sentiment)
                    }
                    .listRowBackground(Color.backgroundCard)

                    // 4. Red Flag Engine
                    Section(header: SectionHeaderView(title: "Red Flag Engine (AI Analysis)")) {
                        RedFlagEngineView(analysis: hub.redFlags)
                    }
                    .listRowBackground(Color.backgroundCard)
                    
                    // 5. Insider Activity
                    Section(header: SectionHeaderView(title: "Insider Activity (Smart Money)")) {
                        InsiderActivityView(activity: hub.insiderActivity)
                    }
                    .listRowBackground(Color.backgroundCard)
                    
                    // 6. Interactive Fundamentals
                    Section(header: SectionHeaderView(title: "Financial Health (Quarterly)")) {
                        FundamentalVisualizationView(dataPoints: hub.fundamentalsChart)
                    }
                    .listRowBackground(Color.backgroundCard)
                    
                } else if let error = analysisVM.errorMessage {
                    Section(header: SectionHeaderView(title: "Analysis Error")) {
                        Text(error).foregroundColor(.red)
                    }
                    .listRowBackground(Color.backgroundCard)
                }

                // 7. Compliance Disclaimer
                // ... (Disclaimer Section) ...
            }
            .listStyle(InsetGroupedListStyle())
            .scrollContentBackground(.hidden)
            .navigationTitle(idea.ticker)
            // ... (Toolbar/Watchlist button) ...
        }
        .task {
            // Load the detailed analysis when the view appears
            await analysisVM.loadAnalysis()
        }
        .onAppear {
             // Initialize price and subscribe if connected
            self.livePrice = realTimeService.livePrices[idea.ticker]
            if realTimeService.connectionStatus == .connected {
                 realTimeService.subscribe(to: [idea.ticker])
            }
        }
        // Listen for real-time updates
        .onReceive(realTimeService.$livePrices) { prices in
            if let newPrice = prices[idea.ticker] {
                withAnimation(.easeInOut) { self.livePrice = newPrice }
            }
        }
        // Subscribe when connection is established
        .onReceive(realTimeService.$connectionStatus) { status in
            if status == .connected {
                realTimeService.subscribe(to: [idea.ticker])
            }
        }
    }
}
