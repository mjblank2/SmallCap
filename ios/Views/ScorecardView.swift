import SwiftUI

struct ScorecardView: View {
    @StateObject private var viewModel = ScorecardViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                // Dashboard Header (KPIs)
                Section(header: Text("Overall Performance")) {
                    HStack {
                        MetricView(title: "Avg. Return", value: String(format: "%.2f%%", viewModel.averageReturn), color: viewModel.averageReturn >= 0 ? .green : .red)
                        Spacer()
                        MetricView(title: "Win Rate", value: String(format: "%.0f%%", viewModel.winRate * 100))
                    }
                }
                
                // Historical Picks List
                Section(header: Text("Track Record")) {
                    if viewModel.isLoading && viewModel.history.isEmpty {
                        ProgressView()
                    } else if viewModel.history.isEmpty {
                        Text("No performance history available yet.").foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.history) { record in
                            PerformanceRow(record: record)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Scorecard")
            .task {
                await viewModel.loadHistory()
            }
            .refreshable {
                 await viewModel.loadHistory()
            }
        }
    }
}

// Helper Views for Scorecard
struct MetricView: View {
    let title: String
    let value: String
    var color: Color = .primary
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline).foregroundColor(.secondary)
            Text(value).font(.title2).fontWeight(.bold).foregroundColor(color)
        }
    }
}

struct PerformanceRow: View {
    let record: PerformanceRecord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(record.ticker).font(.headline)
                Text(record.status).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            if let pct = record.returnPct {
                Text(String(format: "%.2f%%", pct))
                    .fontWeight(.semibold)
                    .foregroundColor(pct >= 0 ? .green : .red)
            }
        }
    }
}
