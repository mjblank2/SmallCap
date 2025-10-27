import SwiftUI

struct IdeaDetailView: View {
    let idea: StockIdea
    let primaryColor: Color
    let accentColor: Color

    var body: some View {
        List {
            // Section 1: Overview & Pricing
            Section(header: Text("Overview")) {
                MetricRow(title: "Company", value: idea.companyName)
                MetricRow(title: "Risk Profile", value: idea.riskLevel.rawValue, valueColor: idea.riskLevel.displayColor)
                MetricRow(title: "Entry Price (Approx)", value: String(format: "$%.2f", idea.entryPrice))
                MetricRow(title: "Target Price", value: String(format: "$%.2f", idea.targetPrice), valueColor: accentColor)
                if let upside = idea.potentialUpside {
                    MetricRow(title: "Potential Upside", value: String(format: "%.0f%%", upside * 100), valueColor: accentColor)
                }
            }

            // Section 2: The Investment Thesis (The Product)
            Section(header: Text("Investment Thesis").font(.title3).fontWeight(.bold).foregroundColor(primaryColor).padding(.top, 10)) {
                Text(idea.investmentThesis)
                    .padding(.vertical, 5)
                    .lineSpacing(4)
            }

            // Section 3: The Due Diligence Hub
            Section(header: Text("Due Diligence Hub")) {
                if let url = idea.secEdgarURL {
                    Link(destination: url) {
                        Label("View SEC Filings (10-K/10-Q/8-K)", systemImage: "doc.text.magnifyingglass")
                    }
                }
                // Link to external charting tools
                if let ticker = idea.ticker.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                   let chartURL = URL(string: "https://finance.yahoo.com/quote/\(ticker)") {
                    Link(destination: chartURL) {
                        Label("View Detailed Chart & News", systemImage: "chart.line.uptrend.xyaxis")
                    }
                }
            }
            
            // Section 4: Disclaimer (CRITICAL FOR COMPLIANCE)
            Section(header: Text("Legal Disclaimer")) {
                Text("This information is for educational purposes only and is NOT investment advice. Micro-cap stocks carry extreme risk, including the total loss of principal. Consult a licensed professional before investing.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(idea.ticker)
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
