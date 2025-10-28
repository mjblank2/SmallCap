import SwiftUI

// Feature 1: Red Flag Engine View
struct RedFlagEngineView: View {
    let analysis: RiskAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let error = analysis.error {
                Text("Analysis Status: \(error)").foregroundColor(.orange).font(StyleGuide.Typography.body)
            }
            
            // Composite Score Visualization (Gauge)
            if let score = analysis.compositeRiskScore {
                Gauge(value: score, in: 0...100) {
                    Text("Overall Risk Score").font(StyleGuide.Typography.headline)
                } currentValueLabel: {
                    Text("\(Int(score))")
                }
                .gaugeStyle(.accessoryLinearCapacity)
                // Gradient from Green (low risk) to Red (high risk)
                .tint(Gradient(colors: [Color.brandPositive, .yellow, .orange, .red]))
            }
            
            // Detailed Breakdown
            if let details = analysis.details, !details.isEmpty {
                ForEach(details) { detail in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(detail.metric).font(StyleGuide.Typography.headline)
                            Spacer()
                            Text("Severity: \(detail.severity.rawValue)")
                                .font(StyleGuide.Typography.caption)
                                .fontWeight(.bold)
                                .foregroundColor(detail.severity.color)
                        }
                        Text(detail.insight)
                            .font(StyleGuide.Typography.body)
                            .foregroundColor(.textSecondary)
                            .fixedSize(horizontal: false, vertical: true) // Ensure text wraps
                    }
                    // Add divider between details
                    if detail.id != analysis.details?.last?.id {
                        Divider().background(Color.gray.opacity(0.5))
                    }
                }
            } else if analysis.error == nil {
                Text("No significant red flags detected.")
                    .font(StyleGuide.Typography.body)
                    .foregroundColor(.textSecondary)
            }
        }
    }
}
