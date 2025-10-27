import SwiftUI

struct IdeaDetailView: View {
    let idea: StockIdea
    // Observe the global WatchlistViewModel injected via EnvironmentObject
    @EnvironmentObject private var watchlistVM: WatchlistViewModel

    var body: some View {
        List {
            // Section 1: Overview & Pricing
            Section(header: Text("Overview")) {
                 MetricRow(title: "Company", value: idea.companyName)
                 MetricRow(title: "Risk Profile", value: idea.riskLevel.rawValue, valueColor: idea.riskLevel.displayColor)
                 if let entry = idea.entryPrice {
                    MetricRow(title: "Entry Price (Approx)", value: String(format: "$%.2f", entry))
                 }
                 if let target = idea.targetPrice {
                     MetricRow(title: "Target Price", value: String(format: "$%.2f", target), valueColor: .green)
                 }
            }
            
            // Section 2: Investment Thesis (The Core Product)
            Section(header: Text("Investment Thesis")) {
                Text(idea.thesis).padding(.vertical, 5).lineSpacing(4)
            }
            
            // Section 3: Enhanced Due Diligence Signals
            Section(header: Text("Key Signals (Due Diligence)")) {
                if let insider = idea.signalInsider, !insider.isEmpty {
                    MetricRow(title: "Insider Activity", value: insider)
                }
                if let shortInterest = idea.signalShortInterest {
                    MetricRow(title: "Short Interest", value: String(format: "%.1f%%", shortInterest))
                }
                if let liquidity = idea.signalLiquidity {
                    MetricRow(title: "Liquidity (ADV)", value: "\(liquidity) shares")
                }
                // Handle case where no signals are provided
                if (idea.signalInsider?.isEmpty ?? true) && idea.signalShortInterest == nil && idea.signalLiquidity == nil {
                    Text("No specific signals available.").foregroundColor(.secondary)
                }
            }

            // Section 4: Disclaimer (Mandatory Compliance)
            Section(header: Text("Legal Disclaimer")) {
                Text("This is NOT investment advice. Micro-cap stocks carry extreme risk, including the total loss of principal. Consult a licensed professional before investing.")
                    .font(.footnote).foregroundColor(.secondary)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(idea.ticker)
        .toolbar {
            // Watchlist Button in Toolbar
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Toggle the watchlist status via the ViewModel
                    Task { await watchlistVM.toggleWatchlist(ticker: idea.ticker) }
                }) {
                    // Dynamic icon based on watchlist status
                    Image(systemName: watchlistVM.isWatching(idea.ticker) ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                }
            }
        }
    }
}

// Helper View for Metrics
struct MetricRow: View {
    let title: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Text(title).foregroundColor(.secondary)
            Spacer()
            Text(value).fontWeight(.semibold).foregroundColor(valueColor)
        }
    }
}
