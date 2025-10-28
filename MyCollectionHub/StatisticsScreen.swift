import SwiftUI

struct StatisticsScreen: View {
    @EnvironmentObject var dataManager: AppDataManager
    @State private var animateCharts = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    StatsCardsView(items: dataManager.getCollectionItems())
                        .animatedCard()
                    
                    ConditionChartView(items: dataManager.getCollectionItems(), animate: animateCharts)
                        .animatedCard()
                    
                    GrowthChartView(items: dataManager.getCollectionItems(), animate: animateCharts)
                        .animatedCard()
                }
                .padding()
            }
            .gradientBackground()
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                withAnimation(ThemeManager.springAnimation.delay(0.2)) {
                    animateCharts = true
                }
            }
        }
    }
}

struct StatsCardsView: View {
    let items: [Item]
    
    var totalItems: Int {
        items.count
    }
    
    var uniqueCategories: Int {
        Set(items.map { $0.category }).count
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(
                    title: "Items",
                    value: "\(totalItems)",
                    icon: "square.grid.2x2",
                    color: .blue
                )
                
                StatCard(
                    title: "Categories",
                    value: "\(uniqueCategories)",
                    icon: "folder",
                    color: .purple
                )
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(color)
            
            Text(value)
                .font(ThemeManager.titleFont)
                .fontWeight(.bold)
                .foregroundColor(ThemeManager.primaryText)
            
            Text(title)
                .font(ThemeManager.captionFont)
                .foregroundColor(ThemeManager.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .cardStyle()
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(ThemeManager.smoothAnimation, value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct ConditionChartView: View {
    let items: [Item]
    let animate: Bool
    
    var conditionData: [ConditionData] {
        let grouped = Dictionary(grouping: items, by: { $0.condition })
        return ItemCondition.allCases.map { condition in
            ConditionData(
                condition: condition,
                count: grouped[condition]?.count ?? 0
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("By Condition")
                .font(ThemeManager.headlineFont)
                .fontWeight(.semibold)
                .foregroundColor(ThemeManager.primaryText)
            
            if items.isEmpty {
                EmptyChartView(message: "No data to display")
            } else {
                ZStack {
                    ForEach(Array(conditionData.enumerated()), id: \.element.id) { index, data in
                        Circle()
                            .trim(from: getStartAngle(for: index), to: getEndAngle(for: index))
                            .stroke(data.condition.color, style: StrokeStyle(lineWidth: 30, lineCap: .round))
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                            .opacity(animate ? 1 : 0)
                            .scaleEffect(animate ? 1 : 0.8)
                            .animation(ThemeManager.springAnimation.delay(Double(index) * 0.1), value: animate)
                    }
                    
                    Text("\(items.count)")
                        .font(ThemeManager.titleFont)
                        .fontWeight(.bold)
                        .foregroundColor(ThemeManager.secondaryText)
                }
                .frame(height: 220)
                
                HStack(spacing: 24) {
                    ForEach(conditionData) { data in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(data.condition.color)
                                .frame(width: 14, height: 14)
                            
                            Text(data.condition.rawValue)
                                .font(ThemeManager.captionFont)
                                .foregroundColor(ThemeManager.secondaryText)
                            
                            Text("\(data.count)")
                                .font(ThemeManager.captionFont)
                                .fontWeight(.semibold)
                                .foregroundColor(ThemeManager.primaryText)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .cardStyle()
    }
    
    private func getStartAngle(for index: Int) -> Double {
        let total = conditionData.reduce(0) { $0 + $1.count }
        guard total > 0 else { return 0 }
        
        var startAngle: Double = 0
        for i in 0..<index {
            let percentage = Double(conditionData[i].count) / Double(total)
            startAngle += percentage
        }
        return startAngle
    }
    
    private func getEndAngle(for index: Int) -> Double {
        let total = conditionData.reduce(0) { $0 + $1.count }
        guard total > 0 else { return 0 }
        
        let percentage = Double(conditionData[index].count) / Double(total)
        return getStartAngle(for: index) + percentage
    }
}

struct GrowthChartView: View {
    let items: [Item]
    let animate: Bool
    
    var monthlyData: [MonthlyData] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: items) { item in
            calendar.dateInterval(of: .month, for: item.purchaseDate)?.start ?? item.purchaseDate
        }
        
        let sortedKeys = grouped.keys.sorted()
        var cumulativeCount = 0
        
        return sortedKeys.map { date in
            cumulativeCount += grouped[date]?.count ?? 0
            return MonthlyData(
                month: date,
                count: cumulativeCount
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Collection Growth")
                .font(ThemeManager.headlineFont)
                .fontWeight(.semibold)
                .foregroundColor(ThemeManager.primaryText)
            
            if items.isEmpty {
                EmptyChartView(message: "No data to display")
            } else {
                GeometryReader { geometry in
                    ZStack {
                        Path { path in
                            let width = geometry.size.width
                            let height = geometry.size.height
                            
                            for i in 0...4 {
                                let x = width * CGFloat(i) / 4
                                path.move(to: CGPoint(x: x, y: 0))
                                path.addLine(to: CGPoint(x: x, y: height))
                            }
                            
                            for i in 0...4 {
                                let y = height * CGFloat(i) / 4
                                path.move(to: CGPoint(x: 0, y: y))
                                path.addLine(to: CGPoint(x: width, y: y))
                            }
                        }
                        .stroke(ThemeManager.secondaryText.opacity(0.3), lineWidth: 0.5)
                        
                        if monthlyData.count > 1 {
                            Path { path in
                                let width = geometry.size.width
                                let height = geometry.size.height
                                let maxCount = monthlyData.map { $0.count }.max() ?? 1
                                
                                for (index, data) in monthlyData.enumerated() {
                                    let x = width * CGFloat(index) / CGFloat(monthlyData.count - 1)
                                    let y = height - (height * CGFloat(data.count) / CGFloat(maxCount))
                                    
                                    if index == 0 {
                                        path.move(to: CGPoint(x: x, y: y))
                                    } else {
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    }
                                }
                            }
                            .stroke(ThemeManager.accentTeal, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                            .opacity(animate ? 1 : 0)
                            .scaleEffect(animate ? 1 : 0.9)
                            .animation(ThemeManager.springAnimation.delay(0.3), value: animate)
                            
                            ForEach(Array(monthlyData.enumerated()), id: \.offset) { index, data in
                                let width = geometry.size.width
                                let height = geometry.size.height
                                let maxCount = monthlyData.map { $0.count }.max() ?? 1
                                
                                let x = width * CGFloat(index) / CGFloat(monthlyData.count - 1)
                                let y = height - (height * CGFloat(data.count) / CGFloat(maxCount))
                                
                                Circle()
                                    .fill(ThemeManager.accentTeal)
                                    .frame(width: 8, height: 8)
                                    .position(x: x, y: y)
                                    .opacity(animate ? 1 : 0)
                                    .scaleEffect(animate ? 1 : 0)
                                    .animation(ThemeManager.springAnimation.delay(0.5 + Double(index) * 0.1), value: animate)
                            }
                        }
                    }
                }
                .frame(height: 220)
                .opacity(animate ? 1 : 0)
                .scaleEffect(animate ? 1 : 0.9)
            }
        }
        .padding(20)
        .cardStyle()
    }
}

struct EmptyChartView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.pie")
                .font(.system(size: 50))
                .foregroundColor(ThemeManager.secondaryText)
            
            Text(message)
                .font(ThemeManager.bodyFont)
                .foregroundColor(ThemeManager.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(height: 220)
        .frame(maxWidth: .infinity)
    }
}

struct ConditionData: Identifiable {
    let id = UUID()
    let condition: ItemCondition
    let count: Int
}

struct MonthlyData: Identifiable {
    let id = UUID()
    let month: Date
    let count: Int
}

#Preview {
    StatisticsScreen()
}
