import SwiftUI
import UIKit

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    static let accentTeal = Color(red: 0.0, green: 0.8, blue: 0.8)
    static let accentPurple = Color(red: 0.6, green: 0.3, blue: 0.9)
    
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    static let cardBackground = Color(.systemBackground)
    static let cardShadow = Color.black.opacity(0.05)
    
    static let conditionNew = Color.green
    static let conditionUsed = Color.orange
    static let conditionRare = Color.purple
    
    static let priorityHigh = Color.red
    static let priorityMedium = Color.orange
    static let priorityLow = Color.green
    
    
    static let primaryGradient = LinearGradient(
        colors: [accentTeal, accentPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        colors: [cardBackground, cardBackground.opacity(0.95)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    
    static let cardCornerRadius: CGFloat = 16
    static let cardShadowRadius: CGFloat = 8
    static let cardShadowOffset = CGSize(width: 0, height: 4)
    
    
    static let springAnimation = Animation.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)
    static let smoothAnimation = Animation.easeInOut(duration: 0.3)
    static let quickAnimation = Animation.easeInOut(duration: 0.2)
    
    
    static let titleFont = Font.system(size: 28, weight: .bold, design: .default)
    static let headlineFont = Font.system(size: 20, weight: .semibold, design: .default)
    static let bodyFont = Font.system(size: 16, weight: .regular, design: .default)
    static let captionFont = Font.system(size: 14, weight: .medium, design: .default)
    static let smallFont = Font.system(size: 12, weight: .regular, design: .default)
}


struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(ThemeManager.cardGradient)
            .cornerRadius(ThemeManager.cardCornerRadius)
            .shadow(
                color: ThemeManager.cardShadow,
                radius: ThemeManager.cardShadowRadius,
                x: ThemeManager.cardShadowOffset.width,
                y: ThemeManager.cardShadowOffset.height
            )
    }
}

struct GradientBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            ThemeManager.primaryGradient
                .opacity(0.1)
                .ignoresSafeArea()
            content
        }
    }
}

struct AnimatedCard: ViewModifier {
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.9)
            .onAppear {
                withAnimation(ThemeManager.springAnimation) {
                    isVisible = true
                }
            }
    }
}

struct HoverEffect: ViewModifier {
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(ThemeManager.smoothAnimation, value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

struct ListStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                UITableView.appearance().separatorStyle = .none
                UITableView.appearance().backgroundColor = .clear
            }
    }
}


extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func gradientBackground() -> some View {
        modifier(GradientBackground())
    }
    
    func animatedCard() -> some View {
        modifier(AnimatedCard())
    }
    
    func hoverEffect() -> some View {
        modifier(HoverEffect())
    }
    
    func hideListSeparatorsAndBackground() -> some View {
        modifier(ListStyleModifier())
    }
}


struct GradientButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(ThemeManager.primaryGradient)
            .cornerRadius(12)
        }
        .hoverEffect()
    }
}

struct GradientFloatingButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(ThemeManager.primaryGradient)
                .clipShape(Circle())
                .shadow(
                    color: ThemeManager.cardShadow,
                    radius: ThemeManager.cardShadowRadius,
                    x: ThemeManager.cardShadowOffset.width,
                    y: ThemeManager.cardShadowOffset.height
                )
        }
        .hoverEffect()
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(ThemeManager.secondaryText)
            
            Text(title)
                .font(ThemeManager.headlineFont)
                .foregroundColor(ThemeManager.primaryText)
            
            Text(message)
                .font(ThemeManager.bodyFont)
                .foregroundColor(ThemeManager.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding()
        .animatedCard()
    }
}
