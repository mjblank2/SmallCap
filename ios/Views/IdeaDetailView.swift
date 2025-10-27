import SwiftUI
import Charts // Import Swift Charts

struct IdeaDetailView: View {
    let idea: StockIdea
    @EnvironmentObject private var watchlistVM: WatchlistViewModel

    var body: some View {
        List {
            // NEW: Charting Section
            Section(header: Text("Historical Performance (Simulated)")) {
                // In production: Fetch historical price data from your API
                let historicalData = fetchSimulatedChartData() 
                
                Chart(historicalData) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Price", point.price)
                    )
                    .foregroundStyle(Color.accentColor)
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(format: .currency(code: "USD"))
                }
            }

            // ... (Existing Sections: Overview, Thesis, Signals, Disclaimer) ...
            
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(idea.ticker)
        // ... (Toolbar code) ...
        .onAppear {
            // Track user engagement
            Analytics.track(.ideaViewed, properties: ["ticker": idea.ticker])
        }
    }
}

// Helper structures for charting (Move these to a separate file if reused)
struct PricePoint: Identifiable {
    let id = UUID()
    let date: Date
    let price: Double
}

func fetchSimulatedChartData() -> [PricePoint] {
    // Simulated data generation
    var data: [PricePoint] = []
    for i in 0..<30 {
        let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
        let price = 10.0 + Double(i) * 0.2 + Double.random(in: -1...1)
        data.append(PricePoint(date: date, price: price))
    }
    return data.reversed()
}
