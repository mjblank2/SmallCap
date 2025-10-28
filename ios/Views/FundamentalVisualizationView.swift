import SwiftUI
import Charts

// Feature 5: Fundamental Visualization View
struct FundamentalVisualizationView: View {
    let dataPoints: [FinancialDataPoint]
    @State private var selectedMetric: MetricType = .revenue
    
    enum MetricType: String, CaseIterable {
        case revenue = "Revenue"
        case netIncome = "Net Income"
    }

    var body: some View {
        if !dataPoints.isEmpty {
            VStack {
                // Metric Selector
                Picker("Select Metric", selection: $selectedMetric) {
                    ForEach(MetricType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.bottom, 10)

                // Interactive Chart
                Chart(dataPoints) { point in
                    let value = selectedMetric == .revenue ? point.revenue : point.netIncome
                    let color = selectedMetric == .revenue ? Color.brandAccent : (value >= 0 ? Color.brandPositive : Color.red)
                    
                    // Visualize using BarMarks for quarterly data
                    BarMark(
                        x: .value("Quarter", point.date, unit: .quarter),
                        y: .value("Amount (USD)", value)
                    )
                    .foregroundStyle(color)
                    .cornerRadius(5)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .quarter, count: 1)) { value in
                        AxisGridLine()
                        AxisTick()
                        // Format X-axis for Quarter and Year
                        AxisValueLabel(format: .dateTime.quarter().year())
                    }
                }
                .chartYAxis {
                    // Format Y-axis for currency in compact notation (e.g., $1M)
                    AxisMarks(format: .currency(code: "USD").notation(.compactName))
                }
                // Smooth animation when switching metrics
                .animation(.easeInOut, value: selectedMetric)
            }
            .padding(.vertical, 10)
        } else {
            Text("Insufficient financial data for charting.").foregroundColor(.textSecondary).padding(.vertical, 10)
        }
    }
}

